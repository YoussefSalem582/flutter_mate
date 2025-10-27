import '../models/video_tutorial.dart';

abstract class VideoTutorialRepository {
  List<VideoTutorial> getAllVideos();
  List<VideoTutorial> getVideosByLesson(String lessonId);
  VideoTutorial? getVideoById(String id);
}

class VideoTutorialRepositoryImpl implements VideoTutorialRepository {
  final List<VideoTutorial> _videos = const [
    // Introduction to Flutter
    VideoTutorial(
      id: 'v1',
      lessonId: 'b1',
      title: 'What is Flutter? Complete Beginner Guide',
      description: 'Learn what Flutter is, why it\'s popular, and how it works',
      thumbnailUrl: 'https://img.youtube.com/vi/1xipg02Wu8s/maxresdefault.jpg',
      videoUrl: '1xipg02Wu8s', // Fireship - Flutter in 100 Seconds
      durationMinutes: 2,
      topics: ['Flutter basics', 'Cross-platform', 'Widgets'],
    ),
    VideoTutorial(
      id: 'v2',
      lessonId: 'b1',
      title: 'Flutter Tutorial for Beginners',
      description: 'Your first Flutter app - Step by step guide',
      thumbnailUrl: 'https://img.youtube.com/vi/1ukSR1GRtMU/maxresdefault.jpg',
      videoUrl: '1ukSR1GRtMU', // FreeCodeCamp - Flutter Course
      durationMinutes: 37,
      topics: ['First app', 'Widgets', 'Hot reload'],
    ),

    // Setup Development Environment
    VideoTutorial(
      id: 'v3',
      lessonId: 'b2',
      title: 'How to Install Flutter - Complete Guide',
      description: 'Install Flutter SDK on Windows, Mac, and Linux',
      thumbnailUrl: 'https://img.youtube.com/vi/VFDbZk2xhO4/maxresdefault.jpg',
      videoUrl: 'VFDbZk2xhO4',
      durationMinutes: 15,
      topics: ['Installation', 'Setup', 'Flutter doctor'],
    ),

    // Understanding Widgets
    VideoTutorial(
      id: 'v4',
      lessonId: 'b3',
      title: 'Flutter Widgets Explained',
      description: 'Deep dive into StatelessWidget and StatefulWidget',
      thumbnailUrl: 'https://img.youtube.com/vi/wE7khGHVkYY/maxresdefault.jpg',
      videoUrl: 'wE7khGHVkYY',
      durationMinutes: 12,
      topics: ['Widgets', 'StatelessWidget', 'StatefulWidget'],
    ),

    // Layout Basics
    VideoTutorial(
      id: 'v5',
      lessonId: 'b4',
      title: 'Flutter Layouts - Row, Column, Container',
      description: 'Master basic layouts in Flutter',
      thumbnailUrl: 'https://img.youtube.com/vi/RJEnTRBxaSg/maxresdefault.jpg',
      videoUrl: 'RJEnTRBxaSg',
      durationMinutes: 20,
      topics: ['Row', 'Column', 'Container', 'Padding'],
    ),

    // State Management Basics
    VideoTutorial(
      id: 'v6',
      lessonId: 'b5',
      title: 'Flutter State Management with setState',
      description: 'Learn how to manage state in Flutter apps',
      thumbnailUrl: 'https://img.youtube.com/vi/AqCMFXEmf3w/maxresdefault.jpg',
      videoUrl: 'AqCMFXEmf3w',
      durationMinutes: 18,
      topics: ['State', 'setState', 'Stateful widgets'],
    ),

    // Navigation and Routing
    VideoTutorial(
      id: 'v7',
      lessonId: 'b6',
      title: 'Flutter Navigation & Routing Tutorial',
      description: 'Navigate between screens in Flutter',
      thumbnailUrl: 'https://img.youtube.com/vi/b2fgMCeSNpY/maxresdefault.jpg',
      videoUrl: 'b2fgMCeSNpY',
      durationMinutes: 25,
      topics: ['Navigation', 'Routes', 'Navigator'],
    ),

    // Forms and User Input
    VideoTutorial(
      id: 'v8',
      lessonId: 'b7',
      title: 'Flutter Forms - Complete Guide',
      description: 'Handle user input with forms and validation',
      thumbnailUrl: 'https://img.youtube.com/vi/S0Nxo-8m1GA/maxresdefault.jpg',
      videoUrl: 'S0Nxo-8m1GA',
      durationMinutes: 30,
      topics: ['Forms', 'Validation', 'TextFormField'],
    ),

    // Working with Lists
    VideoTutorial(
      id: 'v9',
      lessonId: 'b8',
      title: 'ListView & GridView in Flutter',
      description: 'Display scrollable lists and grids',
      thumbnailUrl: 'https://img.youtube.com/vi/KJpkjHGiI5A/maxresdefault.jpg',
      videoUrl: 'KJpkjHGiI5A',
      durationMinutes: 22,
      topics: ['ListView', 'GridView', 'ScrollView'],
    ),
  ];

  @override
  List<VideoTutorial> getAllVideos() {
    return _videos;
  }

  @override
  List<VideoTutorial> getVideosByLesson(String lessonId) {
    return _videos.where((v) => v.lessonId == lessonId).toList();
  }

  @override
  VideoTutorial? getVideoById(String id) {
    try {
      return _videos.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }
}
