import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/assessment_question.dart';
import '../data/models/skill_assessment.dart';
import '../data/models/skill_level.dart';
import '../data/repositories/assessment_repository.dart';
import '../../auth/controller/auth_controller.dart';
import '../../analytics/controller/analytics_controller.dart';

class AssessmentController extends GetxController {
  final AssessmentRepository _repository = AssessmentRepository();
  final AuthController _authController = Get.find<AuthController>();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isAssessmentActive = false.obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxInt score = 0.obs;
  final RxInt correctAnswers = 0.obs;
  final Rx<DateTime?> startTime = Rx<DateTime?>(null);
  final Rx<SkillAssessment?> latestAssessment = Rx<SkillAssessment?>(null);

  // Questions
  final RxList<AssessmentQuestion> allQuestions = <AssessmentQuestion>[].obs;
  final RxList<AssessmentQuestion> selectedQuestions =
      <AssessmentQuestion>[].obs;
  final RxMap<String, int> userAnswers = <String, int>{}.obs;
  final RxMap<String, int> categoryScores = <String, int>{}.obs;
  final RxMap<String, int> categoryMaxScores = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadQuestions();
    loadLatestAssessment();
  }

  // ========== Loading Data ==========

  /// Load all available questions
  Future<void> loadQuestions() async {
    try {
      isLoading.value = true;
      allQuestions.value = await _repository.getAllQuestions();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load questions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load user's latest assessment
  Future<void> loadLatestAssessment() async {
    try {
      final userId = _authController.currentUser.value?.id;
      if (userId == null) return;

      latestAssessment.value =
          await _repository.getUserLatestAssessment(userId);
    } catch (e) {
      print('Failed to load latest assessment: $e');
    }
  }

  // ========== Assessment Flow ==========

  /// Start a new assessment
  Future<void> startAssessment({bool navigateToPage = true}) async {
    // Ensure questions are loaded
    if (allQuestions.isEmpty) {
      isLoading.value = true;
      await loadQuestions();
      isLoading.value = false;
    }

    // Check if we have questions
    if (allQuestions.isEmpty) {
      Get.snackbar(
        'Error',
        'No questions available. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (navigateToPage && Get.currentRoute == '/skill-assessment') {
        Get.back();
      }
      return;
    }

    // Reset state
    currentQuestionIndex.value = 0;
    score.value = 0;
    correctAnswers.value = 0;
    userAnswers.clear();
    categoryScores.clear();
    categoryMaxScores.clear();

    // Select diverse questions
    selectedQuestions.value = _selectDiverseQuestions(30);

    // Initialize category tracking
    for (var question in selectedQuestions) {
      categoryMaxScores[question.category] =
          (categoryMaxScores[question.category] ?? 0) + question.points;
    }

    // Start timer
    startTime.value = DateTime.now();
    isAssessmentActive.value = true;

    if (navigateToPage && Get.currentRoute != '/skill-assessment') {
      Get.toNamed('/skill-assessment');
    }
  }

  /// Select diverse questions across categories and difficulties
  List<AssessmentQuestion> _selectDiverseQuestions(int count) {
    final questions = <AssessmentQuestion>[];

    // Return empty list if no questions available
    if (allQuestions.isEmpty) {
      return questions;
    }

    final categories = <String>{};

    // Group questions by category
    final questionsByCategory = <String, List<AssessmentQuestion>>{};
    for (var q in allQuestions) {
      questionsByCategory.putIfAbsent(q.category, () => []).add(q);
      categories.add(q.category);
    }

    // Return empty list if no categories
    if (categories.isEmpty) {
      return questions;
    }

    // Calculate questions per category
    final questionsPerCategory = (count / categories.length).ceil();

    // Select questions from each category
    for (var category in categories) {
      final categoryQuestions = questionsByCategory[category]!;

      // Get mix of difficulties
      final easy =
          categoryQuestions.where((q) => q.difficulty == 'easy').toList();
      final medium =
          categoryQuestions.where((q) => q.difficulty == 'medium').toList();
      final hard =
          categoryQuestions.where((q) => q.difficulty == 'hard').toList();

      // Shuffle each difficulty level
      easy.shuffle();
      medium.shuffle();
      hard.shuffle();

      // Take proportional questions from each difficulty
      final categorySelection = <AssessmentQuestion>[];
      final easyCount =
          (questionsPerCategory * 0.4).ceil().clamp(0, easy.length);
      final mediumCount =
          (questionsPerCategory * 0.4).ceil().clamp(0, medium.length);
      final hardCount = (questionsPerCategory - easyCount - mediumCount)
          .clamp(0, hard.length);

      categorySelection.addAll(easy.take(easyCount));
      categorySelection.addAll(medium.take(mediumCount));
      categorySelection.addAll(hard.take(hardCount));

      questions.addAll(categorySelection.take(questionsPerCategory));
    }

    // Shuffle final selection
    questions.shuffle();
    return questions.take(count.clamp(0, questions.length)).toList();
  }

  /// Answer current question
  void answerQuestion(int answerIndex) {
    if (currentQuestionIndex.value >= selectedQuestions.length) return;

    final question = selectedQuestions[currentQuestionIndex.value];

    // Store answer
    userAnswers[question.id] = answerIndex;

    // Check if correct
    if (question.isCorrect(answerIndex)) {
      correctAnswers.value++;
      score.value += question.points;

      // Track category score
      categoryScores[question.category] =
          (categoryScores[question.category] ?? 0) + question.points;
    }

    // Move to next question or finish
    if (currentQuestionIndex.value < selectedQuestions.length - 1) {
      currentQuestionIndex.value++;
    } else {
      _finishAssessment();
    }
  }

  /// Skip current question
  void skipQuestion() {
    if (currentQuestionIndex.value < selectedQuestions.length - 1) {
      currentQuestionIndex.value++;
    } else {
      _finishAssessment();
    }
  }

  /// Go to previous question
  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  /// Finish assessment and calculate results
  Future<void> _finishAssessment() async {
    isAssessmentActive.value = false;

    // Calculate time taken
    final timeTaken = DateTime.now().difference(startTime.value!);

    // Calculate total max score
    final totalMaxScore =
        selectedQuestions.fold<int>(0, (sum, q) => sum + q.points);

    // Calculate skill levels per category
    final skills = <String, SkillLevel>{};
    for (var entry in categoryScores.entries) {
      final category = entry.key;
      final categoryScore = entry.value;
      final maxScore = categoryMaxScores[category] ?? 1;
      final percentage = (categoryScore / maxScore) * 100;
      skills[category] = SkillLevel.fromPercentage(percentage);
    }

    // Identify weak and strong areas
    final sortedCategories = categoryScores.entries.toList()
      ..sort((a, b) {
        final percentA = (a.value / (categoryMaxScores[a.key] ?? 1)) * 100;
        final percentB = (b.value / (categoryMaxScores[b.key] ?? 1)) * 100;
        return percentA.compareTo(percentB);
      });

    final weakAreas = sortedCategories.take(3).map((e) => e.key).toList();

    final strongAreas =
        sortedCategories.reversed.take(3).map((e) => e.key).toList();

    // Create assessment result
    final assessment = SkillAssessment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _authController.currentUser.value!.id,
      skills: skills,
      completedAt: DateTime.now(),
      totalScore: score.value,
      maxScore: totalMaxScore,
      categoryScores: Map<String, int>.from(categoryScores),
      categoryMaxScores: Map<String, int>.from(categoryMaxScores),
      weakAreas: weakAreas,
      strongAreas: strongAreas,
      timeTaken: timeTaken,
      questionsAnswered: selectedQuestions.length,
      correctAnswers: correctAnswers.value,
    );

    // Save to Firestore
    try {
      await _repository.saveAssessment(assessment);
      latestAssessment.value = assessment;

      // Update analytics - refresh to include new assessment data
      try {
        final analyticsController = Get.find<AnalyticsController>();
        await analyticsController.refreshAnalytics();
      } catch (e) {
        print('Analytics controller not found: $e');
      }

      // Navigate to results
      Get.offNamed('/assessment-results', arguments: assessment);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save assessment: $e');
    }
  }

  /// Cancel assessment
  void cancelAssessment() {
    Get.dialog(
      GetBuilder<AssessmentController>(
        builder: (_) => AlertDialog(
          title: const Text('Cancel Assessment?'),
          content: const Text(
            'Your progress will be lost. Are you sure you want to cancel?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('No, Continue'),
            ),
            TextButton(
              onPressed: () {
                isAssessmentActive.value = false;
                Get.back(); // Close dialog
                Get.back(); // Go back to previous screen
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== Helper Methods ==========

  /// Get current question
  AssessmentQuestion? get currentQuestion {
    if (currentQuestionIndex.value >= selectedQuestions.length) return null;
    return selectedQuestions[currentQuestionIndex.value];
  }

  /// Check if question was answered
  bool isQuestionAnswered(String questionId) {
    return userAnswers.containsKey(questionId);
  }

  /// Get user's answer for a question
  int? getUserAnswer(String questionId) {
    return userAnswers[questionId];
  }

  /// Get progress percentage
  double get progressPercentage {
    if (selectedQuestions.isEmpty) return 0;
    return (currentQuestionIndex.value / selectedQuestions.length) * 100;
  }

  /// Check if assessment is available
  bool get hasAssessment {
    return latestAssessment.value != null;
  }

  /// Get time since last assessment
  String? get timeSinceLastAssessment {
    if (latestAssessment.value == null) return null;

    final now = DateTime.now();
    final diff = now.difference(latestAssessment.value!.completedAt);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} year(s) ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} month(s) ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} day(s) ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour(s) ago';
    } else {
      return '${diff.inMinutes} minute(s) ago';
    }
  }

  /// Get remaining questions count
  int get remainingQuestions {
    return selectedQuestions.length - currentQuestionIndex.value;
  }

  /// Retake assessment
  void retakeAssessment() {
    startAssessment();
  }
}
