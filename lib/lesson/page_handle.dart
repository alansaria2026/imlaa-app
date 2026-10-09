import 'package:flutter/widgets.dart';

/// قناة بين صفحة الدرس وشريط الأدوات: تلميح، استمع، مؤشر التقدم، الإكمال.
class PageHandle extends ChangeNotifier {
  VoidCallback? onHint;
  VoidCallback? onListen;

  int done = 0;
  int total = 0;
  bool complete = false;

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
    required this.tag,
    required this.builder,
    this.needsCompletion = true,
  });

  final String tag;
  final bool needsCompletion;
  final Widget Function(PageHandle handle) builder;
}
