import 'package:flutter/material.dart';
import 'package:test/utils/colors.dart';

class GameHeader extends StatelessWidget {
  final int secondsElapsed;
  final int remainingMines;
  final String gameStatusEmoji;
  final VoidCallback onRestart;

  const GameHeader({
    super.key,
    required this.secondsElapsed,
    required this.remainingMines,
    required this.gameStatusEmoji,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _DisplayContainer(
            title: "TIME",
            value: secondsElapsed.toString().padLeft(3, '0'),
          ),
          _RestartButton(emoji: gameStatusEmoji, onPressed: onRestart),
          _DisplayContainer(
            title: "MINES",
            value: remainingMines.toString().padLeft(3, '0'),
          ),
        ],
      ),
    );
  }
}

class _DisplayContainer extends StatelessWidget {
  final String title;
  final String value;

  const _DisplayContainer({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(
          top: BorderSide(color: AppColors.borderDark, width: 2),
          left: BorderSide(color: AppColors.borderDark, width: 2),
          bottom: BorderSide(color: AppColors.borderLight, width: 2),
          right: BorderSide(color: AppColors.borderLight, width: 2),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.accentColor,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestartButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onPressed;

  const _RestartButton({required this.emoji, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
