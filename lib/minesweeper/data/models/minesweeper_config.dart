enum Difficulty { easy, medium, hard }

class GameConfig {
  static const double cellSpacing = 2;
  
  static int getGridSize(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 6;
      case Difficulty.medium:
        return 7;
      case Difficulty.hard:
        return 8;
    }
  }
  
  static int getBombCount(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 6;
      case Difficulty.medium:
        return 9;
      case Difficulty.hard:
        return 15;
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
