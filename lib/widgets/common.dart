import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../utils/arabic.dart';

/// نص عربي يميّز (الـ) في بداية كل كلمة باللون الأحمر.
class AlText extends StatelessWidget {
  const AlText(
    this.text, {
    super.key,
    this.size = 28,
    this.color = AppColors.ink,
    this.highlight = true,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final double size;
  final Color color;
  final bool highlight;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final base = AppTheme.word(size, color: color);
    final spans = <InlineSpan>[];
    final words = text.split(' ');
    for (var i = 0; i < words.length; i++) {
      final w = words[i];
      final cut = highlight ? alPrefixLength(w) : 0;
      if (cut > 0) {
        spans.add(
          TextSpan(
            text: w.substring(0, cut),
            style: const TextStyle(color: AppColors.al),
          ),
        );
      }
      spans.add(TextSpan(text: w.substring(cut)));
      if (i < words.length - 1) spans.add(const TextSpan(text: ' '));
    }
    return Text.rich(
      TextSpan(children: spans),
      style: base,
      textAlign: textAlign,
    );
  }
}

/// بطاقة الصفحة مع وسم في الزاوية (مثال، تطبيق، تحدي...).
class PageCard extends StatelessWidget {
  const PageCard({
    super.key,
    required this.tag,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String tag;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: t.bodyMedium?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sandSoft,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  tag,
                  style: t.labelLarge?.copyWith(
                    color: const Color(0xFF9A6A1E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

/// شارة نوع اللام.
class LamChip extends StatelessWidget {
  const LamChip(this.type, {super.key, this.dense = false});

  final LamType type;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final moon = type == LamType.moon;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 12,
        vertical: dense ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: moon ? AppColors.moonSoft : AppColors.sunSoft,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(moon ? '🌙' : '☀️', style: TextStyle(fontSize: dense ? 11 : 14)),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: moon ? AppColors.moon : const Color(0xFF9A6A1E),
            ),
          ),
        ],
      ),
    );
  }
}

/// مربع (الـ) الأحمر المستخدم في المعادلات.
class AlBox extends StatelessWidget {
  const AlBox({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.al.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('الـ', style: AppTheme.word(size, color: AppColors.al)),
    );
  }
}

enum FeedbackTone { success, error, hint }

OverlayEntry? _toast;

/// رسالة قصيرة أعلى الشاشة لا تحجب اللمس (حتى لا تغطي لوحة المفاتيح).
void showFeedback(
  BuildContext context,
  String message, {
  FeedbackTone tone = FeedbackTone.success,
}) {
  switch (tone) {
    case FeedbackTone.success:
      HapticFeedback.lightImpact();
    case FeedbackTone.error:
      HapticFeedback.mediumImpact();
    case FeedbackTone.hint:
      HapticFeedback.selectionClick();
  }
  final (color, icon) = switch (tone) {
    FeedbackTone.success => (AppColors.success, Icons.check_circle_rounded),
    FeedbackTone.error => (AppColors.error, Icons.info_rounded),
    FeedbackTone.hint => (AppColors.primary, Icons.lightbulb_rounded),
  };
  hideFeedback();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Toast(
      color: color,
      icon: icon,
      message: message,
      duration: Duration(seconds: tone == FeedbackTone.hint ? 4 : 2),
      onDone: () {
        if (_toast == entry) hideFeedback();
      },
    ),
  );
  _toast = entry;
  Overlay.of(context, rootOverlay: true).insert(entry);
}

void hideFeedback() {
  _toast?.remove();
  _toast = null;
}

class _Toast extends StatefulWidget {
  const _Toast({
    required this.color,
    required this.icon,
    required this.message,
    required this.duration,
    required this.onDone,
  });

  final Color color;
  final IconData icon;
  final String message;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void initState() {
    super.initState();
    _run();
  }

  Timer? _timer;

  Future<void> _run() async {
    await _c.forward();
    if (!mounted) return;
    _timer = Timer(widget.duration, () async {
      await _c.reverse();
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 8;
    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _c,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, -0.4),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut)),
            child: Material(
              color: widget.color,
              elevation: 6,
              shadowColor: AppColors.ink.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// اهتزاز أفقي خفيف عند الخطأ.
class ShakeOnChange extends StatefulWidget {
  const ShakeOnChange({super.key, required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  State<ShakeOnChange> createState() => _ShakeOnChangeState();
}

class _ShakeOnChangeState extends State<ShakeOnChange>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(ShakeOnChange old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final v = _c.value;
        final dx = math.sin(v * math.pi * 6) * 10 * (1 - v);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
