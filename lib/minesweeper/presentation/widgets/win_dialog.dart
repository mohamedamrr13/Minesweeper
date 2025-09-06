import 'package:flutter/material.dart';
import 'package:test/minesweeper/data/services/score_service.dart';
import '../../data/models/minesweeper_config.dart';
import '../../../utils/colors.dart';

class WinDialog extends StatefulWidget {
  final int timeInSeconds;
  final Difficulty difficulty;
  final HighscoreService highscoreService;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;

  const WinDialog({
    super.key,
    required this.timeInSeconds,
    required this.difficulty,
    required this.highscoreService,
    required this.onPlayAgain,
    required this.onGoHome,
  });

  @override
  State<WinDialog> createState() => _WinDialogState();
}

class _WinDialogState extends State<WinDialog> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isNewRecord = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkIfNewRecord();
    _loadPlayerName();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _checkIfNewRecord() {
    final bestTime =
        widget.highscoreService.getBestTimeForDifficulty(widget.difficulty);
    _isNewRecord =
        bestTime == null || widget.timeInSeconds < bestTime.timeInSeconds;
  }

  void _loadPlayerName() {
    final savedName = widget.highscoreService.getPlayerName();
    _nameController.text = savedName;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = widget.timeInSeconds ~/ 60;
    final seconds = widget.timeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _difficultyString {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  Color get _difficultyColor {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return const Color(0xFF4CAF50);
      case Difficulty.medium:
        return const Color(0xFFFF9800);
      case Difficulty.hard:
        return const Color(0xFFE53E3E);
    }
  }

  Future<void> _saveScore() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final playerName = _nameController.text.trim().isEmpty
          ? 'Anonymous'
          : _nameController.text.trim();

      await widget.highscoreService.addHighscore(
        difficulty: widget.difficulty,
        timeInSeconds: widget.timeInSeconds,
        playerName: playerName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(_isNewRecord ? 'New record saved!' : 'Score saved!'),
              ],
            ),
            backgroundColor:
                _isNewRecord ? Colors.amber : AppColors.primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save score: $e'),
            backgroundColor: AppColors.accentColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final safeAreaTop = mediaQuery.padding.top;
    final safeAreaBottom = mediaQuery.padding.bottom;

    // Calculate available height more precisely
    final availableHeight = screenHeight -
        safeAreaTop -
        safeAreaBottom -
        keyboardHeight -
        40; // Top and bottom margins (20 each)

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: availableHeight,
          maxWidth: 400,
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceColor,
                  AppColors.cardColor,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isNewRecord ? Colors.amber : _difficultyColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isNewRecord ? Colors.amber : _difficultyColor)
                      .withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight - 48, // Account for padding
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            buildHeader(),
                            const SizedBox(height: 16),
                            buildTimeDisplay(),
                            const SizedBox(height: 16),
                            buildDifficultyInfo(),
                            const SizedBox(height: 20),
                            buildNameInput(),
                            const SizedBox(height: 20),
                            buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Column(
      children: [
        if (_isNewRecord)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'NEW RECORD!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        SizedBox(height: _isNewRecord ? 12 : 0),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: const Icon(
            Icons.emoji_events,
            color: Colors.green,
            size: 40,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'CONGRATULATIONS!',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'You cleared the minefield! 🎉',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildTimeDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _difficultyColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'Your Time',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formattedTime,
            style: TextStyle(
              color: _difficultyColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDifficultyInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _difficultyColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _difficultyColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getDifficultyIcon(),
            color: _difficultyColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$_difficultyString Mode',
            style: TextStyle(
              color: _difficultyColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your name to save this score:',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: AppColors.textPrimary),
          maxLength: 20,
          buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) {
            return Text(
              '$currentLength${maxLength != null ? '/$maxLength' : ''}',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 12,
              ),
            );
          },
          decoration: InputDecoration(
            hintText: 'Anonymous',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.backgroundColor.withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _difficultyColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _difficultyColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _difficultyColor, width: 2),
            ),
            prefixIcon: Icon(Icons.person, color: _difficultyColor),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            isDense: true,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _saveScore(),
        ),
      ],
    );
  }

  Widget buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveScore,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isNewRecord ? Colors.amber : _difficultyColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isNewRecord ? 'Save New Record!' : 'Save Score',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onPlayAgain,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.textSecondary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Play Again'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onGoHome,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Home'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData getDifficultyIcon() {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied;
      case Difficulty.medium:
        return Icons.sentiment_neutral;
      case Difficulty.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}
