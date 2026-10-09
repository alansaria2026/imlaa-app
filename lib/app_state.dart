import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// حالة التطبيق المحفوظة: النقاط والصفحات المنجزة وإعدادات الصوت.
class AppState extends ChangeNotifier {
  AppState._(this._prefs)
    : _points = _prefs.getInt(_kPoints) ?? 0,
      _donePages = (_prefs.getStringList(_kDone) ?? const []).toSet(),
      _speechRate = _prefs.getDouble(_kRate) ?? 0.42;

  static const _kPoints = 'points';
  static const _kDone = 'done_pages';
  static const _kRate = 'speech_rate';

  final SharedPreferences _prefs;
  int _points;
  final Set<String> _donePages;
  double _speechRate;

  static Future<AppState> load() async =>
      AppState._(await SharedPreferences.getInstance());

  int get points => _points;
  double get speechRate => _speechRate;

  void addPoints(int value) {
    _points += value;
    _prefs.setInt(_kPoints, _points);
    notifyListeners();
  }

  bool isPageDone(String lessonId, int page) =>
      _donePages.contains('$lessonId:$page');

  int donePagesOf(String lessonId) =>
      _donePages.where((p) => p.startsWith('$lessonId:')).length;

  void markPageDone(String lessonId, int page) {
    if (_donePages.add('$lessonId:$page')) {
      _prefs.setStringList(_kDone, _donePages.toList());
      notifyListeners();
    }
  }

  void setSpeechRate(double value) {
    _speechRate = value;
    _prefs.setDouble(_kRate, value);
    notifyListeners();
  }

  Future<void> reset() async {
    _points = 0;
    _donePages.clear();
    await _prefs.remove(_kPoints);
    await _prefs.remove(_kDone);
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  /// يعيد البناء عند تغيّر الحالة.
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// قراءة فقط بدون اشتراك (للاستخدام داخل الأحداث).
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
