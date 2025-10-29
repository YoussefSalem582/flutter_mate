import 'package:cloud_firestore/cloud_firestore.dart';

/// Sample assessment questions to populate Firestore
/// Run this once to add initial questions to your database
class AssessmentQuestionSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedQuestions() async {
    final questions = _getSampleQuestions();

    try {
      final batch = _firestore.batch();

      for (var question in questions) {
        final docRef =
            _firestore.collection('assessment_questions').doc(question['id']);
        batch.set(docRef, question);
      }

      await batch.commit();
      print('✅ Successfully seeded ${questions.length} assessment questions');
    } catch (e) {
      print('❌ Error seeding questions: $e');
      rethrow;
    }
  }

  static List<Map<String, dynamic>> _getSampleQuestions() {
    return [
      // Flutter Basics
      {
        'id': 'flutter_basics_1',
        'question': 'What is Flutter?',
        'options': [
          'A mobile development framework',
          'A programming language',
          'A database system',
          'An IDE',
        ],
        'correctAnswer': 0,
        'category': 'Flutter Basics',
        'difficulty': 'easy',
        'points': 10,
        'explanation':
            'Flutter is an open-source UI software development kit created by Google for building natively compiled applications.',
      },
      {
        'id': 'flutter_basics_2',
        'question': 'Which programming language is used to write Flutter apps?',
        'options': ['Java', 'Kotlin', 'Dart', 'Swift'],
        'correctAnswer': 2,
        'category': 'Flutter Basics',
        'difficulty': 'easy',
        'points': 10,
        'explanation': 'Flutter uses Dart as its programming language.',
      },
      {
        'id': 'flutter_basics_3',
        'question': 'What is a Widget in Flutter?',
        'options': [
          'A database',
          'A building block of the UI',
          'A network protocol',
          'A testing tool',
        ],
        'correctAnswer': 1,
        'category': 'Flutter Basics',
        'difficulty': 'easy',
        'points': 10,
        'explanation':
            'Everything in Flutter is a Widget. Widgets are the building blocks of Flutter apps.',
      },

      // Widgets & UI
      {
        'id': 'widgets_1',
        'question':
            'What is the difference between StatelessWidget and StatefulWidget?',
        'options': [
          'StatelessWidget can change state',
          'StatefulWidget cannot change state',
          'StatelessWidget is immutable, StatefulWidget can change state',
          'There is no difference',
        ],
        'correctAnswer': 2,
        'category': 'Widgets & UI',
        'difficulty': 'medium',
        'points': 15,
        'explanation':
            'StatelessWidget is immutable and doesn\'t change, while StatefulWidget can maintain mutable state.',
      },
      {
        'id': 'widgets_2',
        'question': 'Which widget is used for layout in rows?',
        'options': ['Column', 'Row', 'Stack', 'ListView'],
        'correctAnswer': 1,
        'category': 'Widgets & UI',
        'difficulty': 'easy',
        'points': 10,
        'explanation':
            'Row widget arranges its children in a horizontal array.',
      },
      {
        'id': 'widgets_3',
        'question': 'What does the setState() method do?',
        'options': [
          'Deletes the widget',
          'Triggers a rebuild of the widget',
          'Navigates to another screen',
          'Saves data to database',
        ],
        'correctAnswer': 1,
        'category': 'Widgets & UI',
        'difficulty': 'medium',
        'points': 15,
        'explanation':
            'setState() tells Flutter that the internal state has changed and triggers a rebuild.',
      },

      // State Management
      {
        'id': 'state_1',
        'question': 'Which is NOT a state management solution in Flutter?',
        'options': ['Provider', 'GetX', 'Redux', 'Angular'],
        'correctAnswer': 3,
        'category': 'State Management',
        'difficulty': 'easy',
        'points': 10,
        'explanation':
            'Angular is a web framework, not a Flutter state management solution.',
      },
      {
        'id': 'state_2',
        'question': 'What is the purpose of InheritedWidget?',
        'options': [
          'To navigate between screens',
          'To share data down the widget tree',
          'To make HTTP requests',
          'To handle animations',
        ],
        'correctAnswer': 1,
        'category': 'State Management',
        'difficulty': 'hard',
        'points': 20,
        'explanation':
            'InheritedWidget efficiently propagates information down the widget tree.',
      },

      // Navigation
      {
        'id': 'navigation_1',
        'question': 'Which method is used to navigate to a new screen?',
        'options': [
          'Navigator.push()',
          'Navigator.open()',
          'Navigator.goto()',
          'Navigator.move()',
        ],
        'correctAnswer': 0,
        'category': 'Navigation',
        'difficulty': 'easy',
        'points': 10,
        'explanation':
            'Navigator.push() pushes a new route onto the navigation stack.',
      },
      {
        'id': 'navigation_2',
        'question': 'How do you go back to the previous screen?',
        'options': [
          'Navigator.back()',
          'Navigator.previous()',
          'Navigator.pop()',
          'Navigator.return()',
        ],
        'correctAnswer': 2,
        'category': 'Navigation',
        'difficulty': 'easy',
        'points': 10,
        'explanation':
            'Navigator.pop() removes the current route from the navigation stack.',
      },

      // Async & Networking
      {
        'id': 'async_1',
        'question': 'What keyword is used to mark a function as asynchronous?',
        'options': ['await', 'async', 'future', 'promise'],
        'correctAnswer': 1,
        'category': 'Async Programming',
        'difficulty': 'easy',
        'points': 10,
        'explanation':
            'The async keyword marks a function as asynchronous in Dart.',
      },
      {
        'id': 'async_2',
        'question': 'What does Future represent in Dart?',
        'options': [
          'A past event',
          'A value that will be available later',
          'A widget type',
          'A database',
        ],
        'correctAnswer': 1,
        'category': 'Async Programming',
        'difficulty': 'medium',
        'points': 15,
        'explanation':
            'Future represents a potential value or error that will be available at some time in the future.',
      },

      // Layout & Design
      {
        'id': 'layout_1',
        'question':
            'Which widget allows children to overflow and be scrollable?',
        'options': ['Container', 'Column', 'SingleChildScrollView', 'Padding'],
        'correctAnswer': 2,
        'category': 'Layout & Design',
        'difficulty': 'medium',
        'points': 15,
        'explanation':
            'SingleChildScrollView makes its child scrollable when content overflows.',
      },
      {
        'id': 'layout_2',
        'question': 'What is the purpose of the Expanded widget?',
        'options': [
          'To add padding',
          'To fill available space in Row/Column',
          'To create animations',
          'To handle gestures',
        ],
        'correctAnswer': 1,
        'category': 'Layout & Design',
        'difficulty': 'medium',
        'points': 15,
        'explanation':
            'Expanded widget fills the available space along the main axis in a Row or Column.',
      },

      // Advanced Topics
      {
        'id': 'advanced_1',
        'question':
            'What is the widget lifecycle method called when a StatefulWidget is created?',
        'options': [
          'build()',
          'initState()',
          'dispose()',
          'didChangeDependencies()'
        ],
        'correctAnswer': 1,
        'category': 'Advanced Topics',
        'difficulty': 'hard',
        'points': 20,
        'explanation':
            'initState() is called once when the StatefulWidget is inserted into the widget tree.',
      },
      {
        'id': 'advanced_2',
        'question': 'What is Hot Reload in Flutter?',
        'options': [
          'Restarting the device',
          'Injecting updated source code without losing app state',
          'Clearing app cache',
          'Updating Flutter SDK',
        ],
        'correctAnswer': 1,
        'category': 'Advanced Topics',
        'difficulty': 'medium',
        'points': 15,
        'explanation':
            'Hot Reload quickly injects updated source code into the running Dart VM without losing the app state.',
      },
    ];
  }
}
