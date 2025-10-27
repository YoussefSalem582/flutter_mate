import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';

/// Interactive study timer widget for tracking lesson study time.
///
/// Features:
/// - Real-time timer display (HH:MM:SS format)
/// - Play/Pause functionality
/// - Reset button
/// - Gradient background with animated color changes
/// - Tabular figures for consistent number width
class StudyTimerWidget extends StatefulWidget {
  const StudyTimerWidget({super.key});

  @override
  State<StudyTimerWidget> createState() => _StudyTimerWidgetState();
}

class _StudyTimerWidgetState extends State<StudyTimerWidget> {
  int _studySeconds = 0;
  bool _isTimerRunning = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  /// Start the timer loop
  void _startTimer() {
    _isTimerRunning = true;
    Future.doWhile(() async {
      if (!_isTimerRunning || !mounted) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isTimerRunning) {
        setState(() => _studySeconds++);
      }
      return _isTimerRunning && mounted;
    });
  }

  /// Toggle timer between play and pause
  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
      if (_isTimerRunning) {
        _startTimer();
      }
    });
  }

  /// Reset timer to zero and start again
  void _resetTimer() {
    setState(() {
      _studySeconds = 0;
      _isTimerRunning = true;
    });
    _startTimer();
  }

  /// Format seconds to HH:MM:SS or MM:SS
  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _isTimerRunning = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.info.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          // Timer icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isTimerRunning
                  ? AppColors.success.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer_rounded,
              color: _isTimerRunning ? AppColors.success : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Timer display
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study Time',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(_studySeconds),
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isTimerRunning ? AppColors.success : Colors.grey,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          // Play/Pause button
          IconButton(
            onPressed: _toggleTimer,
            icon: Icon(
              _isTimerRunning ? Icons.pause_circle : Icons.play_circle,
              size: 32,
            ),
            color: _isTimerRunning ? AppColors.warning : AppColors.success,
            tooltip: _isTimerRunning ? 'Pause Timer' : 'Resume Timer',
          ),

          // Reset button
          IconButton(
            onPressed: _resetTimer,
            icon: const Icon(Icons.refresh_rounded, size: 28),
            color: AppColors.info,
            tooltip: 'Reset Timer',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2);
  }
}
