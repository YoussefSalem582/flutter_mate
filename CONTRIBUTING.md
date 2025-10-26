# Contributing to FlutterMate

First off, thank you for considering contributing to FlutterMate! 🎉

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)
- [Commit Messages](#commit-messages)

## Code of Conduct

This project and everyone participating in it is governed by our commitment to provide a welcoming and inclusive environment. By participating, you are expected to uphold this standard.

### Our Standards

- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed and what you expected**
- **Include screenshots if possible**
- **Specify your environment** (OS, Flutter version, device)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Use a clear and descriptive title**
- **Provide a detailed description of the suggested enhancement**
- **Explain why this enhancement would be useful**
- **List any similar features in other apps**

### Your First Code Contribution

Unsure where to begin? You can start by looking through these issues:

- `good-first-issue` - Issues suitable for beginners
- `help-wanted` - Issues that need assistance

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our style guidelines
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Submit a pull request**

## Development Setup

### Prerequisites

- Flutter SDK >= 3.9.2
- Dart SDK >= 3.0
- Android Studio or VS Code with Flutter plugin
- Git

### Setup Steps

1. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/flutter_mate.git
   cd flutter_mate
   ```

2. **Add upstream remote:**
   ```bash
   git remote add upstream https://github.com/YoussefSalem582/flutter_mate.git
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

5. **Run tests:**
   ```bash
   flutter test
   ```

### Project Structure

```
lib/
├── core/                  # Core functionality (theme, routes, constants)
├── features/             # Feature modules (roadmap, progress, assistant)
│   ├── feature_name/
│   │   ├── controller/   # GetX controllers and bindings
│   │   ├── data/         # Models and repositories
│   │   └── presentation/ # UI pages and widgets
└── shared/               # Shared widgets and utilities
```

## Pull Request Process

1. **Update your fork:**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes and commit:**
   ```bash
   git add .
   git commit -m "feat: add amazing feature"
   ```

4. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request** on GitHub

### PR Checklist

- [ ] Code follows the project's style guidelines
- [ ] Self-review of code completed
- [ ] Comments added for complex code
- [ ] Documentation updated if needed
- [ ] No new warnings generated
- [ ] Tests added/updated for changes
- [ ] All tests passing
- [ ] PR title follows conventional commits

## Style Guidelines

### Dart Code Style

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines:

- Use `lowerCamelCase` for variables, functions, and parameters
- Use `UpperCamelCase` for classes and types
- Use `lowercase_with_underscores` for file names
- Maximum line length: 80 characters (flexible for readability)
- Use trailing commas for better formatting

### Code Organization

- **One class per file** (unless nested classes)
- **Organize imports:** dart imports, package imports, relative imports
- **Use const constructors** where possible
- **Avoid deep nesting** (max 3-4 levels)

### Widget Guidelines

- **Use GetView** for widgets that need controller access
- **Extract reusable widgets** into separate files
- **Use Obx** for reactive updates
- **Add animations** using flutter_animate

### Example:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExamplePage extends GetView<ExampleController> {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: Obx(() => _buildContent()),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(controller.someValue.value),
    ).animate().fadeIn();
  }
}
```

## Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

### Format

```
type(scope): subject

body (optional)

footer (optional)
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```
feat(lessons): add video tutorial support

Add ability to embed video tutorials in lesson detail pages
with progress tracking and playback controls.

Closes #123
```

```
fix(progress): correct XP calculation

XP points were being calculated incorrectly when lessons
were completed out of order. Fixed calculation to use
actual completion count.
```

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Writing Tests

- Write tests for all new features
- Update tests when modifying existing code
- Aim for >80% code coverage
- Use meaningful test descriptions

### Test Structure

```dart
void main() {
  group('FeatureName', () {
    testWidgets('should do something', (tester) async {
      // Arrange
      await tester.pumpWidget(MyApp());
      
      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Expected Result'), findsOneWidget);
    });
  });
}
```

## Documentation

- Update README.md for user-facing changes
- Update technical docs (ARCHITECTURE.md, etc.) for structural changes
- Add inline comments for complex logic
- Document public APIs with dartdoc comments

### Dartdoc Example

```dart
/// Calculates the overall progress percentage.
///
/// Returns a value between 0.0 and 1.0 representing
/// the completion percentage across all stages.
///
/// Example:
/// ```dart
/// final progress = controller.calculateProgress();
/// print('Progress: ${progress * 100}%');
/// ```
double calculateProgress() {
  // Implementation
}
```

## Questions?

Feel free to:
- Open an issue with the `question` label
- Reach out to maintainers
- Check existing discussions

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to FlutterMate! 🚀
