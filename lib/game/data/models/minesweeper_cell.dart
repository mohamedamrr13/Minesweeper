enum CellState { hidden, revealed, flagged }

class Cell {
  bool isBomb;
  int adjacentBombs;
  CellState state;

  Cell({
    this.isBomb = false,
    this.adjacentBombs = 0,
    this.state = CellState.hidden,
  });

  bool get isRevealed => state == CellState.revealed;
  bool get isFlagged => state == CellState.flagged;
  bool get isHidden => state == CellState.hidden;

  void reveal() => state = CellState.revealed;
  void flag() => state = CellState.flagged;
  void unflag() => state = CellState.hidden;
  void toggleFlag() => isFlagged ? unflag() : flag();
}
