import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/lam_lesson.dart';
import '../theme.dart';
import '../utils/arabic.dart';
import '../widgets/mascot.dart';
import '../widgets/pressable.dart';
import 'lam_lesson_pages.dart';
import 'lesson_screen.dart';

class LessonCompleteScreen extends StatefulWidget {
  const LessonCompleteScreen({
    super.key,
    required this.title,
    required this.earned,
  });

  final String title;
  final int earned;

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final _confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final app = AppScope.of(context);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.3, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: const Mascot(size: 170, mood: MascotMood.happy),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'أحسنت! أتممت الدرس',
                    style: t.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.sandDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: t.titleMedium?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _ResultTile(
                          label: 'النقاط المكتسبة',
                          value: '+${arDigits(widget.earned)}',
                          emoji: '⭐',
                          color: AppColors.sand,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ResultTile(
                          label: 'أيام متتالية',
                          value: arDigits(app.streak),
                          emoji: '🔥',
                          color: AppColors.streak,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'الصفحة الرئيسية',
                    icon: Icons.home_rounded,
                    onTap: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'إعادة الدرس',
                    icon: Icons.replay_rounded,
                    style: AppButtonStyle.outline,
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(
                          lessonId: lamLessonId,
                          title: lamLessonTitle,
                          pages: buildLamLessonPages(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _confetti,
              builder: (context, _) => CustomPaint(
                size: MediaQuery.sizeOf(context),
                painter: _ConfettiPainter(_confetti.value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  });

  final String label;
  final String value;
  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              label,
              style: t.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: t.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darken(color, 0.1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t;

  static const _colors = [
    AppColors.primary,
    AppColors.sand,
    AppColors.moon,
    AppColors.error,
    AppColors.success,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1) return;
    final rnd = math.Random(7);
    final paint = Paint();
    for (var i = 0; i < 70; i++) {
      final x0 = rnd.nextDouble() * size.width;
      final speed = 0.6 + rnd.nextDouble() * 0.8;
      final drift = (rnd.nextDouble() - 0.5) * 80;
      final y = -20 + t * speed * (size.height + 60);
      final x = x0 + math.sin(t * 6 + i) * 14 + drift * t;
      paint.color = _colors[i % _colors.length].withValues(
        alpha: (1 - t).clamp(0, 1) * 0.9 + 0.1,
      );
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 8 + i);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-4, -7, 8, 14),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
