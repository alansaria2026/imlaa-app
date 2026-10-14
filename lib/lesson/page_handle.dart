import 'package:flutter/widgets.dart';

/// قناة بين صفحة الدرس وهيكلها: القائمة (استمع، مساعدة)، زر «التالي»،
/// مؤشر النتيجة، الإكمال.
class PageHandle extends ChangeNotifier {
  VoidCallback? onHint;
  VoidCallback? onListen;

  /// تصحيح الإجابات الحالية؛ يستدعيه زر «التالي» قبل إكمال الصفحة.
  VoidCallback? onSubmit;

  /// يُستدعى عند ظهور الصفحة (لتشغيل الصوت تلقائيًا مثلًا).
  VoidCallback? onEnter;

  /// يُستدعى بعد فتح القاعدة من القائمة (لتغيير الكلمات مثلًا).
  VoidCallback? onRuleOpened;

  /// ينتقل إلى الصفحة التالية كزر «التالي»؛ يضبطه هيكل الدرس.
  VoidCallback? next;

  int done = 0;
  int total = 0;
  bool complete = false;

  /// مؤشر عكسي (٠–١٠٠) يبدأ ممتلئًا وينقص مع الأخطاء؛ null إن لم يُستخدم.
  int? level;

  void setLevel(int value) {
    level = value;
    notifyListeners();
  }

  void setProgress(int done, int total) {
    this.done = done;
    this.total = total;
    notifyListeners();
  }

  void markComplete() {
    if (complete) return;
    complete = true;
    notifyListeners();
  }
}

class LessonPageSpec {
  const LessonPageSpec({
    this.tag,
    required this.title,
    required this.emoji,
    required this.builder,
    this.needsCompletion = true,
    this.rule,
    this.centered = false,
  });

  /// المحتوى في وسط الشاشة عموديًا إن اتسع له (تمارين «اختر الإجابة»).
  final bool centered;

  /// محتوى نافذة «القاعدة» لهذه الصفحة؛ null لقاعدة اللام القمرية والشمسية.
  final Widget? rule;

  final String? tag;

  /// اسم المحطة وأيقونتها في مسار التعلّم.
  final String title;
  final String emoji;
  final bool needsCompletion;
  final Widget Function(PageHandle handle) builder;
}
