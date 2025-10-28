import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/routes/app_routes.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';
import 'settings_tile.dart';

/// Account settings card with various configurable options
///
/// Features:
/// - Language selection (currently English only)
/// - Privacy & security settings
/// - Data & storage management
/// - Account management (for authenticated users)
/// - Create account prompt (for guest users)
/// - Logout functionality (for authenticated users)
///
/// Interactive Dialogs:
/// - Language selection dialog with emoji flags
/// - Privacy settings with security options
/// - Storage management with cache clearing
/// - Account settings for email/password changes
///
/// Conditional UI:
/// - Shows "Create Account" for guest users
/// - Shows "Account" and "Logout" for authenticated users
class SettingsCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onLogout;

  const SettingsCard({
    super.key,
    required this.isDark,
    required this.onLogout,
  });

  /// Shows a language selection dialog
  ///
  /// Current features:
  /// - English (active with checkmark)
  /// - Spanish (coming soon, disabled)
  /// - French (coming soon, disabled)
  ///
  /// Future enhancement: Add more languages with localization support
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇺🇸'),
              title: const Text('English'),
              trailing: const Icon(Icons.check, color: AppColors.success),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Language',
                  'English is already selected',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Text('🇪🇸'),
              title: const Text('Spanish'),
              subtitle: const Text('Coming soon'),
              enabled: false,
              onTap: () {},
            ),
            ListTile(
              leading: const Text('🇫🇷'),
              title: const Text('French'),
              subtitle: const Text('Coming soon'),
              enabled: false,
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Shows a privacy & security dialog with various security options
  ///
  /// Options displayed:
  /// - Two-Factor Authentication (coming soon)
  /// - Privacy Mode (hide learning progress)
  /// - Delete Account (permanently remove data)
  ///
  /// Future enhancement: Implement actual privacy controls
  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your data is secure with us.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPrivacyOption(
              icon: Icons.lock,
              title: 'Two-Factor Authentication',
              subtitle: 'Coming soon',
            ),
            const Divider(),
            _buildPrivacyOption(
              icon: Icons.visibility_off,
              title: 'Privacy Mode',
              subtitle: 'Hide your learning progress',
            ),
            const Divider(),
            _buildPrivacyOption(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently remove your data',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Shows a storage management dialog
  ///
  /// Options displayed:
  /// - Clear Cache (free up space)
  /// - Offline Content (download lessons)
  /// - Storage Used (shows approximate usage)
  ///
  /// Future enhancement: Implement actual cache clearing and offline downloads
  void _showStorageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data & Storage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage your app data and storage',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStorageOption(
              icon: Icons.cleaning_services,
              title: 'Clear Cache',
              subtitle: 'Free up space',
              color: AppColors.warning,
            ),
            const Divider(),
            _buildStorageOption(
              icon: Icons.download,
              title: 'Offline Content',
              subtitle: 'Download lessons for offline use',
              color: AppColors.info,
            ),
            const Divider(),
            _buildStorageOption(
              icon: Icons.storage,
              title: 'Storage Used',
              subtitle: 'Approx. 25 MB',
              color: Colors.grey,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Shows an account management dialog
  ///
  /// Options displayed:
  /// - Change Email (update email address)
  /// - Change Password (update password)
  /// - Connected Accounts (view linked accounts)
  ///
  /// Future enhancement: Implement actual account update functionality
  void _showAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage your account settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAccountOption(
              icon: Icons.email,
              title: 'Change Email',
              subtitle: 'Update your email address',
            ),
            const Divider(),
            _buildAccountOption(
              icon: Icons.lock_reset,
              title: 'Change Password',
              subtitle: 'Update your password',
            ),
            const Divider(),
            _buildAccountOption(
              icon: Icons.link,
              title: 'Connected Accounts',
              subtitle: 'Google, Apple',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Builds a privacy option list item
  ///
  /// Used in privacy dialog to display security settings
  Widget _buildPrivacyOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.info),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      dense: true,
    );
  }

  /// Builds a storage option list item with colored icon
  ///
  /// Used in storage dialog to display data management options
  Widget _buildStorageOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      dense: true,
    );
  }

  /// Builds an account option list item
  ///
  /// Used in account dialog to display account management options
  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Conditional: Show "Create Account" button for guest users
          Obx(() {
            if (authController.isGuest) {
              return Column(
                children: [
                  SettingsTile(
                    title: 'Create Account',
                    subtitle: 'Save your progress permanently',
                    icon: Icons.person_add,
                    color: AppColors.success,
                    onTap: () {
                      Get.toNamed(AppRoutes.signup);
                    },
                  ),
                  const Divider(height: 1),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          // Language selection
          SettingsTile(
            title: 'Language',
            subtitle: 'English',
            icon: Icons.language,
            color: AppColors.info,
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(height: 1),

          // Privacy & Security settings
          SettingsTile(
            title: 'Privacy & Security',
            subtitle: 'Manage your data',
            icon: Icons.security,
            color: AppColors.success,
            onTap: () => _showPrivacyDialog(context),
          ),
          const Divider(height: 1),

          // Data & Storage management
          SettingsTile(
            title: 'Data & Storage',
            subtitle: 'Clear cache and data',
            icon: Icons.storage,
            color: Colors.orange,
            onTap: () => _showStorageDialog(context),
          ),
          const Divider(height: 1),

          // Conditional: Show account settings for authenticated users only
          Obx(() {
            // Show account settings only for logged-in users
            if (!authController.isGuest) {
              return Column(
                children: [
                  // Account management option
                  SettingsTile(
                    title: 'Account',
                    subtitle: 'Manage your account',
                    icon: Icons.account_circle,
                    color: Colors.purple,
                    onTap: () => _showAccountDialog(context),
                  ),
                  const Divider(height: 1),

                  // Logout option (calls parent callback)
                  SettingsTile(
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    icon: Icons.logout,
                    color: Colors.red,
                    onTap: onLogout,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
