import 'package:flutter/material.dart' as m;
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

bool _isDark = true;

bool get isDarkMode => _isDark;
set isDarkMode(bool v) => _isDark = v;

m.Color get kBackground => _isDark ? const m.Color(0xFF0C0E12) : const m.Color(0xFFF6F5F2);
m.Color get kSurfaceLow => _isDark ? const m.Color(0xFF12151B) : const m.Color(0xFFFFFFFF);
m.Color get kSurfaceHigh => _isDark ? const m.Color(0xFF181C24) : const m.Color(0xFFEFEEE9);
m.Color get kSurfaceHighest => _isDark ? const m.Color(0xFF232935) : const m.Color(0xFFE3E1DA);
m.Color get kHairline => _isDark ? const m.Color(0xFF262C38) : const m.Color(0xFFDDDAD2);

m.Color get kOnSurface => _isDark ? const m.Color(0xFFEDEFF2) : const m.Color(0xFF16181D);
m.Color get kOnSurfaceVariant => _isDark ? const m.Color(0xFF97A0B0) : const m.Color(0xFF6C7280);
m.Color get kOnSurfaceFaint => _isDark ? const m.Color(0xFF5A6374) : const m.Color(0xFF9A9FA9);

m.Color get kSignal => _isDark ? const m.Color(0xFF63D68C) : const m.Color(0xFF1F8A4C);
m.Color get kSignalDim => _isDark ? const m.Color(0xFF2E5C42) : const m.Color(0xFFBBDECA);
m.Color get kAmber => _isDark ? const m.Color(0xFFE8B44B) : const m.Color(0xFFB07C14);
m.Color get kDanger => _isDark ? const m.Color(0xFFE36960) : const m.Color(0xFFC24438);
m.Color get kInk => _isDark ? const m.Color(0xFF0C0E12) : const m.Color(0xFFF6F5F2);

m.Color get kPrimary => kSignal;
m.Color get kSecondary => kAmber;
m.Color get kTertiary => kSignal;
m.Color get kError => kDanger;

const kRadiusLg = 24.0;
const kRadiusMd = 16.0;
const kRadiusSm = 10.0;

const kMotionFast = Duration(milliseconds: 120);
const kMotionBase = Duration(milliseconds: 220);
const kMotionSlow = Duration(milliseconds: 380);
const kMotionReveal = Duration(milliseconds: 550);
const kCurveSnap = m.Curves.easeOutCubic;
const kCurveEmphasized = m.Cubic(0.2, 0.0, 0.0, 1.0);

m.TextStyle kSerif(double size, {m.FontWeight weight = m.FontWeight.w600, double? height, m.Color? color}) =>
    GoogleFonts.fraunces(fontSize: size, fontWeight: weight, height: height ?? 1.15, color: color ?? kOnSurface);

m.TextStyle kMono(double size, {m.FontWeight weight = m.FontWeight.w500, double letterSpacing = 0, m.Color? color}) =>
    GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: weight, letterSpacing: letterSpacing, color: color ?? kOnSurface);

m.TextStyle kSans(double size, {m.FontWeight weight = m.FontWeight.w400, double? height, m.Color? color}) =>
    GoogleFonts.ibmPlexSans(fontSize: size, fontWeight: weight, height: height ?? 1.5, color: color ?? kOnSurface);

m.TextStyle get kDisplay => kMono(52, weight: m.FontWeight.w600);
m.TextStyle get kHeadline => kSerif(30);
m.TextStyle get kTitle => kSerif(21);
m.TextStyle get kSubtitle => kSans(15, weight: m.FontWeight.w600, height: 1.3);
m.TextStyle get kBody => kSans(14.5);
m.TextStyle get kCaption => kSans(12.5, color: kOnSurfaceVariant);
m.TextStyle get kLabel => kMono(10.5, letterSpacing: 1.6, color: kOnSurfaceVariant);
m.TextStyle get kReadout => kMono(13, weight: m.FontWeight.w600);

m.TextStyle get kDisplayLg => kDisplay;
m.TextStyle get kHeadlineLg => kHeadline;
m.TextStyle get kTitleMd => kSubtitle;
m.TextStyle get kBodyLg => kBody;
m.TextStyle get kLabelSm => kLabel;

ThemeData buildTheme(bool dark) {
  isDarkMode = dark;
  final base = dark ? LegacyColorSchemes.darkZinc() : LegacyColorSchemes.lightZinc();
  return ThemeData(
    colorScheme: base.copyWith(
      background: () => kBackground,
      foreground: () => kOnSurface,
      card: () => kSurfaceLow,
      cardForeground: () => kOnSurface,
      popover: () => kSurfaceHigh,
      popoverForeground: () => kOnSurface,
      primary: () => kSignal,
      primaryForeground: () => kInk,
      secondary: () => kSurfaceHigh,
      secondaryForeground: () => kOnSurface,
      muted: () => kSurfaceLow,
      mutedForeground: () => kOnSurfaceVariant,
      accent: () => kSurfaceHigh,
      accentForeground: () => kOnSurface,
      destructive: () => kDanger,
      destructiveForeground: () => kOnSurface,
      border: () => kHairline,
      input: () => kSurfaceHighest,
      ring: () => kSignal,
    ),
    radius: 0.75,
    scaling: 1,
    typography: const Typography.geist(),
  );
}

m.BoxDecoration get kPanelDecoration => m.BoxDecoration(
  color: kSurfaceLow,
  borderRadius: m.BorderRadius.circular(kRadiusMd),
  border: m.Border.all(color: kHairline, width: 1),
);

m.BoxDecoration get kPanelRaisedDecoration => m.BoxDecoration(
  color: kSurfaceHigh,
  borderRadius: m.BorderRadius.circular(kRadiusMd),
  border: m.Border.all(color: kHairline, width: 1),
);

m.BoxDecoration get kCardDecoration => kPanelDecoration;
m.BoxDecoration get kGlassDecoration => m.BoxDecoration(
  color: kSurfaceHigh.withValues(alpha: 0.72),
  borderRadius: m.BorderRadius.circular(kRadiusMd),
  border: m.Border.all(color: kHairline.withValues(alpha: 0.6), width: 1),
);

m.LinearGradient get kPrimaryGradient => m.LinearGradient(
  begin: m.Alignment.topLeft,
  end: m.Alignment.bottomRight,
  colors: [kSignal, m.Color.lerp(kSignal, kAmber, 0.35)!],
);
