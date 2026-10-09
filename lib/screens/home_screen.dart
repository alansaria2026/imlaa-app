import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/lam_lesson.dart';
import '../lesson/lam_lesson_pages.dart';
import '../lesson/lesson_screen.dart';
import '../theme.dart';
import '../utils/arabic.dart';

const _lamPageCount = 7;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير';
    if (h < 18) return 'نهارك سعيد';
    return 'مساء الخير';
  }

  void _openLesson(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lessonId: lamLessonId,
          title: lamLessonTitle,
          pages: buildLamLessonPages(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final done = app.donePagesOf(lamLessonId).clamp(0, _lamPageCount);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()} 👋',
                            style: t.bodyLarge?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'هيا نتعلم الإملاء',
                            style: t.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'الإعدادات',
                      onPressed: () => _showSettings(context),
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _HeroCard(
                  points: app.points,
                  done: done,
                  total: _lamPageCount,
                  onStart: () => _openLesson(context),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'الدروس',
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.list(
                children: [
                  _LessonTile(
                    emoji: '🌙',
                    color: AppColors.moonSoft,
                    title: lamLessonTitle,
                    subtitle:
                        '${arDigits(done)} من ${arDigits(_lamPageCount)} صفحات',
                    progress: done / _lamPageCount,
                    onTap: () => _openLesson(context),
                  ),
                  const _LessonTile(
                    emoji: '📝',
                    color: AppColors.sandSoft,
                    title: 'التاء المربوطة والتاء المفتوحة',
                  ),
                  const _LessonTile(
                    emoji: '✍️',
                    color: AppColors.primarySoft,
                    title: 'همزة الوصل وهمزة القطع',
                  ),
                  const _LessonTile(
                    emoji: '🔤',
                    color: Color(0xFFF3E1E6),
                    title: 'الألف اللينة',
                  ),
                  const _LessonTile(
                    emoji: '📚',
                    color: Color(0xFFE6EEDB),
                    title: 'الهمزة المتوسطة والمتطرفة',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final app = AppScope.of(context);
        final t = Theme.of(context).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'الإعدادات',
                  textAlign: TextAlign.center,
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                Text(
                  'سرعة النطق',
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.slow_motion_video_rounded,
                      color: AppColors.muted,
                    ),
                    Expanded(
                      child: Slider(
                        value: app.speechRate,
                        min: 0.2,
                        max: 0.7,
                        divisions: 10,
                        onChanged: app.setSpeechRate,
                      ),
                    ),
                    const Icon(Icons.speed_rounded, color: AppColors.muted),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('إعادة ضبط التقدم'),
                        content: const Text(
                          'سيتم حذف النقاط والصفحات المنجزة. هل أنت متأكد؟',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('حذف'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) await app.reset();
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('إعادة ضبط التقدم'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.points,
    required this.done,
    required this.total,
    required this.onStart,
  });

  final int points;
  final int done;
  final int total;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFF4A8A86), Color(0xFF346B69)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.sand,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${arDigits(points)} نقطة',
                      style: t.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text('🌙☀️', style: TextStyle(fontSize: 26)),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            done == 0 ? 'ابدأ درسك الأول' : 'تابع من حيث توقفت',
            style: t.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lamLessonTitle,
            style: t.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: done / total,
              minHeight: 8,
              color: AppColors.sand,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
            ),
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(done == 0 ? 'ابدأ الآن' : 'متابعة'),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.emoji,
    required this.color,
    required this.title,
    this.subtitle,
    this.progress,
    this.onTap,
  });

  final String emoji;
  final Color color;
  final String title;
  final String? subtitle;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final locked = onTap == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Opacity(
              opacity: locked ? 0.6 : 1,
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: t.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (progress != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              color: AppColors.primary,
                              backgroundColor: AppColors.line,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          subtitle ?? 'قريبًا',
                          style: t.bodySmall?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    locked
                        ? Icons.lock_outline_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: locked ? 22 : 16,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
