import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode, defaultTargetPlatform, TargetPlatform;
import 'package:supabase_flutter/supabase_flutter.dart';

final _baseUrl = _resolveBaseUrl();

String _resolveBaseUrl() {
  const override = String.fromEnvironment('API_URL');
  if (override.isNotEmpty) {
    assert(
      !kReleaseMode || override.startsWith('https://'),
      'API_URL must use HTTPS in release builds',
    );
    return override;
  }
  if (kReleaseMode) {
    throw StateError('API_URL must be provided via --dart-define for release builds');
  }
  if (kIsWeb) return 'http://localhost:3000/api';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000/api';
  return 'http://localhost:3000/api';
}

Dio createApiClient() {
  final dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      }
      handler.next(options);
    },
    onError: (error, handler) {
      if (error.response?.statusCode == 401) {
        Supabase.instance.client.auth.signOut();
      }
      handler.next(error);
    },
  ));

  return dio;
}

final apiClient = createApiClient();
