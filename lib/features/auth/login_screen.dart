import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/ui.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _isSignUp = false;

  Future<void> _signInWithEmail() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      if (mounted) context.go('/');
    } on AuthException catch (e) {
      setState(() { _error = e.message; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  static const _oauthRedirect = 'com.snaphealth.snaphealth://login-callback';

  Future<void> _signInWithOAuth(OAuthProvider provider) async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: _oauthRedirect,
      );
    } on AuthException catch (e) {
      setState(() { _error = e.message; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Container(
        color: kBackground,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Entrance(
                    index: 0,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: kSignal, shape: BoxShape.circle),
                        ),
                        const Gap(10),
                        Text('SNAPHEALTH', style: kMono(12, weight: FontWeight.w600, letterSpacing: 3)),
                      ],
                    ),
                  ),
                  const Gap(36),
                  Entrance(
                    index: 1,
                    child: Text(
                      'Know what\nyou\'re putting\nin your body.',
                      style: kSerif(36, height: 1.12),
                    ),
                  ),
                  const Gap(14),
                  Entrance(
                    index: 2,
                    child: Text(
                      'Scan any food, drink, or supplement. Get a lab-grade verdict, personalized to you.',
                      style: kBody.copyWith(color: kOnSurfaceVariant),
                    ),
                  ),
                  const Gap(44),

                  Entrance(
                    index: 3,
                    child: AppButton(
                      label: 'Continue with Google',
                      icon: Icons.g_mobiledata_rounded,
                      onTap: _isLoading ? null : () => _signInWithOAuth(OAuthProvider.google),
                    ),
                  ),
                  const Gap(10),
                  Entrance(
                    index: 4,
                    child: AppButton(
                      label: 'Continue with Apple',
                      icon: Icons.apple_rounded,
                      variant: AppButtonVariant.tonal,
                      onTap: _isLoading ? null : () => _signInWithOAuth(OAuthProvider.apple),
                    ),
                  ),

                  const Gap(28),
                  Entrance(
                    index: 5,
                    child: Row(
                      children: [
                        Expanded(child: Container(height: 1, color: kHairline)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text('OR EMAIL', style: kLabel.copyWith(fontSize: 9.5)),
                        ),
                        Expanded(child: Container(height: 1, color: kHairline)),
                      ],
                    ),
                  ),
                  const Gap(28),

                  Entrance(
                    index: 6,
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          placeholder: const Text('Email'),
                        ),
                        const Gap(10),
                        TextField(
                          controller: _passwordController,
                          placeholder: const Text('Password'),
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),

                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kDanger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(kRadiusSm),
                        border: Border.all(color: kDanger.withValues(alpha: 0.25)),
                      ),
                      child: Text(_error!, style: kBody.copyWith(color: kDanger, fontSize: 13)),
                    ),
                    const Gap(12),
                  ],

                  Entrance(
                    index: 7,
                    child: AppButton(
                      label: _isSignUp ? 'Create account' : 'Sign in',
                      variant: AppButtonVariant.tonal,
                      loading: _isLoading,
                      height: 48,
                      onTap: _signInWithEmail,
                    ),
                  ),
                  const Gap(18),
                  Entrance(
                    index: 8,
                    child: Center(
                      child: Pressable(
                        onTap: () => setState(() { _isSignUp = !_isSignUp; }),
                        child: Text(
                          _isSignUp ? 'Already on file? Sign in' : 'New here? Create an account',
                          style: kBody.copyWith(color: kSignal, fontSize: 13.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
