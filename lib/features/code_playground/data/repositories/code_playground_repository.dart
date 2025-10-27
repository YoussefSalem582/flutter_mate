import '../models/code_snippet.dart';

abstract class CodePlaygroundRepository {
  List<CodeSnippet> getAllSnippets();
  List<CodeSnippet> getSnippetsByCategory(String category);
  CodeSnippet? getSnippetById(String id);
}

class CodePlaygroundRepositoryImpl implements CodePlaygroundRepository {
  final List<CodeSnippet> _snippets = const [
    // Beginner Snippets
    CodeSnippet(
      id: 'hello_world',
      title: 'Hello World',
      description: 'Your first Dart program',
      category: 'beginner',
      tags: ['basics', 'print'],
      initialCode: '''void main() {
  print('Hello, World!');
}''',
      expectedOutput: 'Hello, World!',
    ),
    CodeSnippet(
      id: 'variables',
      title: 'Variables',
      description: 'Learn about variables in Dart',
      category: 'beginner',
      tags: ['basics', 'variables'],
      initialCode: '''void main() {
  var name = 'Flutter';
  int age = 5;
  double version = 3.0;
  bool isAwesome = true;
  
  print('Name: \$name');
  print('Age: \$age');
  print('Version: \$version');
  print('Is Awesome: \$isAwesome');
}''',
      expectedOutput: 'Name: Flutter\nAge: 5\nVersion: 3.0\nIs Awesome: true',
    ),
    CodeSnippet(
      id: 'string_manipulation',
      title: 'String Operations',
      description: 'Work with strings in Dart',
      category: 'beginner',
      tags: ['strings', 'manipulation'],
      initialCode: '''void main() {
  String text = 'Flutter is Amazing!';
  
  print('Original: \$text');
  print('Uppercase: \${text.toUpperCase()}');
  print('Lowercase: \${text.toLowerCase()}');
  print('Length: \${text.length}');
  print('Contains "Flutter": \${text.contains("Flutter")}');
}''',
      expectedOutput: 'Original: Flutter is Amazing!',
    ),

    // Control Flow
    CodeSnippet(
      id: 'if_else',
      title: 'If-Else Statements',
      description: 'Learn conditional logic',
      category: 'control_flow',
      tags: ['conditions', 'if-else'],
      initialCode: '''void main() {
  int score = 85;
  
  if (score >= 90) {
    print('Grade: A');
  } else if (score >= 80) {
    print('Grade: B');
  } else if (score >= 70) {
    print('Grade: C');
  } else {
    print('Grade: F');
  }
  
  print('Score: \$score');
}''',
      expectedOutput: 'Grade: B\nScore: 85',
    ),
    CodeSnippet(
      id: 'loops',
      title: 'Loops',
      description: 'Learn about for and while loops',
      category: 'control_flow',
      tags: ['loops', 'iteration'],
      initialCode: '''void main() {
  print('For loop:');
  for (int i = 1; i <= 5; i++) {
    print('Count: \$i');
  }
  
  print('\\nWhile loop:');
  int j = 1;
  while (j <= 3) {
    print('Number: \$j');
    j++;
  }
}''',
      expectedOutput:
          'For loop:\nCount: 1\nCount: 2\nCount: 3\nCount: 4\nCount: 5',
    ),

    // Collections
    CodeSnippet(
      id: 'lists',
      title: 'Lists',
      description: 'Work with lists in Dart',
      category: 'collections',
      tags: ['lists', 'arrays'],
      initialCode: '''void main() {
  List<String> fruits = ['Apple', 'Banana', 'Orange'];
  
  print('Fruits: \$fruits');
  print('First fruit: \${fruits[0]}');
  print('Number of fruits: \${fruits.length}');
  
  fruits.add('Mango');
  print('After adding: \$fruits');
  
  for (var fruit in fruits) {
    print('- \$fruit');
  }
}''',
      expectedOutput: 'Fruits: [Apple, Banana, Orange]',
    ),
    CodeSnippet(
      id: 'maps',
      title: 'Maps',
      description: 'Learn about key-value pairs',
      category: 'collections',
      tags: ['maps', 'dictionaries'],
      initialCode: '''void main() {
  Map<String, int> scores = {
    'Alice': 95,
    'Bob': 87,
    'Charlie': 92,
  };
  
  print('Scores: \$scores');
  print('Alice\\'s score: \${scores['Alice']}');
  
  scores['David'] = 88;
  print('After adding David: \$scores');
  
  for (var entry in scores.entries) {
    print('\${entry.key}: \${entry.value}');
  }
}''',
      expectedOutput: 'Scores: {Alice: 95, Bob: 87, Charlie: 92}',
    ),

    // Functions
    CodeSnippet(
      id: 'functions',
      title: 'Functions',
      description: 'Create and use functions',
      category: 'functions',
      tags: ['functions', 'methods'],
      initialCode: '''void main() {
  greet('Flutter Developer');
  
  int sum = add(5, 3);
  print('Sum: \$sum');
  
  int product = multiply(4, 7);
  print('Product: \$product');
}

void greet(String name) {
  print('Hello, \$name!');
}

int add(int a, int b) {
  return a + b;
}

int multiply(int a, int b) => a * b;''',
      expectedOutput: 'Hello, Flutter Developer!\nSum: 8\nProduct: 28',
    ),

    // Classes
    CodeSnippet(
      id: 'classes',
      title: 'Classes',
      description: 'Object-oriented programming basics',
      category: 'oop',
      tags: ['classes', 'objects', 'oop'],
      initialCode: '''void main() {
  var person = Person('Alice', 25);
  person.introduce();
  
  person.age = 26;
  print('After birthday: \${person.age} years old');
}

class Person {
  String name;
  int age;
  
  Person(this.name, this.age);
  
  void introduce() {
    print('Hi, I\\'m \$name and I\\'m \$age years old.');
  }
}''',
      expectedOutput: 'Hi, I\'m Alice and I\'m 25 years old.',
    ),
  ];

  @override
  List<CodeSnippet> getAllSnippets() {
    return _snippets;
  }

  @override
  List<CodeSnippet> getSnippetsByCategory(String category) {
    return _snippets.where((s) => s.category == category).toList();
  }

  @override
  CodeSnippet? getSnippetById(String id) {
    try {
      return _snippets.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
