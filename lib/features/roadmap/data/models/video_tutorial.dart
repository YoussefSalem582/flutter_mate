/// Model for video tutorials associated with lessons
class VideoTutorial {
  final String id;
  final String lessonId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl; // YouTube URL or video ID
  final int durationMinutes;
  final List<String> topics;

  const VideoTutorial({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.durationMinutes,
    this.topics = const [],
  });

  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }

  // Extract YouTube video ID from URL
  String? get youtubeVideoId {
    if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
      // Handle different YouTube URL formats
      final uri = Uri.tryParse(videoUrl);
      if (uri == null) return null;

      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      } else if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      }
    }
    // Assume it's already a video ID
    return videoUrl;
  }
}
