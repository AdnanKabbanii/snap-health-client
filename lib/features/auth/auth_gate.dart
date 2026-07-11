import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/profile_provider.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.session == null) {
            context.go('/login');
          } else {
            final needsOnboarding = ref.read(profileProvider.notifier).needsOnboarding;
            context.go(needsOnboarding ? '/onboarding' : '/home');
          }
        });
        return const _Splash();
      },
      loading: () => const _Splash(),
      error: (_, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
        return const _Splash();
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Container(
        color: kBackground,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SnapHealth', style: kSerif(24, weight: FontWeight.w600)),
              const Gap(16),
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: kSignal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
