import 'package:freezed_annotation/freezed_annotation.dart';

part 'sponsor.freezed.dart';
part 'sponsor.g.dart';

@freezed
abstract class Sponsor with _$Sponsor {
  const factory Sponsor({
    required String id,
    required String name,
    String? brand,
    num? healthScore,
    String? tagline,
    String? imageUrl,
  }) = _Sponsor;

  factory Sponsor.fromJson(Map<String, dynamic> json) => _$SponsorFromJson(json);
}
