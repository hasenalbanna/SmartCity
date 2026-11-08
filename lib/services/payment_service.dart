import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';

class PaymentService extends ChangeNotifier {
  final List<Booking> _bookings = [];
  bool _isProcessing = false;
  String? _errorMessage;

  final _uuid = const Uuid();

  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  PaymentService();

  // Get bookings for current user
  List<Booking> getUserBookings(String userId) {
    return _bookings.where((b) => b.userId == userId).toList()
      ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
  }

  Future<bool> updateBookingTripDate(
    String bookingId,
    DateTime newTripDate,
  ) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return false;

    _bookings[index] = _bookings[index].copyWith(tripDate: newTripDate);
    notifyListeners();
    return true;
  }

  // Process payment (mock implementation)
  Future<Map<String, dynamic>> processPayment({
    required String packageId,
    required String packageTitle,
    required double amount,
    required int numberOfPeople,
    required DateTime tripDate,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation
      if (cardNumber.length < 16) {
        throw Exception('Invalid card number');
      }

      // Create transaction ID
      final transactionId = 'TXN_${DateTime.now().millisecondsSinceEpoch}';

      // Create booking
      final booking = Booking(
        id: _uuid.v4(),
        packageId: packageId,
        packageTitle: packageTitle,
        userId: 'user_001',
        userName: 'Explorer',
        bookingDate: DateTime.now(),
        tripDate: tripDate,
        numberOfPeople: numberOfPeople,
        totalAmount: amount,
        paymentStatus: 'completed',
        transactionId: transactionId,
      );

      _bookings.insert(0, booking);
      _isProcessing = false;
      notifyListeners();

      return {
        'success': true,
        'transactionId': transactionId,
        'booking': booking,
      };
    } catch (e) {
      _errorMessage = e.toString();
      _isProcessing = false;
      notifyListeners();

      return {'success': false, 'error': e.toString()};
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(paymentStatus: 'refunded');
      notifyListeners();
      return true;
    }
    return false;
  }

  // Get booking by ID
  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
