import 'dart:async';
import 'package:flutter/material.dart';
import 'package:test/game/data/models/minesweeper_status.dart';
import 'package:test/game/data/services/minesweeper_services.dart';
import 'package:test/game/presentation/widgets/minesweeper_grid.dart';
import 'package:test/game/presentation/widgets/minesweeper_header.dart';
import 'package:test/game/presentation/widgets/minesweeper_instruction_panel.dart';
import 'package:test/utils/colors.dart';

class MinesweeperGamePage extends StatefulWidget {
  const MinesweeperGamePage({super.key});

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
    });
  }

  void onCellLongPress(int index) {
    setState(() {
      gameService.toggleFlag(index);
    });
  }

  void restartGame() {
    timer.cancel();
    setState(() {
      initializeGame();
    });
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
      ),
      body: Column(
        children: [
          Spacer(),
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
          ),

          Spacer(),
          const InstructionsPanel(),
        ],
      ),
    );
  }
}
