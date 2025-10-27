import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/code_playground_controller.dart';

/// Code Editor Widget for the Code Playground feature.
///
/// This widget provides a professional code editing experience with:
/// - Syntax-highlighted line numbers
/// - VS Code-inspired dark/light theme
/// - Real-time code editing
/// - Snippet information display
/// - Gradient header showing current snippet details
///
/// The editor uses a monospace font (Courier) for better code readability
/// and updates the controller state reactively as the user types.
class CodeEditorWidget extends GetView<CodePlaygroundController> {
  const CodeEditorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect current theme for adaptive styling
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // VS Code-inspired color scheme
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Editor Header - Shows snippet title and description
          _buildEditorHeader(context),

          // Main editing area with line numbers and text field
          Expanded(
            child: Row(
              children: [
                // Left sidebar with line numbers
                _buildLineNumbers(isDark),
                // Code input text field
                _buildCodeInput(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the editor header with gradient background.
  ///
  /// Displays:
  /// - Code icon with semi-transparent background
  /// - Current snippet title (or "Custom Code" if none selected)
  /// - Snippet description (if available)
  /// - Info button to view snippet details
  Widget _buildEditorHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.indigo.shade500],
        ),
      ),
      child: Obx(
        () => Row(
          children: [
            // Icon container with semi-transparent background
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.code_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),

            // Snippet title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.currentSnippet?.title ?? 'Custom Code',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // Show description if snippet is loaded
                  if (controller.currentSnippet?.description != null)
                    Text(
                      controller.currentSnippet!.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Info button - only visible when snippet is loaded
            if (controller.currentSnippet != null)
              IconButton(
                icon: const Icon(Icons.info_outline, size: 20),
                onPressed: () => _showSnippetInfo(context),
                tooltip: 'Snippet Info',
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the line numbers sidebar.
  ///
  /// The sidebar:
  /// - Shows line numbers starting from 1
  /// - Updates reactively as lines are added/removed
  /// - Uses a slightly darker background than the editor
  /// - Aligns numbers to the right for better readability
  Widget _buildLineNumbers(bool isDark) {
    return Container(
      width: 50,
      // Slightly darker than editor background (VS Code style)
      color: isDark ? const Color(0xFF252526) : const Color(0xFFEEEEEE),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Obx(() {
        // Calculate number of lines from current code
        final lines = controller.code.split('\n').length;
        return ListView.builder(
          itemCount: lines,
          itemBuilder: (context, index) {
            return SizedBox(
              height: 20, // Match text field line height
              child: Text(
                '${index + 1}', // Line numbers start at 1
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.right,
              ),
            );
          },
        );
      }),
    );
  }

  /// Builds the main code input text field.
  ///
  /// Features:
  /// - Multi-line input with auto-expansion
  /// - Monospace font for code readability
  /// - Real-time updates to controller
  /// - Theme-adaptive text color
  /// - No visible border for clean appearance
  Widget _buildCodeInput(bool isDark) {
    return Expanded(
      child: TextField(
        controller: controller.codeController,
        onChanged: controller.updateCode, // Update controller on each keystroke
        maxLines: null, // Allow unlimited lines
        expands: true, // Fill available space
        style: TextStyle(
          fontFamily: 'Courier', // Monospace font for code
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black,
          height: 1.5, // Line spacing for readability
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none, // No border for clean look
          hintText: 'Write your Dart code here...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontFamily: 'Courier',
          ),
        ),
      ),
    );
  }

  /// Shows a dialog with detailed snippet information.
  ///
  /// Displays:
  /// - Snippet title and description
  /// - Expected output (if available)
  /// - Close button to dismiss the dialog
  void _showSnippetInfo(BuildContext context) {
    final snippet = controller.currentSnippet;
    if (snippet == null) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with info icon and title
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.indigo),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      snippet.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Snippet description
              Text(snippet.description, style: const TextStyle(fontSize: 14)),

              // Expected output section (if available)
              if (snippet.expectedOutput.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Expected Output:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    snippet.expectedOutput,
                    style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Close button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
