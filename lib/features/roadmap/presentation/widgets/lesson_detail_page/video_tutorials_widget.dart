import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../data/models/video_tutorial.dart';
import '../../../data/repositories/video_tutorial_repository.dart';

/// Video tutorials horizontal scrolling list.
///
/// Features:
/// - Horizontal scrollable video cards
/// - YouTube thumbnails with duration overlay
/// - Play button overlay
/// - Opens YouTube app or browser
/// - Dark mode support
class VideoTutorialsWidget extends StatelessWidget {
  final String lessonId;
  final bool isDark;

  const VideoTutorialsWidget({
    super.key,
    required this.lessonId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final videoRepo = Get.find<VideoTutorialRepository>();
    final videos = videoRepo.getVideosByLesson(lessonId);

    if (videos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.play_circle_outline, size: 24),
            const SizedBox(width: 8),
            Text(
              'Video Tutorials',
              style: AppTextStyles.h3.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Video cards list
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = videos[index];
              return _buildVideoCard(video);
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  /// Build a single video card
  Widget _buildVideoCard(VideoTutorial video) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openYouTubeVideo(video),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play button
            Stack(
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(video.thumbnailUrl),
                      fit: BoxFit.cover,
                      onError: (error, stackTrace) {},
                    ),
                  ),
                ),
                // Duration overlay
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.formattedDuration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Play button
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Video info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Open YouTube video in app or browser
  Future<void> _openYouTubeVideo(VideoTutorial video) async {
    final videoId = video.youtubeVideoId;
    if (videoId == null) {
      Get.snackbar(
        'Error',
        'Invalid video URL',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Try YouTube app first, fallback to browser
    final youtubeAppUrl = Uri.parse('vnd.youtube://$videoId');
    final youtubeBrowserUrl = Uri.parse(
      'https://www.youtube.com/watch?v=$videoId',
    );

    try {
      final launched = await launchUrl(
        youtubeAppUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        await launchUrl(
          youtubeBrowserUrl,
          mode: LaunchMode.externalApplication,
        );
      }

      Get.snackbar(
        'Opening Video',
        video.title,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.play_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open video. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
