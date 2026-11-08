class Booking {
  final String id;
  final String packageId;
  final String packageTitle;
  final String userId;
  final String userName;
  final DateTime bookingDate;
  final DateTime tripDate;
  final int numberOfPeople;
  final double totalAmount;
  final String paymentStatus; // 'pending', 'completed', 'failed', 'refunded'
  final String? paymentIntentId;
  final String? transactionId;

  Booking({
    required this.id,
    required this.packageId,
    required this.packageTitle,
    required this.userId,
    required this.userName,
    required this.bookingDate,
    required this.tripDate,
    required this.numberOfPeople,
    required this.totalAmount,
    required this.paymentStatus,
    this.paymentIntentId,
    this.transactionId,
  });

  Booking copyWith({
    String? id,
    String? packageId,
    String? packageTitle,
    String? userId,
    String? userName,
    DateTime? bookingDate,
    DateTime? tripDate,
    int? numberOfPeople,
    double? totalAmount,
    String? paymentStatus,
    String? paymentIntentId,
    String? transactionId,
  }) {
    return Booking(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      packageTitle: packageTitle ?? this.packageTitle,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      bookingDate: bookingDate ?? this.bookingDate,
      tripDate: tripDate ?? this.tripDate,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}
