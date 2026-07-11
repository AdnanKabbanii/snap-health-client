import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../core/theme/app_theme.dart';

class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/history')) return 1;
    if (location.startsWith('/insights')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      child: Container(
        color: kBackground,
        child: Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 12,
              child: _Dock(index: index),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dock extends StatelessWidget {
  final int index;
  const _Dock({required this.index});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: kSurfaceLow.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: kHairline),
          ),
          child: Row(
            children: [
              _DockItem(
                icon: Icons.grid_view_rounded,
                label: 'Today',
                active: index == 0,
                onTap: () => context.go('/home'),
              ),
              _DockItem(
                icon: Icons.receipt_long_rounded,
                label: 'Log',
                active: index == 1,
                onTap: () => context.go('/history'),
              ),
              const _ScanAction(),
              _DockItem(
                icon: Icons.insights_rounded,
                label: 'Trends',
                active: index == 2,
                onTap: () => context.go('/insights'),
              ),
              _DockItem(
                icon: Icons.person_outline_rounded,
                label: 'You',
                active: index == 3,
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanAction extends StatelessWidget {
  const _ScanAction();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            context.push('/scan');
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: kSignal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kSignal.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.center_focus_strong_rounded, color: kInk, size: 24),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? kOnSurface : kOnSurfaceFaint;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: kMotionBase,
              curve: kCurveSnap,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: active ? kSignal.withValues(alpha: 0.14) : const Color(0x00000000),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: active ? kSignal : color, size: 21),
            ),
            const Gap(3),
            Text(
              label.toUpperCase(),
              style: kMono(8.5, weight: FontWeight.w600, letterSpacing: 1.1, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
