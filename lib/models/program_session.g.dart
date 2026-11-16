// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgramSessionAdapter extends TypeAdapter<ProgramSession> {
  @override
  final int typeId = 1;

  @override
  ProgramSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgramSession(
      id: fields[0] as String,
      programType: fields[1] as String,
      dayIndex: fields[2] as int,
      date: fields[3] as DateTime,
      content: fields[4] as String,
      theme: fields[5] as String,
      durationSec: fields[6] as int,
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProgramSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.programType)
      ..writeByte(2)
      ..write(obj.dayIndex)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.theme)
      ..writeByte(6)
      ..write(obj.durationSec)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
