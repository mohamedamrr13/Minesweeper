import 'dart:math';
import '../models/minesweeper_cell.dart';
import '../models/minesweeper_config.dart';
import '../models/minesweeper_status.dart';

class GameService {
  List<Cell> _grid = [];
  GameStatus _status = GameStatus.playing;
  int _flagsPlaced = 0;
  bool _firstTap = true;

  // Getters
  List<Cell> get grid => _grid;
  GameStatus get status => _status;
  int get flagsPlaced => _flagsPlaced;
  int get remainingMines => GameConfig.bombCount - _flagsPlaced;
  bool get isFirstTap => _firstTap;

  // Initialize new game
  void initializeGame() {
    _grid = List.generate(GameConfig.totalCells, (index) => Cell());
    _status = GameStatus.playing;
    _flagsPlaced = 0;
    _firstTap = true;
  }

  // Generate bombs after first tap to ensure first cell is safe
  void generateBombs(int safeCellIndex) {
    final random = Random();
    final bombPositions = <int>{};

    while (bombPositions.length < GameConfig.bombCount) {
      final position = random.nextInt(GameConfig.totalCells);
      if (position != safeCellIndex && !bombPositions.contains(position)) {
        bombPositions.add(position);
        _grid[position].isBomb = true;
      }
    }

    // Calculate adjacent bomb counts
    for (int i = 0; i < GameConfig.totalCells; i++) {
      if (!_grid[i].isBomb) {
        _grid[i].adjacentBombs = getAdjacentBombCount(i);
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

  // Get neighbor indices for a given cell
  List<int> getNeighbors(int index) {
    final neighbors = <int>[];
    final row = index ~/ GameConfig.gridSize;
    final col = index % GameConfig.gridSize;

    for (int deltaRow = -1; deltaRow <= 1; deltaRow++) {
      for (int deltaCol = -1; deltaCol <= 1; deltaCol++) {
        if (deltaRow == 0 && deltaCol == 0) continue;

        final newRow = row + deltaRow;
        final newCol = col + deltaCol;

        if (newRow >= 0 &&
            newRow < GameConfig.gridSize &&
            newCol >= 0 &&
            newCol < GameConfig.gridSize) {
          neighbors.add(newRow * GameConfig.gridSize + newCol);
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

    if (_grid[index].isFlagged) {
      _grid[index].unflag();
      _flagsPlaced--;
    } else if (_flagsPlaced < GameConfig.bombCount) {
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
