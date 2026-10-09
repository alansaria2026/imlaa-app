import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import '../utils/arabic.dart';
import '../widgets/mascot.dart';
import '../widgets/pressable.dart';

class _Badge {
  const _Badge(this.emoji, this.title, this.goal, this.progress);
  final String emoji;
  final String title;
  final String goal;

  /// التقدم من ٠ إلى ١.
  final double progress;
  bool get unlocked => progress >= 1;
}

/// إنجازاتي: إحصاءات وشارات.
class AchievementsTab extends StatelessWidget {
  const AchievementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    double ratio(num v, num goal) => (v / goal).clamp(0, 1).toDouble();
    final badges = [
      _Badge('🌱', 'البداية', 'أنجز أول محطة', ratio(app.totalDonePages, 1)),
      _Badge('⭐', 'جامع النقاط', 'اجمع ١٠٠ نقطة', ratio(app.points, 100)),
      _Badge('🔥', 'مثابر', 'تعلّم ٣ أيام متتالية', ratio(app.streak, 3)),
      _Badge(
        '🏆',
        'بطل اللام',
        'أتمم درس اللام القمرية والشمسية',
        ratio(app.lessonsCompleted, 1),
      ),
      _Badge('🌟', 'نجم الإملاء', 'اجمع ٥٠٠ نقطة', ratio(app.points, 500)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          children: [
            const Mascot(size: 76, mood: MascotMood.happy),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إنجازاتي',
                    style: t.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    app.points == 0
                        ? 'ابدأ أول محطة لتجمع نقاطك!'
                        : 'رائع! استمر في التعلّم كل يوم',
                    style: t.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            _StatTile('🔥', arDigits(app.streak), 'أيام متتالية'),
            _StatTile('⭐', arDigits(app.points), 'مجموع النقاط'),
            _StatTile('✅', arDigits(app.totalDonePages), 'محطات منجزة'),
            _StatTile('🏆', arDigits(app.lessonsCompleted), 'دروس مكتملة'),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'الشارات',
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        for (final b in badges) _BadgeTile(badge: b),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.emoji, this.value, this.label);
  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line, width: 2),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});
  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final on = badge.unlocked;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: on ? AppColors.sand : AppColors.line,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? AppColors.sandSoft : AppColors.locked,
                shape: BoxShape.circle,
              ),
              child: Opacity(
                opacity: on ? 1 : 0.4,
                child: Text(badge.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.title,
                    style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    badge.goal,
                    style: t.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  ChunkyProgress(
                    value: badge.progress,
                    height: 10,
                    color: on ? AppColors.sand : AppColors.primary,
                  ),
                ],
              ),
            ),
            if (on) ...[
              const SizedBox(width: 10),
              const Icon(Icons.verified_rounded, color: AppColors.sand),
            ],
          ],
        ),
      ),
    );
  }
}
