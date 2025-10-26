import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson.dart';

abstract class LessonRepository {
  /// Get all lessons for a specific stage
  Future<List<Lesson>> getLessonsByStage(String stageId);

  /// Get a single lesson by ID
  Future<Lesson?> getLessonById(String lessonId);

  /// Mark a lesson as completed
  Future<void> markLessonCompleted(String lessonId);

  /// Check if a lesson is completed
  Future<bool> isLessonCompleted(String lessonId);

  /// Get completion status for all lessons
  Future<Map<String, bool>> getCompletionStatus();

  /// Get completion percentage for a stage
  Future<double> getStageCompletionPercentage(String stageId);
}

class LessonRepositoryImpl implements LessonRepository {
  static const _completedLessonsKey = 'completed_lessons';
  final SharedPreferences _prefs;

  LessonRepositoryImpl(this._prefs);

  // Mock lesson data - in a real app, this would come from an API
  final List<Lesson> _allLessons = const [
    // Beginner Stage Lessons
    Lesson(
      id: 'b1',
      stageId: 'beginner',
      title: 'What is Flutter?',
      description:
          'Learn the fundamentals of Flutter framework, its architecture, and why it\'s popular for cross-platform development.',
      duration: 15,
      difficulty: 'easy',
      order: 1,
      resources: ['Official Flutter Docs', 'Flutter Introduction Video'],
    ),
    Lesson(
      id: 'b2',
      stageId: 'beginner',
      title: 'Setup Development Environment',
      description:
          'Install Flutter SDK, Android Studio/VS Code, and configure your development environment for Flutter development.',
      duration: 30,
      difficulty: 'easy',
      order: 2,
      prerequisites: ['b1'],
      resources: ['Flutter Installation Guide', 'IDE Setup Tutorial'],
    ),
    Lesson(
      id: 'b3',
      stageId: 'beginner',
      title: 'Dart Basics',
      description:
          'Master Dart programming fundamentals: variables, data types, functions, and control flow structures.',
      duration: 45,
      difficulty: 'easy',
      order: 3,
      prerequisites: ['b2'],
      resources: ['Dart Language Tour', 'DartPad for Practice'],
    ),
    Lesson(
      id: 'b4',
      stageId: 'beginner',
      title: 'First Flutter App',
      description:
          'Create your first Flutter application, understand project structure, and run it on different platforms.',
      duration: 30,
      difficulty: 'easy',
      order: 4,
      prerequisites: ['b3'],
      resources: ['Flutter Getting Started', 'First App Tutorial'],
    ),
    Lesson(
      id: 'b5',
      stageId: 'beginner',
      title: 'Basic Widgets',
      description:
          'Learn about StatelessWidget, StatefulWidget, Container, Text, Row, Column, and other fundamental widgets.',
      duration: 40,
      difficulty: 'easy',
      order: 5,
      prerequisites: ['b4'],
      resources: ['Widget Catalog', 'Flutter Widget 101'],
    ),
    Lesson(
      id: 'b6',
      stageId: 'beginner',
      title: 'Layouts & Styling',
      description:
          'Master Flutter layouts with Flex widgets, Padding, Alignment, and styling widgets with themes and custom properties.',
      duration: 50,
      difficulty: 'medium',
      order: 6,
      prerequisites: ['b5'],
      resources: ['Layout Guide', 'Material Design Specs'],
    ),
    Lesson(
      id: 'b7',
      stageId: 'beginner',
      title: 'User Input & Forms',
      description:
          'Handle user input with TextField, Forms, validation, and gesture detection for interactive applications.',
      duration: 45,
      difficulty: 'medium',
      order: 7,
      prerequisites: ['b6'],
      resources: ['Form Validation', 'Gesture Detection Guide'],
    ),
    Lesson(
      id: 'b8',
      stageId: 'beginner',
      title: 'Navigation & Routing',
      description:
          'Implement navigation between screens using Navigator, named routes, and passing data between pages.',
      duration: 35,
      difficulty: 'medium',
      order: 8,
      prerequisites: ['b7'],
      resources: ['Navigation Guide', 'Routing Best Practices'],
    ),

    // Intermediate Stage Lessons
    Lesson(
      id: 'i1',
      stageId: 'intermediate',
      title: 'State Management Basics',
      description:
          'Understand state management concepts, setState, InheritedWidget, and when to use different state solutions.',
      duration: 45,
      difficulty: 'medium',
      order: 1,
      prerequisites: ['b8'],
      resources: ['State Management Overview', 'Flutter Architecture Patterns'],
    ),
    Lesson(
      id: 'i2',
      stageId: 'intermediate',
      title: 'Provider & Riverpod',
      description:
          'Master Provider and Riverpod for scalable state management in Flutter applications.',
      duration: 60,
      difficulty: 'medium',
      order: 2,
      prerequisites: ['i1'],
      resources: ['Provider Documentation', 'Riverpod Guide'],
    ),
    Lesson(
      id: 'i3',
      stageId: 'intermediate',
      title: 'API Integration',
      description:
          'Learn HTTP requests, REST APIs, JSON parsing, error handling, and async/await patterns in Flutter.',
      duration: 55,
      difficulty: 'medium',
      order: 3,
      prerequisites: ['i1'],
      resources: ['HTTP Package', 'JSON Serialization'],
    ),
    Lesson(
      id: 'i4',
      stageId: 'intermediate',
      title: 'Local Database (SQLite)',
      description:
          'Implement local data persistence using SQLite, CRUD operations, and database migrations.',
      duration: 50,
      difficulty: 'medium',
      order: 4,
      prerequisites: ['i3'],
      resources: ['SQFlite Documentation', 'Database Best Practices'],
    ),
    Lesson(
      id: 'i5',
      stageId: 'intermediate',
      title: 'Advanced Animations',
      description:
          'Create complex animations using AnimationController, Tween, and custom animation sequences.',
      duration: 65,
      difficulty: 'hard',
      order: 5,
      prerequisites: ['b8'],
      resources: ['Animation Guide', 'Animation Examples'],
    ),
    Lesson(
      id: 'i6',
      stageId: 'intermediate',
      title: 'Firebase Integration',
      description:
          'Integrate Firebase services: Authentication, Firestore, Cloud Storage, and Push Notifications.',
      duration: 70,
      difficulty: 'hard',
      order: 6,
      prerequisites: ['i3', 'i4'],
      resources: ['FlutterFire Documentation', 'Firebase Setup Guide'],
    ),

    // Advanced Stage Lessons
    Lesson(
      id: 'a1',
      stageId: 'advanced',
      title: 'Custom Painters',
      description:
          'Create custom graphics, shapes, and visualizations using CustomPaint and Canvas APIs.',
      duration: 60,
      difficulty: 'hard',
      order: 1,
      prerequisites: ['i5'],
      resources: ['CustomPaint Guide', 'Canvas Examples'],
    ),
    Lesson(
      id: 'a2',
      stageId: 'advanced',
      title: 'Platform Channels',
      description:
          'Communicate with native Android/iOS code using platform channels and method channels.',
      duration: 75,
      difficulty: 'hard',
      order: 2,
      prerequisites: ['i6'],
      resources: ['Platform Channel Guide', 'Native Integration'],
    ),
    Lesson(
      id: 'a3',
      stageId: 'advanced',
      title: 'Advanced Architecture',
      description:
          'Implement Clean Architecture, BLoC pattern, and MVVM in large-scale Flutter applications.',
      duration: 90,
      difficulty: 'hard',
      order: 3,
      prerequisites: ['i2'],
      resources: ['Clean Architecture', 'BLoC Pattern Guide'],
    ),
    Lesson(
      id: 'a4',
      stageId: 'advanced',
      title: 'Testing & TDD',
      description:
          'Master unit testing, widget testing, integration testing, and Test-Driven Development practices.',
      duration: 80,
      difficulty: 'hard',
      order: 4,
      prerequisites: ['a3'],
      resources: ['Testing Guide', 'TDD Best Practices'],
    ),
    Lesson(
      id: 'a5',
      stageId: 'advanced',
      title: 'Performance Optimization',
      description:
          'Profile and optimize Flutter apps: reduce jank, optimize builds, and improve app performance.',
      duration: 70,
      difficulty: 'hard',
      order: 5,
      prerequisites: ['a3'],
      resources: ['Performance Guide', 'DevTools Profiling'],
    ),
    Lesson(
      id: 'a6',
      stageId: 'advanced',
      title: 'Deployment & CI/CD',
      description:
          'Deploy apps to stores, set up continuous integration, automated testing, and release pipelines.',
      duration: 65,
      difficulty: 'hard',
      order: 6,
      prerequisites: ['a4'],
      resources: ['Deployment Guide', 'CI/CD Setup'],
    ),
  ];

  @override
  Future<List<Lesson>> getLessonsByStage(String stageId) async {
    return _allLessons.where((lesson) => lesson.stageId == stageId).toList();
  }

  @override
  Future<Lesson?> getLessonById(String lessonId) async {
    try {
      return _allLessons.firstWhere((lesson) => lesson.id == lessonId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> markLessonCompleted(String lessonId) async {
    final completedLessons = await _getCompletedLessons();
    if (!completedLessons.contains(lessonId)) {
      completedLessons.add(lessonId);
      await _prefs.setStringList(_completedLessonsKey, completedLessons);
    }
  }

  @override
  Future<bool> isLessonCompleted(String lessonId) async {
    final completedLessons = await _getCompletedLessons();
    return completedLessons.contains(lessonId);
  }

  @override
  Future<Map<String, bool>> getCompletionStatus() async {
    final completedLessons = await _getCompletedLessons();
    return {
      for (var lesson in _allLessons)
        lesson.id: completedLessons.contains(lesson.id),
    };
  }

  @override
  Future<double> getStageCompletionPercentage(String stageId) async {
    final stageLessons = await getLessonsByStage(stageId);
    if (stageLessons.isEmpty) return 0.0;

    final completedLessons = await _getCompletedLessons();
    final completedCount = stageLessons
        .where((lesson) => completedLessons.contains(lesson.id))
        .length;

    return completedCount / stageLessons.length;
  }

  Future<List<String>> _getCompletedLessons() async {
    return _prefs.getStringList(_completedLessonsKey) ?? [];
  }
}
