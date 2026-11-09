import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String username;
  final DateTime createdAt;
  final String country;
  final String city;

  User({
    required this.id,
    required this.username,
    required this.createdAt,
    this.country = 'Sri Lanka',
    this.city = 'Nintavur',
  });
}

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _lastError;
  bool _initialized = false;
  
  // Rate limiting / brute-force protection
  int _failedLoginAttempts = 0;
  DateTime? _lockoutUntil;
  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(seconds: 30);

  // Application pepper for additional defense-in-depth
  static const String _pepper = 'SmartCity_App_Pepper_#9vK2!z8';

  String _activeCountry = 'United States';
  String _activeCity = 'New York';

  AuthService() {
    _loadUserFromPrefs();
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get lastError => _lastError;
  String get userCountry => _currentUser?.country ?? _activeCountry;
  String get userCity => _currentUser?.city ?? _activeCity;

  Future<void> loginAsGuest({
    required String country,
    required String city,
    String? username,
  }) async {
    _activeCountry = country;
    _activeCity = city;
    final prefs = await SharedPreferences.getInstance();
    final uid = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final uname = username?.trim().isNotEmpty == true ? username!.trim() : 'Guest Citizen';

    await prefs.setString('local_user_id', uid);
    await prefs.setString('local_username', uname);
    await prefs.setString('local_user_country', country);
    await prefs.setString('local_user_city', city);

    _currentUser = User(
      id: uid,
      username: uname,
      createdAt: DateTime.now(),
      country: country,
      city: city,
    );
    notifyListeners();
  }

  Future<void> updateRegion(String country, String city) async {
    _activeCountry = country;
    _activeCity = city;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_user_country', country);
    await prefs.setString('local_user_city', city);
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        username: _currentUser!.username,
        createdAt: _currentUser!.createdAt,
        country: country,
        city: city,
      );
    } else {
      _currentUser = User(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        username: 'Guest Citizen',
        createdAt: DateTime.now(),
        country: country,
        city: city,
      );
    }
    notifyListeners();
  }

  Future<void> _loadUserFromPrefs() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCountry = prefs.getString('local_user_country');
      final savedCity = prefs.getString('local_user_city');
      if (savedCountry != null && savedCountry.isNotEmpty) {
        _activeCountry = savedCountry;
      }
      if (savedCity != null && savedCity.isNotEmpty) {
        _activeCity = savedCity;
      }
      final savedId = prefs.getString('local_user_id');
      final savedName = prefs.getString('local_username');
      if (savedId != null && savedName != null) {
        _currentUser = User(
          id: savedId,
          username: savedName,
          createdAt: DateTime.now(),
          country: _activeCountry,
          city: _activeCity,
        );
        notifyListeners();
      }
    } catch (_) {}
    _initialized = true;
  }

  // Cryptographically secure salt generator
  String _generateSalt([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  // Key-stretched salted password hashing
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt:$password:$_pepper');
    Digest digest = sha256.convert(bytes);
    for (int i = 0; i < 2000; i++) {
      digest = sha256.convert(digest.bytes + bytes);
    }
    return digest.toString();
  }

  // Timing-safe constant-time string comparison
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  // Input validation
  String? _validateUsername(String username) {
    if (username.isEmpty) return 'Username is required.';
    if (username.length < 3) return 'Username must be at least 3 characters.';
    if (username.length > 50) return 'Username cannot exceed 50 characters.';
    final validFormat = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$|^[a-zA-Z0-9_.-]{3,30}$');
    if (!validFormat.hasMatch(username)) {
      return 'Username must be alphanumeric or a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.length < 8) return 'Password must be at least 8 characters.';
    if (password.length > 128) return 'Password cannot exceed 128 characters.';
    return null;
  }

  // Register new user locally with salted password hash
  Future<bool> register(
    String username,
    String password, {
    String country = 'Sri Lanka',
    String city = 'Nintavur',
  }) async {
    _lastError = null;
    final normalizedUsername = username.trim().toLowerCase();

    final userValidation = _validateUsername(normalizedUsername);
    if (userValidation != null) {
      _lastError = userValidation;
      return false;
    }

    final passValidation = _validatePassword(password);
    if (passValidation != null) {
      _lastError = passValidation;
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user already exists
      final existingHash = prefs.getString('local_pwd_hash_$normalizedUsername');
      final legacyExisting = prefs.getString('local_pwd_$normalizedUsername');
      if (existingHash != null || legacyExisting != null) {
        _lastError = 'An account with this username already exists.';
        return false;
      }

      final salt = _generateSalt();
      final hash = _hashPassword(password, salt);
      final uid = 'user_${DateTime.now().millisecondsSinceEpoch}';

      await prefs.setString('local_pwd_salt_$normalizedUsername', salt);
      await prefs.setString('local_pwd_hash_$normalizedUsername', hash);
      // Remove any legacy plaintext entry
      await prefs.remove('local_pwd_$normalizedUsername');

      await prefs.setString('local_user_id', uid);
      await prefs.setString('local_username', normalizedUsername);
      await prefs.setString('local_user_country', country);
      await prefs.setString('local_user_city', city);

      _currentUser = User(
        id: uid,
        username: normalizedUsername,
        createdAt: DateTime.now(),
        country: country,
        city: city,
      );

      _failedLoginAttempts = 0;
      _lockoutUntil = null;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = 'Registration failed: ${e.toString()}';
      return false;
    }
  }

  // Login existing user with password verification & brute force defense
  Future<bool> login(
    String username,
    String password, {
    String? country,
    String? city,
  }) async {
    _lastError = null;
    final normalizedUsername = username.trim().toLowerCase();

    // Check brute-force lockout
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remainingSec = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      _lastError = 'Account temporarily locked. Please try again in $remainingSec seconds.';
      return false;
    }

    if (normalizedUsername.isEmpty || password.isEmpty) {
      _lastError = 'Please enter both username and password.';
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString('local_pwd_hash_$normalizedUsername');
      final storedSalt = prefs.getString('local_pwd_salt_$normalizedUsername');

      bool isAuthenticated = false;

      if (storedHash != null && storedSalt != null) {
        final computedHash = _hashPassword(password, storedSalt);
        isAuthenticated = _constantTimeEquals(computedHash, storedHash);
      } else {
        // Check for legacy unhashed password and auto-upgrade
        final legacyPassword = prefs.getString('local_pwd_$normalizedUsername');
        if (legacyPassword != null && _constantTimeEquals(legacyPassword, password)) {
          final salt = _generateSalt();
          final hash = _hashPassword(password, salt);
          await prefs.setString('local_pwd_salt_$normalizedUsername', salt);
          await prefs.setString('local_pwd_hash_$normalizedUsername', hash);
          await prefs.remove('local_pwd_$normalizedUsername');
          isAuthenticated = true;
        }
      }

      if (!isAuthenticated) {
        _failedLoginAttempts++;
        if (_failedLoginAttempts >= _maxFailedAttempts) {
          _lockoutUntil = DateTime.now().add(_lockoutDuration);
          _lastError = 'Too many failed login attempts. Account locked for 30 seconds.';
        } else {
          _lastError = 'Invalid username or password.';
        }
        return false;
      }

      // Successful login: reset lockouts
      _failedLoginAttempts = 0;
      _lockoutUntil = null;

      final uid = 'user_${normalizedUsername.hashCode.abs()}';
      await prefs.setString('local_user_id', uid);
      await prefs.setString('local_username', normalizedUsername);

      final savedCountry = country ?? prefs.getString('local_user_country') ?? 'Sri Lanka';
      final savedCity = city ?? prefs.getString('local_user_city') ?? 'Nintavur';
      if (country != null) await prefs.setString('local_user_country', country);
      if (city != null) await prefs.setString('local_user_city', city);

      _currentUser = User(
        id: uid,
        username: normalizedUsername,
        createdAt: DateTime.now(),
        country: savedCountry,
        city: savedCity,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _lastError = 'Login failed. Please try again.';
      return false;
    }
  }

  Future<bool> sendPasswordReset(String usernameOrEmail) async {
    _lastError = null;
    final normalized = usernameOrEmail.trim().toLowerCase();
    if (normalized.isEmpty) {
      _lastError = 'Please enter a valid email or username.';
      return false;
    }
    // Safe response without exposing user existence
    return true;
  }

  // Logout locally
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('local_user_id');
      await prefs.remove('local_username');
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }
}
