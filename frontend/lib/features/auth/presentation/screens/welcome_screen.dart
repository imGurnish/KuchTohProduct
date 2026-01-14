import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/responsive.dart';

/// Welcome Screen
///
/// Premium landing screen with Google and Email sign-in options.
/// Fully responsive for mobile, tablet, and desktop.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType, constraints) {
        if (screenType == ScreenType.desktop) {
          return _buildDesktopLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );
  }

  /// Desktop layout with split screen
  Widget _buildDesktopLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // Left side - Branding/Illustration
          Expanded(
            flex: 55,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppColors.darkBackground,
                          const Color(0xFF1a1a3e),
                          const Color(0xFF2d1b4e),
                        ]
                      : [
                          const Color(0xFFF8F9FF),
                          const Color(0xFFEEF1FF),
                          const Color(0xFFE8ECFF),
                        ],
                ),
              ),
              child: Stack(
                children: [
                  // Background decoration
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPatternPainter(isDark: isDark),
                    ),
                  ),
                  // Content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Large Logo
                          Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (isDark
                                                  ? AppColors.darkAccent
                                                  : AppColors.lightPrimary)
                                              .withOpacity(0.3),
                                      blurRadius: 40,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.psychology_outlined,
                                  size: 60,
                                  color: isDark
                                      ? AppColors.darkBackground
                                      : Colors.white,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1, 1),
                                curve: Curves.easeOutBack,
                              ),
                          const SizedBox(height: 40),
                          Text(
                                'Mindspace',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                  letterSpacing: -1,
                                ),
                              )
                              .animate(delay: 200.ms)
                              .fadeIn()
                              .slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 16),
                          Text(
                            'Your private AI companion',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ).animate(delay: 400.ms).fadeIn(),
                          const SizedBox(height: 48),
                          // Feature highlights
                          ..._buildFeatureList(isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side - Auth form
          Expanded(
            flex: 45,
            child: Container(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(48),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: _buildAuthContent(
                            context,
                            isDark,
                            isDesktop: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildFooter(context, isDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureList(bool isDark) {
    final features = [
      ('🔒', 'Local-first storage'),
      ('🧠', 'AI-powered organization'),
      ('🔍', 'Semantic search'),
    ];

    return features.asMap().entries.map((entry) {
      return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.value.$1, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  entry.value.$2,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          )
          .animate(delay: Duration(milliseconds: 600 + entry.key * 150))
          .fadeIn()
          .slideX(begin: -0.2, end: 0);
    }).toList();
  }

  /// Mobile/Tablet layout
  Widget _buildMobileLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isTablet = context.isTablet;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkBackground, const Color(0xFF12122a)]
                : [AppColors.lightBackground, const Color(0xFFF0F0F8)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - padding.top - padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
                  child: Column(
                    children: [
                      SizedBox(height: isTablet ? 80 : 60),
                      // Logo
                      _buildLogo(context, isDark, isTablet),
                      SizedBox(height: isTablet ? 56 : 40),
                      // Auth Content
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 420 : double.infinity,
                          ),
                          child: _buildAuthContent(
                            context,
                            isDark,
                            isDesktop: false,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Footer
                      _buildFooter(context, isDark),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, bool isDark, bool isTablet) {
    final iconSize = isTablet ? 80.0 : 64.0;
    final titleSize = isTablet ? 32.0 : 28.0;

    return Column(
      children: [
        Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(iconSize * 0.25),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isDark ? AppColors.darkAccent : AppColors.lightPrimary)
                            .withOpacity(0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(
                Icons.psychology_outlined,
                size: iconSize * 0.5,
                color: isDark ? AppColors.darkBackground : Colors.white,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: 20),
        Text(
          'Mindspace',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            letterSpacing: -0.5,
          ),
        ).animate(delay: 200.ms).fadeIn(),
        const SizedBox(height: 8),
        Text(
          'Capture everything, remember all.',
          style: TextStyle(
            fontSize: 15,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ).animate(delay: 300.ms).fadeIn(),
      ],
    );
  }

  Widget _buildAuthContent(
    BuildContext context,
    bool isDark, {
    required bool isDesktop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isDesktop) ...[
          Text(
            'Get Started',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue to your private workspace',
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 32),
        ],
        // Auth Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceElevated
                : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Column(
            children: [
              // Google Sign In
              _GoogleSignInButton(
                isDark: isDark,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Google sign-in coming soon!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Email Sign In
              _EmailSignInButton(
                isDark: isDark,
                onPressed: () => context.push(AppRouter.login),
              ),
            ],
          ),
        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
        const SizedBox(height: 24),
        // Privacy Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.purple20 : const Color(0xFFF0EDFF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: isDark
                      ? AppColors.darkAccent
                      : const Color(0xFF6B4EFF),
                ),
                const SizedBox(width: 8),
                Text(
                  'Privacy-Focused Architecture',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkAccent
                        : const Color(0xFF6B4EFF),
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: 600.ms).fadeIn(),
        const SizedBox(height: 12),
        // Privacy text
        Text(
          'Your data is encrypted locally and never sold.\nYou own your Mindspace.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: isDark
                ? AppColors.darkTextMuted
                : AppColors.lightTextSecondary,
          ),
        ).animate(delay: 700.ms).fadeIn(),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _FooterLink(text: 'TERMS OF USE', isDark: isDark, onTap: () {}),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '·',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        _FooterLink(text: 'PRIVACY POLICY', isDark: isDark, onTap: () {}),
      ],
    ).animate(delay: 900.ms).fadeIn();
  }
}

// Custom Google Sign In Button
class _GoogleSignInButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onPressed;

  const _GoogleSignInButton({required this.isDark, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.darkPrimary : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.transparent : AppColors.lightBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google logo
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [
                            Color(0xFF4285F4),
                            Color(0xFFDB4437),
                            Color(0xFFF4B400),
                            Color(0xFF0F9D58),
                          ],
                        ).createShader(const Rect.fromLTWH(0, 0, 20, 20)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Email Sign In Button
class _EmailSignInButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onPressed;

  const _EmailSignInButton({required this.isDark, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 20,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                'Continue with Email',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Footer link widget
class _FooterLink extends StatelessWidget {
  final String text;
  final bool isDark;
  final VoidCallback onTap;

  const _FooterLink({
    required this.text,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: isDark
                ? AppColors.darkTextMuted
                : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }
}

// Grid pattern painter for desktop background
class _GridPatternPainter extends CustomPainter {
  final bool isDark;

  _GridPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
