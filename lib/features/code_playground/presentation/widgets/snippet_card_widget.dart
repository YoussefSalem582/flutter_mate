import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../data/models/code_snippet.dart';
import '../../controller/code_playground_controller.dart';

/// Individual code snippet card widget for the snippets list.
///
/// This widget displays a single code snippet with:
/// - Category badge with gradient background
/// - Snippet title with code icon
/// - Short description (max 2 lines)
/// - Tags for additional metadata
/// - Animated entrance effect (fade in + slide)
///
/// When tapped, the snippet is loaded into the editor and
/// a confirmation snackbar is shown to the user.
class SnippetCardWidget extends StatelessWidget {
  /// The code snippet to display
  final CodeSnippet snippet;

  /// Index for staggered animation delay
  final int index;

  const SnippetCardWidget({
    super.key,
    required this.snippet,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CodePlaygroundController>();

    return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.indigo.shade100, width: 1),
          ),
          child: InkWell(
            // Handle tap to load snippet
            onTap: () {
              // Load the snippet into the editor
              controller.loadSnippet(snippet.id);

              // Close the bottom sheet
              Navigator.pop(context);

              // Show success feedback
              Get.snackbar(
                '✅ Snippet Loaded',
                snippet.title,
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.indigo,
                colorText: Colors.white,
                icon: const Icon(Icons.check_circle, color: Colors.white),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge and arrow icon
                  Row(
                    children: [
                      // Category badge with gradient
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade400,
                              Colors.indigo.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          snippet.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Arrow icon indicating clickability
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.indigo.shade300,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title with code icon
                  Row(
                    children: [
                      Icon(
                        Icons.code_rounded,
                        size: 20,
                        color: Colors.indigo.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          snippet.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description with ellipsis for long text
                  Text(
                    snippet.description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Tags section (only shown if tags exist)
                  if (snippet.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: snippet.tags
                          .map<Widget>(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.indigo.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.indigo.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        )
        // Staggered animation: each card fades in and slides with delay
        .animate()
        .fadeIn(delay: (index * 50).ms)
        .slideX(begin: 0.1);
  }
}
