# Changelog

All notable changes to FlutterMate will be documented in this file.

## [Unreleased]

### Added (Latest - Lesson System Implementation)
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
