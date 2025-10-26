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
      resources: {
        'Official Flutter Docs': 'https://flutter.dev/docs',
        'Flutter Introduction Video':
            'https://www.youtube.com/watch?v=fq4N0hgOWzU',
      },
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
      resources: {
        'Flutter Installation Guide':
            'https://flutter.dev/docs/get-started/install',
        'IDE Setup Tutorial': 'https://flutter.dev/docs/get-started/editor',
      },
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
      resources: {
        'Dart Language Tour': 'https://dart.dev/guides/language/language-tour',
        'DartPad for Practice': 'https://dartpad.dev',
      },
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
      resources: {
        'Flutter Getting Started':
            'https://flutter.dev/docs/get-started/codelab',
        'First App Tutorial': 'https://flutter.dev/docs/get-started/test-drive',
      },
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
      resources: {
        'Widget Catalog': 'https://flutter.dev/docs/development/ui/widgets',
        'Flutter Widget 101':
            'https://flutter.dev/docs/development/ui/widgets-intro',
      },
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
      resources: {
        'Layout Guide': 'https://flutter.dev/docs/development/ui/layout',
        'Material Design Specs': 'https://material.io/design',
      },
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
      resources: {
        'Form Validation': 'https://flutter.dev/docs/cookbook/forms/validation',
        'Gesture Detection Guide':
            'https://flutter.dev/docs/development/ui/advanced/gestures',
      },
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
      resources: {
        'Navigation Guide':
            'https://flutter.dev/docs/development/ui/navigation',
        'Routing Best Practices':
            'https://flutter.dev/docs/cookbook/navigation',
      },
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
      resources: {
        'State Management Overview':
            'https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro',
        'Flutter Architecture Patterns':
            'https://flutter.dev/docs/development/data-and-backend/state-mgmt/options',
      },
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
      resources: {
        'Provider Documentation': 'https://pub.dev/packages/provider',
        'Riverpod Guide':
            'https://riverpod.dev/docs/introduction/getting_started',
      },
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
      resources: {
        'HTTP Package': 'https://pub.dev/packages/http',
        'JSON Serialization':
            'https://flutter.dev/docs/development/data-and-backend/json',
      },
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
      resources: {
        'SQFlite Documentation': 'https://pub.dev/packages/sqflite',
        'Database Best Practices':
            'https://flutter.dev/docs/cookbook/persistence/sqlite',
      },
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
      resources: {
        'Animation Guide': 'https://flutter.dev/docs/development/ui/animations',
        'Animation Examples':
            'https://flutter.dev/docs/development/ui/animations/tutorial',
      },
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
      resources: {
        'FlutterFire Documentation': 'https://firebase.flutter.dev',
        'Firebase Setup Guide':
            'https://firebase.google.com/docs/flutter/setup',
      },
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
      resources: {
        'CustomPaint Guide':
            'https://api.flutter.dev/flutter/widgets/CustomPaint-class.html',
        'Canvas Examples':
            'https://flutter.dev/docs/cookbook/effects/custom-painter',
      },
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
      resources: {
        'Platform Channel Guide':
            'https://flutter.dev/docs/development/platform-integration/platform-channels',
        'Native Integration':
            'https://flutter.dev/docs/development/platform-integration',
      },
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
      resources: {
        'Clean Architecture':
            'https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html',
        'BLoC Pattern Guide': 'https://bloclibrary.dev/#/gettingstarted',
      },
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
      resources: {
        'Testing Guide': 'https://flutter.dev/docs/testing',
        'TDD Best Practices': 'https://flutter.dev/docs/cookbook/testing',
      },
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
      resources: {
        'Performance Guide': 'https://flutter.dev/docs/perf/best-practices',
        'DevTools Profiling':
            'https://flutter.dev/docs/development/tools/devtools/performance',
      },
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
      resources: {
        'Deployment Guide': 'https://flutter.dev/docs/deployment',
        'CI/CD Setup': 'https://flutter.dev/docs/deployment/cd',
      },
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
