import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/code_playground_controller.dart';
import 'snippet_card_widget.dart';

/// Bottom sheet widget for browsing and selecting code snippets.
///
/// This widget provides an interactive interface for:
/// - Browsing pre-made code examples
/// - Filtering snippets by category (Beginner, Control Flow, Collections, etc.)
/// - Viewing snippet details before loading
/// - Quick snippet selection with visual feedback
///
/// The bottom sheet is draggable and supports three size states:
/// - Initial: 70% of screen height
/// - Minimum: 50% of screen height
/// - Maximum: 90% of screen height
class SnippetsBottomSheet extends StatelessWidget {
  const SnippetsBottomSheet({super.key});

  /// Static method to show the bottom sheet from anywhere.
  ///
  /// Usage:
  /// ```dart
  /// SnippetsBottomSheet.show(context);
  /// ```
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow custom sizing
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const SnippetsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CodePlaygroundController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.7, // Start at 70% height
      minChildSize: 0.5, // Can shrink to 50%
      maxChildSize: 0.9, // Can expand to 90%
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Drag handle for visual feedback
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with gradient and icon
          _buildHeader(),

          // Category filter chips
          _buildCategoryChips(controller),

          const Divider(height: 1),

          // Available snippets count indicator
          _buildSnippetsCount(controller),

          // Scrollable list of snippet cards
          Expanded(
            child: Obx(() {
              // Show empty state if no snippets match filter
              if (controller.filteredSnippets.isEmpty) {
                return _buildEmptyState();
              }

              // Display filtered snippets in a scrollable list
              return ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: controller.filteredSnippets.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final snippet = controller.filteredSnippets[index];
                  return SnippetCardWidget(snippet: snippet, index: index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Builds the header section with gradient background.
  ///
  /// Features:
  /// - Library icon with semi-transparent container
  /// - "Code Snippets" title
  /// - Helpful subtitle text
  /// - Indigo gradient for brand consistency
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.indigo.shade500],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Icon container with rounded corners
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.library_books_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Title and subtitle
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Code Snippets',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Choose a snippet to get started',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the category filter chips.
  ///
  /// Categories include:
  /// - All: Shows all snippets
  /// - 🎓 Beginner: Basic concepts
  /// - 🔄 Control Flow: If/else, loops
  /// - 📦 Collections: Lists, Sets, Maps
  /// - ⚡ Functions: Functions and methods
  /// - 🏗️ OOP: Object-oriented programming
  ///
  /// The selected chip is highlighted with indigo background.
  Widget _buildCategoryChips(CodePlaygroundController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Obx(
        () => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.categories.map((category) {
            final isSelected = controller.selectedCategory == category;
            return FilterChip(
              label: Text(controller.getCategoryLabel(category)),
              selected: isSelected,
              onSelected: (_) => controller.setCategory(category),
              selectedColor: Colors.indigo,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Builds the snippet count indicator.
  ///
  /// Shows how many snippets are available based on current filter.
  /// Updates reactively as user changes category selection.
  Widget _buildSnippetsCount(CodePlaygroundController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Obx(
        () => Row(
          children: [
            Icon(Icons.code_rounded, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              '${controller.filteredSnippets.length} snippets available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state when no snippets match the filter.
  ///
  /// Shows:
  /// - Search-off icon
  /// - "No snippets found" message
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No snippets found',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
