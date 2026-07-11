import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../core/theme/app_theme.dart';

class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool haptic;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.haptic = true,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1.0,
        duration: kMotionFast,
        curve: kCurveSnap,
        child: AnimatedOpacity(
          opacity: widget.onTap == null ? 0.45 : 1.0,
          duration: kMotionFast,
          child: widget.child,
        ),
      ),
    );
  }
}

enum AppButtonVariant { filled, tonal, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      AppButtonVariant.filled => (kSignal, kInk, null),
      AppButtonVariant.tonal => (kSurfaceHigh, kOnSurface, kHairline),
      AppButtonVariant.ghost => (const Color(0x00000000), kOnSurfaceVariant, null),
      AppButtonVariant.danger => (kDanger.withValues(alpha: 0.12), kDanger, kDanger.withValues(alpha: 0.25)),
    };

    return Pressable(
      onTap: loading ? null : onTap,
      child: Container(
        height: height,
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: expand ? 20 : 24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(height / 2),
          border: border != null ? Border.all(color: border) : null,
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              )
            else ...[
              if (icon != null) ...[
                Icon(icon, size: 17, color: fg),
                const Gap(8),
              ],
              Text(label, style: kMono(12.5, weight: FontWeight.w600, letterSpacing: 1.2, color: fg)),
            ],
          ],
        ),
      ),
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool raised;
  final VoidCallback? onTap;

  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.raised = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      width: double.infinity,
      padding: padding,
      decoration: raised ? kPanelRaisedDecoration : kPanelDecoration,
      child: child,
    );
    if (onTap == null) return panel;
    return Pressable(onTap: onTap, pressedScale: 0.985, child: panel);
  }
}

class Eyebrow extends StatelessWidget {
  final String text;
  final Color? color;
  final Widget? trailing;

  const Eyebrow(this.text, {super.key, this.color, this.trailing});

  @override
  Widget build(BuildContext context) {
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color ?? kSignal, shape: BoxShape.circle),
        ),
        const Gap(8),
        Text(text.toUpperCase(), style: kLabel.copyWith(color: color ?? kOnSurfaceVariant)),
      ],
    );
    if (trailing == null) return label;
    return Row(children: [Expanded(child: label), trailing!]);
  }
}

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? caption;
  final Widget? trailing;

  const ScreenHeader({super.key, required this.title, this.caption, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: kHeadline.copyWith(fontSize: 26)),
              if (caption != null) ...[
                const Gap(6),
                Text(caption!, style: kCaption),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class IconSquare extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final VoidCallback? onTap;

  const IconSquare({super.key, required this.icon, this.color, this.size = 42, this.onTap});

  @override
  Widget build(BuildContext context) {
    final square = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: kSurfaceHigh,
        borderRadius: BorderRadius.circular(size / 3),
        border: Border.all(color: kHairline),
      ),
      child: Icon(icon, size: size * 0.44, color: color ?? kOnSurfaceVariant),
    );
    if (onTap == null) return square;
    return Pressable(onTap: onTap, pressedScale: 0.92, child: square);
  }
}

class Entrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration step;

  const Entrance({super.key, required this.child, this.index = 0, this.step = const Duration(milliseconds: 55)});

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: kMotionReveal);
    final curved = CurvedAnimation(parent: _c, curve: kCurveEmphasized);
    _fade = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(curved);
    Future.delayed(widget.step * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  const SegmentedTabs({super.key, required this.labels, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kSurfaceLow,
        borderRadius: BorderRadius.circular(kRadiusSm + 4),
        border: Border.all(color: kHairline),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == index;
          return Expanded(
            child: Pressable(
              onTap: () => onChanged(i),
              pressedScale: 0.96,
              child: AnimatedContainer(
                duration: kMotionBase,
                curve: kCurveSnap,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active ? kSurfaceHighest : const Color(0x00000000),
                  borderRadius: BorderRadius.circular(kRadiusSm),
                ),
                child: Center(
                  child: Text(
                    labels[i].toUpperCase(),
                    style: kMono(10.5, weight: FontWeight.w600, letterSpacing: 1.2,
                        color: active ? kOnSurface : kOnSurfaceFaint),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? accent;

  const TagChip({super.key, required this.label, this.selected = false, this.onTap, this.accent});

  @override
  Widget build(BuildContext context) {
    final a = accent ?? kSignal;
    final chip = AnimatedContainer(
      duration: kMotionBase,
      curve: kCurveSnap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: selected ? a.withValues(alpha: 0.14) : kSurfaceHigh,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: selected ? a : kHairline, width: selected ? 1.2 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected) ...[
            Icon(Icons.check_rounded, size: 14, color: a),
            const Gap(6),
          ],
          Text(
            label,
            style: kSans(13.5,
                weight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? kOnSurface : kOnSurfaceVariant),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return Pressable(onTap: onTap, pressedScale: 0.94, child: chip);
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color? accent;

  const StatCard({super.key, required this.label, required this.value, this.unit, this.accent});

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: kLabel.copyWith(fontSize: 9.5)),
          const Gap(10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(value, style: kMono(26, weight: FontWeight.w600, color: accent ?? kOnSurface)),
              ),
              if (unit != null) ...[
                const Gap(4),
                Text(unit!, style: kCaption.copyWith(fontSize: 11)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class ProgressTrack extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;

  const ProgressTrack({super.key, required this.value, this.color, this.height = 6});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: kSurfaceHighest,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
          duration: kMotionSlow,
          curve: kCurveEmphasized,
          builder: (context, v, _) => FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: v,
            child: Container(color: color ?? kSignal),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? caption;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.caption,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: kSurfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: kHairline),
            ),
            child: Icon(icon, size: 30, color: kOnSurfaceFaint),
          ),
          const Gap(18),
          Text(title, style: kTitle.copyWith(fontSize: 18)),
          if (caption != null) ...[
            const Gap(6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(caption!, style: kCaption, textAlign: TextAlign.center),
            ),
          ],
          if (actionLabel != null) ...[
            const Gap(20),
            AppButton(label: actionLabel!, onTap: onAction, expand: false, height: 44),
          ],
        ],
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  final String? message;
  const LoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: kSignal),
          ),
          if (message != null) ...[
            const Gap(14),
            Text(message!.toUpperCase(), style: kLabel),
          ],
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.sensors_off_rounded,
      title: 'Signal lost',
      caption: message,
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }
}
