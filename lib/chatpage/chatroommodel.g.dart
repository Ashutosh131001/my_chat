// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatroommodel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatRoomModelAdapter extends TypeAdapter<ChatRoomModel> {
  @override
  final int typeId = 2;

  @override
  ChatRoomModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatRoomModel(
      chatId: fields[0] as String,
      participants: (fields[1] as List).cast<String>(),
      lastMessage: fields[2] as String?,
      lastMessageTime: fields[3] as int?,
      clearedBy: (fields[4] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatRoomModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.chatId)
      ..writeByte(1)
      ..write(obj.participants)
      ..writeByte(2)
      ..write(obj.lastMessage)
      ..writeByte(3)
      ..write(obj.lastMessageTime)
      ..writeByte(4)
      ..write(obj.clearedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRoomModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatListItemAdapter extends TypeAdapter<ChatListItem> {
  @override
  final int typeId = 3;

  @override
  ChatListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatListItem(
      chatroom: fields[0] as ChatRoomModel,
      otheruser: fields[1] as usermodel,
    );
  }

  @override
  void write(BinaryWriter writer, ChatListItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.chatroom)
      ..writeByte(1)
      ..write(obj.otheruser);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatListItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
