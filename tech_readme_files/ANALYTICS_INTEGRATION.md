# Analytics Integration Guide

## Overview
The analytics system now automatically tracks study time from **all learning activities** in the app:

1. ✅ **Lesson Study Timer** - Automatically tracked
2. ✅ **Quiz Sessions** - Now integrated (newly added)
3. ⏱️ **Code Playground** - Can be integrated (TODO)
4. ⏱️ **Assessment Tests** - Can be integrated (TODO)

---

## 📊 How It Works

### Study Session Flow

```
1. User starts activity (lesson/quiz/assessment)
   ↓
2. AnalyticsController.startStudySession() called
   ↓
3. Session tracked in memory
   ↓
4. User completes or exits activity
   ↓
5. AnalyticsController.endStudySession() called
   ↓
6. Session saved to Hive (local)
   ↓
7. Session synced to Firestore (cloud)
   ↓
8. Analytics dashboard updated
```

---

## ✅ Integrated Features

### 1. Lesson Study Timer
**Location**: `lib/features/roadmap/controller/study_timer_controller.dart`

**How it works**:
- When user opens a lesson and starts the timer
- `startTimer()` → calls `AnalyticsController.startStudySession()`
- When timer completes or user leaves
- `_onTimerComplete()` / `_pauseTimer()` → calls `AnalyticsController.endStudySession()`

**Code**:
```dart
// Start tracking
analyticsController.startStudySession(
  lessonId: lessonId,
  lessonTitle: lesson.title,
  category: lesson.difficulty,
);

// End tracking
await analyticsController.endStudySession(completed: true);
```

**Tracks**:
- ✅ Time spent studying each lesson
- ✅ Lesson title and difficulty
- ✅ Completion status
- ✅ Study activities

---

### 2. Quiz Sessions (Newly Added)
**Location**: `lib/features/quiz/controller/quiz_controller.dart`

**How it works**:
- When user starts a quiz for a lesson
- `onInit()` → calls `_startQuizTracking()`
- When quiz is completed or exited
- `completeQuiz()` / `onClose()` → calls `_endQuizTracking()`

**Code**:
```dart
// On quiz start
void _startQuizTracking() {
  final analyticsController = Get.find<AnalyticsController>();
  analyticsController.startStudySession(
    lessonId: currentLessonId.value,
    lessonTitle: 'Quiz: $lessonId',
    category: 'Quiz',
  );
}

// On quiz end
Future<void> _endQuizTracking({required bool completed}) async {
  final analyticsController = Get.find<AnalyticsController>();
  await analyticsController.endStudySession(completed: completed);
}
```

**Tracks**:
- ✅ Time spent on each quiz
- ✅ Quiz completion status
- ✅ Associated lesson ID

---

## ⏱️ Features to Integrate (TODO)

### 3. Code Playground
**Location**: `lib/features/code_playground/` (if exists)

**How to integrate**:
```dart
// When user opens code editor
void onPlaygroundOpen(String projectId, String projectTitle) {
  final analyticsController = Get.find<AnalyticsController>();
  analyticsController.startStudySession(
    lessonId: projectId,
    lessonTitle: projectTitle,
    category: 'Code Practice',
  );
}

// When user closes or saves project
Future<void> onPlaygroundClose({bool completed = true}) async {
  final analyticsController = Get.find<AnalyticsController>();
  await analyticsController.endStudySession(completed: completed);
}
```

---

### 4. Assessment Tests
**Location**: `lib/features/assessment/controller/assessment_controller.dart`

**How to integrate**:
```dart
// In startAssessment()
void startAssessment() {
  isAssessmentActive.value = true;
  currentQuestionIndex.value = 0;
  answers.clear();
  
  // Add analytics tracking
  final analyticsController = Get.find<AnalyticsController>();
  analyticsController.startStudySession(
    lessonId: 'skill_assessment',
    lessonTitle: 'Skill Assessment Test',
    category: 'Assessment',
  );
}

// In _finishAssessment()
Future<void> _finishAssessment() async {
  // ... existing code ...
  
  // Add analytics tracking
  final analyticsController = Get.find<AnalyticsController>();
  await analyticsController.endStudySession(completed: true);
}
```

---

## 📈 Analytics Data Structure

### Study Session Model
```dart
class StudySession {
  final String id;              // Unique session ID
  final String userId;          // User who studied
  final String lessonId;        // Lesson/quiz/activity ID
  final String lessonTitle;     // Human-readable title
  final String category;        // Category: Beginner/Intermediate/Advanced/Quiz/etc
  final DateTime startTime;     // When session started
  final DateTime endTime;       // When session ended
  final bool completed;         // Did user complete or quit?
  final List<String> activities; // Activities performed
}
```

### Analytics Calculations
- **Total Study Time**: Sum of all session durations
- **Today/Week/Month Time**: Filtered by date range
- **Current Streak**: Consecutive days with at least one session
- **Longest Streak**: Maximum consecutive days ever
- **Time per Category**: Grouped by lesson difficulty or type
- **Study Patterns**: When user typically studies (hour/day analysis)

---

## 🔄 Data Persistence

### Dual Storage Strategy
1. **Hive (Local Cache)**:
   - Saves immediately
   - Works offline
   - Fast retrieval
   - Used as primary source

2. **Firestore (Cloud Sync)**:
   - Syncs when online
   - Persists across devices
   - Backup and recovery
   - Used for multi-device support

### Offline Behavior
```
User studies offline:
├─ Session saved to Hive ✅
├─ Firestore save fails (offline)
└─ User sees study time immediately in analytics ✅

User goes online:
├─ Next session automatically syncs failed sessions
└─ Firestore updated in background
```

---

## 🎯 How Users Track Study Time

### Method 1: Lesson Study Timer (Primary)
1. Go to **Roadmap** → Select a lesson
2. Tap **"Start Learning"** or use the timer widget
3. Study the lesson content
4. Timer tracks your time automatically
5. When done, timer completes or you navigate away
6. ✅ Session saved to analytics

### Method 2: Quiz Completion (Now Tracking!)
1. Go to a lesson and start the quiz
2. Answer the quiz questions
3. Time spent is automatically tracked
4. When you complete or exit the quiz
5. ✅ Session saved to analytics

### Method 3: Just Browse (No Tracking)
- If you just browse lessons without starting timer or quiz
- ❌ No session is created
- This is intentional - we only track active learning

---

## 🧪 Testing Analytics

### Test Lesson Study Timer
1. Open any lesson from Roadmap
2. Start the study timer (⏯️ button)
3. Let it run for 1-2 minutes
4. Complete or close the lesson
5. Check Analytics Dashboard
6. ✅ Should see study time updated

### Test Quiz Tracking
1. Go to a lesson
2. Start the quiz
3. Answer some questions
4. Complete the quiz
5. Check Analytics Dashboard
6. ✅ Should see quiz time added

### View Analytics
1. Go to **Analytics Dashboard**
2. You should see:
   - **Today**: Time studied today
   - **This Week**: Last 7 days
   - **This Month**: Last 30 days
   - **Total**: All-time study time
   - **Current Streak**: Consecutive days
   - **Recent Sessions**: List of last 10 sessions

---

## 🐛 Troubleshooting

### Analytics Showing 0m
**Possible Causes**:
1. Haven't started any study sessions yet
2. Study timer not started (just browsing)
3. Missing Firestore index (check console for errors)
4. Guest user (analytics requires authentication)

**Solutions**:
1. **Start a study session**: Use lesson timer or take a quiz
2. **Check authentication**: Analytics doesn't work for guests
3. **Create Firestore index**: See `ANALYTICS_FIX.md`
4. **Check console**: Look for error messages

### Sessions Not Saving
**Check**:
1. Is user authenticated? (Not guest)
2. Check Hive box is open: `Hive.box('quiz')`
3. Check console for save errors
4. Verify `endStudySession()` is being called

### Streak Not Incrementing
**How Streaks Work**:
- You must study on consecutive calendar days
- Missing a day resets streak to 0
- Multiple sessions in one day = still 1 day streak
- Streak checks midnight-to-midnight (not 24-hour periods)

**Example**:
```
Day 1 (Mon): Study 30m → Streak = 1
Day 2 (Tue): Study 15m → Streak = 2
Day 3 (Wed): No study → Streak = 0
Day 4 (Thu): Study 45m → Streak = 1
```

---

## 📊 Firestore Index Requirements

### Required Composite Index
**Collection**: `study_sessions`
**Fields**:
- `userId` → Ascending
- `startTime` → Descending

### How to Create
See `tech_readme_files/ANALYTICS_FIX.md` for detailed instructions.

---

## 🎨 UI Components

### Analytics Dashboard Widgets
1. **Study Time Card** - Today/Week/Month/Total display
2. **Streak Calendar** - Visual streak tracker (49-day grid)
3. **Productivity Metrics** - Focus score, completion rate
4. **Time Charts** - Study patterns by hour/day
5. **Recent Sessions** - Last 10 study sessions list
6. **Insights Card** - Personalized recommendations

---

## 📝 Best Practices

### For Developers
1. **Always call `startStudySession()`** when user starts learning activity
2. **Always call `endStudySession()`** when activity ends or user exits
3. **Use try-catch** around analytics calls (they shouldn't break the feature)
4. **Provide meaningful titles** for better user experience
5. **Set completed=true** only if user finished the activity
6. **Test offline behavior** - analytics should work without internet

### For Users
1. **Use the study timer** to track lesson study time
2. **Complete quizzes** to track quiz time
3. **Study consistently** to build streaks
4. **Check analytics regularly** to see progress
5. **Study at least once per day** to maintain streaks

---

## 🚀 Future Enhancements

### Potential Features
- [ ] Study goals and reminders
- [ ] Detailed productivity insights
- [ ] Compare with other learners (anonymous)
- [ ] Custom study schedules
- [ ] Weekly/monthly reports export
- [ ] Study time leaderboards
- [ ] Achievement badges for streaks
- [ ] AI-powered study recommendations

---

## 🔗 Related Files

### Core Analytics
- `lib/features/analytics/controller/analytics_controller.dart` - Main controller
- `lib/features/analytics/data/services/time_tracker_service.dart` - Session tracking
- `lib/features/analytics/data/models/study_session.dart` - Session model
- `lib/features/analytics/data/models/time_analytics.dart` - Analytics model

### Integrations
- `lib/features/roadmap/controller/study_timer_controller.dart` - Lesson timer
- `lib/features/quiz/controller/quiz_controller.dart` - Quiz tracking ✨ NEW

### Documentation
- `tech_readme_files/ANALYTICS_FIX.md` - Firestore index setup
- `tech_readme_files/ASSESSMENT_TIMESTAMP_FIX.md` - Timestamp serialization

---

*Last Updated: October 31, 2025*
*Status: ✅ Lesson Timer Working | ✅ Quiz Tracking Added | ⏱️ More integrations coming*

