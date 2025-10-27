import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../controller/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

/// Sign up page for new user registration
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthController authController = Get.find<AuthController>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Create Account',
                        style: AppTextStyles.h1.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Start your learning journey today!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Username Field
                AuthTextField(
                  controller: usernameController,
                  label: 'Username',
                  hint: 'Choose a username',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                const SizedBox(height: 16),

                // Email Field
                AuthTextField(
                  controller: emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
                const SizedBox(height: 16),

                // Password Field
                AuthTextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'Create a password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
                const SizedBox(height: 16),

                // Confirm Password Field
                AuthTextField(
                  controller: confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2),
                const SizedBox(height: 24),

                // Sign Up Button
                Obx(() => ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                authController.signUp(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  username: usernameController.text,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightPrimary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: authController.isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 24),

                // Google Sign In
                SocialLoginButton(
                  onPressed: () => authController.signInWithGoogle(),
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  backgroundColor: isDark ? Colors.white : Colors.white,
                  textColor: Colors.black87,
                ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.2),
                const SizedBox(height: 32),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.lightPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1000.ms),

                const SizedBox(height: 16),

                // Terms & Privacy
                Text(
                  'By signing up, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ).animate().fadeIn(delay: 1100.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
