# Phase 3 Implementation Plan

## Overview
This document outlines the comprehensive implementation plan for Phase 3 features of Flutter Mate, including Personalized Learning Paths, Advanced Analytics, Community Forum, and Authentication System.

---

## 🎯 Feature 1: Personalized Learning Paths

### 1.1 User Skill Assessment System

#### Components to Create:
```
lib/features/assessment/
├── data/
│   ├── models/
│   │   ├── skill_assessment.dart
│   │   ├── skill_level.dart
│   │   └── assessment_question.dart
│   └── repositories/
│       └── assessment_repository.dart
├── controller/
│   └── assessment_controller.dart
└── presentation/
    ├── pages/
    │   ├── skill_assessment_page.dart
    │   └── assessment_results_page.dart
    └── widgets/
        ├── skill_level_indicator.dart
        ├── assessment_question_card.dart
        └── skill_radar_chart.dart
```

#### Data Models:
```dart
class SkillAssessment {
  final String id;
  final String userId;
  final Map<String, SkillLevel> skills; // e.g., "dart_basics": SkillLevel.intermediate
  final DateTime completedAt;
  final int totalScore;
  final Map<String, int> categoryScores;
}

enum SkillLevel {
  beginner,      // 0-30%
  elementary,    // 31-50%
  intermediate,  // 51-70%
  advanced,      // 71-90%
  expert        // 91-100%
}

class AssessmentQuestion {
  final String id;
  final String category;
  final String difficulty;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final int points;
}
```

#### Implementation Steps:
1. **Initial Assessment Flow**:
   - Welcome screen explaining the assessment
   - 20-30 questions covering all Flutter/Dart topics
   - Multiple difficulty levels per category
   - Time tracking (optional)
   - Adaptive questioning (harder questions if user performs well)

2. **Skill Calculation Algorithm**:
   ```dart
   // Calculate skill level based on category performance
   SkillLevel calculateSkillLevel(int score, int maxScore) {
     final percentage = (score / maxScore) * 100;
     if (percentage >= 91) return SkillLevel.expert;
     if (percentage >= 71) return SkillLevel.advanced;
     if (percentage >= 51) return SkillLevel.intermediate;
     if (percentage >= 31) return SkillLevel.elementary;
     return SkillLevel.beginner;
   }
   ```

3. **Visual Results**:
   - Radar chart showing skills across categories
   - Percentage scores per category
   - Recommended learning path based on results
   - Weak areas highlighted for improvement

### 1.2 Dynamic Roadmap Generation

#### Components to Create:
```
lib/features/personalized_roadmap/
├── data/
│   ├── models/
│   │   ├── learning_path.dart
│   │   ├── path_node.dart
│   │   └── recommendation.dart
│   └── services/
│       └── path_generator_service.dart
├── controller/
│   └── personalized_roadmap_controller.dart
└── presentation/
    └── widgets/
        ├── personalized_path_view.dart
        ├── skill_progress_card.dart
        └── next_lesson_suggestion.dart
```

#### Algorithm Logic:
```dart
class PathGeneratorService {
  // Generate personalized learning path
  LearningPath generatePath(SkillAssessment assessment) {
    final nodes = <PathNode>[];
    
    // 1. Identify weak areas
    final weakAreas = _identifyWeakAreas(assessment);
    
    // 2. Build foundation path
    for (var area in weakAreas) {
      nodes.addAll(_getFoundationalLessons(area));
    }
    
    // 3. Add progressive challenges
    nodes.addAll(_getProgressiveLessons(assessment.skills));
    
    // 4. Include practice projects
    nodes.addAll(_getRecommendedProjects(assessment));
    
    return LearningPath(
      userId: assessment.userId,
      nodes: nodes,
      estimatedDuration: _calculateDuration(nodes),
    );
  }
}
```

#### Features:
- **Smart Lesson Sequencing**: Order lessons based on dependencies and skill level
- **Skip Recommendations**: Suggest skipping beginner content for advanced users
- **Focus Areas**: Highlight priority learning areas
- **Alternative Paths**: Offer multiple paths (fast-track, comprehensive, project-based)
- **Adaptive Adjustments**: Update path based on quiz performance

### 1.3 Adaptive Difficulty Adjustment

#### Implementation:
```dart
class AdaptiveDifficultyController extends GetxController {
  // Track user performance
  final performanceHistory = <String, List<QuizResult>>[].obs;
  
  // Adjust difficulty based on recent performance
  DifficultyLevel adjustDifficulty(String category) {
    final recentResults = _getRecentResults(category, limit: 5);
    final avgScore = _calculateAverageScore(recentResults);
    
    if (avgScore >= 90) return DifficultyLevel.hard;
    if (avgScore >= 70) return DifficultyLevel.medium;
    return DifficultyLevel.easy;
  }
  
  // Recommend next lesson difficulty
  Lesson getNextLesson(String category) {
    final difficulty = adjustDifficulty(category);
    return lessonRepository.getLessonByDifficulty(category, difficulty);
  }
}
```

#### Dynamic Quiz Generation:
- Pull harder questions if user scores 90%+
- Add review questions for topics with <70% scores
- Mix question difficulties based on confidence level
- Bonus challenges for expert users

### 1.4 Custom Learning Recommendations

#### Recommendation Engine:
```dart
class RecommendationEngine {
  List<Recommendation> generateRecommendations(User user) {
    final recommendations = <Recommendation>[];
    
    // 1. Based on incomplete lessons
    recommendations.addAll(_getIncompletePathRecommendations(user));
    
    // 2. Based on weak quiz areas
    recommendations.addAll(_getWeakAreaRecommendations(user));
    
    // 3. Based on study time patterns
    recommendations.addAll(_getTimeBasedRecommendations(user));
    
    // 4. Trending/popular lessons
    recommendations.addAll(_getTrendingRecommendations());
    
    // 5. Similar users' paths (collaborative filtering)
    recommendations.addAll(_getSimilarUsersRecommendations(user));
    
    return _prioritizeRecommendations(recommendations);
  }
}
```

#### UI Components:
- **Dashboard Widget**: "Recommended For You" section
- **Smart Notifications**: "You haven't studied widgets in 3 days"
- **Daily Goals**: Auto-generated based on pace and availability
- **Quick Actions**: "Continue where you left off"

---

## 📊 Feature 2: Advanced Analytics

### 2.1 Detailed Study Time Analytics

#### Components to Create:
```
lib/features/analytics/
├── data/
│   ├── models/
│   │   ├── study_session.dart
│   │   ├── time_analytics.dart
│   │   └── productivity_metrics.dart
│   └── services/
│       ├── analytics_service.dart
│       └── time_tracker_service.dart
├── controller/
│   └── analytics_controller.dart
└── presentation/
    ├── pages/
    │   ├── analytics_dashboard_page.dart
    │   └── detailed_stats_page.dart
    └── widgets/
        ├── time_chart_widget.dart
        ├── productivity_card.dart
        ├── streak_calendar.dart
        └── study_heatmap.dart
```

#### Data Models:
```dart
class StudySession {
  final String id;
  final String userId;
  final String lessonId;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final bool completed;
  final List<String> activities; // ['reading', 'quiz', 'practice']
}

class TimeAnalytics {
  final Duration totalStudyTime;
  final Duration averageSessionDuration;
  final Map<String, Duration> timePerCategory;
  final Map<DateTime, Duration> dailyStudyTime;
  final int currentStreak;
  final int longestStreak;
  final List<int> studyHoursDistribution; // 24-hour array
  final List<int> studyDaysDistribution; // 7-day array
}

class ProductivityMetrics {
  final double focusScore; // 0-100
  final double completionRate; // percentage
  final int sessionsPerWeek;
  final Duration optimalStudyTime;
  final List<String> peakProductivityHours;
  final Map<String, double> categoryProgress;
}
```

#### Analytics Features:

1. **Time Tracking Dashboard**:
   - Total study time (all time, this month, this week, today)
   - Average session duration
   - Study time by category (pie chart)
   - Daily/weekly/monthly trends (line chart)

2. **Study Patterns**:
   - Best study hours (when you're most productive)
   - Study consistency (streak calendar)
   - Session length patterns
   - Break patterns and recommendations

3. **Productivity Insights**:
   - Focus score calculation (completed sessions vs abandoned)
   - Optimal study duration recommendation
   - Distraction analysis
   - Efficiency metrics (time spent vs lessons completed)

### 2.2 Quiz Performance Trends

#### Implementation:
```dart
class QuizAnalyticsService {
  // Comprehensive quiz statistics
  QuizPerformanceTrends getPerformanceTrends(String userId) {
    return QuizPerformanceTrends(
      overallAccuracy: _calculateOverallAccuracy(),
      categoryPerformance: _getCategoryPerformance(),
      difficultyPerformance: _getDifficultyPerformance(),
      improvementTrend: _calculateImprovementTrend(),
      weakTopics: _identifyWeakTopics(),
      strongTopics: _identifyStrongTopics(),
      streakData: _getStreakData(),
      timeToAnswer: _getAverageTimePerQuestion(),
    );
  }
  
  // Trend calculation
  TrendDirection _calculateImprovementTrend() {
    final recent = _getRecentQuizzes(limit: 10);
    final older = _getOlderQuizzes(limit: 10);
    
    final recentAvg = recent.map((q) => q.score).average;
    final olderAvg = older.map((q) => q.score).average;
    
    if (recentAvg > olderAvg + 5) return TrendDirection.improving;
    if (recentAvg < olderAvg - 5) return TrendDirection.declining;
    return TrendDirection.stable;
  }
}
```

#### Visualizations:
- **Performance Line Chart**: Score trends over time
- **Category Radar Chart**: Performance across all categories
- **Difficulty Distribution**: Performance by difficulty level
- **Topic Heatmap**: Color-coded topic mastery
- **Accuracy Timeline**: Right/wrong answer patterns

### 2.3 Learning Pattern Visualization

#### Charts & Graphs:
```dart
class LearningVisualizationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Study Heatmap (GitHub-style)
        StudyHeatmapWidget(
          data: controller.dailyStudyData,
          maxIntensity: controller.maxDailyTime,
        ),
        
        // 2. Progress Curve
        ProgressCurveChart(
          data: controller.cumulativeLessons,
        ),
        
        // 3. Activity Timeline
        ActivityTimelineWidget(
          sessions: controller.recentSessions,
        ),
        
        // 4. Category Progress Bars
        CategoryProgressWidget(
          categories: controller.categoryProgress,
        ),
        
        // 5. Learning Velocity
        VelocityChartWidget(
          lessonsPerWeek: controller.weeklyProgress,
        ),
      ],
    );
  }
}
```

### 2.4 Weekly/Monthly Progress Reports

#### Auto-Generated Reports:
```dart
class ProgressReportService {
  // Generate weekly report
  WeeklyReport generateWeeklyReport(String userId) {
    final week = DateTime.now().subtract(Duration(days: 7));
    
    return WeeklyReport(
      totalStudyTime: _getTotalTime(week),
      lessonsCompleted: _getLessonsCompleted(week),
      quizzesAttempted: _getQuizCount(week),
      averageScore: _getAverageScore(week),
      xpEarned: _getXPEarned(week),
      achievements: _getAchievements(week),
      topCategories: _getTopCategories(week),
      improvementAreas: _getImprovementAreas(week),
      comparison: _compareWithPreviousWeek(),
      recommendation: _generateRecommendation(),
    );
  }
  
  // Share report feature
  Future<void> shareReport(WeeklyReport report) async {
    final image = await _generateReportImage(report);
    await Share.shareFiles([image], text: 'My Flutter learning progress!');
  }
}
```

#### Report Features:
- **Automated Email/Notification**: Weekly summary every Monday
- **Beautiful Report Cards**: Shareable progress graphics
- **Comparison Metrics**: Week-over-week, month-over-month
- **Milestone Celebrations**: Highlighted achievements
- **Goal Tracking**: Progress toward personal goals
- **Insights & Tips**: Personalized suggestions

### 2.5 Performance Heatmaps

#### Heatmap Types:
1. **Study Frequency Heatmap**: GitHub-style contribution graph
2. **Time-of-Day Heatmap**: When you study most
3. **Topic Difficulty Heatmap**: Which topics are challenging
4. **Quiz Performance Heatmap**: Visual accuracy map
5. **Focus Heatmap**: Concentration levels throughout day

```dart
class HeatmapWidget extends StatelessWidget {
  final Map<DateTime, double> data;
  final Color Function(double) colorGenerator;
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 365,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 53, // weeks in year
      ),
      itemBuilder: (context, index) {
        final date = _getDateForIndex(index);
        final value = data[date] ?? 0;
        return Container(
          margin: EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: colorGenerator(value),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}
```

---

## 👥 Feature 3: Community Forum

### 3.1 Discussion Boards for Lessons

#### Components to Create:
```
lib/features/community/
├── data/
│   ├── models/
│   │   ├── discussion_thread.dart
│   │   ├── post.dart
│   │   ├── comment.dart
│   │   └── user_profile.dart
│   └── repositories/
│       ├── forum_repository.dart
│       └── user_repository.dart
├── controller/
│   ├── forum_controller.dart
│   └── discussion_controller.dart
└── presentation/
    ├── pages/
    │   ├── forum_home_page.dart
    │   ├── discussion_thread_page.dart
    │   ├── create_post_page.dart
    │   └── user_profile_page.dart
    └── widgets/
        ├── post_card.dart
        ├── comment_widget.dart
        ├── reply_widget.dart
        ├── user_avatar.dart
        └── reputation_badge.dart
```

#### Data Models:
```dart
class DiscussionThread {
  final String id;
  final String lessonId;
  final String title;
  final String content;
  final String authorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final int views;
  final int replies;
  final int upvotes;
  final bool isPinned;
  final bool isSolved;
  final String? acceptedAnswerId;
}

class Post {
  final String id;
  final String threadId;
  final String content;
  final String authorId;
  final DateTime createdAt;
  final DateTime? editedAt;
  final List<String> attachments;
  final int upvotes;
  final int downvotes;
  final bool isAccepted;
  final List<Comment> comments;
}

class Comment {
  final String id;
  final String postId;
  final String content;
  final String authorId;
  final DateTime createdAt;
  final int upvotes;
}
```

#### Features:
1. **Thread Organization**:
   - Threads linked to specific lessons
   - Category-based forum sections
   - Sorting (recent, popular, unanswered)
   - Filtering by tags
   - Search functionality

2. **Rich Text Editor**:
   - Markdown support
   - Code syntax highlighting
   - Image uploads
   - Link previews
   - Emoji support

3. **Engagement**:
   - Upvote/downvote system
   - Mark answer as accepted
   - Follow threads
   - Notifications for replies
   - Bookmark posts

### 3.2 Q&A System

#### Implementation:
```dart
class QAController extends GetxController {
  // Ask a question
  Future<void> askQuestion({
    required String lessonId,
    required String title,
    required String content,
    required List<String> tags,
  }) async {
    final thread = DiscussionThread(
      id: _generateId(),
      lessonId: lessonId,
      title: title,
      content: content,
      authorId: authController.currentUser.value!.id,
      createdAt: DateTime.now(),
      tags: tags,
      views: 0,
      replies: 0,
      upvotes: 0,
    );
    
    await forumRepository.createThread(thread);
    
    // Notify relevant users (mentors, topic experts)
    await _notifyExperts(thread);
  }
  
  // Answer question
  Future<void> answerQuestion({
    required String threadId,
    required String content,
  }) async {
    final post = Post(
      id: _generateId(),
      threadId: threadId,
      content: content,
      authorId: authController.currentUser.value!.id,
      createdAt: DateTime.now(),
    );
    
    await forumRepository.createPost(post);
    
    // Award reputation points
    await _awardReputationPoints(post.authorId, 10);
    
    // Notify thread author
    await _notifyThreadAuthor(threadId);
  }
  
  // Accept answer
  Future<void> acceptAnswer(String postId) async {
    await forumRepository.markAsAccepted(postId);
    
    // Award bonus reputation to answer author
    final post = await forumRepository.getPost(postId);
    await _awardReputationPoints(post.authorId, 50);
  }
}
```

#### Features:
- **Smart Question Suggestions**: Similar questions while typing
- **Expert Matching**: Notify users with expertise in topic
- **Answer Quality**: Community voting on helpful answers
- **Best Answer**: Question author can mark accepted solution
- **Question Status**: Open, Answered, Closed
- **Bounty System** (optional): Offer XP for good answers

### 3.3 User Profiles and Reputation System

#### User Profile Model:
```dart
class UserProfile {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final DateTime joinedAt;
  
  // Reputation & Stats
  final int reputationPoints;
  final ReputationLevel level;
  final int questionsAsked;
  final int answersGiven;
  final int acceptedAnswers;
  final int helpfulVotes;
  final List<String> badges;
  final List<String> expertTopics;
  
  // Learning Stats
  final int lessonsCompleted;
  final int totalXP;
  final int currentStreak;
  final Map<String, double> categoryProgress;
}

enum ReputationLevel {
  newbie,        // 0-100
  contributor,   // 101-500
  helper,        // 501-1000
  expert,        // 1001-5000
  master,        // 5001-10000
  legend,        // 10001+
}
```

#### Reputation System:
```dart
class ReputationService {
  // Award points for actions
  final Map<String, int> reputationPoints = {
    'ask_question': 5,
    'answer_question': 10,
    'accepted_answer': 50,
    'upvote_received': 5,
    'helpful_answer': 15,
    'first_answer': 20,
    'edit_contribution': 3,
    'report_spam': 10,
  };
  
  // Calculate level
  ReputationLevel calculateLevel(int points) {
    if (points >= 10001) return ReputationLevel.legend;
    if (points >= 5001) return ReputationLevel.master;
    if (points >= 1001) return ReputationLevel.expert;
    if (points >= 501) return ReputationLevel.helper;
    if (points >= 101) return ReputationLevel.contributor;
    return ReputationLevel.newbie;
  }
  
  // Award badges
  void checkAndAwardBadges(UserProfile user) {
    // Example badges
    if (user.answersGiven >= 10 && !user.badges.contains('helpful_hands')) {
      _awardBadge(user.id, 'helpful_hands');
    }
    if (user.acceptedAnswers >= 5 && !user.badges.contains('solution_master')) {
      _awardBadge(user.id, 'solution_master');
    }
    // More badge conditions...
  }
}
```

#### Profile Features:
- **Public Profile Page**: Showcase stats and achievements
- **Activity Timeline**: Recent questions, answers, comments
- **Expertise Areas**: Categories where user is most active
- **Reputation Graph**: Progress over time
- **Badges Collection**: Achievements display
- **Leaderboards**: Top contributors, helpers

### 3.4 Comment and Reply System

#### Implementation:
```dart
class CommentController extends GetxController {
  // Add comment to post
  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final comment = Comment(
      id: _generateId(),
      postId: postId,
      content: content,
      authorId: authController.currentUser.value!.id,
      createdAt: DateTime.now(),
      upvotes: 0,
    );
    
    await forumRepository.createComment(comment);
    
    // Notify post author
    await _notifyPostAuthor(postId);
  }
  
  // Nested replies support
  Future<void> replyToComment({
    required String parentCommentId,
    required String content,
  }) async {
    final reply = Comment(
      id: _generateId(),
      postId: parentCommentId,
      content: '@${_getUserMention()} $content',
      authorId: authController.currentUser.value!.id,
      createdAt: DateTime.now(),
    );
    
    await forumRepository.createReply(reply);
  }
}
```

#### UI Features:
- **Threaded Conversations**: Nested replies with indentation
- **@ Mentions**: Tag users in comments
- **Rich Formatting**: Inline code, bold, italic
- **Reaction Emojis**: Quick reactions to comments
- **Edit/Delete**: Author can modify their comments
- **Report System**: Flag inappropriate content

---

## 🔐 Feature 4: Authentication System

### 4.1 Components to Create

```
lib/features/auth/
├── data/
│   ├── models/
│   │   ├── user.dart
│   │   ├── auth_result.dart
│   │   └── user_preferences.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── services/
│       └── auth_service.dart
├── controller/
│   └── auth_controller.dart
└── presentation/
    ├── pages/
    │   ├── login_page.dart
    │   ├── signup_page.dart
    │   ├── forgot_password_page.dart
    │   ├── profile_setup_page.dart
    │   └── email_verification_page.dart
    └── widgets/
        ├── auth_text_field.dart
        ├── social_login_button.dart
        └── auth_divider.dart
```

### 4.2 Authentication Methods

#### Firebase Authentication Setup:
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Email/Password Authentication
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user profile in Firestore
      await _createUserProfile(
        uid: credential.user!.uid,
        email: email,
        username: username,
      );
      
      // Send verification email
      await credential.user!.sendEmailVerification();
      
      return AuthResult.success(credential.user!);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }
  
  // Google Sign-In
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return AuthResult.cancelled();
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create profile if new user
      await _ensureUserProfile(userCredential.user!);
      
      return AuthResult.success(userCredential.user!);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }
  
  // Apple Sign-In
  Future<AuthResult> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      await _ensureUserProfile(userCredential.user!);
      
      return AuthResult.success(userCredential.user!);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }
  
  // Anonymous Sign-In (for offline mode)
  Future<AuthResult> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return AuthResult.success(credential.user!);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }
}
```

### 4.3 User Model

```dart
class User {
  final String id;
  final String email;
  final String username;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  
  // Auth Provider
  final AuthProvider provider; // email, google, apple, anonymous
  
  // Preferences
  final UserPreferences preferences;
  
  // Subscription (for future premium features)
  final SubscriptionTier tier;
  final DateTime? subscriptionExpiresAt;
}

enum AuthProvider {
  email,
  google,
  apple,
  anonymous,
}

enum SubscriptionTier {
  free,
  premium,
  pro,
}

class UserPreferences {
  final bool darkMode;
  final String language;
  final bool notifications;
  final bool emailUpdates;
  final int dailyGoalMinutes;
  final List<String> favoriteCategories;
}
```

### 4.4 Auth Controller

```dart
class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initAuthListener();
  }
  
  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        _loadUserProfile(firebaseUser.uid);
      } else {
        currentUser.value = null;
        isAuthenticated.value = false;
      }
    });
  }
  
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    isLoading.value = true;
    
    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      username: username,
    );
    
    if (result.isSuccess) {
      Get.snackbar('Success', 'Please verify your email');
      Get.offAllNamed('/email-verification');
    } else {
      Get.snackbar('Error', result.message);
    }
    
    isLoading.value = false;
  }
  
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    
    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );
    
    if (result.isSuccess) {
      Get.offAllNamed('/home');
    } else {
      Get.snackbar('Error', result.message);
    }
    
    isLoading.value = false;
  }
  
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    final result = await _authService.signInWithGoogle();
    
    if (result.isSuccess) {
      Get.offAllNamed('/home');
    } else if (!result.isCancelled) {
      Get.snackbar('Error', result.message);
    }
    
    isLoading.value = false;
  }
  
  Future<void> signOut() async {
    await _authService.signOut();
    Get.offAllNamed('/login');
  }
  
  Future<void> resetPassword(String email) async {
    await _authService.sendPasswordResetEmail(email);
    Get.snackbar('Success', 'Password reset email sent');
  }
}
```

### 4.5 Auth UI Pages

#### Login Page:
```dart
class LoginPage extends StatelessWidget {
  final AuthController authController = Get.find();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo & Title
              Image.asset('assets/icons/app_logo.png', height: 80),
              SizedBox(height: 16),
              Text('Welcome Back!', style: AppTextStyles.h1),
              SizedBox(height: 48),
              
              // Email Field
              AuthTextField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              SizedBox(height: 16),
              
              // Password Field
              AuthTextField(
                controller: passwordController,
                label: 'Password',
                isPassword: true,
                prefixIcon: Icons.lock_outlined,
              ),
              SizedBox(height: 8),
              
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed('/forgot-password'),
                  child: Text('Forgot Password?'),
                ),
              ),
              SizedBox(height: 24),
              
              // Sign In Button
              Obx(() => ElevatedButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () => authController.signIn(
                          email: emailController.text,
                          password: passwordController.text,
                        ),
                child: authController.isLoading.value
                    ? CircularProgressIndicator()
                    : Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 56),
                ),
              )),
              SizedBox(height: 24),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 24),
              
              // Social Login Buttons
              SocialLoginButton(
                onPressed: () => authController.signInWithGoogle(),
                icon: 'assets/icons/google.png',
                label: 'Continue with Google',
              ),
              SizedBox(height: 12),
              SocialLoginButton(
                onPressed: () => authController.signInWithApple(),
                icon: 'assets/icons/apple.png',
                label: 'Continue with Apple',
                isDark: true,
              ),
              SizedBox(height: 24),
              
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  TextButton(
                    onPressed: () => Get.toNamed('/signup'),
                    child: Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 4.6 Security Features

#### Implementation:
```dart
class SecurityService {
  // Email verification check
  Future<bool> isEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }
  
  // Two-factor authentication (optional)
  Future<void> enableTwoFactor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.multiFactor.enroll(
        PhoneMultiFactorGenerator.getAssertion(
          phoneVerificationInfo,
        ),
      );
    }
  }
  
  // Session management
  Future<void> enforceSessionTimeout() async {
    // Implement automatic logout after inactivity
    final lastActivity = await _getLastActivityTime();
    final now = DateTime.now();
    
    if (now.difference(lastActivity).inMinutes > 30) {
      await FirebaseAuth.instance.signOut();
    }
  }
  
  // Secure data storage
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  Future<void> storeToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }
}
```

---

## 🚀 Implementation Priority & Timeline

### Phase 3.1 - Authentication (Weeks 1-2)
- [ ] Set up Firebase project
- [ ] Implement email/password auth
- [ ] Add Google Sign-In
- [ ] Add Apple Sign-In
- [ ] Create auth UI pages
- [ ] Implement session management
- [ ] Add email verification

### Phase 3.2 - User Profiles & Analytics Foundation (Weeks 3-4)
- [ ] Create user profile system
- [ ] Set up analytics data models
- [ ] Implement time tracking service
- [ ] Create analytics dashboard UI
- [ ] Add basic charts (study time, progress)

### Phase 3.3 - Advanced Analytics (Weeks 5-6)
- [ ] Implement quiz analytics
- [ ] Add performance trends
- [ ] Create heatmap visualizations
- [ ] Build weekly/monthly reports
- [ ] Add sharing capabilities

### Phase 3.4 - Skill Assessment (Weeks 7-8)
- [ ] Design assessment questions
- [ ] Implement assessment flow
- [ ] Create skill calculation algorithm
- [ ] Build results visualization
- [ ] Add radar chart

### Phase 3.5 - Personalized Learning (Weeks 9-10)
- [ ] Implement path generator
- [ ] Add recommendation engine
- [ ] Create personalized dashboard
- [ ] Implement adaptive difficulty
- [ ] Add smart notifications

### Phase 3.6 - Community Forum (Weeks 11-14)
- [ ] Set up Firestore for forum data
- [ ] Implement discussion threads
- [ ] Add Q&A functionality
- [ ] Create reputation system
- [ ] Build user profiles
- [ ] Add comment/reply system
- [ ] Implement moderation tools

### Phase 3.7 - Testing & Polish (Weeks 15-16)
- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] UI/UX refinements
- [ ] Bug fixes
- [ ] Documentation

---

## 📦 Required Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  # Auth
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  google_sign_in: ^6.1.6
  sign_in_with_apple: ^5.0.0
  flutter_secure_storage: ^9.0.0
  
  # Database
  cloud_firestore: ^4.13.0
  
  # Analytics & Charts
  fl_chart: ^0.65.0
  syncfusion_flutter_charts: ^24.1.41
  charts_flutter: ^0.12.0
  
  # State Management (already have GetX)
  get: ^4.6.6
  
  # Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Image & Media
  cached_network_image: ^3.3.0
  image_picker: ^1.0.5
  
  # Rich Text
  flutter_markdown: ^0.6.18
  flutter_quill: ^9.1.6
  
  # Social Sharing
  share_plus: ^7.2.1
  
  # Notifications
  flutter_local_notifications: ^16.2.0
  
  # Utils
  intl: ^0.18.1
  timeago: ^3.5.0
  collection: ^1.18.0
```

---

## 🎨 UI/UX Considerations

### Design Principles:
1. **Consistency**: Match existing app design language
2. **Accessibility**: Support screen readers, high contrast
3. **Responsiveness**: Work on all screen sizes
4. **Performance**: Lazy loading, pagination for large datasets
5. **Offline Support**: Cache data, sync when online
6. **Dark Mode**: All new features support dark theme

### Color Scheme Extensions:
```dart
// Add to AppColors
class AppColors {
  // Existing colors...
  
  // Analytics Colors
  static const Color analyticsBlue = Color(0xFF42A5F5);
  static const Color analyticsGreen = Color(0xFF66BB6A);
  static const Color analyticsOrange = Color(0xFFFFB300);
  static const Color analyticsPurple = Color(0xFFAB47BC);
  static const Color analyticsRed = Color(0xFFEF5350);
  
  // Forum Colors
  static const Color questionColor = Color(0xFF42A5F5);
  static const Color answerColor = Color(0xFF66BB6A);
  static const Color expertBadge = Color(0xFFFFB300);
  static const Color reputationGold = Color(0xFFFFD700);
  
  // Status Colors
  static const Color onlineStatus = Color(0xFF66BB6A);
  static const Color awayStatus = Color(0xFFFFB300);
  static const Color offlineStatus = Color(0xFF9E9E9E);
}
```

---

## 🧪 Testing Strategy

### Unit Tests:
- Auth service methods
- Analytics calculations
- Recommendation algorithms
- Reputation point calculations

### Integration Tests:
- Complete auth flows
- Forum CRUD operations
- Analytics data collection
- Report generation

### Widget Tests:
- All new UI components
- Chart rendering
- Form validation
- Navigation flows

### E2E Tests:
- User registration → assessment → personalized path
- Post question → receive answer → accept answer
- Complete lesson → view analytics → share report

---

## 📊 Success Metrics

### Key Performance Indicators:
1. **User Engagement**:
   - Daily/Monthly active users increase
   - Average session duration
   - Feature adoption rate

2. **Learning Outcomes**:
   - Completion rates improvement
   - Quiz scores improvement
   - User retention increase

3. **Community Health**:
   - Questions answered percentage
   - Average response time
   - User satisfaction scores

4. **Technical Performance**:
   - Page load times
   - API response times
   - Error rates

---

## 🔄 Data Migration Plan

If you have existing users:
1. Create migration scripts for user data
2. Generate default assessments for existing users
3. Backfill analytics from existing study data
4. Notify users of new features
5. Provide tutorial/onboarding for new features

---

This comprehensive plan provides a roadmap for implementing all Phase 3 features. Would you like me to start implementing any specific feature first, or would you like me to create more detailed documentation for a particular component?
