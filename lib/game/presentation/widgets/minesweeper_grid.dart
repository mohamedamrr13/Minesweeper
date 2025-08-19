import 'package:flutter/material.dart';
import 'package:test/game/data/models/minesweeper_cell.dart';
import 'package:test/game/data/models/minesweeper_config.dart';
import 'package:test/game/presentation/widgets/minesweeper_cell.dart';
import 'package:test/utils/colors.dart';

class GameGrid extends StatelessWidget {
  final List<Cell> grid;
  final Function(int) onCellTap;
  final Function(int) onCellLongPress;

  const GameGrid({
    super.key,
    required this.grid,
    required this.onCellTap,
    required this.onCellLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: GameConfig.totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: GameConfig.gridSize,
              mainAxisSpacing: GameConfig.cellSpacing,
              crossAxisSpacing: GameConfig.cellSpacing,
            ),
            itemBuilder: (context, index) => GameCell(
              cell: grid[index],
              onTap: () => onCellTap(index),
              onLongPress: () => onCellLongPress(index),
            ),
          ),
        ),
      ),
    );
  }
}
