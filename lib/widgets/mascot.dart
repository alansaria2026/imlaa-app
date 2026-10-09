import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

enum MascotMood { happy, thinking, sad }

/// «بومة» تميمة التطبيق، مرسومة بالكامل بالشيفرة مع حركة تنفّس خفيفة.
class Mascot extends StatefulWidget {
  const Mascot({
    super.key,
    this.size = 120,
    this.mood = MascotMood.thinking,
    this.animate = true,
  });

  final double size;
  final MascotMood mood;
  final bool animate;

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // احترام إعداد «تقليل الحركة» في الجهاز.
    if (widget.animate && !MediaQuery.disableAnimationsOf(context)) {
      if (!_c.isAnimating) _c.repeat(reverse: true);
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_c.value);
          return Transform.translate(
            offset: Offset(0, -widget.size * 0.03 * t),
            child: child,
          );
        },
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _OwlPainter(widget.mood),
        ),
      ),
    );
  }
}

class _OwlPainter extends CustomPainter {
  _OwlPainter(this.mood);
  final MascotMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    Offset p(double x, double y) => Offset(x * s, y * s);
    final fill = Paint()..style = PaintingStyle.fill;

    // الظل.
    canvas.drawOval(
      Rect.fromCenter(center: p(.5, .97), width: .56 * s, height: .06 * s),
      fill..color = AppColors.ink.withValues(alpha: .08),
    );

    // الخصلتان.
    for (final dir in [-1, 1]) {
      final path = Path()
        ..moveTo(.5 * s + dir * .2 * s, .3 * s)
        ..lineTo(.5 * s + dir * .34 * s, .14 * s)
        ..lineTo(.5 * s + dir * .36 * s, .36 * s)
        ..close();
      canvas.drawPath(path, fill..color = AppColors.primaryDark);
    }

    // الجسم.
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(.14 * s, .2 * s, .86 * s, .94 * s),
      Radius.circular(.34 * s),
    );
    canvas.drawRRect(
      body.shift(Offset(0, .025 * s)),
      fill..color = AppColors.primaryDark,
    );
    canvas.drawRRect(body, fill..color = AppColors.primary);

    // الجناحان.
    for (final dir in [-1, 1]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: p(.5 + dir * .33, .66),
          width: .16 * s,
          height: .32 * s,
        ),
        fill..color = AppColors.primaryDark,
      );
    }

    // البطن بنقوش ريش.
    canvas.drawOval(
      Rect.fromLTRB(.3 * s, .52 * s, .7 * s, .92 * s),
      fill..color = AppColors.primarySoft,
    );
    final feather = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .018 * s
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primary.withValues(alpha: .35);
    for (final (x, y) in [(.42, .68), (.58, .68), (.5, .78)]) {
      canvas.drawArc(
        Rect.fromCenter(center: p(x, y), width: .1 * s, height: .07 * s),
        .2,
        math.pi - .4,
        false,
        feather,
      );
    }

    // الوجنتان.
    for (final x in [.25, .75]) {
      canvas.drawCircle(
        p(x, .55),
        .045 * s,
        fill..color = const Color(0xFFF2A7A0).withValues(alpha: .7),
      );
    }

    // العينان.
    for (final x in [.37, .63]) {
      canvas.drawCircle(p(x, .44), .135 * s, fill..color = Colors.white);
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .02 * s
        ..color = AppColors.primaryDark;
      canvas.drawCircle(p(x, .44), .135 * s, ring);
      switch (mood) {
        case MascotMood.happy:
          canvas.drawArc(
            Rect.fromCenter(center: p(x, .47), width: .14 * s, height: .1 * s),
            math.pi,
            math.pi,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = .03 * s
              ..strokeCap = StrokeCap.round
              ..color = AppColors.ink,
          );
        case MascotMood.thinking:
        case MascotMood.sad:
          final look = mood == MascotMood.thinking ? -.025 : .02;
          canvas.drawCircle(
            p(x + .015, .44 + look),
            .065 * s,
            fill..color = AppColors.ink,
          );
          canvas.drawCircle(
            p(x + .035, .42 + look),
            .02 * s,
            fill..color = Colors.white,
          );
      }
    }
    if (mood == MascotMood.sad) {
      final brow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .025 * s
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primaryDark;
      canvas.drawLine(p(.28, .29), p(.42, .32), brow);
      canvas.drawLine(p(.72, .29), p(.58, .32), brow);
    }

    // المنقار.
    final beak = Path()
      ..moveTo(.45 * s, .55 * s)
      ..lineTo(.55 * s, .55 * s)
      ..lineTo(.5 * s, .63 * s)
      ..close();
    canvas.drawPath(beak, fill..color = AppColors.sand);

    // القدمان.
    for (final x in [.4, .6]) {
      canvas.drawOval(
        Rect.fromCenter(center: p(x, .94), width: .12 * s, height: .06 * s),
        fill..color = AppColors.sandDark,
      );
    }

    // قبعة التخرج.
    final cap = Path()
      ..moveTo(.5 * s, .07 * s)
      ..lineTo(.78 * s, .17 * s)
      ..lineTo(.5 * s, .27 * s)
      ..lineTo(.22 * s, .17 * s)
      ..close();
    canvas.drawRect(
      Rect.fromLTRB(.36 * s, .17 * s, .64 * s, .27 * s),
      fill..color = const Color(0xFF2B3A42),
    );
    canvas.drawPath(cap, fill..color = AppColors.ink);
    final tassel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .018 * s
      ..strokeCap = StrokeCap.round
      ..color = AppColors.sand;
    canvas.drawLine(p(.5, .17), p(.74, .2), tassel);
    canvas.drawLine(p(.74, .2), p(.74, .32), tassel);
    canvas.drawCircle(p(.74, .33), .025 * s, fill..color = AppColors.sand);
  }

  @override
  bool shouldRepaint(_OwlPainter old) => old.mood != mood;
}

/// فقاعة كلام بجانب التميمة.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line, width: 2),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
