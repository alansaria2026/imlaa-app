import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../services/speaker.dart';
import '../../widgets/common.dart';
import '../page_handle.dart';
import '../rule_content.dart';

/// صفحة «مثال وقاعدة»: المحتوى، و«استمع» ينطق [speech] (أو [speechAll]
/// متتالية)، و«مساعدة» تعرض [hint] أو [hintContent]. لا تمرين فيها.
LessonPageSpec examplePage({
  required String title,
  required String emoji,
  required String heading,
  required Widget rule,
  required String speech,
  required String hint,
  Widget? content,
  Widget? hintContent,
  List<String>? speechAll,
  bool tappable = false,
}) => LessonPageSpec(
  tag: 'مثال وقاعدة',
  title: title,
  emoji: emoji,
  needsCompletion: false,
  rule: rule,
  builder: (h) => _ExamplePage(
    handle: h,
    heading: heading,
    speech: speech,
    hint: hint,
    hintContent: hintContent,
    speechAll: speechAll,
    tappable: tappable,
    child: content ?? rule,
  ),
);

class _ExamplePage extends StatefulWidget {
  const _ExamplePage({
    required this.handle,
    required this.heading,
    required this.speech,
    required this.hint,
    required this.child,
    this.hintContent,
    this.speechAll,
    this.tappable = false,
  });

  final PageHandle handle;
  final String heading;
  final String speech;
  final String hint;
  final Widget child;

  /// محتوى «مساعدة» في نافذة بدل رسالة [hint] القصيرة.
  final Widget? hintContent;

  /// نصوص «استمع» تُنطق متتالية بدل [speech].
  final List<String>? speechAll;

  /// في المحتوى أمثلة تُسمع بالضغط عليها.
  final bool tappable;

  @override
  State<_ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<_ExamplePage> {
  @override
  void initState() {
    super.initState();
    widget.handle
      ..onListen = () {
        final rate = AppScope.read(context).speechRate;
        if (widget.speechAll case final texts?) {
          Speaker.instance.speakAll(texts, rate: rate);
        } else {
          Speaker.instance.speak(widget.speech, rate: rate);
        }
      }
      ..onHint = () => widget.hintContent == null
          ? showFeedback(context, widget.hint, tone: FeedbackTone.hint)
          : showRuleSheet(context, title: 'تلميح', content: widget.hintContent);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.markComplete(),
    );
  }

  @override
  Widget build(BuildContext context) => PageCard(
    tag: 'مثال وقاعدة',
    title: widget.heading,
    subtitle: widget.tappable ? 'اضغط على المثال لتسمعه' : null,
    child: widget.child,
  );
}
