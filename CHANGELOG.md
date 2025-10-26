# Changelog

All notable changes to FlutterMate will be documented in this file.

## [Unreleased]

### Added (Latest - Interactive Quiz System)
- **Quiz Question Model** (`lib/features/quiz/data/models/quiz_question.dart`)
  - Question structure with options, correct answer, explanation
  - Points system for scoring
  - Lesson ID association
  - JSON serialization support

- **Quiz Controller** (`lib/features/quiz/controller/quiz_controller.dart`)
  - 25+ questions covering all lessons and topics
  - Smart question filtering by lesson ID
  - Real-time score calculation
  - Answer validation with instant feedback
  - Progress tracking (answered/total)
  - Quiz completion detection
  - Restart functionality
  - Score percentage calculation

- **Quiz Tracking Service** (`lib/features/quiz/services/quiz_tracking_service.dart`)
  - Persistent quiz result storage with SharedPreferences
  - Track completion status per lesson
  - Calculate average score across all quizzes
  - Monitor total XP earned from quizzes
  - Quiz history with timestamps
  - Result retrieval by lesson ID
  - Clear all quiz results functionality

- **Quiz Page** (`lib/features/quiz/presentation/pages/quiz_page.dart`)
  - Interactive quiz interface with 650+ lines
  - Progress header with XP counter
  - Gradient question cards with animations
  - Color-coded answer options (green=correct, orange=wrong)
  - Explanation cards appearing after answering
  - Navigation buttons (Previous/Next/Finish)
  - Animated transitions between questions
  - Comprehensive results screen with:
    - Performance-based emojis and icons (🎉 90%+, 👍 80%+, ✅ 70%+, 💪 <70%)
    - Large score percentage display
    - Breakdown: Score, Correct answers, XP earned
    - Performance metrics: Accuracy, Questions, Pass/Fail status
    - Retry and Back Home buttons
    - Elastic animation effects

- **Quiz Integration in Lessons**
  - Quiz card in lesson detail pages
  - Trophy icon with gradient blue background
  - Quiz information display (5 questions, ~5 minutes, 50 XP)
  - Direct navigation to lesson-specific quizzes
  - Consistent animations (450ms delay)

- **Enhanced Progress Tracker**
  - Quiz Performance card with gradient design
  - Total quizzes completed counter
  - Average quiz score percentage
  - Total XP earned from quizzes
  - Performance-based motivational messages
  - Real-time reactive updates via GetX

### Changed (Latest)
- **Main.dart** initialization
  - Added QuizTrackingService async initialization
  - Service available globally via Get.find()

- **Quiz Controller** enhancement
  - Integrated with QuizTrackingService
  - Auto-saves results on quiz completion
  - Passes lessonId from route arguments
  - Falls back to all questions if no lesson specified

- **Lesson Detail Page**
  - Added quiz card between objectives and exercises
  - Pass lessonId as argument to quiz route
  - Enhanced visual hierarchy

### Fixed (Latest)
- Infinite rebuild bug in RoadmapPage
  - Changed from `.map().reduce()` to `.fold()` for progress calculation
  - Added empty state check before calculations
  - Resolved crash on Chrome (org-dartlang-sdk window.dart:99:12)

- Material Icons not loading on web
  - Added Material Icons CDN links to web/index.html
  - Included all 5 icon variants (default, outlined, round, sharp, two-tone)
  - Icons now render correctly on all web platforms

### Added (Previous - Lesson System Implementation)
- **Lesson Data Model** (`lib/features/roadmap/data/models/lesson.dart`)
  - Comprehensive lesson structure with 9 properties
  - Support for prerequisites and resources
  - Difficulty levels: easy, medium, hard
  
- **Lesson Repository** (`lib/features/roadmap/data/repositories/lesson_repository.dart`)
  - 22 structured lessons across 3 stages
  - Beginner: 8 lessons (~245 min total)
  - Intermediate: 6 lessons (~345 min total)
  - Advanced: 6 lessons (~440 min total)
  - SharedPreferences-based completion tracking
  - Stage completion percentage calculation
  
- **Lesson Controller** (`lib/features/roadmap/controller/lesson_controller.dart`)
  - GetX-based state management
  - Reactive completion status tracking
  - Prerequisite validation system
  - Auto-refresh on route changes
  
- **Lesson Binding** (`lib/features/roadmap/controller/lesson_binding.dart`)
  - Dependency injection for lesson features
  - Lazy loading of repository and controller
  
- **Lessons List Page** (`lib/features/roadmap/presentation/pages/lessons_page.dart`)
  - Expandable app bar with stage info
  - Real-time progress tracking (X/Y lessons)
  - Interactive lesson cards with animations
  - Prerequisite indicators and lock icons
  - Staggered fade-in animations
  
- **Lesson Detail Page** (`lib/features/roadmap/presentation/pages/lesson_detail_page.dart`)
  - Gradient app bar with difficulty color coding
  - Overview, objectives, resources sections
  - Prerequisite completion status display
  - Practice exercises section
  - Floating action button for marking complete
  - Smooth animations and transitions
  
- **Documentation**
  - `LESSON_SYSTEM.md`: Technical implementation guide
  - `LESSON_GUIDE.md`: User guide for lesson system
  - Updated `README.md` with lesson features
  
- **Routing**
  - `/lessons` route for lessons list page
  - `/lesson-detail` route for lesson details
  - Right-to-left fade transitions

### Changed (Latest)
- **RoadmapController** now accepts optional `LessonRepository`
  - Automatically syncs stage progress from lesson completion
  - `refreshProgress()` method for manual sync
  - Falls back to manual progress if no lesson repository
  
- **RoadmapPage** stage cards now clickable
  - Tap to navigate to lessons list
  - InkWell with ripple effect
  - Arrow icon indicator
  
- **ProgressTrackerController** uses lesson completion data
  - Accurate lesson count from `LessonController`
  - Real-time stats: lessons, projects, XP, streak
  - Auto-refresh on route changes
  
- **ProgressTrackerBinding** injects `LessonController`
  - Ensures lesson repository availability
  - Conditional dependency registration
  
- **RoadmapBinding** provides `LessonRepository` to controller
  - Conditional injection based on availability
  - Graceful degradation

### Added (Previous - Core Features)
- **Project Setup**
  - Clean Architecture structure
  - Feature-first organization
  - GetX state management
  - Material 3 design system
  
- **Core Systems**
  - Theme manager with dark/light modes
  - Theme persistence with SharedPreferences
  - App-wide color constants
  - Text style system
  - Custom routing with GetX
  
- **Onboarding**
  - Splash screen with 3s delay
  - 3-page onboarding carousel
  - Skip button and page indicators
  - Smooth animations
  
- **Roadmap**
  - 3 learning stages (Beginner, Intermediate, Advanced)
  - Stage cards with icons and colors
  - Progress bars per stage
  - Topic chips
  - Manual progress sliders
  
- **Progress Tracker**
  - Overall progress percentage
  - Lessons completed counter
  - Projects completed
  - Day streak tracker
  - XP points system
  - Activity feed
  - Stat cards with icons
  
- **Assistant**
  - Chat interface (mock responses)
  - Message bubbles
  - Input field with send button
  - Scrollable message list
  
- **Profile**
  - User stats display
  - Settings section
  - Theme toggle switch
  - Version info
  
- **Shared Widgets**
  - CustomButton with loading state
  - LoadingIndicator
  - EmptyState widget
  
- **Navigation**
  - Bottom navigation bar
  - 4 main sections: Roadmap, Progress, Assistant, Profile
  - Smooth page transitions
  - Route management with GetX
  
- **Testing**
  - Widget test setup
  - Splash → Onboarding flow test
  - Timer handling in tests
  - All tests passing (1/1)

### Fixed
- CardTheme vs CardThemeData type issue in theme setup
- Unused imports in repository files
- Widget test timer conflicts with animations
- Pending timers in splash screen navigation
- Text style naming inconsistencies (h3 vs heading3)
- App colors naming (darkSurface vs darkCard)

## Version History

### v0.2.0 - Lesson System (Current)
- Complete lesson management system
- 22 structured lessons with content
- Prerequisite-based progression
- Integration with roadmap and progress tracking

### v0.1.0 - Foundation (Initial Release)
- Basic app structure
- Onboarding flow
- Roadmap visualization
- Progress tracking
- AI assistant interface
- Theme system

---

**Note:** This project follows [Semantic Versioning](https://semver.org/).
