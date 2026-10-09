import 'package:flutter/material.dart';

import '../data/lam_lesson.dart';
import '../theme.dart';
import '../utils/arabic.dart';
import 'lam_lesson_pages.dart';
import 'lesson_screen.dart';

class LessonCompleteScreen extends StatelessWidget {
  const LessonCompleteScreen({
    super.key,
    required this.title,
    required this.earned,
  });

  final String title;
  final int earned;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 150,
                  height: 150,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.sandSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🏆', style: TextStyle(fontSize: 76)),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'أحسنت! أتممت الدرس',
                style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: t.titleMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.sand,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '+${arDigits(earned)} نقطة',
                      style: t.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF9A6A1E),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('الصفحة الرئيسية'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(
                        lessonId: lamLessonId,
                        title: lamLessonTitle,
                        pages: buildLamLessonPages(),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('إعادة الدرس'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
