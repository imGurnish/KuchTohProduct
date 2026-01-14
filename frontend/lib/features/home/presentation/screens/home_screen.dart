import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Home Screen
///
/// Simple home screen displayed after successful authentication.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType, constraints) {
        return _buildLayout(context);
      },
    );
  }

  Widget _buildLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRouter.welcome);
        }
      },
      child: Scaffold(
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
            child: Column(
              children: [
                // App Bar
                _buildAppBar(context, isDark),
                // Content
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 600 : double.infinity,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: _buildContent(context, isDark),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withOpacity(0.5)
            : AppColors.lightSurface.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.psychology_outlined,
              size: 24,
              color: isDark ? AppColors.darkBackground : Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Mindspace',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const Spacer(),
          // Sign out button
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            icon: Icon(
              Icons.logout_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            tooltip: 'Sign out',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'User';
        String userEmail = '';

        if (state is AuthAuthenticated) {
          userName = state.user.displayName ?? 'User';
          userEmail = state.user.email;
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark ? AppColors.purple20 : const Color(0xFFF0EDFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 50,
                color: isDark ? AppColors.darkAccent : const Color(0xFF6B4EFF),
              ),
            ).animate().fadeIn().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack,
            ),
            const SizedBox(height: 32),

            // Welcome text
            Text(
              'Welcome, $userName!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 8),

            if (userEmail.isNotEmpty)
              Text(
                userEmail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ).animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 48),

            // Success message
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.rocket_launch_rounded,
                    size: 40,
                    color: isDark
                        ? AppColors.darkAccent
                        : const Color(0xFF6B4EFF),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You\'re all set!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Authentication is working correctly.\nYour session is now active.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            // Sign out button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthSignOutRequested());
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ).animate(delay: 500.ms).fadeIn(),
          ],
        );
      },
    );
  }
}
