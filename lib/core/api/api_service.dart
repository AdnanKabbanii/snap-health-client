import 'api_client.dart';
import '../models/models.dart';

class ApiService {
  Future<UserProfile> getProfile() async {
    final res = await apiClient.get('/profile');
    return UserProfile.fromJson(res.data);
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    final res = await apiClient.put('/profile', data: data);
    return UserProfile.fromJson(res.data);
  }

  Future<List<Map<String, dynamic>>> searchFood(String query, {int limit = 20}) async {
    final res = await apiClient.get('/food/search', queryParameters: {'q': query, 'limit': limit});
    return List<Map<String, dynamic>>.from(res.data['results']);
  }

  Future<Map<String, dynamic>?> scanBarcode(String barcode) async {
    try {
      final res = await apiClient.post('/scan/barcode', data: {'barcode': barcode});
      return res.data['product'];
    } catch (_) {
      return null;
    }
  }

  Future<ScanHistoryResponse> getScanHistory({int page = 1, int limit = 20, String? category}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (category != null) params['category'] = category;
    final res = await apiClient.get('/scans', queryParameters: params);
    return ScanHistoryResponse.fromJson(res.data);
  }

  Future<ScanDetail> getScan(String scanId) async {
    final res = await apiClient.get('/scan/$scanId');
    return ScanDetail.fromJson(res.data);
  }

  Future<GamificationStatus> getGamificationStatus() async {
    final res = await apiClient.get('/gamification/status');
    return GamificationStatus.fromJson(res.data);
  }

  Future<CheckinResponse> checkin() async {
    final res = await apiClient.post('/gamification/checkin');
    return CheckinResponse.fromJson(res.data);
  }

  Future<WeeklyInsights> getWeeklyInsights() async {
    final res = await apiClient.get('/insights/weekly');
    return WeeklyInsights.fromJson(res.data);
  }

  Future<List<Sponsor>> getSponsors(String category, double score) async {
    final res = await apiClient.get('/sponsors/match', queryParameters: {'category': category, 'score': score});
    return (res.data['results'] as List).map((e) => Sponsor.fromJson(e)).toList();
  }

  Future<void> submitFeedback(String scanId, String correctionText) async {
    await apiClient.post('/feedback', data: {'scanId': scanId, 'correctionText': correctionText});
  }

  Future<void> trackImpression(String sponsorId, String? scanId) async {
    await apiClient.post('/sponsors/impression', data: {
      'sponsorId': sponsorId,
      'scanId': ?scanId,
      'clicked': false,
    });
  }

  Future<void> trackClick(String sponsorId, String? scanId) async {
    await apiClient.post('/sponsors/impression', data: {
      'sponsorId': sponsorId,
      'scanId': ?scanId,
      'clicked': true,
    });
  }
  Future<HealthMetrics?> getHealthMetrics() async {
    final res = await apiClient.get('/health/metrics');
    if (res.data == null) return null;
    return HealthMetrics.fromJson(res.data);
  }

  Future<HealthMetrics> updateHealthMetrics(HealthMetrics metrics) async {
    final res = await apiClient.put('/health/metrics', data: metrics.toJson());
    return HealthMetrics.fromJson(res.data);
  }

  Future<void> deleteHealthMetrics() async {
    await apiClient.delete('/health/metrics');
  }

  Future<List<ChallengeWithProgress>> getChallenges() async {
    final res = await apiClient.get('/challenges');
    return (res.data['challenges'] as List)
        .map((e) => ChallengeWithProgress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LeaderboardEntry>> getLeaderboardWeekly() async {
    final res = await apiClient.get('/leaderboard/weekly');
    return (res.data as List)
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LeaderboardEntry>> getLeaderboardAllTime() async {
    final res = await apiClient.get('/leaderboard/alltime');
    return (res.data as List)
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LeaderboardEntry>> getLeaderboardStreak() async {
    final res = await apiClient.get('/leaderboard/streak');
    return (res.data as List)
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }


  Future<String> getReferralCode() async {
    final res = await apiClient.get('/gamification/referral');
    return res.data['code'] as String;
  }

  Future<Map<String, dynamic>> useReferralCode(String code) async {
    final res = await apiClient.post('/gamification/referral/use', data: {'code': code});
    return res.data as Map<String, dynamic>;
  }

  Future<void> trackShare(String scanId) async {
    await apiClient.post('/gamification/share', data: {'scanId': scanId});
  }
}

final apiService = ApiService();
