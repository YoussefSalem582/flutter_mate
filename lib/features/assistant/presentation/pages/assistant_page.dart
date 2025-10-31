import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mate/core/constants/app_colors.dart';
import 'package:flutter_mate/core/constants/app_text_styles.dart';
import 'package:flutter_mate/core/utils/responsive_utils.dart';
import 'package:flutter_mate/shared/widgets/app_bottom_nav_bar.dart';
import 'package:flutter_mate/shared/widgets/app_bar_widget.dart';
import 'package:flutter_mate/features/auth/controller/auth_controller.dart';
import '../../controller/assistant_controller.dart';

/// AI Assistant page for guidance and tips
class AssistantPage extends GetView<AssistantController> {
  const AssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    final ScrollController scrollController = ScrollController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: AppBarWidget(
        title: 'AI Assistant',
        icon: Icons.smart_toy,
        iconColor: AppColors.info,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.clearChat();
              Get.snackbar(
                'Chat Cleared',
                'Starting fresh conversation',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(
          context,
          messageController,
          scrollController,
          isDark,
        ),
        desktop: _buildDesktopLayout(
          context,
          messageController,
          scrollController,
          isDark,
        ),
      ),
      bottomNavigationBar:
          isDesktop ? null : const AppBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    TextEditingController messageController,
    ScrollController scrollController,
    bool isDark,
  ) {
    return Column(
      children: [
        // Tips Banner
        Obx(() {
          if (controller.messages.isEmpty) {
            return const SizedBox.shrink();
          }
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.info.withOpacity(0.1),
                  AppColors.success.withOpacity(0.1),
                ],
              ),
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pro tip: Ask specific questions for better answers!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.3);
        }),

        // Messages List
        Expanded(
          child: Obx(() {
            if (controller.messages.isEmpty) {
              return _buildEmptyState(context);
            }

            // Auto-scroll to bottom when new message added
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });

            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                return _buildMessageBubble(context, message, isDark)
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideX(
                      begin: message.isUser ? 0.2 : -0.2,
                      duration: 300.ms,
                    );
              },
            );
          }),
        ),

        // Typing Indicator
        Obx(() {
          if (!controller.isTyping.value) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTypingDot()
                          .animate(
                            onPlay: (controller) => controller.repeat(),
                          )
                          .fade(duration: 600.ms),
                      const SizedBox(width: 4),
                      _buildTypingDot()
                          .animate(
                            onPlay: (controller) => controller.repeat(),
                          )
                          .fade(duration: 600.ms, delay: 200.ms),
                      const SizedBox(width: 4),
                      _buildTypingDot()
                          .animate(
                            onPlay: (controller) => controller.repeat(),
                          )
                          .fade(duration: 600.ms, delay: 400.ms),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        // Quick Suggestions
        Obx(() {
          if (controller.messages.length > 1) return const SizedBox.shrink();
          return Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.lightbulb_outline, size: 18),
                    label: Text(
                      controller.suggestions[index],
                      style: AppTextStyles.bodySmall,
                    ),
                    onPressed: () {
                      messageController.text = controller.suggestions[index];
                      controller.sendMessage(messageController.text);
                      messageController.clear();
                    },
                  ).animate().fadeIn(delay: (index * 100).ms).scale(),
                );
              },
            ),
          );
        }),

        // Input Field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything about Flutter...',
                      prefixIcon: const Icon(Icons.chat_bubble_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.darkSurface : Colors.grey.shade100,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (text) {
                      controller.sendMessage(text);
                      messageController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded),
                  iconSize: 24,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () {
                    controller.sendMessage(messageController.text);
                    messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    TextEditingController messageController,
    ScrollController scrollController,
    bool isDark,
  ) {
    return Row(
      children: [
        // Sidebar with suggestions and info
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.info.withOpacity(0.1),
                      AppColors.success.withOpacity(0.1),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.smart_toy, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI Assistant',
                        style: AppTextStyles.h3.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Suggestions
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Suggestions',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() => Column(
                            children: controller.suggestions.map((suggestion) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () {
                                    messageController.text = suggestion;
                                    controller
                                        .sendMessage(messageController.text);
                                    messageController.clear();
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkSurface
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .dividerColor
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.lightbulb_outline,
                                          size: 20,
                                          color: AppColors.info,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            suggestion,
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).animate().fadeIn().scale(),
                              );
                            }).toList(),
                          )),
                      const SizedBox(height: 24),
                      Text(
                        'Tips',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTipCard(
                        context,
                        isDark,
                        Icons.chat,
                        'Be Specific',
                        'Ask detailed questions for better answers',
                      ),
                      const SizedBox(height: 12),
                      _buildTipCard(
                        context,
                        isDark,
                        Icons.code,
                        'Code Examples',
                        'Ask for code samples and explanations',
                      ),
                      const SizedBox(height: 12),
                      _buildTipCard(
                        context,
                        isDark,
                        Icons.lightbulb,
                        'Best Practices',
                        'Learn Flutter best practices',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main chat area
        Expanded(
          child: Column(
            children: [
              // Messages List
              Expanded(
                child: Obx(() {
                  if (controller.messages.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  // Auto-scroll to bottom when new message added
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (scrollController.hasClients) {
                      scrollController.animateTo(
                        scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(32),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return _buildMessageBubble(context, message, isDark)
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideX(
                            begin: message.isUser ? 0.2 : -0.2,
                            duration: 300.ms,
                          );
                    },
                  );
                }),
              ),

              // Typing Indicator
              Obx(() {
                if (!controller.isTyping.value) return const SizedBox.shrink();
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTypingDot()
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .fade(duration: 600.ms),
                            const SizedBox(width: 4),
                            _buildTypingDot()
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .fade(duration: 600.ms, delay: 200.ms),
                            const SizedBox(width: 4),
                            _buildTypingDot()
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .fade(duration: 600.ms, delay: 400.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Input Field
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask me anything about Flutter...',
                          prefixIcon: const Icon(Icons.chat_bubble_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurface
                              : Colors.grey.shade100,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (text) {
                          controller.sendMessage(text);
                          messageController.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      icon: const Icon(Icons.send_rounded),
                      iconSize: 24,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      onPressed: () {
                        controller.sendMessage(messageController.text);
                        messageController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.info,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    String greeting = 'Hello';
    if (user != null) {
      greeting = 'Hello, ${user.displayName ?? user.email.split('@')[0]}!';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ).animate().fadeIn().scale(),
          const SizedBox(height: 16),
          Text(
            greeting,
            style: AppTextStyles.h3.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Text(
            'No messages yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with your AI assistant',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    bool isDark,
  ) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Avatar + Name
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!message.isUser) ...[
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.info.withOpacity(0.2),
                      child: const Icon(
                        Icons.smart_toy,
                        size: 14,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    message.isUser ? 'You' : 'AI Assistant',
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (message.isUser) ...[
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.info.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        size: 14,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Message Bubble
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: message.text));
                Get.snackbar(
                  'Copied',
                  'Message copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: message.isUser
                      ? LinearGradient(
                          colors: [
                            AppColors.info,
                            AppColors.info.withOpacity(0.8),
                          ],
                        )
                      : null,
                  color: message.isUser
                      ? null
                      : (isDark ? AppColors.darkSurface : Colors.grey.shade100),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                    bottomRight: Radius.circular(message.isUser ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: message.isUser
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: message.isUser
                                ? Colors.white.withOpacity(0.7)
                                : Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.5),
                          ),
                        ),
                        if (message.isUser) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.done_all,
                            size: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
