import 'package:hive/hive.dart';
import 'package:test/minesweeper/data/models/score_model.dart';
import '../models/minesweeper_config.dart';

class HighscoreService {
  static const String _boxName = 'highscores';
  static const String _settingsBoxName = 'settings';
  static const String _playerNameKey = 'playerName';
  late Box<Highscore> _highscoreBox;
  late Box _settingsBox;

  Future<void> initialize() async {
    try {
      _highscoreBox = await Hive.openBox<Highscore>(_boxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
    } catch (e) {
      throw Exception('Failed to initialize Hive boxes: $e');
    }
  }

  Future<void> close() async {
    await _highscoreBox.close();
    await _settingsBox.close();
  }

  Future<bool> addHighscore({
    required Difficulty difficulty,
    required int timeInSeconds,
    required String playerName,
  }) async {
    try {
      final currentBest = getBestTimeForDifficulty(difficulty);
      final isNewRecord = currentBest == null || timeInSeconds < currentBest.timeInSeconds;

      final highscore = Highscore(
        difficulty: difficulty,
        timeInSeconds: timeInSeconds,
        dateAchieved: DateTime.now(),
        playerName: playerName.trim().isEmpty ? 'Anonymous' : playerName.trim(),
        gridSize: GameConfig.getGridSize(difficulty),
        bombCount: GameConfig.getBombCount(difficulty),
      );

      await _highscoreBox.add(highscore);
      await setPlayerName(playerName);

      return isNewRecord;
    } catch (e) {
      throw Exception('Failed to add highscore: $e');
    }
  }

  List<Highscore> getAllHighscores() {
    try {
      final highscores = _highscoreBox.values.toList();
      highscores.sort((a, b) => a.timeInSeconds.compareTo(b.timeInSeconds));
      return highscores;
    } catch (e) {
      return [];
    }
  }

  List<Highscore> getHighscoresForDifficulty(Difficulty difficulty) {
    try {
      final highscores = _highscoreBox.values
          .where((score) => score.difficulty == difficulty)
          .toList();
      highscores.sort((a, b) => a.timeInSeconds.compareTo(b.timeInSeconds));
      return highscores;
    } catch (e) {
      return [];
    }
  }

  Highscore? getBestTimeForDifficulty(Difficulty difficulty) {
    try {
      final highscores = getHighscoresForDifficulty(difficulty);
      return highscores.isEmpty ? null : highscores.first;
    } catch (e) {
      return null;
    }
  }

  List<Highscore> getTopScores({int limit = 10}) {
    try {
      final allScores = getAllHighscores();
      return allScores.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  List<Highscore> getTopScoresForDifficulty(Difficulty difficulty, {int limit = 5}) {
    try {
      final scores = getHighscoresForDifficulty(difficulty);
      return scores.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearAllHighscores() async {
    try {
      await _highscoreBox.clear();
    } catch (e) {
      throw Exception('Failed to clear highscores: $e');
    }
  }

  Future<void> clearHighscoresForDifficulty(Difficulty difficulty) async {
    try {
      final keysToDelete = <dynamic>[];
      for (var i = 0; i < _highscoreBox.length; i++) {
        final score = _highscoreBox.getAt(i);
        if (score?.difficulty == difficulty) {
          keysToDelete.add(_highscoreBox.keyAt(i));
        }
      }
      
      for (var key in keysToDelete) {
        await _highscoreBox.delete(key);
      }
    } catch (e) {
      throw Exception('Failed to clear highscores for difficulty: $e');
    }
  }

  Future<void> deleteHighscore(Highscore highscore) async {
    try {
      await highscore.delete();
    } catch (e) {
      throw Exception('Failed to delete highscore: $e');
    }
  }

  String getPlayerName() {
    try {
      return _settingsBox.get(_playerNameKey, defaultValue: '') as String;
    } catch (e) {
      return '';
    }
  }

  Future<void> setPlayerName(String name) async {
    try {
      await _settingsBox.put(_playerNameKey, name.trim());
    } catch (e) {
      throw Exception('Failed to save player name: $e');
    }
  }

  bool hasHighscores() {
    return _highscoreBox.isNotEmpty;
  }

  bool hasHighscoresForDifficulty(Difficulty difficulty) {
    return getHighscoresForDifficulty(difficulty).isNotEmpty;
  }

  int getTotalGamesPlayed() {
    return _highscoreBox.length;
  }

  int getGamesPlayedForDifficulty(Difficulty difficulty) {
    return getHighscoresForDifficulty(difficulty).length;
  }

  double getAverageTimeForDifficulty(Difficulty difficulty) {
    final scores = getHighscoresForDifficulty(difficulty);
    if (scores.isEmpty) return 0.0;
    
    final totalTime = scores.fold<int>(0, (sum, score) => sum + score.timeInSeconds);
    return totalTime / scores.length;
  }

  Map<Difficulty, Highscore?> getAllBestTimes() {
    return {
      Difficulty.easy: getBestTimeForDifficulty(Difficulty.easy),
      Difficulty.medium: getBestTimeForDifficulty(Difficulty.medium),
      Difficulty.hard: getBestTimeForDifficulty(Difficulty.hard),
    };
  }

  Future<void> exportHighscores() async {
    // This could be extended to export to a file
    final allScores = getAllHighscores();
    final jsonData = allScores.map((score) => score.toJson()).toList();
    // Implementation would depend on platform and requirements
    print('Exported ${allScores.length} highscores: $jsonData');
  }

  Future<void> importHighscores(List<Map<String, dynamic>> jsonData) async {
    try {
      for (var scoreJson in jsonData) {
        final highscore = Highscore.fromJson(scoreJson);
        await _highscoreBox.add(highscore);
      }
    } catch (e) {
      throw Exception('Failed to import highscores: $e');
    }
  }
}