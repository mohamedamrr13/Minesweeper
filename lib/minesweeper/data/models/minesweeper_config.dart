enum Difficulty { easy, medium, hard }

class GameConfig {
  static const double cellSpacing = 2;

  static int getGridSize(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 9;
      case Difficulty.medium:
        return 11;
      case Difficulty.hard:
        return 13;
    }
  }

  static int getBombCount(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 12;
      case Difficulty.medium:
        return 22;
      case Difficulty.hard:
        return 34;
    }
  }

  static int getTotalCells(Difficulty difficulty) {
    final gridSize = getGridSize(difficulty);
    return gridSize * gridSize;
  }

  // Legacy support - default to medium
  static const int gridSize = 7;
  static const int totalCells = gridSize * gridSize;
  static const int bombCount = 9;
}
