import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'router.dart';

const _sentryDsn = String.fromEnvironment('SENTRY_DSN');
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

Future<void> main() async {
  if (_sentryDsn.isEmpty) {
    await _boot();
    return;
  }
  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.environment = kReleaseMode ? 'production' : 'debug';
      options.tracesSampleRate = 0.2;
    },
    appRunner: _boot,
  );
}

Future<void> _boot() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_supabaseUrl.isEmpty || _supabaseKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are required. '
      'Pass them with --dart-define-from-file=.env.dart-defines',
    );
  }

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseKey,
  );

  runApp(const ProviderScope(child: SnapHealthApp()));
}

class SnapHealthApp extends ConsumerWidget {
  const SnapHealthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(themeProvider);

    return ShadcnApp.router(
      title: 'SnapHealth',
      theme: buildTheme(false),
      darkTheme: buildTheme(true),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
