import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'scan_result.freezed.dart';
part 'scan_result.g.dart';

@freezed
abstract class Effect with _$Effect {
  const factory Effect({
    required BodySystem bodySystem,
    required EffectDirection direction,
    required num magnitude,
    required String description,
    String? personalizedNote,
    WarningLevel? warningLevel,
    num? modifier,
  }) = _Effect;

  factory Effect.fromJson(Map<String, dynamic> json) => _$EffectFromJson(json);
}

@freezed
abstract class Risk with _$Risk {
  const factory Risk({
    required String title,
    required String severity,
    required String description,
  }) = _Risk;

  factory Risk.fromJson(Map<String, dynamic> json) => _$RiskFromJson(json);
}

@freezed
abstract class Benefit with _$Benefit {
  const factory Benefit({
    required String title,
    required String description,
  }) = _Benefit;

  factory Benefit.fromJson(Map<String, dynamic> json) => _$BenefitFromJson(json);
}

@freezed
abstract class Nutrition with _$Nutrition {
  const factory Nutrition({
    num? calories,
    num? proteinG,
    num? carbsG,
    num? fatG,
    num? fiberG,
    num? sugarG,
    num? sodiumMg,
  }) = _Nutrition;

  factory Nutrition.fromJson(Map<String, dynamic> json) => _$NutritionFromJson(json);
}

@freezed
abstract class GoalAdvice with _$GoalAdvice {
  const factory GoalAdvice({
    required String goal,
    required num relevance,
    required String advice,
  }) = _GoalAdvice;

  factory GoalAdvice.fromJson(Map<String, dynamic> json) => _$GoalAdviceFromJson(json);
}

@freezed
abstract class ScanResult with _$ScanResult {
  const factory ScanResult({
    required String itemName,
    required num confidence,
    required String category,
    required num healthScore,
    required String summary,
    @Default([]) List<Effect> effects,
    @Default([]) List<Risk> risks,
    @Default([]) List<Benefit> benefits,
    Nutrition? nutrition,
    @Default([]) List<String> actionableTips,
    String? alternativeCategory,
    @Default([]) List<GoalAdvice> goalAdvice,
  }) = _ScanResult;

  factory ScanResult.fromJson(Map<String, dynamic> json) => _$ScanResultFromJson(json);
}
