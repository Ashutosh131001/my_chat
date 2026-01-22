enum MessageType { text, image }

class MessageModel {
  final String messageId;
  final String chatId;
  final String senderId;
  final String? text;
  final List<String> urls;

  final int timestamp;
  final MessageType messageType;

  final int starredAt;
  final List<String> starredBy;

  final bool isDeletedForEveryone;
  final List<String> deletedFor;
  final List<String> seenBy;

  MessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.messageType,
    required this.timestamp,

    this.text,
    this.urls = const [],

    this.starredAt = 0,
    this.starredBy = const [],

    this.isDeletedForEveryone = false,
    this.deletedFor = const [],
    this.seenBy = const [],
  });

  /* ---------------- FROM FIRESTORE ---------------- */
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'],
      chatId: map['chatId'],
      senderId: map['senderId'],

      messageType: MessageType.values.byName(map['messageType']),
      timestamp: map['timestamp'],

      text: map['text'],
      urls: List<String>.from(map['urls'] ?? []),

      starredAt: map['starredAt'] ?? 0,
      starredBy: List<String>.from(map['starredBy'] ?? []),

      isDeletedForEveryone: map['isDeletedForEveryone'] ?? false,
      deletedFor: List<String>.from(map['deletedFor'] ?? []),
      seenBy: List<String>.from(map['seenBy'] ?? []),
    );
  }

  /* ---------------- TO FIRESTORE ---------------- */
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,

      /// Store enum safely as String
      'messageType': messageType.name,

      'text': text,
      'urls': urls,

      'timestamp': timestamp,

      'starredAt': starredAt,
      'starredBy': starredBy,

      'isDeletedForEveryone': isDeletedForEveryone,
      'deletedFor': deletedFor,
      'seenBy': seenBy,
    };
  }

  /* ---------------- COPY WITH ---------------- */
  MessageModel copyWith({
    String? text,
    List<String>? urls,
    int? starredAt,
    List<String>? starredBy,
    bool? isDeletedForEveryone,
    List<String>? deletedFor,
    List<String>? seenBy,
  }) {
    return MessageModel(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      messageType: messageType,
      timestamp: timestamp,

      text: text ?? this.text,
      urls: urls ?? this.urls,

      starredAt: starredAt ?? this.starredAt,
      starredBy: starredBy ?? this.starredBy,

      isDeletedForEveryone:
          isDeletedForEveryone ?? this.isDeletedForEveryone,
      deletedFor: deletedFor ?? this.deletedFor,
      seenBy: seenBy ?? this.seenBy,
    );
  }
}