class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    final raw = map['createdAt'];
    final createdAt = raw is DateTime
        ? raw
        : DateTime.tryParse('${map['createdAt']}') ?? DateTime.now();

    return ChatMessage(
      id: id,
      roomId: (map['roomId'] ?? '').toString(),
      senderId: (map['senderId'] ?? '').toString(),
      senderName: (map['senderName'] ?? 'Traveler').toString(),
      text: (map['text'] ?? '').toString(),
      createdAt: createdAt,
    );
  }
}
