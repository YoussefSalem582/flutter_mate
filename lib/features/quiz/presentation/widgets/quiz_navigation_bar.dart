import 'package:flutter/material.dart';
import 'package:flutter_mate/shared/widgets/custom_button.dart';

/// Navigation bar for quiz (Previous/Next buttons)
class QuizNavigationBar extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final bool hasAnswered;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const QuizNavigationBar({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.hasAnswered,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstQuestion = currentQuestionIndex == 0;
    final isLastQuestion = currentQuestionIndex >= totalQuestions - 1;

    return Row(
      children: [
        // Previous Button
        if (!isFirstQuestion)
          Expanded(
            child: CustomButton(
              text: 'Previous',
              onPressed: onPrevious ?? () {},
              isOutlined: true,
            ),
          ),
        if (!isFirstQuestion) const SizedBox(width: 16),

        // Next Button
        Expanded(
          flex: isFirstQuestion ? 1 : 1,
          child: CustomButton(
            text: isLastQuestion ? 'Finish Quiz' : 'Next Question',
            onPressed: hasAnswered && onNext != null ? onNext! : () {},
          ),
        ),
      ],
    );
  }
}
