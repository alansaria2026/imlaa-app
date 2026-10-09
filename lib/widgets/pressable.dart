import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// سطح ثلاثي الأبعاد بحافة سفلية أغمق، ينضغط للأسفل عند اللمس.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.color = AppColors.surface,
    this.edgeColor,
    this.borderColor,
    this.radius = 18,
    this.depth = 4,
    this.padding = EdgeInsets.zero,
    this.shape = BoxShape.rectangle,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;

  /// لون الحافة السفلية؛ افتراضيًا نسخة أغمق من [color].
  final Color? edgeColor;
  final Color? borderColor;
  final double radius;
  final double depth;
  final EdgeInsetsGeometry padding;
  final BoxShape shape;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null || _down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final edge = widget.edgeColor ?? AppColors.darken(widget.color);
    final offset = _down ? widget.depth : 0.0;
    final circle = widget.shape == BoxShape.circle;
    final radius = circle ? null : BorderRadius.circular(widget.radius);

    return Semantics(
      button: widget.onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapCancel: () => _set(false),
        onTapUp: (_) => _set(false),
        onTap: widget.onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                widget.onTap!();
              },
        child: Padding(
          padding: EdgeInsets.only(top: offset),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 70),
            decoration: BoxDecoration(
              color: edge,
              shape: widget.shape,
              borderRadius: radius,
            ),
            padding: EdgeInsets.only(bottom: widget.depth - offset),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.color,
                shape: widget.shape,
                borderRadius: radius,
                border: widget.borderColor == null
                    ? null
                    : Border.all(color: widget.borderColor!, width: 2),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

enum AppButtonStyle { primary, secondary, outline, danger }

/// زر رئيسي عريض بأسلوب ثلاثي الأبعاد.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.style = AppButtonStyle.primary,
    this.enabled = true,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final AppButtonStyle style;

  /// زر يبدو معطّلًا لكنه يبقى قابلًا للضغط (لإظهار سبب التعطيل).
  final bool enabled;
  final double height;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, edge, border) = !enabled
        ? (AppColors.line, AppColors.muted, AppColors.lineDark, null)
        : switch (style) {
            AppButtonStyle.primary => (
              AppColors.primary,
              Colors.white,
              AppColors.primaryDark,
              null,
            ),
            AppButtonStyle.secondary => (
              AppColors.sand,
              Colors.white,
              AppColors.sandDark,
              null,
            ),
            AppButtonStyle.danger => (
              AppColors.error,
              Colors.white,
              AppColors.errorDark,
              null,
            ),
            AppButtonStyle.outline => (
              AppColors.surface,
              AppColors.primary,
              AppColors.line,
              AppColors.line,
            ),
          };
    return Pressable(
      onTap: onTap,
      color: bg,
      edgeColor: edge,
      borderColor: border,
      radius: 16,
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, color: fg, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}

/// زر دائري بأيقونة (استمع، تلميح...).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 52,
    this.color = AppColors.surface,
    this.iconColor = AppColors.primary,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color color;
  final Color iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Pressable(
      onTap: onTap,
      color: color,
      edgeColor: color == AppColors.surface ? AppColors.line : null,
      borderColor: color == AppColors.surface ? AppColors.line : null,
      shape: BoxShape.circle,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, color: iconColor, size: size * 0.48),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

/// شريط تقدم سميك بلمعة علوية.
class ChunkyProgress extends StatelessWidget {
  const ChunkyProgress({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.height = 16,
    this.track = AppColors.line,
  });

  final double value;
  final Color color;
  final double height;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Container(
        height: height,
        decoration: BoxDecoration(
          color: track,
          borderRadius: BorderRadius.circular(height),
        ),
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: v,
          heightFactor: 1,
          child: v <= 0
              ? const SizedBox.shrink()
              : Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(height),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    height * 0.5,
                    height * 0.22,
                    height * 0.5,
                    0,
                  ),
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: height * 0.22,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(height),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
