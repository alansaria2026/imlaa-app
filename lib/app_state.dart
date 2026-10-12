import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// حالة التطبيق المحفوظة: النقاط والصفحات المنجزة وإعدادات الصوت.
class AppState extends ChangeNotifier {
  AppState._(this._prefs)
    : _points = _prefs.getInt(_kPoints) ?? 0,
      _donePages = (_prefs.getStringList(_kDone) ?? const []).toSet(),
      _speechRate = _prefs.getDouble(_kRate) ?? 0.42,
      _streak = _prefs.getInt(_kStreak) ?? 0,
      _lastDay = _prefs.getString(_kLastDay),
      _lessonsCompleted = _prefs.getInt(_kLessons) ?? 0,
      _selectedLesson = _prefs.getString(_kSelected);

  /// قابل للاستبدال في الاختبارات.
  static DateTime Function() clock = DateTime.now;

  static const _kPoints = 'points';
  static const _kStreak = 'streak';
  static const _kLastDay = 'last_day';
  static const _kLessons = 'lessons_completed';
  static const _kDone = 'done_pages';
  static const _kRate = 'speech_rate';
  static const _kSelected = 'selected_lesson';

  final SharedPreferences _prefs;
  int _points;
  final Set<String> _donePages;
  double _speechRate;
  int _streak;
  String? _lastDay;
  int _lessonsCompleted;
  String? _selectedLesson;

  static Future<AppState> load() async {
    try {
      return AppState._(await SharedPreferences.getInstance());
    } catch (_) {
      // التخزين محجوب (نافذة خاصة في المتصفح مثلًا): نعمل بذاكرة مؤقتة.
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues({});
      return AppState._(await SharedPreferences.getInstance());
    }
  }

  int get points => _points;
  double get speechRate => _speechRate;

  int get lessonsCompleted => _lessonsCompleted;

  /// آخر وحدة اختارها الطالب في مسار التعلّم.
  String? get selectedLesson => _selectedLesson;

  void selectLesson(String id) {
    _selectedLesson = id;
    _prefs.setString(_kSelected, id);
    notifyListeners();
  }

  int get totalDonePages => _donePages.length;

  static String _day(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// أيام التعلّم المتتالية (تنقطع إذا مرّ يوم كامل دون تعلّم).
  int get streak {
    if (_lastDay == null) return 0;
    final now = clock();
    final today = _day(now);
    final yesterday = _day(now.subtract(const Duration(days: 1)));
    return _lastDay == today || _lastDay == yesterday ? _streak : 0;
  }

  bool get learnedToday => _lastDay == _day(clock());

  void _touchStreak() {
    final now = clock();
    final today = _day(now);
    if (_lastDay == today) return;
    final yesterday = _day(now.subtract(const Duration(days: 1)));
    _streak = _lastDay == yesterday ? _streak + 1 : 1;
    _lastDay = today;
    _prefs.setInt(_kStreak, _streak);
    _prefs.setString(_kLastDay, today);
  }

  void addPoints(int value) {
    _points += value;
    _prefs.setInt(_kPoints, _points);
    _touchStreak();
    notifyListeners();
  }

  void markLessonCompleted() {
    _lessonsCompleted++;
    _prefs.setInt(_kLessons, _lessonsCompleted);
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
    _streak = 0;
    _lastDay = null;
    _lessonsCompleted = 0;
    _selectedLesson = null;
    _donePages.clear();
    for (final k in [
      _kPoints,
      _kDone,
      _kStreak,
      _kLastDay,
      _kLessons,
      _kSelected,
    ]) {
      await _prefs.remove(k);
    }
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
