import 'package:flutter/material.dart';

import '../app_state.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/pressable.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  Future<void> _confirmReset(BuildContext context, AppState app) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('إعادة ضبط التقدم'),
        content: const Text(
          'سيتم حذف النقاط والمحطات المنجزة والأيام المتتالية. هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok == true) await app.reset();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          'الإعدادات',
          style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        _Section(
          icon: Icons.record_voice_over_rounded,
          title: 'سرعة النطق',
          child: Column(
            children: [
              Row(
                children: [
                  const Text('🐢', style: TextStyle(fontSize: 20)),
                  Expanded(
                    child: Slider(
                      value: app.speechRate,
                      min: 0.2,
                      max: 0.7,
                      divisions: 10,
                      onChanged: app.setSpeechRate,
                    ),
                  ),
                  const Text('🐇', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'جرّب الصوت',
                icon: Icons.volume_up_rounded,
                style: AppButtonStyle.outline,
                height: 48,
                onTap: () => Speaker.instance.speak(
                  'الشَّمسُ مُشرقةٌ والقمرُ جميل',
                  rate: app.speechRate,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Section(
          icon: Icons.restart_alt_rounded,
          title: 'التقدم',
          child: AppButton(
            label: 'إعادة ضبط التقدم',
            style: AppButtonStyle.danger,
            height: 48,
            onTap: () => _confirmReset(context, app),
          ),
        ),
        const SizedBox(height: 14),
        _Section(
          icon: Icons.info_outline_rounded,
          title: 'عن التطبيق',
          child: Text(
            'إملائي — تطبيق تعليمي لمسابقات الإملاء العربي.\n'
            'الخطوط: Tajawal و Noto Naskh Arabic (رخصة SIL Open Font License).',
            style: t.bodyMedium?.copyWith(color: AppColors.muted, height: 1.6),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
