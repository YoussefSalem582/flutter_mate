import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../data/models/lesson.dart';
import '../../../../achievements/controller/achievement_controller.dart';

/// Learning resources section with clickable links.
///
/// Features:
/// - Resource cards with link icons
/// - Opens URLs in external browser
/// - Copy URL dialog as fallback
/// - Achievement tracking on resource open
/// - Tap animation and feedback
class LearningResourcesWidget extends StatelessWidget {
  final Lesson lesson;

  const LearningResourcesWidget({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    if (lesson.resources.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simple header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.library_books_rounded,
                color: Colors.grey[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Learning Resources',
                  style: AppTextStyles.h3.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${lesson.resources.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Resource cards with enhanced styling
        ...lesson.resources.entries.map((entry) {
          final index = lesson.resources.keys.toList().indexOf(entry.key);
          final resourceIcon = _getResourceIcon(entry.key, entry.value);
          final resourceColor = _getResourceColor(entry.key, entry.value);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark
                      ? resourceColor.withOpacity(0.08)
                      : resourceColor.withOpacity(0.05),
                  isDark ? resourceColor.withOpacity(0.05) : Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: resourceColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: resourceColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openResource(entry.key, entry.value),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      // Enhanced icon with badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  resourceColor.withOpacity(0.2),
                                  resourceColor.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: resourceColor.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              resourceIcon,
                              color: resourceColor,
                              size: 28,
                            ),
                          ),
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: resourceColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.open_in_new_rounded,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18),

                      // Resource info with enhanced styling
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 14,
                                  color: resourceColor.withOpacity(0.8),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _getResourceDescription(
                                        entry.key, entry.value),
                                    style: AppTextStyles.caption.copyWith(
                                      color: resourceColor.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Arrow indicator
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: resourceColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: resourceColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: 100 * index))
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1);
        }),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  /// Get appropriate icon for resource type
  IconData _getResourceIcon(String title, String url) {
    final lowerTitle = title.toLowerCase();
    final lowerUrl = url.toLowerCase();

    if (lowerTitle.contains('video') ||
        lowerUrl.contains('youtube') ||
        lowerUrl.contains('vimeo')) {
      return Icons.play_circle_rounded;
    } else if (lowerTitle.contains('doc') ||
        lowerTitle.contains('guide') ||
        lowerUrl.contains('docs.')) {
      return Icons.description_rounded;
    } else if (lowerTitle.contains('tutorial') ||
        lowerTitle.contains('learn')) {
      return Icons.school_rounded;
    } else if (lowerTitle.contains('github') || lowerUrl.contains('github')) {
      return Icons.code_rounded;
    } else if (lowerTitle.contains('article') || lowerTitle.contains('blog')) {
      return Icons.article_rounded;
    } else if (lowerTitle.contains('book') || lowerTitle.contains('ebook')) {
      return Icons.menu_book_rounded;
    }
    return Icons.link_rounded;
  }

  /// Get appropriate color for resource type
  Color _getResourceColor(String title, String url) {
    final lowerTitle = title.toLowerCase();
    final lowerUrl = url.toLowerCase();

    if (lowerTitle.contains('video') || lowerUrl.contains('youtube')) {
      return Colors.red;
    } else if (lowerTitle.contains('doc') || lowerTitle.contains('guide')) {
      return AppColors.info;
    } else if (lowerTitle.contains('tutorial')) {
      return Colors.purple;
    } else if (lowerTitle.contains('github') || lowerUrl.contains('github')) {
      return Colors.black87;
    } else if (lowerTitle.contains('article')) {
      return Colors.orange;
    }
    return AppColors.info;
  }

  /// Get description based on resource type
  String _getResourceDescription(String title, String url) {
    final lowerTitle = title.toLowerCase();
    final lowerUrl = url.toLowerCase();

    if (lowerTitle.contains('video') || lowerUrl.contains('youtube')) {
      return 'Watch video tutorial';
    } else if (lowerTitle.contains('doc') || lowerTitle.contains('guide')) {
      return 'Read documentation';
    } else if (lowerTitle.contains('tutorial')) {
      return 'Follow step-by-step';
    } else if (lowerTitle.contains('github')) {
      return 'View source code';
    } else if (lowerTitle.contains('article')) {
      return 'Read article';
    }
    return 'Open external link';
  }

  /// Open resource URL in browser with achievement tracking
  Future<void> _openResource(String title, String url) async {
    final uri = Uri.parse(url);

    try {
      // Track resource opening for achievements
      final achievementController = Get.find<AchievementController>();
      await achievementController.onResourceOpened();

      // Launch URL in external browser
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        Get.snackbar(
          'Opening Resource',
          'Opening "$title"...',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        // If launch returns false, show copy dialog
        _showCopyUrlDialog(title, url);
      }
    } catch (e) {
      // On any error, show copy dialog as fallback
      print('Error launching URL: $e');
      _showCopyUrlDialog(title, url);
    }
  }

  /// Show dialog to manually copy URL
  void _showCopyUrlDialog(String title, String url) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.link_rounded,
                  color: AppColors.info,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                title,
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Copy the URL and open it in your browser',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // URL display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: SelectableText(
                  url,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: url));
                        Get.back();
                        Get.snackbar(
                          'Copied!',
                          'URL copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppColors.success,
                          colorText: Colors.white,
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Copy URL'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.info),
                        foregroundColor: AppColors.info,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
