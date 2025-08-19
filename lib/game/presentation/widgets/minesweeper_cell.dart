import 'package:flutter/material.dart';
import 'package:test/game/data/models/minesweeper_cell.dart';
import 'package:test/utils/colors.dart';


class GameCell extends StatelessWidget {
  final Cell cell;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const GameCell({
    super.key,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: _getCellBackgroundColor(),
          border: Border(
            top: BorderSide(
              color: cell.isRevealed
                  ? AppColors.borderDark
                  : AppColors.borderLight,
              width: 2,
            ),
            left: BorderSide(
              color: cell.isRevealed
                  ? AppColors.borderDark
                  : AppColors.borderLight,
              width: 2,
            ),
            bottom: BorderSide(
              color: cell.isRevealed
                  ? AppColors.borderLight
                  : AppColors.borderDark,
              width: 2,
            ),
            right: BorderSide(
              color: cell.isRevealed
                  ? AppColors.borderLight
                  : AppColors.borderDark,
              width: 2,
            ),
          ),
        ),
        child: Center(child: _buildCellContent()),
      ),
    );
  }

  Color _getCellBackgroundColor() {
    if (cell.isRevealed) {
      return cell.isBomb ? Colors.red : AppColors.cellRevealed;
    }
    return AppColors.cellDefault;
  }

  Widget? _buildCellContent() {
    if (cell.isFlagged) {
      return const Icon(Icons.flag, color: AppColors.accentColor, size: 20);
    }

    if (cell.isRevealed) {
      if (cell.isBomb) {
        return const Icon(Icons.whatshot, color: Colors.white, size: 20);
      } else if (cell.adjacentBombs > 0) {
        return Text(
          cell.adjacentBombs.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColorUtils.getNumberColor(cell.adjacentBombs),
          ),
        );
      }
    }

    return null;
  }
}
