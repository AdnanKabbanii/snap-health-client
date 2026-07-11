import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../api/sse_client.dart';
import '../models/models.dart';

class ScanState {
  final bool isScanning;
  final String? status;
  final String? itemName;
  final String? category;
  final int? confidence;
  final double? score;
  final String? scoreColor;
  final String? summary;
  final List<Effect> effects;
  final List<Risk> risks;
  final List<Benefit> benefits;
  final Nutrition? nutrition;
  final List<String> tips;
  final List<GoalAdvice> goalAdvice;
  final Sponsor? sponsor;
  final String? error;
  final String? scanId;
  final bool isDone;

  const ScanState({
    this.isScanning = false,
    this.status,
    this.itemName,
    this.category,
    this.confidence,
    this.score,
    this.scoreColor,
    this.summary,
    this.effects = const [],
    this.risks = const [],
    this.benefits = const [],
    this.nutrition,
    this.tips = const [],
    this.goalAdvice = const [],
    this.sponsor,
    this.error,
    this.scanId,
    this.isDone = false,
  });

  ScanState copyWith({
    bool? isScanning,
    String? status,
    String? itemName,
    String? category,
    int? confidence,
    double? score,
    String? scoreColor,
    String? summary,
    List<Effect>? effects,
    List<Risk>? risks,
    List<Benefit>? benefits,
    Nutrition? nutrition,
    List<String>? tips,
    List<GoalAdvice>? goalAdvice,
    Sponsor? sponsor,
    String? error,
    String? scanId,
    bool? isDone,
  }) {
    return ScanState(
      isScanning: isScanning ?? this.isScanning,
      status: status ?? this.status,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      score: score ?? this.score,
      scoreColor: scoreColor ?? this.scoreColor,
      summary: summary ?? this.summary,
      effects: effects ?? this.effects,
      risks: risks ?? this.risks,
      benefits: benefits ?? this.benefits,
      nutrition: nutrition ?? this.nutrition,
      tips: tips ?? this.tips,
      goalAdvice: goalAdvice ?? this.goalAdvice,
      sponsor: sponsor ?? this.sponsor,
      error: error ?? this.error,
      scanId: scanId ?? this.scanId,
      isDone: isDone ?? this.isDone,
    );
  }
}

final activeScanProvider = StateNotifierProvider<ActiveScanNotifier, ScanState>((ref) {
  return ActiveScanNotifier();
});

class ActiveScanNotifier extends StateNotifier<ScanState> {
  ActiveScanNotifier() : super(const ScanState());

  Future<void> startScan(Uint8List imageBytes, {String? barcode}) async {
    state = const ScanState(isScanning: true, status: 'Uploading...');

    try {
      await for (final event in streamScan(imageBytes, 'scan.jpg', barcode: barcode)) {
        switch (event.event) {
          case 'status':
            state = state.copyWith(status: event.data['message'] as String?);
            break;
          case 'identification':
            state = state.copyWith(
              itemName: event.data['name'] as String?,
              category: event.data['category'] as String?,
              confidence: (event.data['confidence'] as num?)?.toInt(),
            );
            break;
          case 'score':
            state = state.copyWith(
              score: (event.data['score'] as num?)?.toDouble(),
              scoreColor: event.data['color'] as String?,
            );
            break;
          case 'summary':
            state = state.copyWith(summary: event.data['text'] as String?);
            break;
          case 'details':
            final d = event.data;
            state = state.copyWith(
              effects: (d['effects'] as List?)?.map((e) => Effect.fromJson(e)).toList() ?? [],
              risks: (d['risks'] as List?)?.map((e) => Risk.fromJson(e)).toList() ?? [],
              benefits: (d['benefits'] as List?)?.map((e) => Benefit.fromJson(e)).toList() ?? [],
              nutrition: d['nutrition'] != null ? Nutrition.fromJson(d['nutrition']) : null,
              tips: (d['tips'] as List?)?.cast<String>() ?? [],
              goalAdvice: (d['goalAdvice'] as List?)?.map((e) => GoalAdvice.fromJson(e)).toList() ?? [],
            );
            break;
          case 'sponsor':
            state = state.copyWith(sponsor: Sponsor.fromJson(event.data));
            break;
          case 'error':
            state = state.copyWith(error: event.data['message'] as String?, isScanning: false);
            break;
          case 'done':
            state = state.copyWith(isScanning: false, isDone: true);
            break;
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isScanning: false);
    }
  }

  void reset() {
    state = const ScanState();
  }
}

final scanHistoryProvider = FutureProvider.family<ScanHistoryResponse, int>((ref, page) {
  return apiService.getScanHistory(page: page);
});

final scanDetailProvider = FutureProvider.family<ScanDetail, String>((ref, scanId) {
  return apiService.getScan(scanId);
});
