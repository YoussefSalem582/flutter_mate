import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import 'package:flutter_mate/core/utils/auth_utils.dart';
import 'package:flutter_mate/shared/widgets/app_bottom_nav_bar.dart';
import 'package:flutter_mate/shared/widgets/app_bar_widget.dart';
import 'package:flutter_mate/shared/widgets/desktop_sidebar.dart';
import 'package:flutter_mate/shared/widgets/quick_access_cards.dart';
import 'package:flutter_mate/features/progress_tracker/controller/progress_tracker_controller.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';
import '../widgets/widgets.dart';

/// Profile page displaying user information, statistics, and settings
///
/// Features:
/// - User profile header with avatar, name, level, and XP
/// - Achievement badges showcase
/// - Learning statistics (lessons, projects, streak, XP)
/// - Learning preferences (theme, notifications, sounds)
/// - Account settings (language, privacy, storage)
/// - About & support section
/// - Profile editing capability
/// - Logout functionality
///
/// Layout:
/// - Mobile: Scrollable list view with all sections
/// - Desktop: Fixed sidebar (profile + badges) + scrollable content area
///
/// Responsive Design:
/// - Uses [ResponsiveUtils] to switch between mobile/desktop layouts
/// - Desktop breakpoint: 900px
///
/// State Management:
/// - Uses GetX for dependency injection and reactive updates
/// - Observes [ProgressTrackerController] for stats
/// - Observes [AuthController] for user authentication state
class ProfilePage extends GetView<ProgressTrackerController> {
  const ProfilePage({super.key});

  /// Shows a confirmation dialog before logging out
  ///
  /// Displays an alert dialog with:
  /// - Logout confirmation message
  /// - Cancel button (dismisses dialog)
  /// - Logout button (signs out and navigates to login)
  ///
  /// On logout:
  /// - Calls [authController.signOut()]
  /// - Navigates to login page (replaces all routes)
  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authController.signOut();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the profile edit dialog
  ///
  /// Flow:
  /// 1. Checks if user is authenticated using [AuthUtils.requireAuth]
  /// 2. If guest user, shows authentication prompt
  /// 3. If authenticated, opens [ProfileEditDialog]
  ///
  /// The dialog allows editing:
  /// - Display name
  /// - Profile photo URL
  void _showProfileEditDialog() {
    if (!AuthUtils.requireAuth(
      title: 'Profile Editing',
      message:
          'Create an account to edit your profile and customize your learning experience.',
    )) {
      return;
    }
    Get.dialog(const ProfileEditDialog());
  }

  /// Navigates to assessment history
  ///
  /// Flow:
  /// 1. Checks if user is authenticated using [AuthUtils.requireAuth]
  /// 2. If guest user, shows authentication prompt
  /// 3. If authenticated, navigates to assessment history page
  void _navigateToAssessmentHistory() {
    if (!AuthUtils.requireAuth(
      title: 'Assessment History',
      message:
          'Sign in to view your assessment history and track your skill progress over time.',
    )) {
      return;
    }
    Get.toNamed(AppRoutes.assessmentHistory);
  }

  /// Builds the assessment history button widget
  Widget _buildAssessmentHistoryButton(
    BuildContext context,
    bool isDark,
    AuthController authController,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: _navigateToAssessmentHistory,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.2),
                      Colors.deepPurple.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_edu,
                  size: 32,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assessment History',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View your past assessments and track progress',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get required dependencies
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      // Custom app bar with title, icon, and actions
      appBar: AppBarWidget(
        title: 'Profile & Settings',
        icon: Icons.person,
        actions: [
          // Edit profile button - opens profile edit dialog
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showProfileEditDialog,
            tooltip: 'Edit Profile',
          ),
          // Logout button - only shown for authenticated users
          // Uses Obx to reactively show/hide based on auth state
          Obx(() => authController.isAuthenticated.value
              ? IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _showLogoutDialog(context, authController),
                  tooltip: 'Logout',
                )
              : const SizedBox.shrink()),
        ],
      ),
      // Responsive body - switches between mobile/desktop layouts
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(context, isDark, authController),
        desktop: _buildDesktopLayout(context, isDark, authController),
      ),
      // Bottom navigation bar - only shown on mobile
      bottomNavigationBar:
          isDesktop ? null : const AppBottomNavBar(currentIndex: 3),
    );
  }

  /// Builds the mobile layout
  ///
  /// Layout Structure:
  /// - Scrollable ListView with vertical stacking
  /// - Profile header (avatar, name, stats)
  /// - Achievement badges (horizontal scroll)
  /// - Statistics grid (2x2 cards)
  /// - Learning preferences card
  /// - Account settings card
  /// - About & support card
  ///
  /// Animations:
  /// - Each section fades in with staggered delays
  /// - Alternating slide directions (left/right) for visual interest
  Widget _buildMobileLayout(
      BuildContext context, bool isDark, AuthController authController) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile header with gradient background
        // Shows avatar, name, email, join date, level, achievements, and XP
        ProfileHeaderWidget(isDark: isDark)
            .animate()
            .fadeIn()
            .scale(duration: 600.ms),
        const SizedBox(height: 24),

        // Achievement badges section
        // Displays up to 6 unlocked badges in horizontal scroll
        // Links to full achievements page
        AchievementBadgesSection(isDark: isDark)
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.2),
        const SizedBox(height: 24),

        // Statistics section title
        Text(
          'Statistics',
          style: AppTextStyles.h3.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 16),

        // Statistics grid (2x2)
        // Shows: Lessons completed, Projects built, Learning streak, Total XP
        // Each card uses shared StatCard widget
        ProfileStatsGrid(isDark: isDark)
            .animate()
            .fadeIn(delay: 400.ms)
            .slideX(begin: -0.2),
        const SizedBox(height: 24),

        // New Features section
        Text(
          'Advanced Features',
          style: AppTextStyles.h3.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 450.ms),
        const SizedBox(height: 16),

        // Analytics & Assessment Cards
        QuickAccessCards(
          showTitle: false,
          cardHeight: 140,
          isDark: isDark,
        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
        const SizedBox(height: 16),

        // Assessment History Button
        _buildAssessmentHistoryButton(context, isDark, authController)
            .animate()
            .fadeIn(delay: 550.ms)
            .slideX(begin: 0.2),
        const SizedBox(height: 24),

        // Learning preferences section
        const SectionHeader(title: 'Learning Preferences', icon: Icons.tune)
            .animate()
            .fadeIn(delay: 500.ms),
        const SizedBox(height: 16),

        // Preferences card
        // Contains: Dark mode toggle, Daily reminders, Sound effects
        PreferencesCard(isDark: isDark)
            .animate()
            .fadeIn(delay: 600.ms)
            .slideX(begin: 0.2),
        const SizedBox(height: 24),

        // Account settings section
        const SectionHeader(title: 'Account Settings', icon: Icons.settings)
            .animate()
            .fadeIn(delay: 700.ms),
        const SizedBox(height: 16),

        // Settings card
        // For guests: Create account option
        // For users: Language, Privacy, Storage, Account, Logout
        SettingsCard(
                isDark: isDark,
                onLogout: () => _showLogoutDialog(context, authController))
            .animate()
            .fadeIn(delay: 800.ms)
            .slideX(begin: -0.2),
        const SizedBox(height: 24),

        // About & support section
        const SectionHeader(title: 'About & Support', icon: Icons.help_outline)
            .animate()
            .fadeIn(delay: 900.ms),
        const SizedBox(height: 16),

        // About card
        // Contains: About app, Help & support, Rate us, Share app
        AboutCard(isDark: isDark)
            .animate()
            .fadeIn(delay: 1000.ms)
            .slideX(begin: 0.2),

        // Bottom padding for comfortable scrolling
        const SizedBox(height: 100),
      ],
    );
  }

  /// Builds the desktop layout
  ///
  /// Layout Structure:
  /// - Two-column layout using Row
  /// - Left: Fixed sidebar (350px width)
  ///   - Profile header
  ///   - Achievement badges
  ///   - Navigation menu
  /// - Right: Scrollable content area
  ///   - Statistics grid (wider 2x2)
  ///   - All settings sections
  ///   - Max width constraint (1000px) for readability
  ///
  /// Advantages:
  /// - Profile always visible while scrolling
  /// - More screen real estate for content
  /// - Better use of wide screens
  ///
  /// Animations:
  /// - Same staggered fade-in animations as mobile
  /// - Consistent visual experience across devices
  Widget _buildDesktopLayout(
      BuildContext context, bool isDark, AuthController authController) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left sidebar - Fixed position
        // Shows profile header and achievement badges
        // Includes navigation menu at bottom
        DesktopSidebar(
          isDark: isDark,
          topContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header in sidebar
              ProfileHeaderWidget(isDark: isDark)
                  .animate()
                  .fadeIn()
                  .scale(duration: 600.ms),
              const SizedBox(height: 24),

              // Achievement badges in sidebar
              AchievementBadgesSection(isDark: isDark)
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideY(begin: 0.2),
            ],
          ),
        ),

        // Right content area - Scrollable
        // Contains all settings and information sections
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Center(
              // Constrain width for readability on ultra-wide screens
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics section
                    Text('Statistics',
                            style: AppTextStyles.h3.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontWeight: FontWeight.bold))
                        .animate()
                        .fadeIn(delay: 300.ms),
                    const SizedBox(height: 16),

                    // Stats grid - larger on desktop
                    ProfileStatsGrid(isDark: isDark)
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: -0.2),
                    const SizedBox(height: 24),

                    // Advanced Features section
                    Text('Advanced Features',
                            style: AppTextStyles.h3.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontWeight: FontWeight.bold))
                        .animate()
                        .fadeIn(delay: 450.ms),
                    const SizedBox(height: 16),

                    // Assessment History Button
                    _buildAssessmentHistoryButton(
                            context, isDark, authController)
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideX(begin: -0.2),
                    const SizedBox(height: 32),

                    // Learning preferences section
                    const SectionHeader(
                            title: 'Learning Preferences', icon: Icons.tune)
                        .animate()
                        .fadeIn(delay: 500.ms),
                    const SizedBox(height: 16),
                    PreferencesCard(isDark: isDark)
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideX(begin: 0.2),
                    const SizedBox(height: 32),

                    // Account settings section
                    const SectionHeader(
                            title: 'Account Settings', icon: Icons.settings)
                        .animate()
                        .fadeIn(delay: 700.ms),
                    const SizedBox(height: 16),
                    SettingsCard(
                            isDark: isDark,
                            onLogout: () =>
                                _showLogoutDialog(context, authController))
                        .animate()
                        .fadeIn(delay: 800.ms)
                        .slideX(begin: -0.2),
                    const SizedBox(height: 32),

                    // About & support section
                    const SectionHeader(
                            title: 'About & Support', icon: Icons.help_outline)
                        .animate()
                        .fadeIn(delay: 900.ms),
                    const SizedBox(height: 16),
                    AboutCard(isDark: isDark)
                        .animate()
                        .fadeIn(delay: 1000.ms)
                        .slideX(begin: 0.2),

                    // Bottom padding for comfortable scrolling
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
