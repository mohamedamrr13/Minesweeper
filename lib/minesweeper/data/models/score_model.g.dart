// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HighscoreAdapter extends TypeAdapter<Highscore> {
  @override
  final int typeId = 0;

  @override
  Highscore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Highscore(
      difficulty: fields[0] as Difficulty,
      timeInSeconds: fields[1] as int,
      dateAchieved: fields[2] as DateTime,
      playerName: fields[3] as String,
      gridSize: fields[4] as int,
      bombCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Highscore obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.difficulty)
      ..writeByte(1)
      ..write(obj.timeInSeconds)
      ..writeByte(2)
      ..write(obj.dateAchieved)
      ..writeByte(3)
      ..write(obj.playerName)
      ..writeByte(4)
      ..write(obj.gridSize)
      ..writeByte(5)
      ..write(obj.bombCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighscoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
