import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Help dialog for the Code Playground feature.
///
/// This dialog provides users with quick guidance on how to use
/// the Code Playground, including:
/// - Browsing pre-made code snippets
/// - Editing and experimenting with code
/// - Running code to see output
/// - Resetting code to original state
///
/// The dialog features a gradient design consistent with the app's
/// theme and can be shown from anywhere using the static show() method.
class PlaygroundHelpDialog extends StatelessWidget {
  const PlaygroundHelpDialog({super.key});

  /// Static method to display the help dialog.
  ///
  /// Usage:
  /// ```dart
  /// PlaygroundHelpDialog.show(context);
  /// ```
  static void show(BuildContext context) {
    Get.dialog(const PlaygroundHelpDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Subtle gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large help icon with circular gradient background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade600, Colors.indigo.shade400],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            // Dialog title
            const Text(
              'Code Playground Help',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Help items explaining each feature
            _buildHelpItem(
              Icons.library_books_rounded,
              'Browse Snippets',
              'Tap the library icon to browse pre-made code examples',
            ),
            _buildHelpItem(
              Icons.edit_rounded,
              'Edit Code',
              'Modify the code in the editor to experiment',
            ),
            _buildHelpItem(
              Icons.play_arrow_rounded,
              'Run Code',
              'Click "Run Code" to execute and see the output',
            ),
            _buildHelpItem(
              Icons.refresh_rounded,
              'Reset',
              'Reset to the original snippet code',
            ),
            const SizedBox(height: 20),

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Got it!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single help item row.
  ///
  /// Each help item consists of:
  /// - Icon with colored background
  /// - Title in bold
  /// - Description text
  ///
  /// Parameters:
  /// - [icon]: The icon to display
  /// - [title]: The feature title
  /// - [description]: Explanation of the feature
  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container with background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.indigo.shade700, size: 20),
          ),
          const SizedBox(width: 12),

          // Title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
