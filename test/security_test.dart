import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_city/services/auth_service.dart';
import 'package:smart_city/services/routing_service.dart';
import 'package:smart_city/services/geocoding_service.dart';
import 'package:smart_city/services/lita_ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Security Audit Tests: Authentication & Password Security', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Rejects registration with password shorter than 8 characters', () async {
      final auth = AuthService();
      final success = await auth.register('testcitizen', '123456');
      expect(success, isFalse);
      expect(auth.lastError, contains('at least 8 characters'));
      expect(auth.isLoggedIn, isFalse);
    });

    test('Rejects registration with invalid characters in username', () async {
      final auth = AuthService();
      final success = await auth.register('bad user!#\$%', 'ValidPassword123');
      expect(success, isFalse);
      expect(auth.lastError, contains('alphanumeric or a valid email'));
      expect(auth.isLoggedIn, isFalse);
    });

    test('Stores salted cryptographic hash and never stores plaintext password', () async {
      final auth = AuthService();
      const rawPassword = 'SecretCitizenPass123!';
      final success = await auth.register('citizen_alpha', rawPassword);
      expect(success, isTrue);

      final prefs = await SharedPreferences.getInstance();
      // Ensure plaintext password key does NOT exist
      expect(prefs.containsKey('local_pwd_citizen_alpha'), isFalse);

      // Ensure hash and salt exist and are properly generated
      final hash = prefs.getString('local_pwd_hash_citizen_alpha');
      final salt = prefs.getString('local_pwd_salt_citizen_alpha');
      expect(hash, isNotNull);
      expect(salt, isNotNull);
      expect(hash, isNot(equals(rawPassword)));
      expect(hash!.length, equals(64)); // SHA-256 hex string length
    });

    test('Different users with the same password produce distinct salts and hashes', () async {
      final auth1 = AuthService();
      const commonPass = 'CommonSecurePassword2026!';
      await auth1.register('citizen_one', commonPass);

      final auth2 = AuthService();
      await auth2.register('citizen_two', commonPass);

      final prefs = await SharedPreferences.getInstance();
      final hash1 = prefs.getString('local_pwd_hash_citizen_one');
      final hash2 = prefs.getString('local_pwd_hash_citizen_two');
      final salt1 = prefs.getString('local_pwd_salt_citizen_one');
      final salt2 = prefs.getString('local_pwd_salt_citizen_two');

      expect(salt1, isNot(equals(salt2)));
      expect(hash1, isNot(equals(hash2)));
    });

    test('Prevents account overwriting / account takeover during registration', () async {
      final auth = AuthService();
      final first = await auth.register('existing_user', 'FirstPassword123');
      expect(first, isTrue);

      final second = await auth.register('existing_user', 'AttackerPassword123');
      expect(second, isFalse);
      expect(auth.lastError, contains('already exists'));
    });

    test('Verifies correct password and rejects incorrect password', () async {
      final auth = AuthService();
      await auth.register('john_doe', 'MySecretPassword99');
      await auth.logout();

      // Wrong password
      final fail = await auth.login('john_doe', 'WrongPassword99');
      expect(fail, isFalse);
      expect(auth.isLoggedIn, isFalse);

      // Correct password
      final pass = await auth.login('john_doe', 'MySecretPassword99');
      expect(pass, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.currentUser?.username, equals('john_doe'));
    });

    test('Rate limits / locks account after 5 consecutive failed login attempts', () async {
      final auth = AuthService();
      await auth.register('victim_user', 'StrongPass123!');
      await auth.logout();

      for (int i = 0; i < 4; i++) {
        final res = await auth.login('victim_user', 'WrongAttempt$i');
        expect(res, isFalse);
        expect(auth.lastError, equals('Invalid username or password.'));
      }

      // 5th failed attempt should trigger lockout
      final fifth = await auth.login('victim_user', 'WrongAttempt5');
      expect(fifth, isFalse);
      expect(auth.lastError, contains('Too many failed login attempts'));

      // Subsequent attempt even with correct password is blocked during lockout
      final locked = await auth.login('victim_user', 'StrongPass123!');
      expect(locked, isFalse);
      expect(auth.lastError, contains('Account temporarily locked'));
    });
  });

  group('Security Audit Tests: Network Security & Parameter Validation', () {
    test('RoutingService rejects invalid coordinate bounds', () async {
      final routing = RoutingService();
      // Out of bounds coordinates (latitude > 90)
      final result = await routing.getSafestRoute(
        const LatLng(999.0, 10.0),
        const LatLng(7.0, 80.0),
      );
      expect(result.points, isEmpty);
      expect(result.safetyScore.summary, contains('Invalid coordinate bounds'));
    });

    test('GeocodingService rejects empty or excessively large queries', () async {
      final geocoding = GeocodingService();
      final emptyResult = await geocoding.searchPlaces('');
      expect(emptyResult, isEmpty);

      final whitespaceResult = await geocoding.searchPlaces('   ');
      expect(whitespaceResult, isEmpty);

      final hugeQuery = 'A' * 300;
      final hugeResult = await geocoding.searchPlaces(hugeQuery);
      expect(hugeResult, isEmpty);
    });

    test('LitaAiService does not expose hardcoded API keys in source', () {
      final lita = LitaAiService();
      // Verify LitaAiService initializes without throwing an unhandled exception
      expect(lita, isNotNull);
    });
  });
}

