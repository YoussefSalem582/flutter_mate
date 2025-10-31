# FlutterMate 🚀

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Deploy to GitHub Pages](https://github.com/YoussefSalem582/flutter_mate/actions/workflows/deploy.yml/badge.svg)](https://github.com/YoussefSalem582/flutter_mate/actions/workflows/deploy.yml)
[![GitHub stars](https://img.shields.io/github/stars/YoussefSalem582/flutter_mate?style=social)](https://github.com/YoussefSalem582/flutter_mate/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/YoussefSalem582/flutter_mate?style=social)](https://github.com/YoussefSalem582/flutter_mate/network/members)
[![GitHub issues](https://img.shields.io/github/issues/YoussefSalem582/flutter_mate)](https://github.com/YoussefSalem582/flutter_mate/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/YoussefSalem582/flutter_mate/pulls)

**Your Personal Flutter Learning Companion**

FlutterMate is a comprehensive learning assistant designed to guide you from Flutter beginner to advanced developer through structured lessons, progress tracking, and AI-powered assistance.

🌐 [**Live Demo**](https://youssefsalem582.github.io/flutter_mate/) | 📚 [**Documentation**](https://youssefsalem582.github.io/flutter_mate/) | 🐛 [**Report Bug**](https://github.com/YoussefSalem582/flutter_mate/issues) | 💡 [**Request Feature**](https://github.com/YoussefSalem582/flutter_mate/issues)

## ✨ Features

### 📚 Structured Learning Path
- **22 Comprehensive Lessons** across 3 difficulty levels
- **Beginner Stage:** 8 lessons covering Flutter basics (245 min)
- **Intermediate Stage:** 6 lessons on state management & APIs (345 min)  
- **Advanced Stage:** 6 lessons on architecture & optimization (440 min)
- **Prerequisite System:** Unlock lessons as you progress
- **Time Estimates:** Know how long each lesson takes
- **Interactive Quizzes:** Test your knowledge after each lesson

### 🎯 Quiz System
- **25+ Quiz Questions** covering all lessons and topics
- **Instant Feedback:** Color-coded answers with explanations
- **Score Tracking:** Monitor your quiz performance
- **XP Rewards:** Earn points for correct answers
- **Performance Stats:** View completion rate and average score
- **Smart Results:** Get personalized feedback based on performance

### 📊 Progress Tracking
- **Real-time Stats:** Lessons completed, projects built, XP earned
- **Quiz Analytics:** Track quizzes completed and average scores
- **Stage Completion:** Visual progress bars for each level
- **Achievement System:** Unlock badges and milestones
- **Day Streak:** Track your learning consistency
- **Activity Feed:** See your recent accomplishments
- **Weekly Charts:** Visualize your learning progress

### 🎓 Lesson Detail Pages
- **Rich Content:** Detailed overviews and objectives
- **Learning Resources:** Curated external links and docs
- **Practice Exercises:** Hands-on challenges
- **Quiz Integration:** Take quizzes directly from lessons
- **Completion Tracking:** Mark lessons complete
- **Difficulty Indicators:** Easy, Medium, Hard badges
- **XP Indicators:** See potential rewards before starting

### 🎨 Beautiful UI
- **Material 3 Design:** Modern, clean interface
- **Dark/Light Themes:** Automatic theme persistence
- **Smooth Animations:** Delightful transitions
- **Responsive Layout:** Works on all screen sizes
- **Color-Coded Stages:** Visual learning hierarchy

### 🤖 AI Assistant (Coming Soon)
- Chat interface for Flutter questions
- Context-aware help based on your progress
- Code examples and explanations

## 🏗️ Architecture

Built with **Clean Architecture** principles:
- **Presentation Layer:** Pages, widgets, controllers
- **Domain Layer:** Business logic and use cases
- **Data Layer:** Repositories, models, data sources

**State Management:** GetX for reactive programming
**Storage:** SharedPreferences for persistence
**Navigation:** GetX routing with smooth transitions

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0 (included with Flutter)
- Android Studio / VS Code with Flutter plugin

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/flutter_mate.git
   cd flutter_mate
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   # Mobile/Desktop
   flutter run
   
   # Web (optimized)
   flutter run -d chrome
   ```

### Building for Web (Optimized)
```bash
# Quick build with all optimizations
./build-web-optimized.sh  # Linux/Mac
# or
.\build-web-optimized.ps1  # Windows

# Manual build
flutter build web --release \
  --base-href /flutter_mate/ \
  --web-renderer canvaskit \
  --pwa-strategy offline-first \
  --tree-shake-icons
```

See [DEPLOYMENT_GUIDE.md](tech_readme_files/DEPLOYMENT_GUIDE.md) for details.

### Quick Start
1. Launch the app and complete the onboarding
2. Explore the **Roadmap** to see all learning stages
3. Tap a stage to view **Lessons**
4. Start with "What is Flutter?" in Beginner
5. Complete lessons to unlock new content
6. Track your progress in the **Progress Tracker**
7. Ask the **AI Assistant** for help (coming soon)

## 📖 Documentation

### Core Documentation
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Project overview and goals
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture details
- **[LESSON_SYSTEM.md](LESSON_SYSTEM.md)** - Lesson implementation guide
- **[LESSON_GUIDE.md](LESSON_GUIDE.md)** - User guide for lessons
- **[QUICK_START.md](QUICK_START.md)** - Development setup guide
- **[ROADMAP.md](ROADMAP.md)** - Future development plans

### Web & Deployment
- **[WEB_PERFORMANCE_OPTIMIZATION.md](tech_readme_files/WEB_PERFORMANCE_OPTIMIZATION.md)** - Performance optimizations explained
- **[DEPLOYMENT_GUIDE.md](tech_readme_files/DEPLOYMENT_GUIDE.md)** - Build and deploy instructions
- **[GITHUB_PAGES.md](tech_readme_files/GITHUB_PAGES.md)** - GitHub Pages setup

## 🛠️ Tech Stack

- **Framework:** Flutter 3.0+
- **Language:** Dart 3.0+
- **State Management:** GetX 4.6.6
- **Animations:** flutter_animate 4.5.0, Lottie 3.1.0
- **Storage:** shared_preferences 2.2.2
- **Architecture:** Clean Architecture + Feature-First

## 📱 Screenshots

*(Screenshots will be added soon)*

## 🧪 Testing

Run tests with:
```bash
flutter test
```

Current test coverage:
- Widget tests: ✅ 1/1 passing
- Unit tests: (in development)
- Integration tests: (planned)

## 🗺️ Roadmap

### ✅ Phase 1 (Completed)
- [x] Project structure & architecture
- [x] Onboarding & splash screens
- [x] Theme system with persistence
- [x] Roadmap with 3 stages
- [x] Progress tracker with stats
- [x] 22 structured lessons
- [x] Lesson detail pages
- [x] Completion tracking
- [x] Prerequisite system

### 🚧 Phase 2 (In Progress)
- [ ] AI assistant integration
- [ ] Interactive code playground
- [ ] Achievement system
- [ ] Video tutorials
- [ ] Post-lesson quizzes

### 📋 Phase 3 (Planned)
- [ ] Social features (share progress)
- [ ] Offline mode
- [ ] Personalized learning paths
- [ ] Advanced analytics
- [ ] Community forum

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting a pull request.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors & Contributors

### Creator
- **Youssef Hassan** ([@YoussefSalem582](https://github.com/YoussefSalem582)) - Initial work and development

### Contributors

We welcome contributions! See our [contributors page](https://github.com/YoussefSalem582/flutter_mate/graphs/contributors).

Want to contribute? Check out our [Contributing Guidelines](CONTRIBUTING.md)!

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX community for state management
- All contributors and testers

---

**Happy Learning! 📚✨**

Start your Flutter journey today with FlutterMate!
