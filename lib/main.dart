import 'dart:io' show Platform;

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test/minesweeper/data/models/minesweeper_config.dart';
import 'package:test/minesweeper/data/models/score_model.dart';
import 'package:test/minesweeper/data/services/score_service.dart';
import 'package:test/minesweeper/presentation/home_page.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await initializeHive();

  // Set window size for desktop platforms
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    setWindowMinSize(const Size(600, 2000));
  }

  runApp(
    DevicePreview(
      enabled: false,
      builder: (BuildContext context) {
        return const MineSweeper();
      },
    ),
  );
}

Future<void> initializeHive() async {
  try {
    if (kIsWeb) {
      // For web, Hive will use IndexedDB
      await Hive.initFlutter();
    } else {
      // For mobile/desktop, use app documents directory
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    }

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HighscoreAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DifficultyAdapter());
    }

    print('Hive initialized successfully');
  } catch (e) {
    print('Failed to initialize Hive: $e');
    // You might want to show an error dialog here or use a fallback storage
  }
}

class MineSweeper extends StatefulWidget {
  const MineSweeper({super.key});

  @override
  State<MineSweeper> createState() => _MineSweeperState();
}

class _MineSweeperState extends State<MineSweeper> {
  late HighscoreService highscoreService;
  bool isInitialized = false;
  String? initializationError;

  @override
  void initState() {
    super.initState();
    initializeServices();
  }

  Future<void> initializeServices() async {
    try {
      highscoreService = HighscoreService();
      await highscoreService.initialize();
      setState(() {
        isInitialized = true;
      });
      print('HighscoreService initialized successfully');
    } catch (e) {
      setState(() {
        initializationError = e.toString();
        isInitialized = true; // Still allow app to run
      });
      print('Failed to initialize HighscoreService: $e');
    }
  }

  @override
  void dispose() {
    if (isInitialized) {
      highscoreService.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isInitialized
          ? HomePage(
              highscoreService:
                  initializationError == null ? highscoreService : null,
            )
          : const SplashScreen(),
      debugShowCheckedModeBanner: false,
      title: 'Minesweeper',
      theme: ThemeData(
        fontFamily: 'Minesweeper',
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53E3E)),
            ),
            SizedBox(height: 24),
            Text(
              'Initializing Minesweeper...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Setting up local storage',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Difficulty enum adapter for Hive
class DifficultyAdapter extends TypeAdapter<Difficulty> {
  @override
  final int typeId = 1;

  @override
  Difficulty read(BinaryReader reader) {
    final index = reader.readByte();
    return Difficulty.values[index];
  }

  @override
  void write(BinaryWriter writer, Difficulty obj) {
    writer.writeByte(obj.index);
  }
}
