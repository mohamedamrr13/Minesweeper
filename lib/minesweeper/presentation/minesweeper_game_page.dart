import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test/minesweeper/data/models/minesweeper_config.dart';
import 'package:test/minesweeper/data/models/minesweeper_status.dart';
import 'package:test/minesweeper/data/services/minesweeper_services.dart';
import 'package:test/minesweeper/presentation/widgets/minesweeper_grid.dart';
import 'package:test/minesweeper/presentation/widgets/minesweeper_header.dart';
import 'package:test/minesweeper/presentation/widgets/minesweeper_instruction_panel.dart';
import 'package:test/utils/colors.dart';

class MinesweeperGamePage extends StatefulWidget {
  final Difficulty? initialDifficulty;

  const MinesweeperGamePage({super.key, this.initialDifficulty});

  @override
  State<MinesweeperGamePage> createState() => MinesweeperGamePageState();
}

class MinesweeperGamePageState extends State<MinesweeperGamePage> {
  late GameService gameService;
  late Timer timer;
  int secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    gameService = GameService();
    if (widget.initialDifficulty != null) {
      gameService.setDifficulty(widget.initialDifficulty!);
    }
    initializeGame();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void initializeGame() {
    gameService.initializeGame();
    secondsElapsed = 0;
    timer = Timer.periodic(const Duration(seconds: 1), updateTimer);
  }

  void updateTimer(Timer timer) {
    if (gameService.status == GameStatus.playing) {
      setState(() {
        secondsElapsed++;
      });
    }
  }

  void onCellTap(int index) {
    setState(() {
      gameService.tapCell(index);
      if (gameService.status == GameStatus.lost) {
        SystemSound.play(SystemSoundType.alert);
      } else if (!gameService.toggleFlag(index) &&
          !gameService.grid[index].isBomb) {
        SystemSound.play(SystemSoundType.click);
      } else {
        SystemSound.play(SystemSoundType.alert);
      }
      if (gameService.status == GameStatus.won) {
        _showWinDialog();
      }
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          title: const Text(
            'YOU WON!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            '🎉 Congratulations! 🎉',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  restartGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Press to Play Again',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void onCellLongPress(int index) {
    setState(() {
      gameService.toggleFlag(index);
      HapticFeedback.vibrate();
      SystemSound.play(SystemSoundType.alert);
    });
  }

  void restartGame() {
    timer.cancel();
    setState(() {
      initializeGame();
    });
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          title: const Text(
            'Select Difficulty',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDifficultyButton(
                'Easy',
                Difficulty.easy,
                '6x6 grid, 6 mines',
              ),
              const SizedBox(height: 12),
              _buildDifficultyButton(
                'Medium',
                Difficulty.medium,
                '7x7 grid, 9 mines',
              ),
              const SizedBox(height: 12),
              _buildDifficultyButton(
                'Hard',
                Difficulty.hard,
                '8x8 grid, 15 mines',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDifficultyButton(
    String title,
    Difficulty difficulty,
    String description,
  ) {
    final isSelected = gameService.difficulty == difficulty;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          setState(() {
            gameService.setDifficulty(difficulty);
            restartGame();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.accentColor
              : AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  String getDifficultyText() {
    switch (gameService.difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  String getGameStatusEmoji() {
    switch (gameService.status) {
      case GameStatus.won:
        return '😎';
      case GameStatus.lost:
        return '😵';
      default:
        return '🙂';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'MINESWEEPER',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: AppColors.surfaceColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
            onPressed: _showDifficultyDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
          // Difficulty indicator
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Difficulty: ${getDifficultyText()}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          GameHeader(
            secondsElapsed: secondsElapsed,
            remainingMines: gameService.remainingMines,
            gameStatusEmoji: getGameStatusEmoji(),
            onRestart: restartGame,
          ),
          GameGrid(
            grid: gameService.grid,
            onCellTap: onCellTap,
            onCellLongPress: onCellLongPress,
            difficulty: gameService.difficulty,
          ),
          const Spacer(),
          const InstructionsPanel(),
        ],
      ),
    );
  }
}
