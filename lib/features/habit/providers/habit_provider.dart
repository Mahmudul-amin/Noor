import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';

class HabitState {
  final int salahCount;
  final bool quranDone;
  final bool dhikrDone;
  final int streak;
  final List<double> weeklyData;
  const HabitState({
    this.salahCount = 0, this.quranDone = false, this.dhikrDone = false,
    this.streak = 0, this.weeklyData = const [0, 0, 0, 0, 0, 0, 0],
  });
  double get todayPercent => ((salahCount / 5) * 40 + (quranDone ? 30 : 0) + (dhikrDone ? 30 : 0)).clamp(0, 100);
  HabitState copyWith({int? salahCount, bool? quranDone, bool? dhikrDone, int? streak, List<double>? weeklyData}) =>
      HabitState(
        salahCount: salahCount ?? this.salahCount, quranDone: quranDone ?? this.quranDone,
        dhikrDone: dhikrDone ?? this.dhikrDone, streak: streak ?? this.streak,
        weeklyData: weeklyData ?? this.weeklyData,
      );
}

class HabitNotifier extends StateNotifier<HabitState> {
  late Box _box;
  HabitNotifier() : super(const HabitState()) { _load(); }

  Future<void> _load() async {
    _box = Hive.box(AppConstants.habitsBox);
    final today = _todayKey();
    final salah = _box.get('${today}_salah', defaultValue: 0) as int;
    final quran = _box.get('${today}_quran', defaultValue: false) as bool;
    final dhikr = _box.get('${today}_dhikr', defaultValue: false) as bool;
    final streak = _box.get('streak', defaultValue: 0) as int;
    final weekly = List<double>.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      final k = '${d.year}-${d.month}-${d.day}';
      return (_box.get('${k}_salah', defaultValue: 0) as int) / 5.0 * 100;
    });
    state = HabitState(salahCount: salah, quranDone: quran, dhikrDone: dhikr, streak: streak, weeklyData: weekly);
  }

  String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  Future<void> incrementSalah() async {
    if (state.salahCount >= 5) return;
    final n = state.salahCount + 1;
    await _box.put('${_todayKey()}_salah', n);
    if (n == 5) await _box.put('streak', state.streak + 1);
    state = state.copyWith(salahCount: n);
  }

  Future<void> toggleQuran() async {
    final v = !state.quranDone;
    await _box.put('${_todayKey()}_quran', v);
    state = state.copyWith(quranDone: v);
  }

  Future<void> toggleDhikr() async {
    final v = !state.dhikrDone;
    await _box.put('${_todayKey()}_dhikr', v);
    state = state.copyWith(dhikrDone: v);
  }

  Future<void> resetToday() async {
    await _box.put('${_todayKey()}_salah', 0);
    await _box.put('${_todayKey()}_quran', false);
    await _box.put('${_todayKey()}_dhikr', false);
    state = state.copyWith(salahCount: 0, quranDone: false, dhikrDone: false);
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, HabitState>((ref) => HabitNotifier());
