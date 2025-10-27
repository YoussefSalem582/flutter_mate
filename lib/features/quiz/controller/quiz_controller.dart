import 'package:get/get.dart';
import '../data/models/quiz_question.dart';
import '../services/quiz_tracking_service.dart';

/// Controller for managing quiz state and logic
class QuizController extends GetxController {
  final QuizTrackingService _trackingService = Get.find<QuizTrackingService>();

  final RxList<QuizQuestion> questions = <QuizQuestion>[].obs;
  final RxList<QuizQuestion> allQuestions = <QuizQuestion>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxMap<int, int> userAnswers = <int, int>{}.obs;
  final RxInt score = 0.obs;
  final RxBool isCompleted = false.obs;
  final RxBool showExplanation = false.obs;
  final RxString currentLessonId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllQuestions();

    // Get lessonId from route arguments if available
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('lessonId')) {
      loadQuizForLesson(args['lessonId'] as String);
    } else {
      // Load all questions if no specific lesson
      questions.value = allQuestions;
    }
  }

  void loadAllQuestions() {
    // Comprehensive quiz questions mapped to actual lesson IDs
    allQuestions.value = [
      // b1: What is Flutter?
      const QuizQuestion(
        id: 'q_b1_1',
        lessonId: 'b1',
        question: 'What is Flutter?',
        options: [
          'A programming language',
          'A UI toolkit for building cross-platform apps',
          'A database management system',
          'A web server',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Flutter is an open-source UI toolkit created by Google for building natively compiled applications for mobile, web, and desktop from a single codebase.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b1_2',
        lessonId: 'b1',
        question: 'Which company developed Flutter?',
        options: ['Facebook', 'Google', 'Microsoft', 'Apple'],
        correctAnswerIndex: 1,
        explanation: 'Flutter was developed by Google and released in 2017.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b1_3',
        lessonId: 'b1',
        question: 'Which platforms does Flutter support?',
        options: [
          'Only Android',
          'Only iOS',
          'Mobile, Web, Desktop, and Embedded',
          'Only Mobile',
        ],
        correctAnswerIndex: 2,
        explanation:
            'Flutter supports mobile (Android, iOS), web, desktop (Windows, macOS, Linux), and embedded devices.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b1_4',
        lessonId: 'b1',
        question: 'What makes Flutter different from other frameworks?',
        options: [
          'It uses JavaScript',
          'It has its own rendering engine',
          'It only works on Android',
          'It requires native code for UI',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Flutter uses its own rendering engine (Skia) to draw widgets, ensuring consistent UI across platforms.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b1_5',
        lessonId: 'b1',
        question: 'What is hot reload in Flutter?',
        options: [
          'A feature to restart the app',
          'A feature to instantly see code changes without restarting',
          'A debugging tool',
          'A performance optimizer',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Hot reload allows developers to see code changes instantly without losing the app state, making development faster.',
        points: 10,
      ),

      // b2: Setup Development Environment
      const QuizQuestion(
        id: 'q_b2_1',
        lessonId: 'b2',
        question: 'Which command checks if Flutter is properly installed?',
        options: [
          'flutter check',
          'flutter doctor',
          'flutter install',
          'flutter verify',
        ],
        correctAnswerIndex: 1,
        explanation:
            'flutter doctor checks your environment and displays a report of Flutter installation status.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b2_2',
        lessonId: 'b2',
        question: 'Which IDEs are officially supported for Flutter?',
        options: [
          'Only Android Studio',
          'Only VS Code',
          'Android Studio and VS Code',
          'Sublime Text and Atom',
        ],
        correctAnswerIndex: 2,
        explanation:
            'Flutter officially supports Android Studio and Visual Studio Code with dedicated plugins.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b2_3',
        lessonId: 'b2',
        question: 'What do you need to install before Flutter?',
        options: [
          'Node.js',
          'Git',
          'Python',
          'Java',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Git is required to download and manage Flutter SDK and packages.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b2_4',
        lessonId: 'b2',
        question: 'What is the Flutter SDK?',
        options: [
          'A code editor',
          'A collection of tools and libraries for Flutter development',
          'A database',
          'A testing framework',
        ],
        correctAnswerIndex: 1,
        explanation:
            'The Flutter SDK includes tools, libraries, and the Dart SDK needed for Flutter development.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b2_5',
        lessonId: 'b2',
        question:
            'Which folder should be added to PATH after installing Flutter?',
        options: [
          'flutter/lib',
          'flutter/bin',
          'flutter/packages',
          'flutter/sdk',
        ],
        correctAnswerIndex: 1,
        explanation:
            'The flutter/bin directory contains the Flutter command-line tools and should be added to your system PATH.',
        points: 10,
      ),

      // b3: Dart Basics
      const QuizQuestion(
        id: 'q_b3_1',
        lessonId: 'b3',
        question: 'Which programming language does Flutter use?',
        options: ['JavaScript', 'Python', 'Dart', 'Kotlin'],
        correctAnswerIndex: 2,
        explanation:
            'Flutter uses Dart, a modern, object-oriented programming language developed by Google.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b3_2',
        lessonId: 'b3',
        question:
            'How do you declare a variable that cannot be changed in Dart?',
        options: ['var', 'const', 'let', 'static'],
        correctAnswerIndex: 1,
        explanation:
            'const is used for compile-time constants that cannot be changed. final can also be used for runtime constants.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b3_3',
        lessonId: 'b3',
        question: 'What is the entry point of a Dart application?',
        options: [
          'start()',
          'main()',
          'init()',
          'run()',
        ],
        correctAnswerIndex: 1,
        explanation:
            'The main() function is the entry point of every Dart application.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b3_4',
        lessonId: 'b3',
        question: 'Which keyword is used for type inference in Dart?',
        options: ['auto', 'var', 'dynamic', 'let'],
        correctAnswerIndex: 1,
        explanation:
            'var allows Dart to infer the type from the initial value.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b3_5',
        lessonId: 'b3',
        question: 'What does the ?? operator do in Dart?',
        options: [
          'Division',
          'Null-aware operator (returns right if left is null)',
          'Comparison',
          'Assignment',
        ],
        correctAnswerIndex: 1,
        explanation:
            'The ?? operator returns the right operand if the left operand is null, otherwise returns the left operand.',
        points: 10,
      ),

      // b4: First Flutter App
      const QuizQuestion(
        id: 'q_b4_1',
        lessonId: 'b4',
        question: 'Which command creates a new Flutter project?',
        options: [
          'flutter new',
          'flutter create',
          'flutter init',
          'flutter start',
        ],
        correctAnswerIndex: 1,
        explanation:
            'flutter create [project_name] creates a new Flutter project with the default template.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b4_2',
        lessonId: 'b4',
        question: 'What is the main file in a Flutter project?',
        options: [
          'app.dart',
          'main.dart',
          'index.dart',
          'start.dart',
        ],
        correctAnswerIndex: 1,
        explanation:
            'main.dart is the entry point of a Flutter application, located in the lib/ directory.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b4_3',
        lessonId: 'b4',
        question: 'What does runApp() do?',
        options: [
          'Starts the Dart VM',
          'Takes the given widget and makes it the root of the widget tree',
          'Compiles the app',
          'Opens the app in browser',
        ],
        correctAnswerIndex: 1,
        explanation:
            'runApp() takes a widget and inflates it, making it the root of the widget tree.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b4_4',
        lessonId: 'b4',
        question: 'Which widget is typically used as the root widget?',
        options: [
          'Container',
          'MaterialApp',
          'Scaffold',
          'Column',
        ],
        correctAnswerIndex: 1,
        explanation:
            'MaterialApp is typically the root widget as it provides Material Design and navigation functionality.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b4_5',
        lessonId: 'b4',
        question: 'What folder contains the Dart code for your Flutter app?',
        options: ['src/', 'app/', 'lib/', 'code/'],
        correctAnswerIndex: 2,
        explanation:
            'The lib/ directory contains all Dart code for your Flutter application.',
        points: 10,
      ),

      // b5: Widgets Fundamentals
      const QuizQuestion(
        id: 'q_b5_1',
        lessonId: 'b5',
        question: 'What are the two types of widgets in Flutter?',
        options: [
          'Static and Dynamic',
          'Stateless and Stateful',
          'Active and Passive',
          'Fixed and Flexible',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Flutter has Stateless widgets (immutable) and Stateful widgets (mutable with state).',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b5_2',
        lessonId: 'b5',
        question: 'When should you use a StatefulWidget?',
        options: [
          'When the widget never changes',
          'When the widget needs to change dynamically',
          'For all widgets',
          'Only for buttons',
        ],
        correctAnswerIndex: 1,
        explanation:
            'StatefulWidget is used when the widget needs to maintain state that can change over time.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b5_3',
        lessonId: 'b5',
        question: 'What method builds the UI in a widget?',
        options: [
          'create()',
          'build()',
          'render()',
          'display()',
        ],
        correctAnswerIndex: 1,
        explanation:
            'The build() method describes how to display the widget in terms of other widgets.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b5_4',
        lessonId: 'b5',
        question: 'What is a widget in Flutter?',
        options: [
          'A function',
          'Everything in Flutter UI',
          'Only buttons',
          'Only containers',
        ],
        correctAnswerIndex: 1,
        explanation:
            'In Flutter, everything is a widget - from layout structures to styling to text.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b5_5',
        lessonId: 'b5',
        question: 'Which widget creates a material design app bar?',
        options: [
          'TopBar',
          'AppBar',
          'Header',
          'TitleBar',
        ],
        correctAnswerIndex: 1,
        explanation:
            'AppBar is a Material Design widget that creates an app bar with title, actions, and more.',
        points: 10,
      ),

      // b6: Layouts and UI
      const QuizQuestion(
        id: 'q_b6_1',
        lessonId: 'b6',
        question: 'Which widget arranges children vertically?',
        options: ['Row', 'Column', 'Stack', 'Grid'],
        correctAnswerIndex: 1,
        explanation:
            'Column arranges its children vertically. Row is used for horizontal arrangement.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b6_2',
        lessonId: 'b6',
        question: 'What does Expanded widget do?',
        options: [
          'Makes widget larger',
          'Fills available space in Row/Column',
          'Adds padding',
          'Centers the widget',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Expanded makes a child fill available space in a Row, Column, or Flex.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b6_3',
        lessonId: 'b6',
        question: 'Which widget is used for overlapping children?',
        options: [
          'Row',
          'Column',
          'Stack',
          'Container',
        ],
        correctAnswerIndex: 2,
        explanation:
            'Stack allows widgets to overlap, with children positioned relative to the Stack edges.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b6_4',
        lessonId: 'b6',
        question: 'What property controls spacing between Row/Column children?',
        options: [
          'spacing',
          'gap',
          'mainAxisAlignment',
          'padding',
        ],
        correctAnswerIndex: 2,
        explanation:
            'mainAxisAlignment controls how children are distributed along the main axis (horizontal for Row, vertical for Column).',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b6_5',
        lessonId: 'b6',
        question: 'Which widget adds space around its child?',
        options: [
          'Margin',
          'Padding',
          'Spacer',
          'Gap',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Padding widget adds space (padding) around its child widget.',
        points: 10,
      ),

      // b7: State Management Basics
      const QuizQuestion(
        id: 'q_b7_1',
        lessonId: 'b7',
        question: 'What is state in Flutter?',
        options: [
          'The current URL',
          'Data that can change over time',
          'Widget styles',
          'App configuration',
        ],
        correctAnswerIndex: 1,
        explanation:
            'State is any data that can change during the app lifetime and affects what is displayed.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b7_2',
        lessonId: 'b7',
        question: 'How do you update state in a StatefulWidget?',
        options: [
          'Directly modify variables',
          'Call setState()',
          'Call update()',
          'Call refresh()',
        ],
        correctAnswerIndex: 1,
        explanation:
            'setState() notifies the framework that state changed and the widget needs to rebuild.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b7_3',
        lessonId: 'b7',
        question: 'Where should you initialize state variables?',
        options: [
          'In build()',
          'In initState()',
          'In constructor',
          'In main()',
        ],
        correctAnswerIndex: 1,
        explanation:
            'initState() is called once when the State object is created and is ideal for initializing state.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b7_4',
        lessonId: 'b7',
        question: 'What happens when setState() is called?',
        options: [
          'The app restarts',
          'The widget rebuilds',
          'State is saved',
          'Nothing',
        ],
        correctAnswerIndex: 1,
        explanation:
            'setState() triggers a rebuild of the widget, causing build() to be called again.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b7_5',
        lessonId: 'b7',
        question:
            'Which lifecycle method is called when a StatefulWidget is removed?',
        options: [
          'destroy()',
          'dispose()',
          'close()',
          'remove()',
        ],
        correctAnswerIndex: 1,
        explanation:
            'dispose() is called when the State object is permanently removed from the tree.',
        points: 10,
      ),

      // b8: Navigation and Routing
      const QuizQuestion(
        id: 'q_b8_1',
        lessonId: 'b8',
        question: 'Which class manages screen navigation in Flutter?',
        options: ['Router', 'Navigator', 'Routes', 'PageManager'],
        correctAnswerIndex: 1,
        explanation:
            'Navigator manages a stack of Route objects for screen navigation.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b8_2',
        lessonId: 'b8',
        question: 'How do you navigate to a new screen?',
        options: [
          'Navigator.push()',
          'Navigator.go()',
          'Navigator.open()',
          'Navigator.show()',
        ],
        correctAnswerIndex: 0,
        explanation:
            'Navigator.push() adds a new route to the navigation stack.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b8_3',
        lessonId: 'b8',
        question: 'How do you go back to the previous screen?',
        options: [
          'Navigator.back()',
          'Navigator.pop()',
          'Navigator.return()',
          'Navigator.previous()',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Navigator.pop() removes the current route and returns to the previous screen.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b8_4',
        lessonId: 'b8',
        question: 'What is a named route?',
        options: [
          'A route with a title',
          'A route identified by a string path',
          'A route with parameters',
          'The first route',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Named routes use string identifiers (like "/home") for navigation, making code cleaner.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_b8_5',
        lessonId: 'b8',
        question: 'How do you pass data to a new screen?',
        options: [
          'Global variables',
          'Through route arguments',
          'Shared preferences',
          'Cannot pass data',
        ],
        correctAnswerIndex: 1,
        explanation:
            'You can pass data through the arguments parameter in Navigator.push() or Navigator.pushNamed().',
        points: 10,
      ),

      // i1: Advanced Widgets
      const QuizQuestion(
        id: 'q_i1_1',
        lessonId: 'i1',
        question: 'Which widget creates a scrollable list?',
        options: ['Column', 'ListView', 'ScrollView', 'List'],
        correctAnswerIndex: 1,
        explanation:
            'ListView creates a scrollable list and efficiently renders only visible items.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i1_2',
        lessonId: 'i1',
        question:
            'What is the difference between ListView and ListView.builder?',
        options: [
          'No difference',
          'ListView.builder is for infinite lists',
          'ListView.builder builds items lazily on demand',
          'ListView is deprecated',
        ],
        correctAnswerIndex: 2,
        explanation:
            'ListView.builder creates items lazily as they scroll into view, making it more efficient for long lists.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i1_3',
        lessonId: 'i1',
        question: 'Which widget creates a grid layout?',
        options: [
          'GridView',
          'Grid',
          'Matrix',
          'Table',
        ],
        correctAnswerIndex: 0,
        explanation: 'GridView creates a 2D scrollable grid of widgets.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i1_4',
        lessonId: 'i1',
        question: 'What does CustomScrollView allow you to do?',
        options: [
          'Scroll faster',
          'Create custom scroll effects with slivers',
          'Disable scrolling',
          'Add scroll bars',
        ],
        correctAnswerIndex: 1,
        explanation:
            'CustomScrollView allows you to create custom scroll effects using slivers for advanced layouts.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i1_5',
        lessonId: 'i1',
        question: 'What is a Sliver in Flutter?',
        options: [
          'A small widget',
          'A scrollable area portion that can be customized',
          'A layout widget',
          'An animation',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Slivers are scrollable areas that can have custom scroll effects and are used with CustomScrollView.',
        points: 10,
      ),

      // i2: Forms and Input
      const QuizQuestion(
        id: 'q_i2_1',
        lessonId: 'i2',
        question: 'Which widget creates a text input field?',
        options: [
          'TextInput',
          'TextField',
          'InputField',
          'TextBox',
        ],
        correctAnswerIndex: 1,
        explanation:
            'TextField is the primary widget for accepting text input from users.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i2_2',
        lessonId: 'i2',
        question: 'What is used to validate form inputs?',
        options: [
          'FormValidator',
          'GlobalKey<FormState>',
          'Validator',
          'InputValidator',
        ],
        correctAnswerIndex: 1,
        explanation:
            'GlobalKey<FormState> is used to access form methods like validate(), save(), and reset().',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i2_3',
        lessonId: 'i2',
        question: 'How do you get the current value from a TextField?',
        options: [
          'TextField.value',
          'Using a TextEditingController',
          'TextField.text',
          'Using a FormField',
        ],
        correctAnswerIndex: 1,
        explanation:
            'TextEditingController manages the text being edited and provides access to the current value.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i2_4',
        lessonId: 'i2',
        question: 'What widget wraps multiple form fields?',
        options: [
          'FormContainer',
          'Form',
          'FormGroup',
          'InputGroup',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Form widget acts as a container for form fields and provides validation functionality.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i2_5',
        lessonId: 'i2',
        question: 'What does the validator function return on success?',
        options: [
          'true',
          'null',
          '"success"',
          'void',
        ],
        correctAnswerIndex: 1,
        explanation:
            'The validator function returns null if validation succeeds, or an error string if it fails.',
        points: 10,
      ),

      // i3: Networking and APIs
      const QuizQuestion(
        id: 'q_i3_1',
        lessonId: 'i3',
        question: 'Which package is commonly used for HTTP requests?',
        options: [
          'network',
          'http',
          'api',
          'request',
        ],
        correctAnswerIndex: 1,
        explanation:
            'The http package is the most common package for making HTTP requests in Flutter.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i3_2',
        lessonId: 'i3',
        question: 'What does jsonDecode() do?',
        options: [
          'Converts JSON to String',
          'Converts String to Dart object',
          'Validates JSON',
          'Encrypts JSON',
        ],
        correctAnswerIndex: 1,
        explanation:
            'jsonDecode() converts a JSON string into a Dart object (Map or List).',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i3_3',
        lessonId: 'i3',
        question: 'Which HTTP method is used to fetch data?',
        options: [
          'POST',
          'GET',
          'PUT',
          'DELETE',
        ],
        correctAnswerIndex: 1,
        explanation: 'GET is used to retrieve/fetch data from a server.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i3_4',
        lessonId: 'i3',
        question: 'What widget is used to show data while loading from API?',
        options: [
          'LoadingWidget',
          'FutureBuilder',
          'AsyncWidget',
          'DataLoader',
        ],
        correctAnswerIndex: 1,
        explanation:
            'FutureBuilder builds UI based on the state of a Future, showing loading, error, or success states.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i3_5',
        lessonId: 'i3',
        question: 'What is the alternative to http package?',
        options: [
          'request',
          'dio',
          'fetch',
          'ajax',
        ],
        correctAnswerIndex: 1,
        explanation:
            'dio is a powerful HTTP client with interceptors, global configuration, and more features.',
        points: 10,
      ),

      // i4: Async Programming
      const QuizQuestion(
        id: 'q_i4_1',
        lessonId: 'i4',
        question: 'What keyword marks a function as asynchronous?',
        options: [
          'await',
          'async',
          'future',
          'promise',
        ],
        correctAnswerIndex: 1,
        explanation:
            'The async keyword marks a function as asynchronous and allows using await inside it.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i4_2',
        lessonId: 'i4',
        question: 'What does await keyword do?',
        options: [
          'Creates a delay',
          'Waits for a Future to complete',
          'Makes code faster',
          'Stops execution permanently',
        ],
        correctAnswerIndex: 1,
        explanation:
            'await pauses execution until a Future completes and returns its result.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i4_3',
        lessonId: 'i4',
        question: 'What is a Future in Dart?',
        options: [
          'A time value',
          'A value that will be available later',
          'A function',
          'A widget',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Future represents a potential value or error that will be available at some point in the future.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i4_4',
        lessonId: 'i4',
        question: 'How do you handle errors in async functions?',
        options: [
          'if-else',
          'try-catch',
          'error handler',
          'validate',
        ],
        correctAnswerIndex: 1,
        explanation:
            'try-catch blocks are used to handle errors in async functions.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i4_5',
        lessonId: 'i4',
        question: 'What is Stream in Dart?',
        options: [
          'A video player',
          'A sequence of async events',
          'A file reader',
          'A network connection',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Stream provides a sequence of asynchronous events/data over time.',
        points: 10,
      ),

      // i5: Local Storage
      const QuizQuestion(
        id: 'q_i5_1',
        lessonId: 'i5',
        question: 'Which package stores simple key-value pairs?',
        options: [
          'storage',
          'shared_preferences',
          'database',
          'cache',
        ],
        correctAnswerIndex: 1,
        explanation:
            'shared_preferences stores simple key-value pairs persistently on the device.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i5_2',
        lessonId: 'i5',
        question: 'Which package provides SQLite database?',
        options: [
          'sql',
          'sqflite',
          'database',
          'sqlite',
        ],
        correctAnswerIndex: 1,
        explanation:
            'sqflite provides SQLite database functionality for Flutter apps.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i5_3',
        lessonId: 'i5',
        question: 'What types of data can SharedPreferences store?',
        options: [
          'Only strings',
          'Primitives: int, double, bool, string, List<String>',
          'Any objects',
          'Only JSON',
        ],
        correctAnswerIndex: 1,
        explanation:
            'SharedPreferences can store primitive types: int, double, bool, String, and List<String>.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i5_4',
        lessonId: 'i5',
        question: 'Which is a NoSQL database for Flutter?',
        options: [
          'SQLite',
          'Hive',
          'MySQL',
          'PostgreSQL',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Hive is a lightweight and fast NoSQL database written in pure Dart.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i5_5',
        lessonId: 'i5',
        question: 'Where is data stored with SharedPreferences on Android?',
        options: [
          'External storage',
          'XML files in app data directory',
          'SQLite database',
          'Cloud',
        ],
        correctAnswerIndex: 1,
        explanation:
            'On Android, SharedPreferences stores data in XML files in the app\'s data directory.',
        points: 10,
      ),

      // i6: Animations
      const QuizQuestion(
        id: 'q_i6_1',
        lessonId: 'i6',
        question: 'Which widget provides implicit animations?',
        options: [
          'Animation',
          'AnimatedContainer',
          'Animator',
          'TransitionWidget',
        ],
        correctAnswerIndex: 1,
        explanation:
            'AnimatedContainer automatically animates changes to its properties.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i6_2',
        lessonId: 'i6',
        question: 'What controls explicit animations?',
        options: [
          'AnimationBuilder',
          'AnimationController',
          'AnimationManager',
          'Animator',
        ],
        correctAnswerIndex: 1,
        explanation:
            'AnimationController controls animation playback: start, stop, reverse, and duration.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i6_3',
        lessonId: 'i6',
        question: 'What is a Tween?',
        options: [
          'An animation type',
          'A mapping between two values',
          'A widget',
          'A controller',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Tween defines a linear mapping between a beginning and ending value.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i6_4',
        lessonId: 'i6',
        question: 'What does TickerProviderStateMixin provide?',
        options: [
          'Animation widgets',
          'Ticker for AnimationController',
          'Animation curves',
          'Transition effects',
        ],
        correctAnswerIndex: 1,
        explanation:
            'TickerProviderStateMixin provides Ticker for AnimationController to run animations.',
        points: 10,
      ),
      const QuizQuestion(
        id: 'q_i6_5',
        lessonId: 'i6',
        question: 'What is Hero animation used for?',
        options: [
          'Game animations',
          'Shared element transition between screens',
          'Loading animations',
          'Button animations',
        ],
        correctAnswerIndex: 1,
        explanation:
            'Hero animation creates smooth transitions for shared elements when navigating between screens.',
        points: 10,
      ),
    ];
  }

  void loadQuizForLesson(String lessonId) {
    currentLessonId.value = lessonId;
    questions.value =
        allQuestions.where((q) => q.lessonId == lessonId).toList();

    // If no questions found for this lesson, use general questions
    if (questions.isEmpty) {
      questions.value = allQuestions.take(5).toList();
    }
  }

  QuizQuestion get currentQuestion => questions[currentQuestionIndex.value];

  bool get hasNextQuestion => currentQuestionIndex.value < questions.length - 1;

  bool get hasPreviousQuestion => currentQuestionIndex.value > 0;

  int get totalQuestions => questions.length;

  int get answeredCount => userAnswers.length;

  double get progress =>
      questions.isEmpty ? 0.0 : answeredCount / totalQuestions;

  void selectAnswer(int answerIndex) {
    userAnswers[currentQuestionIndex.value] = answerIndex;
    showExplanation.value = true;

    // Calculate score
    if (answerIndex == currentQuestion.correctAnswerIndex) {
      score.value += currentQuestion.points;
    }
  }

  void nextQuestion() {
    if (hasNextQuestion) {
      currentQuestionIndex.value++;
      showExplanation.value = false;
    } else {
      completeQuiz();
    }
  }

  void previousQuestion() {
    if (hasPreviousQuestion) {
      currentQuestionIndex.value--;
      showExplanation.value = userAnswers.containsKey(
        currentQuestionIndex.value,
      );
    }
  }

  void completeQuiz() {
    isCompleted.value = true;

    // Save quiz result
    if (currentLessonId.value.isNotEmpty) {
      final maxScore = questions.fold<int>(0, (sum, q) => sum + q.points);
      final isPerfectScore = correctAnswersCount == totalQuestions;

      // Only award XP if user got all answers correct
      final xpEarned = isPerfectScore ? score.value : 0;

      _trackingService.saveQuizResult(
        lessonId: currentLessonId.value,
        score: score.value,
        maxScore: maxScore,
        xpEarned: xpEarned,
        correctAnswers: correctAnswersCount,
        totalQuestions: totalQuestions,
      );
    }
  }

  void restartQuiz() {
    currentQuestionIndex.value = 0;
    userAnswers.clear();
    score.value = 0;
    isCompleted.value = false;
    showExplanation.value = false;
  }

  int? getUserAnswer(int questionIndex) {
    return userAnswers[questionIndex];
  }

  bool isAnswerCorrect(int questionIndex) {
    final userAnswer = userAnswers[questionIndex];
    if (userAnswer == null) return false;
    return userAnswer == questions[questionIndex].correctAnswerIndex;
  }

  int get correctAnswersCount {
    int count = 0;
    for (int i = 0; i < questions.length; i++) {
      if (isAnswerCorrect(i)) {
        count++;
      }
    }
    return count;
  }

  double get scorePercentage {
    if (questions.isEmpty) return 0.0;
    final maxScore = questions.fold<int>(0, (sum, q) => sum + q.points);
    return maxScore > 0 ? (score.value / maxScore) * 100 : 0.0;
  }
}
