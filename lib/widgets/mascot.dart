import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

enum MascotMood { happy, thinking, sad }

/// «قلم» تميمة التطبيق يكتب الإملاء، مرسوم بالكامل بالشيفرة مع حركة كتابة خفيفة.
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
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // احترام إعداد «تقليل الحركة» في الجهاز.
    if (widget.animate && !MediaQuery.disableAnimationsOf(context)) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c
        ..stop()
        ..value = 0;
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
          // تمايل حول رأس القلم كأنه يكتب.
          // يبدأ ويتوقف قائمًا (الزاوية صفر عند القيمة صفر).
          return Transform.rotate(
            angle: math.sin(_c.value * 2 * math.pi) * 0.06,
            alignment: const Alignment(0, 0.78),
            child: child,
          );
        },
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _PencilPainter(widget.mood),
        ),
      ),
    );
  }
}

class _PencilPainter extends CustomPainter {
  _PencilPainter(this.mood);
  final MascotMood mood;

  static const _wood = Color(0xFFF4DDB8);
  static const _eraser = Color(0xFFF2A7A0);
  static const _eraserDark = Color(0xFFD9867F);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    Offset p(double x, double y) => Offset(x * s, y * s);
    Paint fill(Color c) => Paint()..color = c;
    Paint stroke(Color c, double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = c;

    // الظل.
    canvas.drawOval(
      Rect.fromCenter(center: p(.55, .95), width: .62 * s, height: .05 * s),
      fill(AppColors.ink.withValues(alpha: .08)),
    );

    // حرف «ض» يكتبه القلم؛ رأس القلم عند نهاية ذيل الحرف.
    final letter = TextPainter(
      text: TextSpan(
        text: 'ض',
        style: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: .3 * s,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          height: 1,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    final baseline = letter.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    letter.paint(canvas, Offset(.54 * s, .88 * s - baseline));

    // الذراعان.
    final arm = stroke(AppColors.sandDark, .032);
    if (mood == MascotMood.happy) {
      canvas.drawLine(p(.31, .5), p(.17, .36), arm);
      canvas.drawLine(p(.69, .5), p(.83, .36), arm);
    } else if (mood == MascotMood.thinking) {
      canvas.drawLine(p(.31, .52), p(.22, .6), arm);
      canvas.drawLine(p(.69, .5), p(.6, .47), arm);
    } else {
      canvas.drawLine(p(.31, .5), p(.24, .62), arm);
      canvas.drawLine(p(.69, .5), p(.76, .62), arm);
    }

    // الممحاة.
    final eraser = RRect.fromRectAndCorners(
      Rect.fromLTRB(.32 * s, .03 * s, .68 * s, .15 * s),
      topLeft: Radius.circular(.08 * s),
      topRight: Radius.circular(.08 * s),
    );
    canvas.drawRRect(eraser, fill(_eraser));
    canvas.drawRect(
      Rect.fromLTRB(.32 * s, .12 * s, .68 * s, .15 * s),
      fill(_eraserDark),
    );

    // الحلقة المعدنية.
    canvas.drawRect(
      Rect.fromLTRB(.31 * s, .14 * s, .69 * s, .21 * s),
      fill(AppColors.primaryDark),
    );
    for (final y in [.165, .19]) {
      canvas.drawLine(
        p(.32, y),
        p(.68, y),
        stroke(AppColors.primarySoft.withValues(alpha: .6), .01),
      );
    }

    // الجسم بأوجهه.
    canvas.drawRect(
      Rect.fromLTRB(.32 * s, .21 * s, .68 * s, .66 * s),
      fill(AppColors.sand),
    );
    canvas.drawRect(
      Rect.fromLTRB(.56 * s, .21 * s, .68 * s, .66 * s),
      fill(AppColors.sandDark.withValues(alpha: .45)),
    );
    canvas.drawRect(
      Rect.fromLTRB(.32 * s, .21 * s, .37 * s, .66 * s),
      fill(Colors.white.withValues(alpha: .25)),
    );

    // البري الخشبي ورأس الرصاص.
    final cone = Path()
      ..moveTo(.32 * s, .66 * s)
      ..lineTo(.68 * s, .66 * s)
      ..lineTo(.5 * s, .89 * s)
      ..close();
    canvas.drawPath(cone, fill(_wood));
    // حافة البري المتموجة.
    final scallop = Path()..moveTo(.32 * s, .66 * s);
    for (var i = 0; i < 3; i++) {
      final x = .32 + i * .12;
      scallop.quadraticBezierTo((x + .06) * s, .7 * s, (x + .12) * s, .66 * s);
    }
    canvas.drawPath(scallop..close(), fill(AppColors.sand));
    final tip = Path()
      ..moveTo(.455 * s, .83 * s)
      ..lineTo(.545 * s, .83 * s)
      ..lineTo(.5 * s, .9 * s)
      ..close();
    canvas.drawPath(tip, fill(AppColors.ink));

    // الوجنتان.
    for (final x in [.39, .61]) {
      canvas.drawCircle(
        p(x, .47),
        .032 * s,
        fill(_eraser.withValues(alpha: .8)),
      );
    }

    // العينان.
    for (final x in [.42, .58]) {
      switch (mood) {
        case MascotMood.happy:
          canvas.drawArc(
            Rect.fromCenter(center: p(x, .37), width: .08 * s, height: .06 * s),
            math.pi,
            math.pi,
            false,
            stroke(AppColors.ink, .022),
          );
        case MascotMood.thinking:
        case MascotMood.sad:
          canvas.drawCircle(p(x, .365), .052 * s, fill(Colors.white));
          final look = mood == MascotMood.thinking ? -.012 : .012;
          canvas.drawCircle(
            p(x + .01, .365 + look),
            .028 * s,
            fill(AppColors.ink),
          );
          canvas.drawCircle(
            p(x + .02, .355 + look),
            .009 * s,
            fill(Colors.white),
          );
      }
    }
    if (mood == MascotMood.sad) {
      canvas.drawLine(
        p(.37, .3),
        p(.45, .32),
        stroke(AppColors.sandDark, .016),
      );
      canvas.drawLine(
        p(.63, .3),
        p(.55, .32),
        stroke(AppColors.sandDark, .016),
      );
    }

    // الفم.
    final mouth = stroke(AppColors.ink, .02);
    switch (mood) {
      case MascotMood.happy:
        canvas.drawArc(
          Rect.fromCenter(center: p(.5, .45), width: .11 * s, height: .08 * s),
          .15,
          math.pi - .3,
          false,
          mouth,
        );
      case MascotMood.thinking:
        canvas.drawCircle(p(.52, .48), .016 * s, mouth);
      case MascotMood.sad:
        canvas.drawArc(
          Rect.fromCenter(center: p(.5, .5), width: .1 * s, height: .06 * s),
          math.pi + .25,
          math.pi - .5,
          false,
          mouth,
        );
    }
  }

  @override
  bool shouldRepaint(_PencilPainter old) => old.mood != mood;
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
