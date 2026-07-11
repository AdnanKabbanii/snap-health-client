import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../models/models.dart';

final gamificationProvider = FutureProvider<GamificationStatus>((ref) {
  return apiService.getGamificationStatus();
});

final weeklyInsightsProvider = FutureProvider<WeeklyInsights>((ref) {
  return apiService.getWeeklyInsights();
});

final checkinProvider = FutureProvider.family<CheckinResponse, void>((ref, _) {
  return apiService.checkin();
});

final challengesProvider = FutureProvider.autoDispose<List<ChallengeWithProgress>>((ref) {
  return apiService.getChallenges();
});
