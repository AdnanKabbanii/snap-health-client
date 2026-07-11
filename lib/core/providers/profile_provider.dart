import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../models/models.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile?>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    try {
      return await apiService.getProfile();
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await apiService.updateProfile(data);
    ref.invalidateSelf();
  }

  bool get needsOnboarding {
    final profile = state.valueOrNull;
    if (profile == null) return true;
    return profile.conditions.isEmpty && profile.goals.isEmpty;
  }
}
