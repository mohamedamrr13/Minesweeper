import 'package:flutter/material.dart';
import 'package:test/minesweeper/data/models/minesweeper_config.dart';
import 'package:test/minesweeper/data/services/score_service.dart';

import 'package:test/minesweeper/presentation/minesweeper_game_page.dart';
import 'package:test/minesweeper/presentation/score_page.dart';
import 'package:test/utils/colors.dart';

class HomePage extends StatefulWidget {
  final HighscoreService? highscoreService;

  const HomePage({super.key, this.highscoreService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  late Animation<double> _backgroundRotation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Background rotation animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _backgroundRotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
    _backgroundController.repeat();

    // Pulse animation for mines
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Floating animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
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
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (widget.highscoreService != null)
            IconButton(
              icon:
                  const Icon(Icons.emoji_events, color: AppColors.textPrimary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HighscorePage(
                    highscoreService: widget.highscoreService!,
                  ),
                ),
              ),
              tooltip: 'View Highscores',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Enhanced animated background
          _buildEnhancedBackground(),

          // Main content with scrolling
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Difficulty selection section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.borderDark.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Select Your Challenge',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Easy difficulty button
                        _buildEnhancedDifficultyCard(
                          context,
                          'Easy',
                          '6×6 Grid • 6 Mines',
                          'Perfect for beginners',
                          Icons.sentiment_satisfied,
                          const Color(0xFF4CAF50),
                          Difficulty.easy,
                        ),
                        const SizedBox(height: 16),

                        // Medium difficulty button
                        _buildEnhancedDifficultyCard(
                          context,
                          'Medium',
                          '7×7 Grid • 9 Mines',
                          'Balanced challenge',
                          Icons.sentiment_neutral,
                          const Color(0xFFFF9800),
                          Difficulty.medium,
                        ),
                        const SizedBox(height: 16),

                        // Hard difficulty button
                        _buildEnhancedDifficultyCard(
                          context,
                          'Hard',
                          '8×8 Grid • 15 Mines',
                          'For experienced players',
                          Icons.sentiment_very_dissatisfied,
                          const Color(0xFFE53E3E),
                          Difficulty.hard,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Enhanced leaderboard section with dynamic content
                  _buildLeaderboardSection(),

                  // Add bottom padding for better scrolling
                  const SizedBox(height: 16),
                  const Center(
                      child: Text(
                    "MADE BY MOHAMEDAMR",
                    style: TextStyle(fontSize: 24, color: AppColors.white),
                  ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardSection() {
    if (widget.highscoreService == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderDark.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '🚧 Storage Unavailable 🚧',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Scores cannot be saved in this session',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final hasScores = widget.highscoreService!.hasHighscores();
    final bestTimes = widget.highscoreService!.getAllBestTimes();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDark.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Best Times',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasScores) ...[
            const Text(
              '🏁 No records yet! 🏁',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Play some games to set your personal bests',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            ...Difficulty.values.map((difficulty) {
              final bestTime = bestTimes[difficulty];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getDifficultyIcon(difficulty),
                          color: _getDifficultyColor(difficulty),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getDifficultyName(difficulty),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      bestTime?.formattedTime ?? '--:--',
                      style: TextStyle(
                        color: bestTime != null
                            ? Colors.amber
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HighscorePage(
                      highscoreService: widget.highscoreService!,
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber,
                  side: const BorderSide(color: Colors.amber),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'View All Scores',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedBackground() {
    return Stack(
      children: [
        // Base gradient background
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                AppColors.backgroundColor.withOpacity(0.8),
                const Color(0xFF1A1A2E).withOpacity(0.9),
                const Color(0xFF16213E).withOpacity(0.95),
              ],
            ),
          ),
        ),

        // Animated geometric pattern
        AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _backgroundRotation.value * 2 * 3.14159,
              child: CustomPaint(
                painter: GeometricBackgroundPainter(),
                size: Size.infinite,
              ),
            );
          },
        ),

        // Floating mine particles (safe positioning)
        ...List.generate(6, (index) => _buildFloatingMine(index)),

        // Gradient overlay for content readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.backgroundColor.withOpacity(0.3),
                AppColors.backgroundColor.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingMine(int index) {
    // Safe positioning within screen bounds
    final positions = [
      const Offset(0.1, 0.2),
      const Offset(0.8, 0.15),
      const Offset(0.2, 0.7),
      const Offset(0.9, 0.6),
      const Offset(0.15, 0.45),
      const Offset(0.75, 0.8),
    ];

    final position = positions[index % positions.length];

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * position.dx,
          top: MediaQuery.of(context).size.height * position.dy,
          child: Transform.scale(
            scale: 0.5 + (_pulseAnimation.value * 0.3),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.4 * _pulseAnimation.value),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2 * _pulseAnimation.value),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '💣',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(_pulseAnimation.value),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedDifficultyCard(
    BuildContext context,
    String title,
    String subtitle,
    String description,
    IconData icon,
    Color iconColor,
    Difficulty difficulty,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startGame(context, difficulty),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceColor.withOpacity(0.9),
                  AppColors.surfaceColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: iconColor.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        iconColor.withOpacity(0.3),
                        iconColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.play_arrow, color: iconColor, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, Difficulty difficulty) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MinesweeperGamePage(
          initialDifficulty: difficulty,
          highscoreService: widget.highscoreService,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
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
}

class GeometricBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Create a grid pattern with hexagonal elements
    final gridSize = 80.0;
    final rows = (size.height / gridSize).ceil() + 2;
    final cols = (size.width / gridSize).ceil() + 2;

    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        final x = col * gridSize + (row.isEven ? 0 : gridSize / 2);
        final y = row * gridSize * 0.866; // Hexagonal spacing

        // Vary opacity and color based on position
        final distance =
            ((x - size.width / 2).abs() + (y - size.height / 2).abs()) /
                (size.width + size.height);
        final opacity = (0.3 - distance * 0.2).clamp(0.0, 0.3);

        if (opacity > 0) {
          paint.color = AppColors.borderDark.withOpacity(opacity);

          // Draw hexagonal cells
          _drawHexagon(canvas, paint, Offset(x, y), 25);

          // Occasionally draw mine symbols
          if ((row + col) % 7 == 0) {
            paint.style = PaintingStyle.fill;
            paint.color = Colors.red.withOpacity(opacity * 2);
            canvas.drawCircle(Offset(x, y), 8, paint);
            paint.style = PaintingStyle.stroke;
          }
        }
      }
    }
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60.0) * (3.14159 / 180.0);
      final x = center.dx + radius * [1.0, 0.5, -0.5, -1.0, -0.5, 0.5][i];
      final y =
          center.dy + radius * [0.0, 0.866, 0.866, 0.0, -0.866, -0.866][i];

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
