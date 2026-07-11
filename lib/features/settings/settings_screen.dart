import 'package:flutter/material.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/theme_provider.dart';
import '../../widgets/ui.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(themeProvider);

    return Scaffold(
      child: Container(
        color: kBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconSquare(
                      icon: Icons.arrow_back_rounded,
                      size: 38,
                      onTap: () => context.pop(),
                    ),
                    const Gap(16),
                    Text('Controls', style: kHeadline.copyWith(fontSize: 24)),
                  ],
                ),
                const Gap(28),

                const Eyebrow('Appearance'),
                const Gap(12),
                Panel(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Icon(Icons.contrast_rounded, size: 19, color: kOnSurfaceVariant),
                      const Gap(13),
                      Expanded(child: Text('Theme', style: kSubtitle.copyWith(fontSize: 14.5))),
                      SizedBox(
                        width: 170,
                        child: SegmentedTabs(
                          labels: const ['Dark', 'Light'],
                          index: dark ? 0 : 1,
                          onChanged: (i) => ref.read(themeProvider.notifier).setDark(i == 0),
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(26),
                const Eyebrow('Account'),
                const Gap(12),
                _SettingsRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Recalibrate profile',
                  onTap: () => context.push('/onboarding'),
                ),
                const Gap(8),
                _SettingsRow(
                  icon: Icons.monitor_heart_outlined,
                  label: 'Biometrics',
                  onTap: () => context.push('/profile/health'),
                ),
                const Gap(8),
                _SettingsRow(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  trailing: Text('SOON', style: kLabel.copyWith(fontSize: 9, color: kOnSurfaceFaint)),
                ),

                const Gap(26),
                const Eyebrow('Legal'),
                const Gap(12),
                _SettingsRow(
                  icon: Icons.shield_outlined,
                  label: 'Privacy policy',
                  onTap: () => _openUrl('https://snaphealth.app/privacy'),
                ),
                const Gap(8),
                _SettingsRow(
                  icon: Icons.description_outlined,
                  label: 'Terms of use',
                  onTap: () => _openUrl('https://snaphealth.app/terms'),
                ),
                const Gap(8),
                _SettingsRow(
                  icon: Icons.article_outlined,
                  label: 'Open source licenses',
                  onTap: () => m.showLicensePage(
                    context: context,
                    applicationName: 'SnapHealth',
                    applicationVersion: '1.0.0',
                  ),
                ),

                const Gap(26),
                const Eyebrow('About'),
                const Gap(12),
                Panel(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Icon(Icons.qr_code_2_rounded, size: 19, color: kOnSurfaceVariant),
                      const Gap(13),
                      Expanded(child: Text('Version', style: kSubtitle.copyWith(fontSize: 14.5))),
                      Text('1.0.0', style: kMono(12.5, color: kOnSurfaceVariant)),
                    ],
                  ),
                ),

                const Gap(32),
                AppButton(
                  label: 'Sign out',
                  variant: AppButtonVariant.danger,
                  height: 48,
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsRow({required this.icon, required this.label, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Panel(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Icon(icon, size: 19, color: kOnSurfaceVariant),
          const Gap(13),
          Expanded(child: Text(label, style: kSubtitle.copyWith(fontSize: 14.5))),
          trailing ?? Icon(Icons.chevron_right_rounded, size: 18, color: kOnSurfaceFaint),
        ],
      ),
    );
  }
}
