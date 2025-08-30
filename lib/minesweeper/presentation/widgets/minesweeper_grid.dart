import 'package:flutter/material.dart';
import 'package:test/minesweeper/data/models/minesweeper_cell.dart';
import 'package:test/minesweeper/data/models/minesweeper_config.dart';
import 'package:test/minesweeper/presentation/widgets/minesweeper_cell.dart';
import 'package:test/utils/colors.dart';

class GameGrid extends StatelessWidget {
  final List<Cell> grid;
  final Function(int) onCellTap;
  final Function(int) onCellLongPress;
  final Difficulty difficulty;

  const GameGrid({
    super.key,
    required this.grid,
    required this.onCellTap,
    required this.onCellLongPress,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final gridSize = GameConfig.getGridSize(difficulty);
    final totalCells = GameConfig.getTotalCells(difficulty);
    
    return Container(
      width: MediaQuery.of(context).size.height / 2.3,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the maximum square size that fits in the available space
          double maxSize = constraints.maxHeight < constraints.maxWidth
              ? constraints.maxHeight
              : constraints.maxWidth;

          return Center(
            child: SizedBox(
              width: maxSize,
              height: maxSize,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: totalCells,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
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
          );
        },
      ),
    );
  }
}
