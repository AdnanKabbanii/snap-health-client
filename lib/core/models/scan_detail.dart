import 'package:freezed_annotation/freezed_annotation.dart';
import 'scan_result.dart';

part 'scan_detail.freezed.dart';
part 'scan_detail.g.dart';

@freezed
abstract class ScanDetail with _$ScanDetail {
  const factory ScanDetail({
    required String id,
    required String userId,
    required String imageHash,
    String? imageUrl,
    String? itemName,
    String? category,
    num? healthScore,
    ScanResult? result,
    required String createdAt,
  }) = _ScanDetail;

  factory ScanDetail.fromJson(Map<String, dynamic> json) =>
      _$ScanDetailFromJson(json);
}
