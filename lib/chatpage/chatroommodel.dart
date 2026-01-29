class ChatRoomModel {
  final String chatId;
  final List<String> participants;
  final String? lastMessage;
  final int? lastMessageTime;

  // 🔥 userId -> cleared timestamp
  final Map<String, int> clearedBy;

  ChatRoomModel({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.clearedBy,
  });

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      chatId: map['chatId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'],
      clearedBy: Map<String, int>.from(map['clearedBy'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'clearedBy': clearedBy,
    };
  }
}