import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
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
  /// - Arabic (coming soon, disabled)
  ///
  /// Future enhancement: Add Arabic localization support
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
              leading: const Text('🇪🇬'),
              title: const Text('Arabic - العربية'),
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
  /// Functional features:
  /// - Delete Account with confirmation dialog
  void _showPrivacyDialog(BuildContext context) {
    final authController = Get.find<AuthController>();

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
              onTap: null,
            ),
            const Divider(),
            _buildPrivacyOption(
              icon: Icons.visibility_off,
              title: 'Privacy Mode',
              subtitle: 'Hide your learning progress',
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Coming Soon',
                  'Privacy mode will be available in a future update',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            const Divider(),
            _buildPrivacyOption(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently remove your data',
              onTap: () {
                Navigator.pop(context);
                _showDeleteAccountConfirmation(context, authController);
              },
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

  /// Shows confirmation dialog for account deletion
  void _showDeleteAccountConfirmation(
      BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Account?'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All your progress, achievements, and data will be permanently deleted.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authController.deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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
  /// Functional features:
  /// - Clear cache functionality using Hive
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
              onTap: () async {
                Navigator.pop(context);
                await _clearCache();
              },
            ),
            const Divider(),
            _buildStorageOption(
              icon: Icons.download,
              title: 'Offline Content',
              subtitle: 'Download lessons for offline use',
              color: AppColors.info,
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Coming Soon',
                  'Offline content downloads will be available in a future update',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            const Divider(),
            _buildStorageOption(
              icon: Icons.storage,
              title: 'Storage Used',
              subtitle: 'Approx. 25 MB',
              color: Colors.grey,
              onTap: null,
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

  /// Clear app cache from all Hive boxes
  Future<void> _clearCache() async {
    try {
      // Get all open boxes
      final boxes = [
        'progress',
        'roadmap',
        'quiz',
        'study_timer',
      ];

      int itemsCleared = 0;

      for (var boxName in boxes) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            final count = box.length;

            // Clear specific cache keys but preserve user progress
            if (boxName == 'progress') {
              // Only clear temporary cache, keep completed lessons
              final keysToRemove = box.keys
                  .where((key) => key.toString().contains('cache_'))
                  .toList();
              for (var key in keysToRemove) {
                await box.delete(key);
              }
              itemsCleared += keysToRemove.length;
            } else {
              // For other boxes, it's safe to clear everything
              await box.clear();
              itemsCleared += count;
            }
          }
        } catch (e) {
          print('Error clearing box $boxName: $e');
        }
      }

      Get.snackbar(
        'Success',
        'Cache cleared! Freed up space ($itemsCleared items removed)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear cache: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Shows an account management dialog
  ///
  /// Options displayed:
  /// - Change Email (update email address)
  /// - Change Password (update password)
  /// - Connected Accounts (view linked accounts)
  ///
  /// Functional features:
  /// - Actual email and password update functionality
  void _showAccountDialog(BuildContext context) {
    final authController = Get.find<AuthController>();

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
              onTap: () {
                Navigator.pop(context);
                _showChangeEmailDialog(context, authController);
              },
            ),
            const Divider(),
            _buildAccountOption(
              icon: Icons.lock_reset,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog(context, authController);
              },
            ),
            const Divider(),
            _buildAccountOption(
              icon: Icons.link,
              title: 'Connected Accounts',
              subtitle:
                  authController.currentUser.value?.provider.name ?? 'None',
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Account Provider',
                  'Signed in with ${authController.currentUser.value?.provider.name ?? "unknown"}',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            const Divider(),
            _buildAccountOption(
              icon: Icons.phone,
              title: 'Phone Number',
              subtitle: authController.currentUser.value?.phoneNumber ??
                  'Add phone number',
              onTap: () {
                Navigator.pop(context);
                _showAddPhoneNumberDialog(context, authController);
              },
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

  /// Shows dialog to add phone number
  void _showAddPhoneNumberDialog(
      BuildContext context, AuthController authController) {
    final phoneController = TextEditingController();
    final codeController = TextEditingController();
    final RxBool codeSent = false.obs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Phone Number'),
        content: Obx(() => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add a phone number to enable phone login',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !codeSent.value,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+1234567890',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  if (!codeSent.value) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: authController.isVerifyingPhone.value
                            ? null
                            : () async {
                                final phone = phoneController.text.trim();
                                if (phone.isEmpty) {
                                  Get.snackbar(
                                      'Error', 'Please enter phone number');
                                  return;
                                }
                                await authController.verifyPhoneNumber(phone);
                                if (authController
                                    .verificationId.value.isNotEmpty) {
                                  codeSent.value = true;
                                }
                              },
                        icon: authController.isVerifyingPhone.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          authController.isVerifyingPhone.value
                              ? 'Sending...'
                              : 'Send Code',
                        ),
                      ),
                    ),
                  ],
                  if (codeSent.value) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Verification Code',
                        hintText: '123456',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pin),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              codeSent.value = false;
                              codeController.clear();
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Change Number'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Obx(() => TextButton(
                onPressed: codeSent.value
                    ? () async {
                        final phone = phoneController.text.trim();
                        final code = codeController.text.trim();

                        if (code.isEmpty) {
                          Get.snackbar(
                              'Error', 'Please enter verification code');
                          return;
                        }

                        Navigator.pop(context);
                        await authController.addPhoneNumber(phone, code);
                      }
                    : null,
                child: const Text('Verify'),
              )),
        ],
      ),
    );
  }

  /// Shows dialog to change email with two-step verification
  /// Step 1: Verify current email
  /// Step 2: Enter and verify new email
  void _showChangeEmailDialog(
      BuildContext context, AuthController authController) {
    final RxBool currentEmailVerified = false.obs;
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: Obx(() => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!currentEmailVerified.value) ...[
                    // Step 1: Verify current email
                    const Text(
                      'Step 1: Verify Your Current Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: AppColors.info.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: AppColors.info,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'For security, please verify your current email address first.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current: ${authController.currentUser.value?.email ?? "N/A"}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: authController.isLoading.value
                            ? null
                            : () async {
                                final verified = await authController
                                    .sendEmailChangeVerification();
                                if (verified) {
                                  // Show instructions
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Row(
                                        children: [
                                          Icon(
                                            Icons.mark_email_read,
                                            color: AppColors.info,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Check Your Email'),
                                        ],
                                      ),
                                      content: const Text(
                                        'We\'ve sent a verification link to your current email. '
                                        'Please check your inbox and click the link to verify.\n\n'
                                        'After verifying, come back here and click "I\'ve Verified".',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                        icon: authController.isLoading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          authController.isLoading.value
                              ? 'Sending...'
                              : 'Send Verification Email',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          // Check if email is verified
                          final isVerified =
                              await authController.checkCurrentEmailVerified();

                          if (isVerified) {
                            currentEmailVerified.value = true;
                            Get.snackbar(
                              'Verified',
                              'Email verified! You can now enter your new email.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.success,
                              colorText: Colors.white,
                            );
                          } else {
                            Get.snackbar(
                              'Not Verified',
                              'Please check your email and click the verification link first.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.warning,
                              colorText: Colors.white,
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('I\'ve Verified My Email'),
                      ),
                    ),
                  ] else ...[
                    // Step 2: Enter new email
                    const Text(
                      'Step 2: Enter New Email Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Current email verified! Enter your new email below.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'New Email Address',
                        hintText: 'your.new.email@example.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A verification link will be sent to this new email address.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Obx(() => currentEmailVerified.value
              ? TextButton(
                  onPressed: () async {
                    final newEmail = emailController.text.trim();
                    if (newEmail.isNotEmpty) {
                      Navigator.pop(context);
                      await authController.updateEmail(newEmail);
                    }
                  },
                  child: const Text('Update Email'),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  /// Shows dialog to change password with old password verification
  void _showChangePasswordDialog(
      BuildContext context, AuthController authController) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your current password and new password (minimum 6 characters)',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_open),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final oldPassword = oldPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;

              if (oldPassword.isEmpty) {
                Get.snackbar('Error', 'Please enter your current password');
                return;
              }

              if (newPassword.isEmpty) {
                Get.snackbar('Error', 'Please enter a new password');
                return;
              }

              if (newPassword != confirmPassword) {
                Get.snackbar('Error', 'Passwords do not match');
                return;
              }

              Navigator.pop(context);
              await authController.updatePassword(oldPassword, newPassword);
            },
            child: const Text('Update'),
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
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.info),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      dense: true,
      enabled: onTap != null,
      onTap: onTap,
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
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      dense: true,
      enabled: onTap != null,
      onTap: onTap,
    );
  }

  /// Builds an account option list item
  ///
  /// Used in account dialog to display account management options
  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      dense: true,
      enabled: onTap != null,
      onTap: onTap,
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
      ),
    );
  }
}
