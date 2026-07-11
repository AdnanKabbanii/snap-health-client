import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    String? displayName,
    String? avatarUrl,
    String? ageRange,
    String? biologicalSex,
    @Default([]) List<String> conditions,
    @Default([]) List<String> goals,
    String? dietaryPreference,
    @Default([]) List<String> allergies,
    @Default([]) List<String> medications,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}
