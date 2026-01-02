class MessageModel {
  final String messageId;
  final String chatId;
  final String senderId;
  final String? text;
  final int timestamp;
  final bool isDeletedForEveryone;
  final List<String> deletedFor;
  final List<String> seenBy;

  MessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isDeletedForEveryone = false,
    this.deletedFor = const [],
    this.seenBy = const [],
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'],
      chatId: map['chatId'],
      senderId: map['senderId'],
      text: map['text'],
      timestamp: map['timestamp'],
      isDeletedForEveryone: map['isDeletedForEveryone'] ?? false,
      deletedFor: List<String>.from(map['deletedFor'] ?? []),
      seenBy: List<String>.from(map['seenBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'isDeletedForEveryone': isDeletedForEveryone,
      'deletedFor': deletedFor,
      'seenBy': seenBy,
    };
  }

  MessageModel copyWith({
    String? text,
    bool? isDeletedForEveryone,
    List<String>? deletedFor,
    List<String>? seenBy,
  }) {
    return MessageModel(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      text: text ?? this.text,
      timestamp: timestamp,
      isDeletedForEveryone:
          isDeletedForEveryone ?? this.isDeletedForEveryone,
      deletedFor: deletedFor ?? this.deletedFor,
      seenBy: seenBy ?? this.seenBy,
    );
  }
}