import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/auth_gate.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/scan/camera_screen.dart';
import 'features/scan/scanning_screen.dart';
import 'features/scan/scan_result_screen.dart';
import 'features/history/history_screen.dart';
import 'features/insights/insights_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/health_connect_screen.dart';
import 'features/gamification/challenges_screen.dart';
import 'features/gamification/leaderboard_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/home_shell.dart';

const _publicPaths = {'/', '/login'};

CustomTransitionPage<void> _fadeThrough(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: kMotionBase,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(parent: animation, curve: kCurveEmphasized);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.008), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _slideUp(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: kMotionSlow,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(parent: animation, curve: kCurveEmphasized);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
        child: child,
      );
    },
  );
}

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isAuthenticated = Supabase.instance.client.auth.currentSession != null;
    final isPublic = _publicPaths.contains(state.matchedLocation);
    if (!isAuthenticated && !isPublic) return '/login';
    if (isAuthenticated && state.matchedLocation == '/login') return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(path: '/home', pageBuilder: (context, state) => _fadeThrough(state, const HomeScreen())),
        GoRoute(path: '/history', pageBuilder: (context, state) => _fadeThrough(state, const HistoryScreen())),
        GoRoute(path: '/insights', pageBuilder: (context, state) => _fadeThrough(state, const InsightsScreen())),
        GoRoute(path: '/profile', pageBuilder: (context, state) => _fadeThrough(state, const ProfileScreen())),
      ],
    ),
    GoRoute(path: '/scan', pageBuilder: (context, state) => _slideUp(state, const CameraScreen())),
    GoRoute(path: '/settings', pageBuilder: (context, state) => _fadeThrough(state, const SettingsScreen())),
    GoRoute(path: '/profile/health', pageBuilder: (context, state) => _fadeThrough(state, const HealthConnectScreen())),
    GoRoute(path: '/challenges', pageBuilder: (context, state) => _fadeThrough(state, const ChallengesScreen())),
    GoRoute(path: '/leaderboard', pageBuilder: (context, state) => _fadeThrough(state, const LeaderboardScreen())),
    GoRoute(
      path: '/scanning',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra == null) return _fadeThrough(state, const CameraScreen());
        return _fadeThrough(
          state,
          ScanningScreen(
            imageBytes: extra['bytes'] as List<int>,
            barcode: extra['barcode'] as String?,
          ),
        );
      },
    ),
    GoRoute(
      path: '/result/:scanId',
      pageBuilder: (context, state) {
        final scanId = state.pathParameters['scanId']!;
        return _fadeThrough(state, ScanResultScreen(scanId: scanId));
      },
    ),
  ],
);
