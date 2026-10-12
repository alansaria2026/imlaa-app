import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/app_state.dart';
import 'package:imlaa/screens/home_screen.dart';
import 'package:imlaa/theme.dart';

import 'helpers/harness.dart';

/// إزاحة تأرجح شريط المحطات أفقيًا.
double _sway(WidgetTester t) => t
    .widgetList<Transform>(
      find.descendant(
        of: find.byType(SingleChildScrollView).first,
        matching: find.byType(Transform),
      ),
    )
    .firstWhere((e) => e.child is SizedBox)
    .transform
    .getTranslation()
    .x;

Widget _app(AppState state) => AppScope(
  state: state,
  child: MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: const HomeScreen(),
  ),
);

void main() {
  setUpAll(loadAppFonts);
  setUp(mockPlatform);

  testWidgets('شريط المحطات: يتأرجح حتى أول سحب، وفي المنتصف إن لم يتأرجح', (
    t,
  ) async {
    // «تقليل الحركة»: لا تأرجح والشريط في مكانه.
    final state = await pumpScreen(t, const HomeScreen());
    expect(_sway(t), 0);

    t.platformDispatcher.clearAccessibilityFeaturesTestValue();
    await t.pumpWidget(Container());
    await t.pumpWidget(_app(state));
    await t.pump(const Duration(milliseconds: 800));
    final a = _sway(t);
    await t.pump(const Duration(milliseconds: 700));
    expect(_sway(t), isNot(a));

    // أول سحب يوقفه في المنتصف نهائيًا.
    await t.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(-200, 0),
    );
    await t.pump(const Duration(milliseconds: 300));
    expect(_sway(t), 0);
    await t.pump(const Duration(milliseconds: 700));
    expect(_sway(t), 0);

    // شاشة عريضة تتسع لكل محطات درس التاء: لا شيء يُسحب فلا تأرجح.
    await t.pumpWidget(Container());
    t.view.physicalSize = const Size(3000, 2400);
    state.selectLesson('taa');
    await t.pumpWidget(_app(state));
    await t.pump(const Duration(milliseconds: 100));
    await t.pump(const Duration(milliseconds: 500));
    expect(_sway(t), 0);
    await t.pumpWidget(Container());
  });
}
