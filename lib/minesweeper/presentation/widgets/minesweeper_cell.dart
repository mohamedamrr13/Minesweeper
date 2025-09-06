import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test/minesweeper/data/models/minesweeper_cell.dart';
import 'package:test/utils/colors.dart';

class GameCell extends StatelessWidget {
  final Cell cell;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onRightClick;
  const GameCell({
    super.key,
    required this.cell,
    required this.onTap,
    required this.onLongPress,
    required this.onRightClick,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        // Check for right mouse button (button = 2)
        if (event.kind == PointerDeviceKind.mouse &&
            event.buttons == kSecondaryMouseButton) {
          onRightClick();
          HapticFeedback.lightImpact();
        }
      },
      child: GestureDetector(
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
        return Image.asset("assets/images/bomb.jpg");
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
