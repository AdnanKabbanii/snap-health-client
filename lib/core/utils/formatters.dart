import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../theme/app_theme.dart';

Color scoreToColor(double score) {
  if (score >= 7) return kSignal;
  if (score >= 4) return kAmber;
  return kDanger;
}

String scoreToLabel(double score) {
  if (score >= 8) return 'OPTIMAL';
  if (score >= 7) return 'SOLID';
  if (score >= 5) return 'MIXED';
  if (score >= 3) return 'WEAK';
  return 'AVOID';
}

String scoreToVerdict(double score) {
  if (score >= 8) return 'Optimal choice';
  if (score >= 7) return 'Solid choice';
  if (score >= 5) return 'Mixed signals';
  if (score >= 3) return 'Weak choice';
  return 'Best avoided';
}

String timeAgo(String isoDate) {
  final date = DateTime.parse(isoDate);
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${date.day}/${date.month}/${date.year}';
}

String prettyKey(String key) {
  if (key.isEmpty) return key;
  final words = key.replaceAll('_', ' ');
  return words[0].toUpperCase() + words.substring(1);
}
