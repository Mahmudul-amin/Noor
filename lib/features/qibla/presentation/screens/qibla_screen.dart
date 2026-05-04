import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

final _qiblaProvider = StreamProvider<double>((ref) async* {
  Position? pos;
  try {
    final p = await Geolocator.requestPermission();
    if (p == LocationPermission.always || p == LocationPermission.whileInUse) {
      pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium));
    }
  } catch (_) {}
  final lat = pos?.latitude ?? 23.8103;
  final lng = pos?.longitude ?? 90.4125;
  final qibla = _calcQibla(lat, lng);
  await for (final e in FlutterCompass.events!) {
    yield (qibla - (e.heading ?? 0) + 360) % 360;
  }
});

double _calcQibla(double lat, double lng) {
  final kLat = AppConstants.kaabaLat * pi / 180;
  final kLng = AppConstants.kaabaLng * pi / 180;
  final uLat = lat * pi / 180;
  final dLng = kLng - lng * pi / 180;
  final y = sin(dLng) * cos(kLat);
  final x = cos(uLat) * sin(kLat) - sin(uLat) * cos(kLat) * cos(dLng);
  return (atan2(y, x) * 180 / pi + 360) % 360;
}

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qibla = ref.watch(_qiblaProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla Finder')),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
          child: const Row(children: [
            Icon(Icons.info_outline_rounded,
                color: AppColors.primary, size: 18),
            SizedBox(width: 10),
            Expanded(
                child: Text(
                    'Point flat and rotate until the green arrow faces Mecca.',
                    style: TextStyle(fontSize: 13))),
          ]),
        ),
        Expanded(
            child: Center(
          child: qibla.when(
            loading: () =>
                const CircularProgressIndicator(color: AppColors.primary),
            error: (_, __) =>
                const Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.compass_calibration_outlined,
                  size: 64, color: AppColors.textLight),
              SizedBox(height: 12),
              Text(
                  'Compass unavailable.\nEnable location & compass permissions.',
                  textAlign: TextAlign.center),
            ]),
            data: (angle) => _Compass(angle: angle, isDark: isDark),
          ),
        )),
        Padding(
          padding: const EdgeInsets.only(bottom: 110),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('🕋', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text('Mecca, Saudi Arabia',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Compass extends StatelessWidget {
  final double angle;
  final bool isDark;
  const _Compass({required this.angle, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            isDark ? AppColors.cardDark : Colors.white,
            isDark ? AppColors.surfaceDark : const Color(0xFFF0F4F2)
          ]),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 4)
          ],
        ),
      ),
      ...List.generate(8, (i) {
        final labels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
        final r = i * pi / 4;
        return Transform.translate(
          offset: Offset(sin(r) * 110, -cos(r) * 110),
          child: Text(labels[i],
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: labels[i] == 'N'
                      ? AppColors.error
                      : (isDark ? Colors.white54 : AppColors.textMedium))),
        );
      }),
      Transform.rotate(
        angle: angle * pi / 180,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 14,
              height: 75,
              decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(7)))),
          Container(
              width: 14,
              height: 75,
              decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.grey.shade300,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(7)))),
        ]),
      ),
      Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
              gradient: AppColors.goldGradient, shape: BoxShape.circle)),
    ]);
  }
}
