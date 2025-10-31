import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/assessment_question.dart';
import '../models/skill_assessment.dart';

class AssessmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get Hive box for local caching
  Box get _box => Hive.box('quiz'); // Reuse quiz box for simplicity

  // Collection references
  CollectionReference get _assessmentsCollection =>
      _firestore.collection('skill_assessments');
  CollectionReference get _questionsCollection =>
      _firestore.collection('assessment_questions');

  // ========== Assessment CRUD Operations ==========

  /// Save completed assessment to Firestore and Hive
  Future<void> saveAssessment(SkillAssessment assessment) async {
    // Save to Hive first (always succeeds, works offline)
    try {
      final assessmentKey = 'assessment_${assessment.userId}_${assessment.id}';
      // Use forFirestore: false for Hive (ISO strings)
      await _box.put(
          assessmentKey, jsonEncode(assessment.toMap(forFirestore: false)));
    } catch (e) {
      print('Error saving assessment to local cache: $e');
    }

    // Try to save to Firestore (requires internet and auth)
    try {
      // Use forFirestore: true for Firestore (Timestamps)
      await _assessmentsCollection
          .doc(assessment.id)
          .set(assessment.toMap(forFirestore: true));
    } catch (e) {
      print('Error syncing assessment to Firestore: $e');
      // Continue anyway - local save succeeded
    }
  }

  /// Get user's latest assessment (from Hive cache first, then Firestore)
  Future<SkillAssessment?> getUserLatestAssessment(String userId) async {
    SkillAssessment? latestAssessment;

    // Try to load from Hive cache first (fast, works offline)
    try {
      final allKeys = _box.keys
          .where((key) => key.toString().startsWith('assessment_$userId'));

      DateTime? latestDate;
      for (final key in allKeys) {
        final data = _box.get(key);
        if (data is String) {
          try {
            final assessmentMap = Map<String, dynamic>.from(jsonDecode(data));
            final assessment = SkillAssessment.fromMap(assessmentMap);

            if (latestDate == null ||
                assessment.completedAt.isAfter(latestDate)) {
              latestDate = assessment.completedAt;
              latestAssessment = assessment;
            }
          } catch (e) {
            print('Error parsing cached assessment: $e');
          }
        }
      }
    } catch (e) {
      print('Error loading cached assessments: $e');
    }

    // Try to sync with Firestore (online only)
    try {
      final querySnapshot = await _assessmentsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final firestoreAssessment =
            SkillAssessment.fromFirestore(querySnapshot.docs.first);

        // Use more recent assessment
        if (latestAssessment == null ||
            firestoreAssessment.completedAt
                .isAfter(latestAssessment.completedAt)) {
          latestAssessment = firestoreAssessment;
        }

        // Cache Firestore assessment locally
        final assessmentKey =
            'assessment_${firestoreAssessment.userId}_${firestoreAssessment.id}';
        // Use forFirestore: false for Hive (ISO strings)
        await _box.put(assessmentKey,
            jsonEncode(firestoreAssessment.toMap(forFirestore: false)));
      }
    } catch (e) {
      print('Error syncing with Firestore (using cached data): $e');
      // Continue with cached assessment
    }

    return latestAssessment;
  }

  /// Get all assessments for a user (from Hive cache first, then Firestore)
  Future<List<SkillAssessment>> getUserAssessments(String userId) async {
    List<SkillAssessment> assessments = [];

    // Load from Hive cache first (fast, works offline)
    try {
      final allKeys = _box.keys
          .where((key) => key.toString().startsWith('assessment_$userId'));

      for (final key in allKeys) {
        final data = _box.get(key);
        if (data is String) {
          try {
            final assessmentMap = Map<String, dynamic>.from(jsonDecode(data));
            assessments.add(SkillAssessment.fromMap(assessmentMap));
          } catch (e) {
            print('Error parsing cached assessment: $e');
          }
        }
      }
    } catch (e) {
      print('Error loading cached assessments: $e');
    }

    // Try to sync with Firestore (online only)
    try {
      final querySnapshot = await _assessmentsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      final firestoreAssessments = querySnapshot.docs
          .map((doc) => SkillAssessment.fromFirestore(doc))
          .toList();

      // Merge: prefer Firestore data, add local-only assessments
      final assessmentIds = firestoreAssessments.map((a) => a.id).toSet();
      final localOnlyAssessments =
          assessments.where((a) => !assessmentIds.contains(a.id)).toList();

      assessments = [...firestoreAssessments, ...localOnlyAssessments];

      // Cache Firestore assessments locally
      for (final assessment in firestoreAssessments) {
        final assessmentKey =
            'assessment_${assessment.userId}_${assessment.id}';
        // Use forFirestore: false to get ISO string format for Hive
        await _box.put(
            assessmentKey, jsonEncode(assessment.toMap(forFirestore: false)));
      }
    } catch (e) {
      print('Error syncing with Firestore (using cached data): $e');
      // Continue with cached assessments
    }

    // Sort by completion date (most recent first)
    assessments.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return assessments;
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
        xp: 10,
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
        xp: 10,
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
        xp: 20,
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
        xp: 10,
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
        xp: 20,
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
        xp: 30,
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
        xp: 10,
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
        xp: 20,
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
        xp: 30,
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
        xp: 10,
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
        xp: 20,
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
        xp: 30,
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
        xp: 10,
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
        xp: 20,
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
        xp: 30,
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
        xp: 10,
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
        xp: 20,
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
        xp: 30,
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
        xp: 10,
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
        xp: 20,
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
        xp: 30,
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
        xp: 10,
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
        xp: 20,
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
        xp: 30,
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
        xp: 10,
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
        xp: 20,
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
        xp: 30,
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
        xp: 20,
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
        xp: 30,
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
        xp: 30,
        explanation:
            'const widgets are canonicalized and reused, preventing unnecessary rebuilds and improving performance.',
        tags: ['optimization', 'const'],
      ),

      // ===== More Dart Basics =====
      AssessmentQuestion(
        id: 'q031',
        category: 'Dart Basics',
        difficulty: 'easy',
        question: 'What is null safety in Dart?',
        options: [
          'A feature that prevents null reference errors',
          'A security feature',
          'A testing framework',
          'A deprecated feature'
        ],
        correctAnswer: 0,
        xp: 10,
        explanation:
            'Null safety helps developers avoid null reference exceptions by distinguishing nullable and non-nullable types.',
        tags: ['null-safety', 'types'],
      ),
      AssessmentQuestion(
        id: 'q032',
        category: 'Dart Basics',
        difficulty: 'medium',
        question: 'What does the "late" keyword do in Dart?',
        options: [
          'Defers initialization of a variable',
          'Makes variables nullable',
          'Creates a timer',
          'Marks deprecated code'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            '"late" allows non-nullable variables to be initialized after declaration.',
        tags: ['late', 'initialization'],
      ),
      AssessmentQuestion(
        id: 'q033',
        category: 'Dart Basics',
        difficulty: 'hard',
        question: 'What are extension methods in Dart?',
        options: [
          'Methods added to existing types without modifying them',
          'Methods that extend classes',
          'Deprecated methods',
          'Private methods'
        ],
        correctAnswer: 0,
        xp: 30,
        explanation:
            'Extension methods allow you to add functionality to existing types without inheritance.',
        tags: ['extensions', 'methods'],
      ),

      // ===== More Widgets =====
      AssessmentQuestion(
        id: 'q034',
        category: 'Widgets',
        difficulty: 'easy',
        question: 'What widget displays an image in Flutter?',
        options: ['Image', 'Picture', 'Photo', 'ImageView'],
        correctAnswer: 0,
        xp: 10,
        explanation:
            'Image widget displays images from assets, network, files, or memory.',
        tags: ['images', 'widgets'],
      ),
      AssessmentQuestion(
        id: 'q035',
        category: 'Widgets',
        difficulty: 'medium',
        question: 'What is the purpose of SafeArea widget?',
        options: [
          'Avoid system UI overlaps like notches and status bars',
          'Secure user data',
          'Validate user input',
          'Handle exceptions'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            'SafeArea insets its child by sufficient padding to avoid system UI intrusions.',
        tags: ['SafeArea', 'layout'],
      ),
      AssessmentQuestion(
        id: 'q036',
        category: 'Widgets',
        difficulty: 'hard',
        question:
            'What is the difference between MediaQuery and LayoutBuilder?',
        options: [
          'MediaQuery gets screen info, LayoutBuilder gets parent constraints',
          'They are identical',
          'LayoutBuilder is deprecated',
          'MediaQuery only works on mobile'
        ],
        correctAnswer: 0,
        xp: 30,
        explanation:
            'MediaQuery provides device/screen info, LayoutBuilder provides parent widget constraints.',
        tags: ['MediaQuery', 'LayoutBuilder'],
      ),

      // ===== Material Design =====
      AssessmentQuestion(
        id: 'q037',
        category: 'Material Design',
        difficulty: 'easy',
        question: 'What widget creates a Material Design app bar?',
        options: ['AppBar', 'TopBar', 'Header', 'Toolbar'],
        correctAnswer: 0,
        xp: 10,
        explanation:
            'AppBar is Material Design app bar that appears at the top of the app.',
        tags: ['AppBar', 'material'],
      ),
      AssessmentQuestion(
        id: 'q038',
        category: 'Material Design',
        difficulty: 'medium',
        question:
            'Which widget creates a Material Design floating action button?',
        options: [
          'FloatingActionButton',
          'FAB',
          'ActionButton',
          'CircleButton'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            'FloatingActionButton creates a circular button that floats above content.',
        tags: ['FAB', 'buttons'],
      ),
      AssessmentQuestion(
        id: 'q039',
        category: 'Material Design',
        difficulty: 'hard',
        question: 'What is a SnackBar used for?',
        options: [
          'Show brief messages at the bottom of the screen',
          'Display permanent notifications',
          'Create navigation menus',
          'Handle errors'
        ],
        correctAnswer: 0,
        xp: 30,
        explanation:
            'SnackBar displays temporary messages with optional actions at the bottom.',
        tags: ['SnackBar', 'feedback'],
      ),

      // ===== Forms & Input =====
      AssessmentQuestion(
        id: 'q040',
        category: 'Forms & Input',
        difficulty: 'easy',
        question: 'Which widget is used for text input in Flutter?',
        options: ['TextField', 'TextInput', 'InputField', 'EditText'],
        correctAnswer: 0,
        xp: 10,
        explanation:
            'TextField widget allows users to enter text with a keyboard.',
        tags: ['TextField', 'input'],
      ),
      AssessmentQuestion(
        id: 'q041',
        category: 'Forms & Input',
        difficulty: 'medium',
        question: 'What is the purpose of TextEditingController?',
        options: [
          'Control and monitor text input changes',
          'Style text',
          'Validate forms',
          'Submit forms'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            'TextEditingController manages the text being edited and notifies listeners of changes.',
        tags: ['controller', 'text-editing'],
      ),
      AssessmentQuestion(
        id: 'q042',
        category: 'Forms & Input',
        difficulty: 'hard',
        question: 'How do you validate form fields in Flutter?',
        options: [
          'Using Form widget with GlobalKey and validators',
          'Only with if statements',
          'Validation is automatic',
          'Using TextEditingController'
        ],
        correctAnswer: 0,
        xp: 30,
        explanation:
            'Form widget with GlobalKey<FormState> provides validation methods for TextFormField widgets.',
        tags: ['validation', 'forms'],
      ),

      // ===== Advanced State Management =====
      AssessmentQuestion(
        id: 'q043',
        category: 'State Management',
        difficulty: 'medium',
        question: 'What is Provider in Flutter?',
        options: [
          'A state management solution using InheritedWidget',
          'A database provider',
          'An API client',
          'A routing package'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            'Provider is a wrapper around InheritedWidget making state management easier.',
        tags: ['Provider', 'state'],
      ),
      AssessmentQuestion(
        id: 'q044',
        category: 'State Management',
        difficulty: 'hard',
        question: 'What is BLoC pattern?',
        options: [
          'Business Logic Component pattern separating logic from UI',
          'A widget type',
          'A deprecated pattern',
          'A testing framework'
        ],
        correctAnswer: 0,
        xp: 30,
        explanation:
            'BLoC pattern uses Streams to separate business logic from UI, making code testable.',
        tags: ['BLoC', 'architecture'],
      ),

      // ===== Packages & Dependencies =====
      AssessmentQuestion(
        id: 'q045',
        category: 'Packages',
        difficulty: 'easy',
        question: 'Where do you declare Flutter package dependencies?',
        options: ['pubspec.yaml', 'package.json', 'build.gradle', 'main.dart'],
        correctAnswer: 0,
        xp: 10,
        explanation:
            'pubspec.yaml file contains all project dependencies and configuration.',
        tags: ['pubspec', 'dependencies'],
      ),
      AssessmentQuestion(
        id: 'q046',
        category: 'Packages',
        difficulty: 'medium',
        question: 'What command installs Flutter packages?',
        options: [
          'flutter pub get',
          'flutter install',
          'pub install',
          'flutter fetch'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            '"flutter pub get" downloads all packages specified in pubspec.yaml.',
        tags: ['pub', 'cli'],
      ),

      // ===== Platform-Specific =====
      AssessmentQuestion(
        id: 'q047',
        category: 'Platform',
        difficulty: 'medium',
        question: 'How do you detect the current platform in Flutter?',
        options: [
          'Platform.isAndroid or Platform.isIOS',
          'Device.platform',
          'Flutter.platform',
          'OS.type'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            'dart:io Platform class provides platform detection methods.',
        tags: ['platform', 'detection'],
      ),
      AssessmentQuestion(
        id: 'q048',
        category: 'Platform',
        difficulty: 'hard',
        question: 'What is a Platform Channel?',
        options: [
          'Communication bridge between Dart and native code',
          'A TV streaming platform',
          'A navigation route',
          'A state management solution'
        ],
        correctAnswer: 0,
        xp: 30,
        explanation:
            'Platform Channels allow Dart code to communicate with platform-specific APIs.',
        tags: ['platform-channel', 'native'],
      ),

      // ===== Build & Deployment =====
      AssessmentQuestion(
        id: 'q049',
        category: 'Build & Deploy',
        difficulty: 'easy',
        question: 'What command builds a Flutter app for release?',
        options: [
          'flutter build',
          'flutter compile',
          'flutter release',
          'flutter deploy'
        ],
        correctAnswer: 0,
        xp: 10,
        explanation:
            '"flutter build" compiles the app for production with optimizations.',
        tags: ['build', 'release'],
      ),
      AssessmentQuestion(
        id: 'q050',
        category: 'Build & Deploy',
        difficulty: 'medium',
        question: 'What is the difference between debug and release mode?',
        options: [
          'Debug includes debugging tools, release is optimized',
          'They are identical',
          'Release mode is slower',
          'Debug is for production'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            'Debug mode includes debugging tools and hot reload, release mode is optimized for performance.',
        tags: ['modes', 'optimization'],
      ),

      // ===== Error Handling =====
      AssessmentQuestion(
        id: 'q051',
        category: 'Error Handling',
        difficulty: 'medium',
        question: 'How do you catch errors in async functions?',
        options: [
          'try-catch blocks',
          'if-else statements',
          'Errors are ignored',
          'onError callback only'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            'try-catch blocks catch exceptions in async functions, including awaited Futures.',
        tags: ['exceptions', 'async'],
      ),
      AssessmentQuestion(
        id: 'q052',
        category: 'Error Handling',
        difficulty: 'hard',
        question: 'What is FlutterError.onError used for?',
        options: [
          'Global error handler for uncaught Flutter framework errors',
          'Widget-specific errors',
          'Network errors',
          'Deprecated feature'
        ],
        correctAnswer: 0,
        xp: 30,
        explanation:
            'FlutterError.onError catches framework errors for custom error reporting.',
        tags: ['FlutterError', 'debugging'],
      ),

      // ===== More Layouts =====
      AssessmentQuestion(
        id: 'q053',
        category: 'Layouts',
        difficulty: 'medium',
        question: 'What does Stack widget do?',
        options: [
          'Positions children on top of each other',
          'Stacks children vertically',
          'Creates a navigation stack',
          'Manages memory'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            'Stack allows positioning widgets on top of each other, similar to absolute positioning.',
        tags: ['Stack', 'positioning'],
      ),
      AssessmentQuestion(
        id: 'q054',
        category: 'Layouts',
        difficulty: 'hard',
        question: 'When should you use GridView instead of ListView?',
        options: [
          'When displaying items in a 2D grid layout',
          'When you need scrolling',
          'Always use ListView',
          'GridView is deprecated'
        ],
        correctAnswer: 0,
        xp: 30,
        explanation:
            'GridView displays items in a scrollable 2D grid, ListView is for single-column lists.',
        tags: ['GridView', 'layouts'],
      ),

      // ===== More Navigation =====
      AssessmentQuestion(
        id: 'q055',
        category: 'Navigation',
        difficulty: 'medium',
        question: 'What is Navigator 2.0?',
        options: [
          'Declarative routing API for complex navigation',
          'A new Navigator widget',
          'Deprecated Navigator',
          'Mobile-only navigation'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            'Navigator 2.0 provides declarative routing with better deep linking support.',
        tags: ['navigator-2', 'routing'],
      ),
      AssessmentQuestion(
        id: 'q056',
        category: 'Navigation',
        difficulty: 'hard',
        question: 'What is the purpose of WillPopScope?',
        options: [
          'Intercept back button presses',
          'Navigate forward',
          'Create popups',
          'Handle gestures'
        ],
        correctAnswer: 0,
        xp: 30,
        explanation:
            'WillPopScope catches back button/swipe gestures to confirm navigation or prevent it.',
        tags: ['WillPopScope', 'navigation'],
      ),

      // ===== More Async =====
      AssessmentQuestion(
        id: 'q057',
        category: 'Async Programming',
        difficulty: 'medium',
        question: 'What does FutureBuilder widget do?',
        options: [
          'Builds UI based on Future state',
          'Creates Futures',
          'Cancels Futures',
          'Tests async code'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            'FutureBuilder rebuilds when Future completes, handling loading/error states.',
        tags: ['FutureBuilder', 'widgets'],
      ),
      AssessmentQuestion(
        id: 'q058',
        category: 'Async Programming',
        difficulty: 'hard',
        question: 'What is StreamBuilder used for?',
        options: [
          'Build widgets from Stream data',
          'Create streams',
          'Filter streams',
          'Close streams'
        ],
        correctAnswer: 0,
        xp: 30,
        explanation:
            'StreamBuilder rebuilds whenever Stream emits new data, perfect for real-time updates.',
        tags: ['StreamBuilder', 'streams'],
      ),

      // ===== More Performance =====
      AssessmentQuestion(
        id: 'q059',
        category: 'Performance',
        difficulty: 'medium',
        question: 'What is a RepaintBoundary used for?',
        options: [
          'Isolate widget rendering to improve performance',
          'Animate widgets',
          'Handle gestures',
          'Manage state'
        ],
        correctAnswer: 0,
        xp: 20,
        explanation:
            'RepaintBoundary creates a separate layer, preventing unnecessary repaints of surrounding widgets.',
        tags: ['optimization', 'rendering'],
      ),
      AssessmentQuestion(
        id: 'q060',
        category: 'Performance',
        difficulty: 'hard',
        question: 'What is the purpose of ListView.builder?',
        options: [
          'Lazy loading for better performance with long lists',
          'Better styling options',
          'Faster scrolling',
          'Grid layouts'
        ],
        correctAnswer: 0,
        xp: 30,
        explanation:
            'ListView.builder creates items on-demand as they scroll into view, saving memory.',
        tags: ['ListView', 'lazy-loading'],
      ),
    ];
  }
}
