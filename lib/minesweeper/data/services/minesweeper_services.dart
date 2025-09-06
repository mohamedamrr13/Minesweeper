import 'dart:math';
import '../models/minesweeper_cell.dart';
import '../models/minesweeper_config.dart';
import '../models/minesweeper_status.dart';

class GameService {
  List<Cell> _grid = [];
  GameStatus _status = GameStatus.playing;
  int _flagsPlaced = 0;
  bool _firstTap = true;
  Difficulty _difficulty = Difficulty.medium;

  // Getters
  List<Cell> get grid => _grid;
  GameStatus get status => _status;
  int get flagsPlaced => _flagsPlaced;
  int get remainingMines => GameConfig.getBombCount(_difficulty) - _flagsPlaced;
  bool get isFirstTap => _firstTap;
  Difficulty get difficulty => _difficulty;

  // Set difficulty
  void setDifficulty(Difficulty difficulty) {
    _difficulty = difficulty;
  }

  // Initialize new game
  void initializeGame() {
    final totalCells = GameConfig.getTotalCells(_difficulty);
    _grid = List.generate(totalCells, (index) => Cell());
    _status = GameStatus.playing;
    _flagsPlaced = 0;
    _firstTap = true;
  }

  // Generate bombs after first tap to ensure first cell is safe & empty
  void generateBombs(int safeCellIndex) {
    final random = Random();
    final bombCount = GameConfig.getBombCount(_difficulty);
    final totalCells = GameConfig.getTotalCells(_difficulty);

    bool validSetup = false;

    while (!validSetup) {
      // Clear any existing bombs
      for (var cell in _grid) {
        cell.isBomb = false;
        cell.adjacentBombs = 0;
      }

      // Place bombs randomly (avoiding safeCellIndex)
      final bombPositions = <int>{};
      while (bombPositions.length < bombCount) {
        final position = random.nextInt(totalCells);
        if (position != safeCellIndex) {
          bombPositions.add(position);
          _grid[position].isBomb = true;
        }
      }

      // Calculate adjacent bomb counts
      for (int i = 0; i < totalCells; i++) {
        if (!_grid[i].isBomb) {
          _grid[i].adjacentBombs = getAdjacentBombCount(i);
        }
      }

      // ✅ Check: is the safe cell a "0"? If yes, we’re good
      if (_grid[safeCellIndex].adjacentBombs == 0) {
        validSetup = true;
      }
    }

    _firstTap = false;
  }

  // Get adjacent bomb count for a cell
  int getAdjacentBombCount(int index) {
    int count = 0;
    final neighbors = getNeighbors(index);

    for (final neighbor in neighbors) {
      if (_grid[neighbor].isBomb) {
        count++;
      }
    }

    return count;
  }

  List<int> getNeighbors(int index) {
    final neighbors = <int>[];
    final gridSize = GameConfig.getGridSize(_difficulty);
    final row = index ~/ gridSize;
    final col = index % gridSize;

    for (int deltaRow = -1; deltaRow <= 1; deltaRow++) {
      for (int deltaCol = -1; deltaCol <= 1; deltaCol++) {
        if (deltaRow == 0 && deltaCol == 0) continue;

        final newRow = row + deltaRow;
        final newCol = col + deltaCol;

        if (newRow >= 0 &&
            newRow < gridSize &&
            newCol >= 0 &&
            newCol < gridSize) {
          neighbors.add(newRow * gridSize + newCol);
        }
      }
    }

    return neighbors;
  }

  // Handle cell tap
  bool tapCell(int index) {
    if (_status != GameStatus.playing || _grid[index].isFlagged) {
      return false;
    }

    // Generate bombs on first tap
    if (_firstTap) {
      generateBombs(index);
    }

    if (_grid[index].isBomb) {
      _status = GameStatus.lost;
      _revealAllBombs();
      return true;
    } else {
      _revealCell(index);
      _checkWinCondition();
      return true;
    }
  }

  // Handle cell long press (flagging)
  bool toggleFlag(int index) {
    if (_status != GameStatus.playing || _grid[index].isRevealed) {
      return false;
    }

    final bombCount = GameConfig.getBombCount(_difficulty);
    if (_grid[index].isFlagged) {
      _grid[index].unflag();
      _flagsPlaced--;
    } else if (_flagsPlaced < bombCount) {
      _grid[index].flag();
      _flagsPlaced++;
    } else {
      return false; // Can't place more flags
    }

    return true;
  }

  // Reveal a cell and adjacent empty cells
  void _revealCell(int index) {
    if (_grid[index].isRevealed || _grid[index].isFlagged) {
      return;
    }

    _grid[index].reveal();

    // If cell has no adjacent bombs, reveal neighbors
    if (_grid[index].adjacentBombs == 0) {
      final neighbors = getNeighbors(index);
      for (final neighbor in neighbors) {
        _revealCell(neighbor);
      }
    }
  }

  // Reveal all bombs (game over)
  void _revealAllBombs() {
    for (final cell in _grid) {
      if (cell.isBomb) {
        cell.reveal();
      }
    }
  }

  void _checkWinCondition() {
    bool hasWon = true;

    for (final cell in _grid) {
      if (!cell.isBomb && !cell.isRevealed) {
        hasWon = false;
        break;
      }
    }

    if (hasWon) {
      _status = GameStatus.won;
    }
  }
}
