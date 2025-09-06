import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:test/minesweeper/data/models/minesweeper_config.dart';
import 'package:test/minesweeper/data/models/minesweeper_status.dart';
import 'package:test/minesweeper/data/services/minesweeper_services.dart';
import 'package:test/minesweeper/data/services/score_service.dart';
import 'package:test/minesweeper/presentation/widgets/minesweeper_grid.dart';
import 'package:test/minesweeper/presentation/widgets/minesweeper_header.dart';
import 'package:test/minesweeper/presentation/widgets/minesweeper_instruction_panel.dart';
import 'package:test/minesweeper/presentation/widgets/win_dialog.dart';
import 'package:test/utils/colors.dart';

class MinesweeperGamePage extends StatefulWidget {
  final Difficulty? initialDifficulty;
  final HighscoreService? highscoreService;

  const MinesweeperGamePage({
    super.key,
    this.initialDifficulty,
    this.highscoreService,
  });

  @override
  State<MinesweeperGamePage> createState() => MinesweeperGamePageState();
}

class MinesweeperGamePageState extends State<MinesweeperGamePage>
    with TickerProviderStateMixin {
  late GameService gameService;
  late Timer timer;
  int secondsElapsed = 0;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    gameService = GameService();
    if (widget.initialDifficulty != null) {
      gameService.setDifficulty(widget.initialDifficulty!);
    }

    // Initialize animations
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    initializeGame();
  }

  @override
  void dispose() {
    timer.cancel();
    _shakeController.dispose();
    _pulseController.dispose();
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
    if (gameService.status != GameStatus.playing) return;

    setState(() {
      final wasFirstTap = gameService.isFirstTap;
      gameService.tapCell(index);

      if (gameService.status == GameStatus.lost) {
        _triggerShakeAnimation();
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) _showLoseDialog();
        });
      } else if (gameService.status == GameStatus.won) {
        _triggerPulseAnimation();
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.mediumImpact();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _showWinDialog();
        });
      } else {
        if (wasFirstTap) {
          HapticFeedback.lightImpact();
        } else {
          SystemSound.play(SystemSoundType.click);
        }
      }
    });
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }

  void _triggerPulseAnimation() {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  void _showWinDialog() {
    if (widget.highscoreService != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WinDialog(
            timeInSeconds: secondsElapsed,
            difficulty: gameService.difficulty,
            highscoreService: widget.highscoreService!,
            onPlayAgain: () {
              Navigator.of(context).pop();
              restartGame();
            },
            onGoHome: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          );
        },
      );
    } else {
      _showSimpleWinDialog();
    }
  }

  void _showSimpleWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.green, width: 2),
          ),
          title: const Column(
            children: [
              Icon(Icons.emoji_events, color: Colors.green, size: 48),
              SizedBox(height: 8),
              Text(
                'YOU WON!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 Congratulations! 🎉',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Time',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(secondsElapsed),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(gameService.difficulty)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getDifficultyColor(gameService.difficulty)
                        .withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getDifficultyIcon(gameService.difficulty),
                      color: _getDifficultyColor(gameService.difficulty),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${getDifficultyText()} Mode',
                      style: TextStyle(
                        color: _getDifficultyColor(gameService.difficulty),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Note: Scores cannot be saved in this session',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.textSecondary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Home'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      restartGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Play Again',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showLoseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.accentColor, width: 2),
          ),
          title: Column(
            children: [
              Lottie.asset('assets/jsons/bombAnimation.json',
                  repeat: true, height: 80),
              const SizedBox(height: 8),
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: AppColors.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '💥 Mine exploded! 💥',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.accentColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Time Survived',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(secondsElapsed),
                      style: const TextStyle(
                        color: AppColors.accentColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(gameService.difficulty)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getDifficultyColor(gameService.difficulty)
                        .withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getDifficultyIcon(gameService.difficulty),
                      color: _getDifficultyColor(gameService.difficulty),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${getDifficultyText()} Mode',
                      style: TextStyle(
                        color: _getDifficultyColor(gameService.difficulty),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Better luck next time!',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.textSecondary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Home'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      restartGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void onCellLongPress(int index) {
    if (gameService.status != GameStatus.playing) return;

    setState(() {
      final flagged = gameService.toggleFlag(index);
      if (flagged) {
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.click);
      } else {
        HapticFeedback.lightImpact();
      }
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                '6×6 grid, 6 mines',
                Icons.sentiment_satisfied,
                const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 12),
              _buildDifficultyButton(
                'Medium',
                Difficulty.medium,
                '7×7 grid, 9 mines',
                Icons.sentiment_neutral,
                const Color(0xFFFF9800),
              ),
              const SizedBox(height: 12),
              _buildDifficultyButton(
                'Hard',
                Difficulty.hard,
                '8×8 grid, 15 mines',
                Icons.sentiment_very_dissatisfied,
                const Color(0xFFE53E3E),
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
    IconData icon,
    Color color,
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
          backgroundColor: isSelected ? color : AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isSelected ? 8 : 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, size: 20),
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const Color(0xFF4CAF50);
      case Difficulty.medium:
        return const Color(0xFFFF9800);
      case Difficulty.hard:
        return const Color(0xFFE53E3E);
    }
  }

  IconData _getDifficultyIcon(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied;
      case Difficulty.medium:
        return Icons.sentiment_neutral;
      case Difficulty.hard:
        return Icons.sentiment_very_dissatisfied;
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
              tooltip: 'Change Difficulty',
            ),
          ],
        ),
        body: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              final shakeOffset = _shakeAnimation.value *
                  10 *
                  (gameService.status == GameStatus.lost ? 1 : 0);
              return Transform.translate(
                offset: Offset(
                    shakeOffset * (1 - _shakeAnimation.value * 2).sign, 0),
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Column(
                    children: [
                      const Spacer(),
                      // Game status and difficulty indicator
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getDifficultyColor(gameService.difficulty)
                                  .withOpacity(0.2),
                              _getDifficultyColor(gameService.difficulty)
                                  .withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getDifficultyColor(gameService.difficulty)
                                .withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getDifficultyIcon(gameService.difficulty),
                              color:
                                  _getDifficultyColor(gameService.difficulty),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Difficulty: ${getDifficultyText()}',
                              style: TextStyle(
                                color:
                                    _getDifficultyColor(gameService.difficulty),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Game header with timer and mine counter
                      GameHeader(
                        secondsElapsed: secondsElapsed,
                        remainingMines: gameService.remainingMines,
                        gameStatusEmoji: getGameStatusEmoji(),
                        onRestart: restartGame,
                      ),
                      GameGrid(
                        onCellRightClick: (p0) {},
                        grid: gameService.grid,
                        onCellTap: onCellTap,
                        onCellLongPress: onCellLongPress,
                        difficulty: gameService.difficulty,
                      ),

                      const Spacer(),

                      // Instructions panel
                      const InstructionsPanel(),

                      // Bottom padding
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            }));
  }
}
