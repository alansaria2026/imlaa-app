import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../utils/arabic.dart';
import 'mascot.dart';

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

/// محتوى الصفحة: السؤال بخط النسخ وبحجم كبير، ثم التمرين.
/// الوسم (مثال، تحدي...) اختياري وصغير.
class PageCard extends StatelessWidget {
  const PageCard({
    super.key,
    this.tag,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String? tag;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (tag != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              tag!,
              style: t.labelMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTheme.word(26).copyWith(height: 1.5),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
        const SizedBox(height: 16),
        child,
      ],
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
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: moon ? AppColors.moon : AppColors.sun),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: moon ? AppColors.moon : AppColors.sun,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.al, width: 1.2),
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
    FeedbackTone.success => (AppColors.success, Icons.check_rounded),
    FeedbackTone.error => (AppColors.error, Icons.close_rounded),
    FeedbackTone.hint => (AppColors.primary, Icons.help_outline_rounded),
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
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darken(widget.color),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
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

/// رسالة إكمال مشتركة لصفحات التمارين.
class PageDoneMessage extends StatelessWidget {
  const PageDoneMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Mascot(size: 96, mood: MascotMood.happy),
          const SizedBox(height: 14),
          Text(
            'أحسنت! أنهيت هذا التمرين',
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'اضغط «التالي» للمتابعة',
            style: t.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
