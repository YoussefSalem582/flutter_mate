# 📐 FlutterMate Architecture Overview

## 🏗️ Architecture Pattern

**Clean Architecture + Feature-First Structure**

```
┌─────────────────────────────────────────────────────────────┐
│                         PRESENTATION                         │
│  (UI Layer - Widgets, Pages, Animations)                    │
├─────────────────────────────────────────────────────────────┤
│                          CONTROLLER                          │
│  (Business Logic - GetX Controllers, State Management)      │
├─────────────────────────────────────────────────────────────┤
│                            DATA                              │
│  (Data Sources - SharedPreferences, Future: API, DB)        │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Layer Breakdown

### 1. Core Layer (Shared Across Features)
**Location:** `lib/core/`

```
core/
├── constants/          # App-wide constants
│   ├── app_colors.dart      # Color palette
│   ├── app_text_styles.dart # Typography
│   └── app_assets.dart      # Asset paths
│
├── theme/              # Theme system
│   ├── app_theme.dart       # Light/Dark themes
│   └── theme_manager.dart   # Theme state controller
│
├── routes/             # Navigation
│   ├── app_routes.dart      # Route constants
│   └── app_pages.dart       # GetX page config
│
└── utils/              # Helper functions
    ├── helpers.dart         # Utility functions
    └── validators.dart      # Input validation
```

**Purpose:**
- Centralized configuration
- Reusable utilities
- Consistent theming
- Navigation setup

---

### 2. Features Layer (Modular Features)
**Location:** `lib/features/`

```
features/
├── onboarding/         # Onboarding feature
│   └── presentation/
│       └── pages/
│           ├── splash_page.dart
│           └── onboarding_page.dart
│
├── roadmap/            # Learning roadmap feature
│   └── presentation/
│       └── pages/
│           └── roadmap_page.dart
│
├── progress_tracker/   # Progress tracking feature
│   └── presentation/
│       └── pages/
│           └── progress_tracker_page.dart
│
└── assistant/          # AI assistant feature
    └── presentation/
        └── pages/
            ├── assistant_page.dart
            └── profile_page.dart
```

**Structure for Each Feature (Ready to Expand):**
```
feature_name/
├── presentation/    # UI Layer
│   ├── pages/      # Full screens
│   ├── widgets/    # Feature-specific widgets
│   └── controllers/# GetX controllers (future)
│
├── domain/          # Business Logic (future)
│   ├── entities/   # Core business objects
│   ├── repositories/ # Abstract interfaces
│   └── usecases/   # Business operations
│
└── data/            # Data Layer (future)
    ├── models/     # Data models
    ├── datasources/# API, DB, SharedPreferences
    └── repositories_impl/ # Repository implementations
```

---

### 3. Shared Layer (Reusable Components)
**Location:** `lib/shared/`

```
shared/
└── widgets/              # Reusable widgets
    ├── custom_button.dart
    ├── loading_indicator.dart
    └── empty_state.dart
```

**Purpose:**
- UI components used across features
- Consistent design system
- DRY principle

---

## 🔄 Data Flow

### Current Implementation (Simple):

```
┌──────────┐         ┌──────────┐         ┌──────────┐
│   USER   │────────▶│   PAGE   │────────▶│  WIDGET  │
└──────────┘         └──────────┘         └──────────┘
     ▲                     │
     │                     ▼
     │              ┌──────────────┐
     └──────────────│ ThemeManager │
                    │ (GetX)       │
                    └──────────────┘
```

### Future Implementation (With Controllers):

```
┌──────────┐         ┌──────────┐         ┌────────────┐
│   USER   │────────▶│   PAGE   │────────▶│ CONTROLLER │
└──────────┘         └──────────┘         └────────────┘
                           ▲                      │
                           │                      ▼
                           │               ┌─────────────┐
                           └───────────────│ REPOSITORY  │
                                          └─────────────┘
                                                  │
                                                  ▼
                                          ┌─────────────┐
                                          │ DATA SOURCE │
                                          │ (API/DB)    │
                                          └─────────────┘
```

---

## 🎯 State Management

### Current: GetX with ThemeManager

```dart
// Initialize in main.dart
Get.put(ThemeManager());

// Use in widgets
final themeManager = Get.find<ThemeManager>();

// Reactive UI
Obx(() => Switch(
  value: themeManager.isDarkMode,
  onChanged: (_) => themeManager.toggleTheme(),
));
```

### Future: Add Controllers for Each Feature

```dart
// Example: RoadmapController
class RoadmapController extends GetxController {
  final RxList<Lesson> lessons = <Lesson>[].obs;
  final RxDouble progress = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchLessons();
  }
  
  Future<void> fetchLessons() async {
    // Load from repository
  }
}
```

---

## 🚀 Navigation Architecture

### GetX Navigation Setup:

```dart
// 1. Define routes (app_routes.dart)
class AppRoutes {
  static const String splash = '/splash';
  static const String roadmap = '/roadmap';
  // ...
}

// 2. Register pages (app_pages.dart)
class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
    ),
    // ...
  ];
}

// 3. Use in app (main.dart)
GetMaterialApp(
  getPages: AppPages.routes,
  initialRoute: AppRoutes.splash,
);

// 4. Navigate from anywhere
Get.toNamed(AppRoutes.roadmap);
Get.offNamed(AppRoutes.onboarding);
Get.offAllNamed(AppRoutes.splash);
```

### Navigation Tree:

```
SplashPage (/)
    │
    ├──▶ OnboardingPage (/onboarding)
    │         │
    │         └──▶ RoadmapPage (/roadmap) [HOME]
    │                   │
    │                   ├──▶ ProgressTrackerPage (/progress-tracker)
    │                   │
    │                   ├──▶ AssistantPage (/assistant)
    │                   │
    │                   └──▶ ProfilePage (/profile)
    │
    └──▶ (Direct access to RoadmapPage after first launch)
```

---

## 🎨 Theming Architecture

### Theme System Components:

```
┌─────────────────────────────────────────────┐
│           app_colors.dart                   │
│  (Color constants for light/dark)           │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│           app_theme.dart                    │
│  (ThemeData configurations)                 │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│         theme_manager.dart                  │
│  (Runtime theme switching + persistence)    │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│           main.dart                         │
│  (Apply themes to GetMaterialApp)           │
└─────────────────────────────────────────────┘
```

### How Theme Switching Works:

```
1. User taps toggle in ProfilePage
         ↓
2. ThemeManager.toggleTheme() called
         ↓
3. Toggle internal state (light ↔ dark)
         ↓
4. Get.changeThemeMode() updates UI
         ↓
5. Save to SharedPreferences
         ↓
6. All widgets rebuild with new theme
```

---

## 🔮 Future Architecture Additions

### 1. Data Layer

```dart
// Repository pattern
abstract class RoadmapRepository {
  Future<List<Lesson>> getLessons();
  Future<void> updateProgress(String lessonId, double progress);
}

// Implementation
class RoadmapRepositoryImpl implements RoadmapRepository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;
  
  @override
  Future<List<Lesson>> getLessons() async {
    // Try remote first, fallback to local
  }
}
```

### 2. Use Cases

```dart
// Single responsibility business logic
class GetLessonsUseCase {
  final RoadmapRepository repository;
  
  Future<Result<List<Lesson>>> execute() async {
    try {
      final lessons = await repository.getLessons();
      return Success(lessons);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
```

### 3. Dependency Injection

```dart
// Bindings for each feature
class RoadmapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RoadmapRepository());
    Get.lazyPut(() => RoadmapController());
  }
}

// Use in routes
GetPage(
  name: AppRoutes.roadmap,
  page: () => const RoadmapPage(),
  binding: RoadmapBinding(),
);
```

---

## 📊 Component Hierarchy

### Typical Page Structure:

```
Page (StatelessWidget/StatefulWidget)
│
├── Scaffold
│   ├── AppBar
│   │   ├── Title
│   │   └── Actions (IconButton)
│   │
│   ├── Body
│   │   └── ListView/Column
│   │       ├── Header Widget
│   │       ├── Content Cards
│   │       │   ├── Icon
│   │       │   ├── Text (Title)
│   │       │   ├── Text (Subtitle)
│   │       │   ├── ProgressIndicator
│   │       │   └── Action Buttons
│   │       └── Footer Widget
│   │
│   └── BottomNavigationBar
│       └── BottomNavigationBarItems
│
└── Animations (.animate())
    ├── FadeIn
    ├── SlideX/SlideY
    └── Scale
```

---

## 🔐 Design Principles Used

### 1. **Separation of Concerns**
- Each layer has a specific responsibility
- UI doesn't know about data sources
- Business logic is isolated

### 2. **Dependency Rule**
- Inner layers don't depend on outer layers
- Core doesn't depend on features
- Features can depend on core

### 3. **Single Responsibility**
- Each file has one main purpose
- Widgets are focused and composable
- Controllers manage specific state

### 4. **Open/Closed Principle**
- Easy to add new features without modifying existing code
- Extend functionality through new files/classes

### 5. **DRY (Don't Repeat Yourself)**
- Shared widgets in `shared/` folder
- Constants in `core/constants/`
- Utils in `core/utils/`

---

## 🎯 Benefits of This Architecture

### ✅ Scalability
- Easy to add new features
- Clear structure for team collaboration
- Can grow from simple to complex

### ✅ Testability
- Each layer can be tested independently
- Mock dependencies easily
- Unit, widget, and integration tests

### ✅ Maintainability
- Changes are localized
- Easy to find and fix bugs
- Clear dependencies

### ✅ Reusability
- Shared components across features
- Consistent patterns
- Less code duplication

### ✅ Flexibility
- Can swap implementations
- Easy to change state management
- Platform-agnostic business logic

---

## 🔄 Evolution Path

### Phase 1 (Current): Simple MVC
- Pages directly render UI
- Minimal state management
- Mock data in widgets

### Phase 2 (Next): Add Controllers
- Separate UI from logic
- GetX controllers for state
- Load data from SharedPreferences

### Phase 3 (Future): Full Clean Architecture
- Repository pattern
- Use cases for business logic
- Remote API integration
- Local database (Hive/Drift)

### Phase 4 (Advanced): Microservices Ready
- Feature modules as packages
- Plugin architecture
- Offline-first with sync
- Modular monolith

---

## 📚 Key Architectural Decisions

### 1. **GetX over BLoC**
**Why:** Simpler for beginners, less boilerplate, built-in routing
**Trade-off:** Less explicit patterns, harder to enforce architecture

### 2. **Feature-First Structure**
**Why:** Scales better, easier to find related code
**Alternative:** Layer-first (all pages, all controllers, all models)

### 3. **Material 3**
**Why:** Modern design, better theming, future-proof
**Note:** Some widgets behave differently from Material 2

### 4. **Shared Widgets Layer**
**Why:** Promotes reusability, consistency
**Note:** Balance between DRY and over-abstraction

---

## 🛠️ Tools for Architecture Visualization

### Generate dependency graph:
```bash
flutter pub run dependency_validator
```

### Analyze code structure:
```bash
flutter analyze
```

### Check unused files:
```bash
dart analyze --no-fatal-warnings
```

---

## 📖 Further Reading

### Architecture Patterns:
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [GetX Pattern](https://github.com/jonataslaw/getx/blob/master/documentation/en_US/state_management.md)

### Best Practices:
- [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)

---

<div align="center">

## 🎓 Understanding This Architecture = Better Flutter Developer

**Take time to explore each folder and understand the separation of concerns. This foundation will serve you well as the app grows!**

</div>
