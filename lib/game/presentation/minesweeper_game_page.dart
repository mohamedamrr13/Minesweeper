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
  State<MinesweeperGamePage> createState() => _MinesweeperGamePageState();
}

class _MinesweeperGamePageState extends State<MinesweeperGamePage> {
  late GameService _gameService;
  late Timer _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _gameService = GameService();
    _initializeGame();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeGame() {
    _gameService.initializeGame();
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer(Timer timer) {
    if (_gameService.status == GameStatus.playing) {
      setState(() {
        _secondsElapsed++;
      });
    }
  }

  void _onCellTap(int index) {
    setState(() {
      _gameService.tapCell(index);
    });
  }

  void _onCellLongPress(int index) {
    setState(() {
      _gameService.toggleFlag(index);
    });
  }

  void _restartGame() {
    _timer.cancel();
    setState(() {
      _initializeGame();
    });
  }

  String _getGameStatusEmoji() {
    switch (_gameService.status) {
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
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          GameHeader(
            secondsElapsed: _secondsElapsed,
            remainingMines: _gameService.remainingMines,
            gameStatusEmoji: _getGameStatusEmoji(),
            onRestart: _restartGame,
          ),
          GameGrid(
            grid: _gameService.grid,
            onCellTap: _onCellTap,
            onCellLongPress: _onCellLongPress,
          ),
          const InstructionsPanel(),
        ],
      ),
    );
  }
}
