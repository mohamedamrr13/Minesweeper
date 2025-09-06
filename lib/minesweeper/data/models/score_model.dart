import 'package:hive/hive.dart';
import 'minesweeper_config.dart';

part 'score_model.g.dart';

@HiveType(typeId: 0)
class Highscore extends HiveObject {
  @HiveField(0)
  late Difficulty difficulty;

  @HiveField(1)
  late int timeInSeconds;

  @HiveField(2)
  late DateTime dateAchieved;

  @HiveField(3)
  late String playerName;

  @HiveField(4)
  late int gridSize;

  @HiveField(5)
  late int bombCount;

  Highscore({
    required this.difficulty,
    required this.timeInSeconds,
    required this.dateAchieved,
    required this.playerName,
    required this.gridSize,
    required this.bombCount,
  });

  Highscore.empty() {
    difficulty = Difficulty.easy;
    timeInSeconds = 0;
    dateAchieved = DateTime.now();
    playerName = '';
    gridSize = 0;
    bombCount = 0;
  }

  String get formattedTime {
    final minutes = timeInSeconds ~/ 60;
    final seconds = timeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get difficultyString {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  String get formattedDate {
    return '${dateAchieved.day}/${dateAchieved.month}/${dateAchieved.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty.index,
      'timeInSeconds': timeInSeconds,
      'dateAchieved': dateAchieved.toIso8601String(),
      'playerName': playerName,
      'gridSize': gridSize,
      'bombCount': bombCount,
    };
  }

  factory Highscore.fromJson(Map<String, dynamic> json) {
    return Highscore(
      difficulty: Difficulty.values[json['difficulty']],
      timeInSeconds: json['timeInSeconds'],
      dateAchieved: DateTime.parse(json['dateAchieved']),
      playerName: json['playerName'],
      gridSize: json['gridSize'],
      bombCount: json['bombCount'],
    );
  }

  @override
  String toString() {
    return 'Highscore{difficulty: $difficulty, time: $formattedTime, date: $formattedDate, player: $playerName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Highscore &&
        other.difficulty == difficulty &&
        other.timeInSeconds == timeInSeconds &&
        other.dateAchieved == dateAchieved &&
        other.playerName == playerName;
  }

  @override
  int get hashCode {
    return difficulty.hashCode ^
        timeInSeconds.hashCode ^
        dateAchieved.hashCode ^
        playerName.hashCode;
  }
}
