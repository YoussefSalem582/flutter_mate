import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../controller/study_timer_controller.dart';

/// Interactive persistent study timer widget.
///
/// Features:
/// - Persistent timer that continues even when app is closed
/// - Real-time timer display (HH:MM:SS format)
/// - Play/Pause functionality
/// - Reset button
/// - Elegant gradient design
/// - Per-lesson time tracking
/// - Auto-completion when target duration is reached
class StudyTimerWidget extends StatelessWidget {
  final String lessonId;
  final int? durationMinutes;

  const StudyTimerWidget({
    super.key,
    required this.lessonId,
    this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    // Get or create timer controller
    final timerController = Get.put(StudyTimerController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize timer for this lesson
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (timerController.currentLessonId.value != lessonId) {
        timerController.startTimer(lessonId, durationMinutes: durationMinutes);
      }
    });

    return Obx(() {
      final isRunning = timerController.isRunning.value;
      final elapsedSeconds = timerController.elapsedSeconds.value;
      final targetSeconds = timerController.targetDuration.value;
      final hasTarget = targetSeconds > 0;
      final progress =
          hasTarget ? (elapsedSeconds / targetSeconds).clamp(0.0, 1.0) : 0.0;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.withOpacity(0.12)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.grey.withOpacity(0.25)
                : Colors.grey.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Simple timer icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF42A5F5).withOpacity(0.15)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.timer_rounded,
                    color: isDark ? const Color(0xFF42A5F5) : Colors.grey[700],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Timer display
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Study Time',
                            style: AppTextStyles.bodySmall.copyWith(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (isRunning) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF66BB6A).withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Active',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark
                                      ? const Color(0xFF66BB6A)
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(elapsedSeconds),
                        style: AppTextStyles.h1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[100] : Colors.grey[800],
                          fontFeatures: [const FontFeature.tabularFigures()],
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // Control buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Play/Pause button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => timerController.toggleTimer(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF42A5F5).withOpacity(0.15)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF42A5F5).withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 28,
                            color: isDark
                                ? const Color(0xFF42A5F5)
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Reset button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => timerController.resetTimer(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 28,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Persistence indicator
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Auto-saved',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
                if (hasTarget)
                  Text(
                    'Target: ${_formatTime(targetSeconds)}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),

            // Progress bar (if target duration is set)
            if (hasTarget) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? Colors.grey.withOpacity(0.25)
                      : Colors.grey.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0
                        ? (isDark ? const Color(0xFF66BB6A) : Colors.green)
                        : (isDark
                            ? const Color(0xFF42A5F5)
                            : Colors.grey[700]!),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% complete',
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2);
    });
  }

  /// Format seconds to readable time
  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
