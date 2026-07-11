import 'package:json_annotation/json_annotation.dart';

enum ScanCategory {
  @JsonValue('food')
  food,
  @JsonValue('beverage')
  beverage,
  @JsonValue('supplement')
  supplement,
  @JsonValue('lighting')
  lighting,
  @JsonValue('skincare')
  skincare,
  @JsonValue('label')
  label,
  @JsonValue('electronics')
  electronics,
  @JsonValue('other')
  other,
}

enum BodySystem {
  @JsonValue('insulin')
  insulin,
  @JsonValue('blood_pressure')
  bloodPressure,
  @JsonValue('sleep')
  sleep,
  @JsonValue('metabolism')
  metabolism,
  @JsonValue('inflammation')
  inflammation,
  @JsonValue('gut')
  gut,
  @JsonValue('energy')
  energy,
  @JsonValue('cholesterol')
  cholesterol,
  @JsonValue('hydration')
  hydration,
  @JsonValue('cortisol')
  cortisol,
  @JsonValue('bone_density')
  boneDensity,
  @JsonValue('liver')
  liver,
}

enum EffectDirection {
  @JsonValue('increase')
  increase,
  @JsonValue('decrease')
  decrease,
  @JsonValue('neutral')
  neutral,
}

enum WarningLevel {
  @JsonValue('info')
  info,
  @JsonValue('caution')
  caution,
  @JsonValue('warning')
  warning,
  @JsonValue('critical')
  critical,
  @JsonValue('danger')
  danger,
}
