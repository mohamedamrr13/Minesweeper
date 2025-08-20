import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:test/game/presentation/minesweeper_game_page.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowMinSize(const Size(600, 2000));
  runApp(
    DevicePreview(
      enabled: false,
      builder: (BuildContext context) {
        return const MineSweeper();
      },
    ),
  );
}

class MineSweeper extends StatelessWidget {
  const MineSweeper({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MinesweeperGamePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
