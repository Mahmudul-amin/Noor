import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';

class PrayerTimes {
  final String fajr, sunrise, dhuhr, asr, maghrib, isha, date, location;
  const PrayerTimes({
    required this.fajr, required this.sunrise, required this.dhuhr,
    required this.asr, required this.maghrib, required this.isha,
    required this.date, required this.location,
  });
  static PrayerTimes mock() => const PrayerTimes(
    fajr: '04:32', sunrise: '06:01', dhuhr: '12:10',
    asr: '15:30', maghrib: '18:24', isha: '19:52',
    date: 'Today', location: 'Dhaka, Bangladesh',
  );
}

class PrayerState {
  final PrayerTimes? times;
  final bool isLoading;
  final String? error;
  final String nextPrayerName;
  final String nextPrayerTimeFormatted;
  final DateTime? nextPrayerTime;
  final int currentPrayerIndex;
  const PrayerState({
    this.times, this.isLoading = false, this.error,
    this.nextPrayerName = 'Dhuhr', this.nextPrayerTimeFormatted = '--:--',
    this.nextPrayerTime, this.currentPrayerIndex = 0,
  });
  PrayerState copyWith({PrayerTimes? times, bool? isLoading, String? error,
      String? nextPrayerName, String? nextPrayerTimeFormatted,
      DateTime? nextPrayerTime, int? currentPrayerIndex}) =>
      PrayerState(
        times: times ?? this.times, isLoading: isLoading ?? this.isLoading,
        error: error, nextPrayerName: nextPrayerName ?? this.nextPrayerName,
        nextPrayerTimeFormatted: nextPrayerTimeFormatted ?? this.nextPrayerTimeFormatted,
        nextPrayerTime: nextPrayerTime ?? this.nextPrayerTime,
        currentPrayerIndex: currentPrayerIndex ?? this.currentPrayerIndex,
      );
}

class PrayerNotifier extends StateNotifier<PrayerState> {
  final Dio _dio = Dio();
  PrayerNotifier() : super(const PrayerState(isLoading: true)) { loadPrayerTimes(); }

  Future<void> loadPrayerTimes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      Position? position;
      try {
        final perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
          position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.medium));
        }
      } catch (_) {}

      PrayerTimes times;
      if (position != null) {
        final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
        final resp = await _dio.get(
          '${AppConstants.aladhanBaseUrl}/timings/$today',
          queryParameters: {'latitude': position.latitude, 'longitude': position.longitude, 'method': 3},
        ).timeout(const Duration(seconds: 8));
        final data = resp.data['data']['timings'];
        times = PrayerTimes(
          fajr: data['Fajr'], sunrise: data['Sunrise'], dhuhr: data['Dhuhr'],
          asr: data['Asr'], maghrib: data['Maghrib'], isha: data['Isha'],
          date: DateFormat('d MMM yyyy').format(DateTime.now()), location: 'Current Location',
        );
      } else {
        times = PrayerTimes.mock();
      }
      final next = _computeNext(times);
      state = state.copyWith(
        times: times, isLoading: false,
        nextPrayerName: next['name'] as String,
        nextPrayerTimeFormatted: next['formatted'] as String,
        nextPrayerTime: next['dt'] as DateTime?,
        currentPrayerIndex: next['index'] as int,
      );
    } catch (_) {
      final times = PrayerTimes.mock();
      final next = _computeNext(times);
      state = state.copyWith(
        times: times, isLoading: false,
        nextPrayerName: next['name'] as String,
        nextPrayerTimeFormatted: next['formatted'] as String,
        nextPrayerTime: next['dt'] as DateTime?,
        currentPrayerIndex: next['index'] as int,
      );
    }
  }

  Map<String, dynamic> _computeNext(PrayerTimes times) {
    final prayers = [
      {'name': 'Fajr', 'time': times.fajr, 'index': 0},
      {'name': 'Dhuhr', 'time': times.dhuhr, 'index': 1},
      {'name': 'Asr', 'time': times.asr, 'index': 2},
      {'name': 'Maghrib', 'time': times.maghrib, 'index': 3},
      {'name': 'Isha', 'time': times.isha, 'index': 4},
    ];
    final now = DateTime.now();
    for (final p in prayers) {
      final parts = (p['time'] as String).split(':');
      final dt = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      if (dt.isAfter(now)) return {'name': p['name'], 'formatted': _fmt12(p['time'] as String), 'dt': dt, 'index': p['index']};
    }
    final fp = times.fajr.split(':');
    final tomorrow = DateTime(now.year, now.month, now.day + 1, int.parse(fp[0]), int.parse(fp[1]));
    return {'name': 'Fajr', 'formatted': _fmt12(times.fajr), 'dt': tomorrow, 'index': 0};
  }

  String _fmt12(String t) {
    final p = t.split(':'); final h = int.parse(p[0]);
    return '${h > 12 ? h - 12 : (h == 0 ? 12 : h)}:${p[1]} ${h >= 12 ? 'PM' : 'AM'}';
  }
}

final prayerProvider = StateNotifierProvider<PrayerNotifier, PrayerState>((ref) => PrayerNotifier());
