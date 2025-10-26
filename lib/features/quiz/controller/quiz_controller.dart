import 'package:get/get.dart';
import '../data/models/quiz_question.dart';
import '../services/quiz_tracking_service.dart';

/// Controller for managing quiz state and logic
class QuizController extends GetxController {
  final QuizTrackingService _trackingService = Get.find<QuizTrackingService>();

  final RxList<QuizQuestion> questions = <QuizQuestion>[].obs;
  final RxList<QuizQuestion> allQuestions = <QuizQuestion>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxMap<int, int> userAnswers = <int, int>{}.obs;
  final RxInt score = 0.obs;
  final RxBool isCompleted = false.obs;
  final RxBool showExplanation = false.obs;
  final RxString currentLessonId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllQuestions();

    // Get lessonId from route arguments if available
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('lessonId')) {
      loadQuizForLesson(args['lessonId'] as String);
    } else {
      // Load all questions if no specific lesson
      questions.value = allQuestions;
    }
  }

  void loadAllQuestions() {
    // Comprehensive quiz questions for all lessons
    allQuestions.value = [
      const QuizQuestion(
        id: 'q1',
        lessonId: 'dart-basics',
        question: 'What is Flutter primarily used for?',
        options: [
          'Backend development',
          'Cross-platform mobile app development',
          'Database management',
          'Web hosting',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Flutter is an open-source UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q2',
        lessonId: 'dart-basics',
        question: 'Which programming language does Flutter use?',
        options: ['JavaScript', 'Python', 'Dart', 'Kotlin'],
        correctAnswerIndex: 2,
        explanation:
            'Flutter uses Dart, a modern, object-oriented programming language developed by Google.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q3',
        lessonId: 'widgets',
        question: 'What are the two types of widgets in Flutter?',
        options: [
          'Static and Dynamic',
          'Stateless and Stateful',
          'Active and Passive',
          'Simple and Complex',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Flutter has two types of widgets: Stateless widgets (immutable) and Stateful widgets (mutable with state).',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q4',
        lessonId: 'widgets',
        question:
            'Which widget is used to create a scrollable list in Flutter?',
        options: ['Container', 'ListView', 'Column', 'Stack'],
        correctAnswerIndex: 1,
        explanation:
            'ListView is the widget used to create scrollable lists in Flutter. It efficiently renders only visible items.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q5',
        lessonId: 'layouts',
        question: 'Which layout widget arranges children in a vertical array?',
        options: ['Row', 'Stack', 'Column', 'Grid'],
        correctAnswerIndex: 2,
        explanation:
            'Column widget arranges its children vertically. For horizontal arrangement, use Row.',
        points: 10,
      ),
      // State Management Questions
      const QuizQuestion(
        id: 'q6',
        lessonId: 'state-management-intro',
        question: 'What is state in Flutter?',
        options: [
          'The current page URL',
          'Data that can change over time',
          'Widget styling properties',
          'App configuration',
        ],
        correctAnswerIndex: 1,
        explanation:
            'State refers to any data that can change during the lifetime of the app and affects what is displayed.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q7',
        lessonId: 'state-management-intro',
        question:
            'Which method is called when a StatefulWidget\'s state changes?',
        options: ['build()', 'setState()', 'initState()', 'dispose()'],
        correctAnswerIndex: 1,
        explanation:
            'setState() is used to notify the framework that the internal state has changed and the widget needs to rebuild.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q8',
        lessonId: 'provider',
        question: 'What is Provider in Flutter?',
        options: [
          'A database package',
          'A state management solution',
          'A routing package',
          'A testing framework',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Provider is a recommended state management solution that uses InheritedWidget under the hood.',
        points: 10,
      ),
      // Navigation Questions
      const QuizQuestion(
        id: 'q9',
        lessonId: 'navigation',
        question: 'Which class is used for navigation in Flutter?',
        options: ['Router', 'Navigator', 'PageView', 'Routes'],
        correctAnswerIndex: 1,
        explanation:
            'Navigator manages a stack of Route objects and provides methods to navigate between screens.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q10',
        lessonId: 'navigation',
        question: 'How do you navigate back to the previous screen?',
        options: [
          'Navigator.push()',
          'Navigator.pop()',
          'Navigator.back()',
          'Navigator.return()',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Navigator.pop() removes the current route from the stack and returns to the previous screen.',
        points: 10,
      ),
      // Forms and Input Questions
      const QuizQuestion(
        id: 'q11',
        lessonId: 'forms-input',
        question: 'Which widget is used to create text input fields?',
        options: ['TextField', 'TextInput', 'InputField', 'FormField'],
        correctAnswerIndex: 0,
        explanation:
            'TextField is the primary widget for accepting text input from users.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q12',
        lessonId: 'forms-input',
        question: 'What is used to validate form inputs?',
        options: ['FormKey', 'Validator', 'FormState', 'FormValidator'],
        correctAnswerIndex: 0,
        explanation:
            'GlobalKey<FormState> (FormKey) is used to validate, save, and reset forms.',
        points: 10,
      ),
      // Networking Questions
      const QuizQuestion(
        id: 'q13',
        lessonId: 'networking',
        question: 'Which package is commonly used for HTTP requests?',
        options: ['dio', 'http', 'requests', 'Both a and b'],
        correctAnswerIndex: 3,
        explanation:
            'Both http and dio are popular packages for making HTTP requests in Flutter.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q14',
        lessonId: 'networking',
        question: 'What does JSON.decode() do?',
        options: [
          'Converts JSON to String',
          'Converts String to JSON object',
          'Validates JSON',
          'Compresses JSON',
        ],
        correctAnswerIndex: 1,
        explanation:
            'jsonDecode() converts a JSON string into a Dart object (Map or List).',
        points: 10,
      ),
      // Async Programming Questions
      const QuizQuestion(
        id: 'q15',
        lessonId: 'async-programming',
        question: 'What keyword is used to mark a function as asynchronous?',
        options: ['await', 'async', 'future', 'promise'],
        correctAnswerIndex: 1,
        explanation:
            'The async keyword marks a function as asynchronous and allows the use of await inside it.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q16',
        lessonId: 'async-programming',
        question: 'What does the await keyword do?',
        options: [
          'Creates a delay',
          'Waits for a Future to complete',
          'Makes code run faster',
          'Stops execution',
        ],
        correctAnswerIndex: 1,
        explanation:
            'await pauses execution until a Future completes and returns its result.',
        points: 10,
      ),
      // Database Questions
      const QuizQuestion(
        id: 'q17',
        lessonId: 'local-storage',
        question: 'Which package is used for local storage in Flutter?',
        options: ['shared_preferences', 'sqflite', 'hive', 'All of the above'],
        correctAnswerIndex: 3,
        explanation:
            'Flutter supports multiple local storage solutions: shared_preferences for key-value, sqflite for SQL, and hive for NoSQL.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q18',
        lessonId: 'local-storage',
        question: 'What type of data does SharedPreferences store?',
        options: [
          'Complex objects',
          'Key-value pairs',
          'SQL tables',
          'Binary files',
        ],
        correctAnswerIndex: 1,
        explanation:
            'SharedPreferences stores simple key-value pairs (strings, ints, bools, etc.).',
        points: 10,
      ),
      // Animation Questions
      const QuizQuestion(
        id: 'q19',
        lessonId: 'animations',
        question: 'Which widget provides implicit animations?',
        options: [
          'AnimatedContainer',
          'AnimationController',
          'Tween',
          'CustomPainter',
        ],
        correctAnswerIndex: 0,
        explanation:
            'AnimatedContainer provides implicit animations automatically when properties change.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q20',
        lessonId: 'animations',
        question: 'What is the purpose of AnimationController?',
        options: [
          'Display animations',
          'Control animation playback',
          'Create widgets',
          'Handle gestures',
        ],
        correctAnswerIndex: 1,
        explanation:
            'AnimationController controls animation playback: start, stop, reverse, and duration.',
        points: 10,
      ),
      // Testing Questions
      const QuizQuestion(
        id: 'q21',
        lessonId: 'testing',
        question: 'What type of test checks individual functions?',
        options: ['Widget test', 'Unit test', 'Integration test', 'E2E test'],
        correctAnswerIndex: 1,
        explanation:
            'Unit tests verify the behavior of individual functions, methods, or classes.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q22',
        lessonId: 'testing',
        question: 'Which function is used to define a test?',
        options: ['test()', 'describe()', 'expect()', 'verify()'],
        correctAnswerIndex: 0,
        explanation:
            'test() function defines a single test case with a description and callback.',
        points: 10,
      ),
      // Performance Questions
      const QuizQuestion(
        id: 'q23',
        lessonId: 'performance',
        question: 'What tool helps identify performance issues?',
        options: [
          'Flutter Inspector',
          'Performance Overlay',
          'DevTools',
          'All of the above',
        ],
        correctAnswerIndex: 3,
        explanation:
            'Flutter provides multiple tools for performance analysis: Inspector, Performance Overlay, and DevTools.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q24',
        lessonId: 'performance',
        question: 'What does const constructor help with?',
        options: [
          'Faster compilation',
          'Better performance by avoiding rebuilds',
          'Smaller app size',
          'Easier debugging',
        ],
        correctAnswerIndex: 1,
        explanation:
            'const constructors create compile-time constants, preventing unnecessary widget rebuilds.',
        points: 10,
      ),
      // Deployment Questions
      const QuizQuestion(
        id: 'q25',
        lessonId: 'deployment',
        question: 'Which command builds a release version of your app?',
        options: [
          'flutter run',
          'flutter build',
          'flutter release',
          'flutter deploy',
        ],
        correctAnswerIndex: 1,
        explanation:
            'flutter build [platform] creates an optimized release build for the specified platform.',
        points: 10,
      ),
    ];
  }

  void loadQuizForLesson(String lessonId) {
    currentLessonId.value = lessonId;
    questions.value = allQuestions
        .where((q) => q.lessonId == lessonId)
        .toList();

    // If no questions found for this lesson, use general questions
    if (questions.isEmpty) {
      questions.value = allQuestions.take(5).toList();
    }
  }

  QuizQuestion get currentQuestion => questions[currentQuestionIndex.value];

  bool get hasNextQuestion => currentQuestionIndex.value < questions.length - 1;

  bool get hasPreviousQuestion => currentQuestionIndex.value > 0;

  int get totalQuestions => questions.length;

  int get answeredCount => userAnswers.length;

  double get progress =>
      questions.isEmpty ? 0.0 : answeredCount / totalQuestions;

  void selectAnswer(int answerIndex) {
    userAnswers[currentQuestionIndex.value] = answerIndex;
    showExplanation.value = true;

    // Calculate score
    if (answerIndex == currentQuestion.correctAnswerIndex) {
      score.value += currentQuestion.points;
    }
  }

  void nextQuestion() {
    if (hasNextQuestion) {
      currentQuestionIndex.value++;
      showExplanation.value = false;
    } else {
      completeQuiz();
    }
  }

  void previousQuestion() {
    if (hasPreviousQuestion) {
      currentQuestionIndex.value--;
      showExplanation.value = userAnswers.containsKey(
        currentQuestionIndex.value,
      );
    }
  }

  void completeQuiz() {
    isCompleted.value = true;

    // Save quiz result
    if (currentLessonId.value.isNotEmpty) {
      final maxScore = questions.fold<int>(0, (sum, q) => sum + q.points);
      _trackingService.saveQuizResult(
        lessonId: currentLessonId.value,
        score: score.value,
        maxScore: maxScore,
        xpEarned: score.value,
        correctAnswers: correctAnswersCount,
        totalQuestions: totalQuestions,
      );
    }
  }

  void restartQuiz() {
    currentQuestionIndex.value = 0;
    userAnswers.clear();
    score.value = 0;
    isCompleted.value = false;
    showExplanation.value = false;
  }

  int? getUserAnswer(int questionIndex) {
    return userAnswers[questionIndex];
  }

  bool isAnswerCorrect(int questionIndex) {
    final userAnswer = userAnswers[questionIndex];
    if (userAnswer == null) return false;
    return userAnswer == questions[questionIndex].correctAnswerIndex;
  }

  int get correctAnswersCount {
    int count = 0;
    for (int i = 0; i < questions.length; i++) {
      if (isAnswerCorrect(i)) {
        count++;
      }
    }
    return count;
  }

  double get scorePercentage {
    if (questions.isEmpty) return 0.0;
    final maxScore = questions.fold<int>(0, (sum, q) => sum + q.points);
    return maxScore > 0 ? (score.value / maxScore) * 100 : 0.0;
  }
}
