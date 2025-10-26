import 'package:get/get.dart';
import '../data/models/quiz_question.dart';

/// Controller for managing quiz state and logic
class QuizController extends GetxController {
  final RxList<QuizQuestion> questions = <QuizQuestion>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxMap<int, int> userAnswers = <int, int>{}.obs;
  final RxInt score = 0.obs;
  final RxBool isCompleted = false.obs;
  final RxBool showExplanation = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadQuizQuestions();
  }

  void loadQuizQuestions() {
    // Sample quiz questions for Flutter basics
    questions.value = [
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
    ];
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
