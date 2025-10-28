/// Barrel file for roadmap feature widgets
///
/// Organized by page usage:
/// - lesson_detail_page/ - Widgets only used in lesson detail page (11 widgets)
/// - lessons_page/ - Widgets used in lessons page (4 widgets)
/// - roadmap_page/ - Widgets used in roadmap page (5 widgets)
/// - shared/ - Widgets used across multiple pages (2 widgets)
///
/// Many widgets use shared components from lib/shared/widgets:
/// - InfoChip (duration, metadata)
/// - DifficultyChip (easy/medium/hard)
/// - CustomProgressBar (progress tracking)
library;

// Export all lesson detail page widgets
export 'lesson_detail_page/widgets.dart';

// Export all lessons page widgets
export 'lessons_page/widgets.dart';

// Export all roadmap page widgets
export 'roadmap_page/widgets.dart';

// Export all shared widgets (used across multiple pages)
export 'shared/widgets.dart';
