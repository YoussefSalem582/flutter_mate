import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../controller/code_playground_controller.dart';

/// Widget that displays the control buttons for the code playground.
///
/// This widget provides three main actions:
/// - Run Code: Executes the current code in the editor
/// - Reset: Restores the code to the original snippet
/// - Clear: Clears the output console
///
/// The widget uses GetX for reactive state management and adapts
/// its appearance based on the current theme (dark/light mode).
class ControlButtonsWidget extends GetView<CodePlaygroundController> {
  const ControlButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect current theme to adapt button styling
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Adapt background color based on theme
        color: isDark ? AppColors.darkSurface : Colors.white,
        // Add subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Run Code Button - Takes up 2/3 of the available space
          Expanded(
            flex: 2,
            child: Obx(() {
              // Reactive widget that rebuilds when execution state changes
              return ElevatedButton.icon(
                // Disable button while code is executing
                onPressed: controller.isExecuting
                    ? null
                    : controller.executeCode,
                // Show loading indicator or play icon based on state
                icon: controller.isExecuting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 24),
                // Dynamic label showing current execution state
                label: Text(
                  controller.isExecuting ? 'Running...' : 'Run Code',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              );
            }),
          ),
          const SizedBox(width: 12),

          // Reset Button - Restores original snippet code
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.resetCode,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Reset'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.indigo.shade300, width: 2),
                foregroundColor: Colors.indigo.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Clear Button - Clears the output console
          IconButton(
            onPressed: controller.clearOutput,
            icon: const Icon(Icons.clear_all_rounded),
            tooltip: 'Clear Output',
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
