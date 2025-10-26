import 'package:get/get.dart';

class AssistantController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isTyping = false.obs;
  final suggestions = <String>[
    'How do I create a stateful widget?',
    'What is the difference between hot reload and hot restart?',
    'How to manage state in Flutter?',
    'Best practices for Flutter layouts?',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    messages.add(
      ChatMessage(
        text: 'Hello! 👋 I\'m your Flutter learning assistant. I can help you with:\n\n'
            '• Flutter concepts and best practices\n'
            '• Code examples and explanations\n'
            '• Debugging tips\n'
            '• Learning path recommendations\n\n'
            'What would you like to learn about today?',
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    messages.add(
      ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
      ),
    );

    // Show typing indicator
    isTyping.value = true;

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate response based on keywords
    final response = _generateResponse(text);

    isTyping.value = false;

    // Add AI response
    messages.add(
      ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.text,
      ),
    );
  }

  String _generateResponse(String userMessage) {
    final lowercaseMessage = userMessage.toLowerCase();

    if (lowercaseMessage.contains('widget') || lowercaseMessage.contains('stateful') || lowercaseMessage.contains('stateless')) {
      return 'Great question about widgets! 🎨\n\n'
          'In Flutter, there are two main types of widgets:\n\n'
          '**StatelessWidget**: Immutable widgets that don\'t change their state.\n'
          'Example: Text, Icon, Container\n\n'
          '**StatefulWidget**: Widgets that can change their state over time.\n'
          'Example: Checkbox, TextField, AnimatedContainer\n\n'
          'Would you like to see code examples?';
    } else if (lowercaseMessage.contains('state') || lowercaseMessage.contains('management')) {
      return 'State management is crucial in Flutter! 📊\n\n'
          'Popular approaches:\n\n'
          '1. **Provider** - Recommended by Google\n'
          '2. **Riverpod** - Advanced provider\n'
          '3. **GetX** - What we use in FlutterMate!\n'
          '4. **BLoC** - Business Logic Component\n'
          '5. **Redux** - Predictable state container\n\n'
          'Check out the "State Management" lesson in the Intermediate stage!';
    } else if (lowercaseMessage.contains('hot reload') || lowercaseMessage.contains('hot restart')) {
      return 'Let me explain the difference! 🔥\n\n'
          '**Hot Reload** (⚡ faster):\n'
          '• Injects updated code into running app\n'
          '• Preserves app state\n'
          '• Usually takes < 1 second\n'
          '• Use: Ctrl+S or ⚡ icon\n\n'
          '**Hot Restart** (🔄 full reload):\n'
          '• Restarts the entire app\n'
          '• Resets app state\n'
          '• Takes a few seconds\n'
          '• Use when changing app structure';
    } else if (lowercaseMessage.contains('layout') || lowercaseMessage.contains('row') || lowercaseMessage.contains('column')) {
      return 'Flutter layouts are powerful! 📐\n\n'
          'Key layout widgets:\n\n'
          '• **Column**: Vertical arrangement\n'
          '• **Row**: Horizontal arrangement\n'
          '• **Stack**: Overlapping widgets\n'
          '• **Container**: Box model with padding, margin\n'
          '• **Expanded**: Takes available space\n'
          '• **Flexible**: Flexible space allocation\n\n'
          'Check the "Layouts & Styling" lesson for hands-on practice!';
    } else if (lowercaseMessage.contains('help') || lowercaseMessage.contains('learn')) {
      return 'I\'m here to help! 🚀\n\n'
          'Here are some ways I can assist:\n\n'
          '1. Answer Flutter questions\n'
          '2. Explain code concepts\n'
          '3. Suggest learning resources\n'
          '4. Debug common issues\n'
          '5. Recommend next lessons\n\n'
          'Try asking about widgets, state management, layouts, or any Flutter topic!';
    } else if (lowercaseMessage.contains('api') || lowercaseMessage.contains('http') || lowercaseMessage.contains('fetch')) {
      return 'Making API calls in Flutter! 🌐\n\n'
          'Best practices:\n\n'
          '1. Use the **http** package\n'
          '2. Handle async/await properly\n'
          '3. Parse JSON responses\n'
          '4. Handle errors gracefully\n'
          '5. Show loading indicators\n\n'
          'Check the "API Integration" lesson in Intermediate stage for a complete guide!';
    } else if (lowercaseMessage.contains('error') || lowercaseMessage.contains('debug') || lowercaseMessage.contains('fix')) {
      return 'Debugging tips! 🐛\n\n'
          '1. **Read error messages** carefully\n'
          '2. Use **print()** statements\n'
          '3. Try **Flutter DevTools**\n'
          '4. Check **Stack Overflow**\n'
          '5. Use **hot reload** frequently\n\n'
          'Common errors:\n'
          '• RenderFlex overflow → Use Flexible/Expanded\n'
          '• Null check failed → Handle null values\n'
          '• setState during build → Use addPostFrameCallback\n\n'
          'What specific error are you facing?';
    } else {
      return 'Interesting question! 🤔\n\n'
          'While I\'m still learning, here are some resources that might help:\n\n'
          '• Flutter Documentation: docs.flutter.dev\n'
          '• Flutter Cookbook: recipes and examples\n'
          '• Stack Overflow: community Q&A\n'
          '• Our lesson library: structured learning\n\n'
          'Try rephrasing your question or asking about:\n'
          '• Widgets\n'
          '• State management\n'
          '• Layouts\n'
          '• API integration\n\n'
          'I\'m here to help! 😊';
    }
  }

  void clearChat() {
    messages.clear();
    _addWelcomeMessage();
  }

  void useSuggestion(String suggestion) {
    sendMessage(suggestion);
  }
}

enum MessageType {
  text,
  code,
  image,
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType messageType;
  final String? codeLanguage;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.messageType = MessageType.text,
    this.codeLanguage,
  });
}
