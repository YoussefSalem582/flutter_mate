import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../controller/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

/// Login page for user authentication
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController authController = Get.put(AuthController());
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // App Logo & Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.lightPrimary,
                              AppColors.lightPrimary.withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ).animate().scale(delay: 100.ms),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome Back!',
                        style: AppTextStyles.h1.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue your learning journey',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

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
                  hint: 'Enter your password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed('/forgot-password'),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.lightPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 24),

                // Sign In Button
                Obx(() => ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                authController.signIn(
                                  email: emailController.text,
                                  password: passwordController.text,
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
                              'Sign In',
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
                const SizedBox(height: 12),

                // Guest Mode
                SocialLoginButton(
                  onPressed: () => authController.signInAsGuest(),
                  icon: Icons.person_outline,
                  label: 'Continue as Guest',
                  backgroundColor: Colors.grey[200]!,
                  textColor: Colors.black87,
                ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.2),
                const SizedBox(height: 32),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/signup'),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.lightPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1100.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
