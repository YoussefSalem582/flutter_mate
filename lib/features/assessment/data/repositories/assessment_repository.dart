import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assessment_question.dart';
import '../models/skill_assessment.dart';

class AssessmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _assessmentsCollection =>
      _firestore.collection('skill_assessments');
  CollectionReference get _questionsCollection =>
      _firestore.collection('assessment_questions');

  // ========== Assessment CRUD Operations ==========

  /// Save completed assessment to Firestore
  Future<void> saveAssessment(SkillAssessment assessment) async {
    try {
      await _assessmentsCollection.doc(assessment.id).set(assessment.toMap());
    } catch (e) {
      throw Exception('Failed to save assessment: $e');
    }
  }

  /// Get user's latest assessment
  Future<SkillAssessment?> getUserLatestAssessment(String userId) async {
    try {
      final querySnapshot = await _assessmentsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return SkillAssessment.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to fetch assessment: $e');
    }
  }

  /// Get all assessments for a user
  Future<List<SkillAssessment>> getUserAssessments(String userId) async {
    try {
      final querySnapshot = await _assessmentsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SkillAssessment.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch assessments: $e');
    }
  }

  /// Delete assessment
  Future<void> deleteAssessment(String assessmentId) async {
    try {
      await _assessmentsCollection.doc(assessmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete assessment: $e');
    }
  }

  // ========== Question Operations ==========

  /// Get all assessment questions
  /// Returns hardcoded questions if no questions exist in Firestore
  Future<List<AssessmentQuestion>> getAllQuestions() async {
    try {
      final querySnapshot = await _questionsCollection.get();

      if (querySnapshot.docs.isEmpty) {
        // Return hardcoded questions if database is empty
        return _getHardcodedQuestions();
      }

      return querySnapshot.docs
          .map((doc) =>
              AssessmentQuestion.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback to hardcoded questions on error
      return _getHardcodedQuestions();
    }
  }

  /// Get questions by category
  Future<List<AssessmentQuestion>> getQuestionsByCategory(
      String category) async {
    try {
      final querySnapshot = await _questionsCollection
          .where('category', isEqualTo: category)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Filter hardcoded questions by category
        return _getHardcodedQuestions()
            .where((q) => q.category == category)
            .toList();
      }

      return querySnapshot.docs
          .map((doc) =>
              AssessmentQuestion.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getHardcodedQuestions()
          .where((q) => q.category == category)
          .toList();
    }
  }

  /// Get questions by difficulty
  Future<List<AssessmentQuestion>> getQuestionsByDifficulty(
      String difficulty) async {
    final allQuestions = await getAllQuestions();
    return allQuestions.where((q) => q.difficulty == difficulty).toList();
  }

  /// Seed questions to Firestore (admin function)
  Future<void> seedQuestions() async {
    try {
      final questions = _getHardcodedQuestions();
      final batch = _firestore.batch();

      for (var question in questions) {
        batch.set(
          _questionsCollection.doc(question.id),
          question.toMap(),
        );
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to seed questions: $e');
    }
  }

  // ========== Hardcoded Questions ==========

  List<AssessmentQuestion> _getHardcodedQuestions() {
    return [
      // ===== Dart Basics =====
      AssessmentQuestion(
        id: 'q001',
        category: 'Dart Basics',
        difficulty: 'easy',
        question: 'What is the correct way to declare a variable in Dart?',
        options: [
          'var name = "John";',
          'variable name = "John";',
          'let name = "John";',
          'String name = "John";'
        ],
        correctAnswer: 0,
        points: 1,
        explanation:
            'Dart uses "var" for type inference or explicit type declaration.',
        tags: ['variables', 'syntax'],
      ),
      AssessmentQuestion(
        id: 'q002',
        category: 'Dart Basics',
        difficulty: 'easy',
        question: 'Which keyword is used to define a constant in Dart?',
        options: ['const', 'final', 'var', 'static'],
        correctAnswer: 0,
        points: 1,
        explanation:
            '"const" creates compile-time constants, while "final" creates runtime constants.',
        tags: ['constants', 'keywords'],
      ),
      AssessmentQuestion(
        id: 'q003',
        category: 'Dart Basics',
        difficulty: 'medium',
        question:
            'What is the difference between "==" and "identical()" in Dart?',
        options: [
          '"==" checks value equality, identical() checks reference equality',
          'They are the same',
          '"==" checks reference, identical() checks value',
          'identical() is deprecated'
        ],
        correctAnswer: 0,
        points: 2,
        explanation:
            '"==" compares values, while identical() checks if two objects are the same instance.',
        tags: ['operators', 'comparison'],
      ),

      // ===== Flutter Widgets =====
      AssessmentQuestion(
        id: 'q004',
        category: 'Widgets',
        difficulty: 'easy',
        question:
            'What is the difference between StatelessWidget and StatefulWidget?',
        options: [
          'StatelessWidget cannot change, StatefulWidget can rebuild with new state',
          'They are the same',
          'StatelessWidget is faster',
          'StatefulWidget cannot have children'
        ],
        correctAnswer: 0,
        points: 1,
        explanation:
            'StatelessWidget is immutable, StatefulWidget has mutable state that triggers rebuilds.',
        tags: ['widgets', 'state'],
      ),
      AssessmentQuestion(
        id: 'q005',
        category: 'Widgets',
        difficulty: 'medium',
        question: 'Which widget should you use for scrollable content?',
        options: ['ListView', 'Container', 'Column', 'Row'],
        correctAnswer: 0,
        points: 2,
        explanation: 'ListView is designed for scrollable lists of widgets.',
        tags: ['scrolling', 'lists'],
      ),
      AssessmentQuestion(
        id: 'q006',
        category: 'Widgets',
        difficulty: 'hard',
        question: 'When should you use const constructors in Flutter?',
        options: [
          'When the widget configuration never changes',
          'Always',
          'Never',
          'Only for StatefulWidgets'
        ],
        correctAnswer: 0,
        points: 3,
        explanation:
            'const constructors improve performance by reusing widget instances that never change.',
        tags: ['optimization', 'const'],
      ),

      // ===== State Management =====
      AssessmentQuestion(
        id: 'q007',
        category: 'State Management',
        difficulty: 'easy',
        question: 'What does setState() do in a StatefulWidget?',
        options: [
          'Triggers a rebuild of the widget',
          'Creates a new state',
          'Deletes the widget',
          'Nothing'
        ],
        correctAnswer: 0,
        points: 1,
        explanation:
            'setState() notifies the framework that the state has changed and triggers a rebuild.',
        tags: ['setState', 'lifecycle'],
      ),
      AssessmentQuestion(
        id: 'q008',
        category: 'State Management',
        difficulty: 'medium',
        question:
            'Which of these is a popular state management solution in Flutter?',
        options: ['GetX', 'StateManager', 'FlutterState', 'WidgetManager'],
        correctAnswer: 0,
        points: 2,
        explanation:
            'GetX, Provider, Bloc, and Riverpod are popular state management solutions.',
        tags: ['getx', 'architecture'],
      ),
      AssessmentQuestion(
        id: 'q009',
        category: 'State Management',
        difficulty: 'hard',
        question: 'What is the purpose of InheritedWidget?',
        options: [
          'To efficiently propagate information down the widget tree',
          'To create animations',
          'To handle routing',
          'To manage app themes'
        ],
        correctAnswer: 0,
        points: 3,
        explanation:
            'InheritedWidget allows data to be efficiently accessed by descendants without passing through constructors.',
        tags: ['InheritedWidget', 'data-flow'],
      ),

      // ===== Layouts =====
      AssessmentQuestion(
        id: 'q010',
        category: 'Layouts',
        difficulty: 'easy',
        question: 'Which widget arranges children horizontally?',
        options: ['Row', 'Column', 'Stack', 'ListView'],
        correctAnswer: 0,
        points: 1,
        explanation: 'Row arranges children horizontally, Column vertically.',
        tags: ['layout', 'flex'],
      ),
      AssessmentQuestion(
        id: 'q011',
        category: 'Layouts',
        difficulty: 'medium',
        question: 'What does mainAxisAlignment control in a Row?',
        options: [
          'Horizontal alignment',
          'Vertical alignment',
          'Widget size',
          'Widget order'
        ],
        correctAnswer: 0,
        points: 2,
        explanation:
            'mainAxisAlignment controls alignment along the main axis (horizontal for Row).',
        tags: ['alignment', 'Row'],
      ),
      AssessmentQuestion(
        id: 'q012',
        category: 'Layouts',
        difficulty: 'hard',
        question: 'When should you use Expanded vs Flexible?',
        options: [
          'Expanded forces child to fill available space, Flexible allows shrinking',
          'They are identical',
          'Flexible is deprecated',
          'Expanded only works in Column'
        ],
        correctAnswer: 0,
        points: 3,
        explanation:
            'Expanded (with flex=1 and fit=tight) fills space, Flexible allows flexible sizing.',
        tags: ['flex', 'sizing'],
      ),

      // ===== Navigation =====
      AssessmentQuestion(
        id: 'q013',
        category: 'Navigation',
        difficulty: 'easy',
        question: 'How do you navigate to a new screen in Flutter?',
        options: [
          'Navigator.push()',
          'Navigator.next()',
          'Screen.navigate()',
          'Route.go()'
        ],
        correctAnswer: 0,
        points: 1,
        explanation:
            'Navigator.push() pushes a new route onto the navigation stack.',
        tags: ['navigation', 'routes'],
      ),
      AssessmentQuestion(
        id: 'q014',
        category: 'Navigation',
        difficulty: 'medium',
        question:
            'What is the difference between Navigator.push() and Navigator.pushReplacement()?',
        options: [
          'pushReplacement replaces current route',
          'They are the same',
          'pushReplacement is faster',
          'push is deprecated'
        ],
        correctAnswer: 0,
        points: 2,
        explanation:
            'pushReplacement removes the current route before pushing the new one.',
        tags: ['navigator', 'stack'],
      ),
      AssessmentQuestion(
        id: 'q015',
        category: 'Navigation',
        difficulty: 'hard',
        question: 'What is named routing in Flutter?',
        options: [
          'Defining routes with string identifiers',
          'Naming widgets',
          'A deprecated feature',
          'Automatic route generation'
        ],
        correctAnswer: 0,
        points: 3,
        explanation:
            'Named routing uses string identifiers (like "/home") to navigate instead of widget constructors.',
        tags: ['routes', 'named-routes'],
      ),

      // ===== Async Programming =====
      AssessmentQuestion(
        id: 'q016',
        category: 'Async Programming',
        difficulty: 'easy',
        question: 'What keyword makes a function asynchronous in Dart?',
        options: ['async', 'await', 'future', 'promise'],
        correctAnswer: 0,
        points: 1,
        explanation:
            'The "async" keyword marks a function as asynchronous, allowing use of "await".',
        tags: ['async', 'futures'],
      ),
      AssessmentQuestion(
        id: 'q017',
        category: 'Async Programming',
        difficulty: 'medium',
        question: 'What does the "await" keyword do?',
        options: [
          'Pauses execution until Future completes',
          'Creates a new Future',
          'Cancels a Future',
          'Makes code synchronous'
        ],
        correctAnswer: 0,
        points: 2,
        explanation:
            'await pauses execution until the Future completes and returns the result.',
        tags: ['await', 'futures'],
      ),
      AssessmentQuestion(
        id: 'q018',
        category: 'Async Programming',
        difficulty: 'hard',
        question: 'What is the difference between Future and Stream?',
        options: [
          'Future returns one value, Stream returns multiple values over time',
          'They are identical',
          'Stream is deprecated',
          'Future is faster'
        ],
        correctAnswer: 0,
        points: 3,
        explanation:
            'Future represents a single future value, Stream represents a sequence of values.',
        tags: ['future', 'stream'],
      ),

      // ===== APIs & Data =====
      AssessmentQuestion(
        id: 'q019',
        category: 'APIs & Data',
        difficulty: 'easy',
        question:
            'Which package is commonly used for HTTP requests in Flutter?',
        options: ['http', 'request', 'api', 'network'],
        correctAnswer: 0,
        points: 1,
        explanation:
            'The "http" package is the standard Dart package for making HTTP requests.',
        tags: ['http', 'api'],
      ),
      AssessmentQuestion(
        id: 'q020',
        category: 'APIs & Data',
        difficulty: 'medium',
        question: 'How do you parse JSON in Dart?',
        options: ['jsonDecode()', 'JSON.parse()', 'parseJson()', 'toJson()'],
        correctAnswer: 0,
        points: 2,
        explanation:
            'jsonDecode() from dart:convert converts JSON strings to Dart objects.',
        tags: ['json', 'parsing'],
      ),
      AssessmentQuestion(
        id: 'q021',
        category: 'APIs & Data',
        difficulty: 'hard',
        question:
            'What is the recommended way to handle API errors in Flutter?',
        options: [
          'Try-catch blocks with specific error types',
          'Ignore errors',
          'Only use print statements',
          'Crash the app'
        ],
        correctAnswer: 0,
        points: 3,
        explanation:
            'Proper error handling with try-catch and specific error types provides better user experience.',
        tags: ['error-handling', 'best-practices'],
      ),

      // ===== Firebase =====
      AssessmentQuestion(
        id: 'q022',
        category: 'Firebase',
        difficulty: 'easy',
        question:
            'Which Firebase service provides real-time database capabilities?',
        options: [
          'Firestore',
          'FirebaseCore',
          'FirebaseAuth',
          'FirebaseStorage'
        ],
        correctAnswer: 0,
        points: 1,
        explanation:
            'Cloud Firestore is Firebase\'s NoSQL document database with real-time sync.',
        tags: ['firestore', 'database'],
      ),
      AssessmentQuestion(
        id: 'q023',
        category: 'Firebase',
        difficulty: 'medium',
        question: 'How do you listen to real-time updates in Firestore?',
        options: [
          'snapshots() stream',
          'get() method',
          'listen() method',
          'watch() method'
        ],
        correctAnswer: 0,
        points: 2,
        explanation:
            'The snapshots() method returns a Stream that emits data whenever the document/collection changes.',
        tags: ['firestore', 'streams'],
      ),
      AssessmentQuestion(
        id: 'q024',
        category: 'Firebase',
        difficulty: 'hard',
        question: 'What are Firestore security rules used for?',
        options: [
          'Control read/write access to data',
          'Validate data types',
          'Index data',
          'Backup data'
        ],
        correctAnswer: 0,
        points: 3,
        explanation:
            'Security rules define who can read/write data and under what conditions.',
        tags: ['security', 'rules'],
      ),

      // ===== Testing =====
      AssessmentQuestion(
        id: 'q025',
        category: 'Testing',
        difficulty: 'easy',
        question: 'What type of test checks individual functions or classes?',
        options: ['Unit test', 'Widget test', 'Integration test', 'E2E test'],
        correctAnswer: 0,
        points: 1,
        explanation:
            'Unit tests test individual functions, methods, or classes in isolation.',
        tags: ['testing', 'unit-tests'],
      ),
      AssessmentQuestion(
        id: 'q026',
        category: 'Testing',
        difficulty: 'medium',
        question: 'Which package is used for widget testing in Flutter?',
        options: [
          'flutter_test',
          'widget_test',
          'test_widgets',
          'flutter_testing'
        ],
        correctAnswer: 0,
        points: 2,
        explanation:
            'flutter_test provides utilities for testing Flutter widgets.',
        tags: ['testing', 'widgets'],
      ),
      AssessmentQuestion(
        id: 'q027',
        category: 'Testing',
        difficulty: 'hard',
        question: 'What is the purpose of testWidgets()?',
        options: [
          'Create widget tests with a test environment',
          'Test API calls',
          'Test databases',
          'Generate test reports'
        ],
        correctAnswer: 0,
        points: 3,
        explanation:
            'testWidgets() provides a WidgetTester for building and interacting with widgets in tests.',
        tags: ['testWidgets', 'widget-testing'],
      ),

      // ===== Animations =====
      AssessmentQuestion(
        id: 'q028',
        category: 'Animations',
        difficulty: 'medium',
        question: 'What is an AnimationController used for?',
        options: [
          'Control animation duration and playback',
          'Create widgets',
          'Handle user input',
          'Manage app state'
        ],
        correctAnswer: 0,
        points: 2,
        explanation:
            'AnimationController manages the animation timeline and provides control methods.',
        tags: ['animations', 'controller'],
      ),
      AssessmentQuestion(
        id: 'q029',
        category: 'Animations',
        difficulty: 'hard',
        question:
            'What is the difference between implicit and explicit animations?',
        options: [
          'Implicit animations are automatic, explicit require controllers',
          'They are the same',
          'Explicit is deprecated',
          'Implicit is faster'
        ],
        correctAnswer: 0,
        points: 3,
        explanation:
            'Implicit animations (AnimatedContainer) handle animation automatically, explicit animations (AnimationController) require manual control.',
        tags: ['animations', 'types'],
      ),

      // ===== Performance =====
      AssessmentQuestion(
        id: 'q030',
        category: 'Performance',
        difficulty: 'hard',
        question: 'What is the purpose of the "const" keyword for widgets?',
        options: [
          'Prevent unnecessary widget rebuilds',
          'Make widgets faster',
          'Required for all widgets',
          'No real purpose'
        ],
        correctAnswer: 0,
        points: 3,
        explanation:
            'const widgets are canonicalized and reused, preventing unnecessary rebuilds and improving performance.',
        tags: ['optimization', 'const'],
      ),
    ];
  }
}
