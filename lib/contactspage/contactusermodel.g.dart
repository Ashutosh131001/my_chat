// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contactusermodel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class usermodelAdapter extends TypeAdapter<usermodel> {
  @override
  final int typeId = 1;

  @override
  usermodel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return usermodel(
      uid: fields[0] as String,
      name: fields[1] as String,
      phonenumber: fields[2] as String,
      about: fields[3] as String?,
      profileImageUrl: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, usermodel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phonenumber)
      ..writeByte(3)
      ..write(obj.about)
      ..writeByte(4)
      ..write(obj.profileImageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is usermodelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
