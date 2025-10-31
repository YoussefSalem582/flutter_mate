import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';
import '../../controller/code_playground_controller.dart';

/// Output Console Widget for displaying code execution results.
///
/// This widget provides a terminal-like interface for displaying:
/// - Syntax-highlighted output with VS Code color scheme
/// - Success/Error status badges
/// - Empty state when no output is available
/// - Scrollable output for long results
///
/// The console supports colored output through the OutputSegment model,
/// highlighting strings, numbers, booleans, keywords, and punctuation
/// in different colors similar to VS Code IDE.
class OutputConsoleWidget extends GetView<CodePlaygroundController> {
  const OutputConsoleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect theme for adaptive styling
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // VS Code-inspired dark background
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Console header with status badge
          _buildConsoleHeader(),

          // Output content area with reactive state management
          Expanded(
            child: Obx(() {
              // Show empty state if no output
              if (controller.output.isEmpty) {
                return _buildEmptyState();
              }

              // Show colored output or plain text
              return _buildOutputContent();
            }),
          ),
        ],
      ),
    );
  }

  /// Builds the console header with gradient background and status badge.
  ///
  /// Features:
  /// - Terminal icon with semi-transparent background
  /// - "Output Console" title
  /// - Dynamic status badge (Success/Error) that appears when output exists
  /// - Green gradient theme for positive association
  Widget _buildConsoleHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
        ),
      ),
      child: Row(
        children: [
          // Terminal icon container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.terminal_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),

          // Console title
          const Text(
            'Output Console',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),

          // Status badge - only shown when output exists
          Obx(() {
            if (controller.output.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  // Red tint for errors, white tint for success
                  color: controller.hasError
                      ? Colors.red.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.hasError
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.hasError ? 'Error' : 'Success',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  /// Builds the empty state UI when no output is available.
  ///
  /// Shows:
  /// - Personalized greeting based on auth state
  /// - Large code-off icon
  /// - "No output yet" message
  /// - Helpful instruction text
  Widget _buildEmptyState() {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    String greeting = 'Happy Coding!';
    if (user != null) {
      final name = user.displayName ?? user.email.split('@')[0];
      greeting = 'Happy Coding, $name!';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.code_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            greeting,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No output yet',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Run your code to see the output here',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Builds the output content with syntax highlighting.
  ///
  /// Two rendering modes:
  /// 1. Plain text - When coloredOutput is empty (fallback)
  /// 2. Syntax-highlighted - When coloredOutput contains segments
  ///
  /// The colored output uses VS Code-inspired color scheme:
  /// - Orange (#CE9178) for strings
  /// - Light green (#B5CEA8) for numbers (bold)
  /// - Blue (#569CD6) for booleans and null (bold)
  /// - Purple (#C586C0) for keywords (bold)
  /// - Light gray (#D4D4D4) for default text and punctuation
  Widget _buildOutputContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Dark red for errors, VS Code dark for success
            color: controller.hasError
                ? const Color(0xFF2D0000)
                : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.hasError
                  ? Colors.red.shade700
                  : Colors.green.shade700,
              width: 2,
            ),
          ),
          // Choose between plain text or syntax-highlighted rendering
          child: controller.coloredOutput.isEmpty
              ? SelectableText(
                  controller.output,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 14,
                    color: controller.hasError
                        ? Colors.red.shade300
                        : const Color(0xFFD4D4D4),
                    height: 1.5,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Map each line's segments to RichText widgets
                  children: controller.coloredOutput.map((lineSegments) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 14,
                            height: 1.5,
                          ),
                          // Map each segment to a TextSpan with its color and style
                          children: lineSegments.map((segment) {
                            return TextSpan(
                              text: segment.text,
                              style: TextStyle(
                                color: segment.color,
                                fontWeight: segment.isBold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }
}
