# FlutterMate - Quiz System Documentation

## 🎯 Overview

The Quiz System is an interactive assessment feature that allows users to test their knowledge after completing lessons. It includes 25+ carefully crafted questions covering all topics from beginner to advanced levels.

## 📂 Architecture

```
lib/features/quiz/
├── data/
│   └── models/
│       └── quiz_question.dart          # Quiz question data model
├── controller/
│   ├── quiz_controller.dart            # Quiz state management
│   └── quiz_binding.dart               # Dependency injection
├── services/
│   └── quiz_tracking_service.dart      # Persistent quiz tracking
└── presentation/
    └── pages/
        └── quiz_page.dart              # Interactive quiz UI
```

## 🎨 Features

### 1. Question Management
- **25+ Questions** covering:
  - Dart Basics (2 questions)
  - Widgets (2 questions)
  - Layouts (1 question)
  - State Management (3 questions)
  - Navigation (2 questions)
  - Forms & Input (2 questions)
  - Networking (2 questions)
  - Async Programming (2 questions)
  - Local Storage (2 questions)
  - Animations (2 questions)
  - Testing (2 questions)
  - Performance (2 questions)
  - Deployment (1 question)

- **Smart Filtering**: Questions filtered by lesson ID
- **Fallback**: Shows 5 general questions if lesson has none

### 2. Quiz Interface

#### Progress Header
```dart
- Current question number (e.g., "Question 1 of 5")
- Progress bar with completion percentage
- XP counter with star icon
```

#### Question Card
```dart
- Gradient background (purple to blue)
- Large question text
- 4 multiple choice options
- Color-coded answers:
  ✅ Green: Correct answer
  🟧 Orange: Wrong answer
  ⚪ White: Unanswered
```

#### Explanation Card
```dart
- Appears after answering
- Light blue background
- Lightbulb icon
- Detailed explanation text
```

#### Navigation
```dart
- Previous button (if not first question)
- Next button (if not last question)
- Finish button (on last question)
- Disabled state for unanswered questions
```

### 3. Results Screen

#### Performance-Based Feedback
| Score Range | Icon | Title | Message |
|------------|------|-------|---------|
| 90%+ | 🏆 `emoji_events` | 🎉 Excellent! | Outstanding performance! You're a Flutter expert! |
| 80-89% | 👍 `check_circle` | 👍 Great Job! | You're doing really well! Keep it up! |
| 70-79% | ✅ `check_circle` | ✅ Well Done! | You passed! Continue your learning journey! |
| <70% | 💪 `replay` | 💪 Keep Learning! | Don't give up! Review the material and try again! |

#### Score Card
```dart
Components:
- Large score percentage (48px font)
- Score points
- Correct answers count (X/Y format)
- XP earned
- Gradient background (green if passed, orange if failed)
- Shadow effect for depth
```

#### Performance Breakdown
```dart
Metrics:
- Accuracy percentage
- Total questions count
- Pass/Fail status badge
- Each with icon and color coding
```

#### Actions
```dart
- Retry Quiz: Restart with same questions
- Back Home: Return to previous page
```

### 4. Quiz Tracking Service

#### Persistent Data
```dart
Storage Keys:
- quiz_{lessonId}_score: Integer score
- quiz_{lessonId}_max: Maximum possible score
- quiz_{lessonId}_xp: XP earned
- quiz_{lessonId}_time: Completion timestamp
- quiz_{lessonId}_correct: Number of correct answers
- quiz_{lessonId}_total: Total questions
```

#### Real-time Stats
```dart
- totalQuizzesCompleted: Count of completed quizzes
- totalQuizXP: Sum of all XP earned
- averageScore: Mean score percentage across all quizzes
```

#### Methods
```dart
- saveQuizResult(): Persist quiz completion data
- getQuizResult(lessonId): Retrieve specific quiz result
- hasCompletedQuiz(lessonId): Check completion status
- getQuizScore(lessonId): Get score percentage
- clearAllQuizResults(): Reset all quiz data
```

## 🔗 Integration Points

### 1. Lesson Detail Page
Location: `lib/features/roadmap/presentation/pages/lesson_detail_page.dart`

```dart
// Quiz Card in lesson details
_buildQuizCard(context, lesson, isDark)
  - Gradient blue card
  - Trophy icon
  - "Test Your Knowledge" title
  - Quiz info: 5 questions, ~5 min, 50 XP
  - "Start Quiz" button → navigates to /quiz with lessonId
```

### 2. Progress Tracker
Location: `lib/features/progress_tracker/presentation/pages/progress_tracker_page.dart`

```dart
// Quiz Stats Card
_buildQuizStatsCard(context, isDark)
  - Gradient info card
  - Quiz icon
  - Total quizzes completed
  - Average score percentage
  - Total XP earned
  - Motivational message based on performance
```

### 3. Main App Initialization
Location: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);
  Get.put(ThemeManager());
  
  // Initialize Quiz Tracking Service
  await Get.putAsync(() => QuizTrackingService().init());
  
  runApp(const FlutterMateApp());
}
```

## 🎮 User Flow

### Taking a Quiz
1. User navigates to lesson detail page
2. Sees "Test Your Knowledge" card
3. Taps "Start Quiz" button
4. Quiz page loads with filtered questions
5. User reads question and selects answer
6. Answer is color-coded immediately
7. Explanation appears below
8. User navigates through questions
9. Completes all questions
10. Views results screen with feedback
11. Can retry or return home

### Viewing Quiz Stats
1. User navigates to Progress Tracker
2. Sees "Quiz Performance" card
3. Views completion count, average score, XP earned
4. Reads motivational message

## 🎨 Design System

### Colors
```dart
- Primary: AppColors.primary (purple)
- Quiz Card: AppColors.info (blue)
- Success: AppColors.success (green)
- Warning: AppColors.warning (orange)
- Correct Answer: Green gradient
- Wrong Answer: Orange gradient
```

### Animations
```dart
- fadeIn(): Smooth appearance
- slideY(): Vertical slide transition
- slideX(): Horizontal slide transition
- scale(): Bounce effect
- shake(): Celebration animation
- Delays: Staggered (200ms, 300ms, 400ms, etc.)
- Duration: 600ms for main animations
```

### Typography
```dart
- h1: Large titles (32px bold)
- h2: Section headers (24px bold)
- h3: Card titles (18px bold)
- bodyLarge: Main text (16px)
- bodyMedium: Secondary text (14px)
- caption: Labels (12px)
```

## 📊 Data Models

### QuizQuestion
```dart
class QuizQuestion {
  final String id;              // Unique identifier
  final String lessonId;        // Associated lesson
  final String question;        // Question text
  final List<String> options;   // Answer choices (4)
  final int correctAnswerIndex; // Index of correct answer (0-3)
  final String explanation;     // Why answer is correct
  final int points;             // XP awarded (usually 10)
}
```

### QuizResult
```dart
class QuizResult {
  final String lessonId;        // Quiz identifier
  final int score;              // Points earned
  final int maxScore;           // Maximum possible points
  final int xpEarned;           // XP awarded
  final DateTime timestamp;     // Completion time
  final int correctAnswers;     // Number correct
  final int totalQuestions;     // Total asked
  
  double get scorePercentage;   // Calculated percentage
  bool get isPassed;            // >= 70%
  String get formattedDate;     // Human-readable time
}
```

## 🔧 Configuration

### Pass Threshold
```dart
static const double PASS_THRESHOLD = 70.0;
```

### Points Per Question
```dart
static const int POINTS_PER_QUESTION = 10;
```

### Questions Per Quiz
```dart
static const int QUESTIONS_PER_QUIZ = 5;
```

### Time Estimate
```dart
static const String TIME_ESTIMATE = "~5 Minutes";
```

## 🚀 Future Enhancements

### Planned Features
- [ ] Timed quizzes with countdown
- [ ] Question difficulty levels
- [ ] Hints system (cost 5 XP)
- [ ] Review incorrect answers after completion
- [ ] Quiz history page
- [ ] Leaderboards with rankings
- [ ] Share results on social media
- [ ] Daily quiz challenges
- [ ] Streak tracking for quizzes
- [ ] Badge system for quiz achievements
- [ ] Question bookmarking
- [ ] Practice mode (no score tracking)
- [ ] Quiz categories/tags
- [ ] Custom quiz creation
- [ ] Multiplayer quiz battles

### Technical Improvements
- [ ] API integration for dynamic questions
- [ ] Analytics tracking for question difficulty
- [ ] A/B testing for explanations
- [ ] Offline support with sync
- [ ] Export quiz results to PDF
- [ ] Question report/feedback system
- [ ] Accessibility improvements (screen reader)
- [ ] Internationalization (i18n)

## 📝 Testing

### Test Coverage Needed
```dart
- Quiz question model serialization
- Quiz controller state transitions
- Score calculation accuracy
- Filtering by lesson ID
- Persistent storage save/load
- Navigation flow
- Animation timing
- Color state changes
- Result screen rendering
- Edge cases (empty questions, invalid lesson)
```

## 🐛 Known Issues

None currently! 🎉

## 💡 Tips for Developers

### Adding New Questions
```dart
// In quiz_controller.dart → loadAllQuestions()
const QuizQuestion(
  id: 'q26',
  lessonId: 'your-lesson-id',
  question: 'Your question text?',
  options: [
    'Option A',
    'Option B',
    'Option C',
    'Option D',
  ],
  correctAnswerIndex: 1,  // 0-based index
  explanation: 'Why this answer is correct...',
  points: 10,
),
```

### Styling Quiz Cards
```dart
// Use consistent gradient pattern
gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    AppColors.info,
    AppColors.info.withOpacity(0.7),
  ],
),
```

### Accessing Quiz Service
```dart
final quizService = Get.find<QuizTrackingService>();
final result = quizService.getQuizResult('dart-basics');
```

## 📚 References

- GetX Documentation: https://pub.dev/packages/get
- SharedPreferences: https://pub.dev/packages/shared_preferences
- Flutter Animate: https://pub.dev/packages/flutter_animate
- Material Design 3: https://m3.material.io/

---

**Last Updated:** October 26, 2025
**Version:** 0.3.0 (Quiz System)
**Author:** FlutterMate Team
