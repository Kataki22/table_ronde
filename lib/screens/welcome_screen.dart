import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/theme_extensions.dart';
import 'dart:math' as math;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Animated Avatars Section
              SizedBox(
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Floating Bubbles
                    _buildFloatingBubble(0, -100, -80, 0.0),
                    _buildFloatingBubble(1, 60, -70, 0.5),
                    _buildFloatingBubble(2, -90, 20, 1.0),
                    _buildFloatingBubble(3, 100, 40, 1.5),

                    // Center Avatars Cluster
                    _buildAvatarCluster(),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Welcome Text
              FadeTransition(
                opacity: _fadeController,
                child: Column(
                  children: [
                    Text(
                      'Bienvenue sur TableRonde !',
                      style: AppTheme.headingLarge
                          .copyWith(color: context.themeColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'L\'écosystème complet pour votre\ncommunauté : social, finance, éducation et jeux !',
                      style: AppTheme.bodyMedium
                          .copyWith(color: context.themeColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Buttons
              FadeTransition(
                opacity: _fadeController,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.themeColors.colorPrimary,
                          foregroundColor: context.themeColors.textInverse,
                        ),
                        child: Text('Commencer',
                            style: AppTheme.buttonText.copyWith(
                                color: context.themeColors.textInverse)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        'Se connecter',
                        style: AppTheme.bodyLarge.copyWith(
                          color: context.themeColors.colorPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBubble(int index, double dx, double dy, double delay) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final offset =
            math.sin((_floatingController.value * 2 * math.pi) + delay) * 10;
        return Transform.translate(
          offset: Offset(dx, dy + offset),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.themeColors.colorPrimary.withOpacity(0.3),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarCluster() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Avatar positions
        _buildAvatar('assets/avatars/avatar1.jpg', -60, -40, 50),
        _buildAvatar('assets/avatars/avatar2.jpg', 50, -50, 45),
        _buildAvatar('assets/avatars/avatar3.jpg', -70, 30, 42),
        _buildAvatar('assets/avatars/avatar4.jpg', 60, 25, 48),
        _buildAvatar('assets/avatars/avatar5.jpg', -20, -80, 40),
        _buildAvatar('assets/avatars/avatar6.jpg', 0, 60, 44),

        // Center Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.themeColors.colorPrimary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.themeColors.colorPrimary.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.chat_bubble_rounded,
            color: context.themeColors.textInverse,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String imagePath, double dx, double dy, double size) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.themeColors.bgSurface, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: CircleAvatar(
          backgroundColor: AppTheme.lightBlue.withOpacity(0.3),
          child: Icon(
            Icons.person,
            color: context.themeColors.colorPrimary,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }
}
