import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import 'package:flutter_mate/shared/widgets/app_bottom_nav_bar.dart';
import '../../controller/code_playground_controller.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/control_buttons_widget.dart';
import '../widgets/output_console_widget.dart';
import '../widgets/snippets_bottom_sheet.dart';
import '../widgets/playground_help_dialog.dart';

/// Main page for the Code Playground feature.
///
/// This page provides an interactive environment where users can:
/// - Browse and load pre-made Dart code snippets
/// - Edit code in a VS Code-style editor with line numbers
/// - Execute code and see syntax-highlighted output
/// - Reset code to original state or clear output
/// - Access help documentation
///
/// **Architecture**: Widget composition pattern
/// The page acts as a coordinator, delegating rendering to specialized widgets:
/// - CodeEditorWidget: VS Code-style editor with line numbers (60% screen)
/// - ControlButtonsWidget: Run, Reset, Clear action buttons
/// - OutputConsoleWidget: Terminal-like output display (40% screen)
/// - SnippetsBottomSheet: Snippet browser (modal)
/// - PlaygroundHelpDialog: Help information (modal)
///
/// **State Management**: GetX with CodePlaygroundController
/// - Extends GetView<CodePlaygroundController> for automatic controller access
/// - Controller manages code, output, execution state, and snippets
/// - Reactive UI updates using Obx in child widgets
///
/// **Layout**: Vertical split with Expanded widgets
/// - Code editor takes 3/5 of available space
/// - Control buttons fixed height
/// - Output console takes 2/5 of available space
class CodePlaygroundPage extends GetView<CodePlaygroundController> {
  const CodePlaygroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    // Safety check: Ensure controller is registered before rendering
    // If not registered, show loading state instead of crashing
    if (!Get.isRegistered<CodePlaygroundController>()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Code Playground'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        // Show loading indicator while waiting for controller initialization
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar:
            isDesktop ? null : const AppBottomNavBar(currentIndex: 2),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Playground'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Snippets library button - Opens bottom sheet with pre-made code examples
          IconButton(
            icon: const Icon(Icons.library_books_rounded),
            onPressed: () => SnippetsBottomSheet.show(context),
            tooltip: 'Code Snippets',
          ),
          // Help button - Shows usage guide dialog
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => PlaygroundHelpDialog.show(context),
            tooltip: 'Help',
          ),
        ],
      ),
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
      bottomNavigationBar:
          isDesktop ? null : const AppBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildMobileLayout() {
    return const Column(
      children: [
        // Code Editor Section (60% of screen)
        // - Line numbers sidebar
        // - Multi-line code input
        // - Snippet info display
        Expanded(flex: 3, child: CodeEditorWidget()),

        // Control Buttons Row (fixed height)
        // - Run Code: Execute current code
        // - Reset: Restore original snippet
        // - Clear: Clear output console
        ControlButtonsWidget(),

        // Output Console Section (40% of screen)
        // - VS Code-style syntax highlighting
        // - Status badge (Success/Error)
        // - Scrollable output display
        Expanded(flex: 2, child: OutputConsoleWidget()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Code Editor Section (50% of screen width)
        Expanded(
          child: Column(
            children: [
              const Expanded(child: CodeEditorWidget()),
              const ControlButtonsWidget(),
            ],
          ),
        ),
        // Output Console Section (50% of screen width)
        const Expanded(child: OutputConsoleWidget()),
      ],
    );
  }
}
