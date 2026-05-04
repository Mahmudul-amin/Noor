import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/noor_widgets.dart';
import '../../providers/prayer_provider.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerProvider);


    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prayer Times',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(state.times?.location ?? 'Loading...',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const Spacer(),
                          IconButton(
                            onPressed: () => ref
                                .read(prayerProvider.notifier)
                                .loadPrayerTimes(),
                            icon: const Icon(Icons.refresh_rounded,
                                color: Colors.white70, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _NextPrayerBanner(state: state),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (state.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _PrayerRow(
                      name: 'Fajr',
                      time: state.times?.fajr ?? '--:--',
                      emoji: '🌙',
                      color: AppColors.fajr,
                      isNext: state.currentPrayerIndex == 0),
                  const SizedBox(height: 12),
                  _PrayerRow(
                      name: 'Sunrise',
                      time: state.times?.sunrise ?? '--:--',
                      emoji: '🌅',
                      color: AppColors.warning,
                      isNext: false),
                  const SizedBox(height: 12),
                  _PrayerRow(
                      name: 'Dhuhr',
                      time: state.times?.dhuhr ?? '--:--',
                      emoji: '☀️',
                      color: AppColors.primary,
                      isNext: state.currentPrayerIndex == 1),
                  const SizedBox(height: 12),
                  _PrayerRow(
                      name: 'Asr',
                      time: state.times?.asr ?? '--:--',
                      emoji: '🌤️',
                      color: AppColors.asr,
                      isNext: state.currentPrayerIndex == 2),
                  const SizedBox(height: 12),
                  _PrayerRow(
                      name: 'Maghrib',
                      time: state.times?.maghrib ?? '--:--',
                      emoji: '🌇',
                      color: AppColors.maghrib,
                      isNext: state.currentPrayerIndex == 3),
                  const SizedBox(height: 12),
                  _PrayerRow(
                      name: 'Isha',
                      time: state.times?.isha ?? '--:--',
                      emoji: '🌃',
                      color: AppColors.isha,
                      isNext: state.currentPrayerIndex == 4),
                  const SizedBox(height: 28),
                  const SectionHeader(title: 'Prayer Settings'),
                  const SizedBox(height: 14),
                  _SettingsTile(
                      icon: Icons.notifications_outlined,
                      label: 'Adhan Notifications',
                      trailing: Switch(
                          value: true,
                          onChanged: (_) {},
                          activeThumbColor: AppColors.primary)),
                  const SizedBox(height: 10),
                  _SettingsTile(
                      icon: Icons.calculate_outlined,
                      label: 'Calculation Method',
                      trailing: const Text('Muslim World League',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textLight))),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _NextPrayerBanner extends StatelessWidget {
  final PrayerState state;
  const _NextPrayerBanner({required this.state});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Next Prayer',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(state.nextPrayerName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              Text(state.nextPrayerTimeFormatted,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12)),
            child: const _CountdownTimer(),
          ),
        ],
      ),
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  const _CountdownTimer();
  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  String _time = '--:--';
  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      final now = DateTime.now();
      setState(() => _time =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}');
      return true;
    });
  }

  @override
  Widget build(BuildContext context) => Text(_time,
      style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5));
}

class _PrayerRow extends StatelessWidget {
  final String name, time, emoji;
  final Color color;
  final bool isNext;
  const _PrayerRow(
      {required this.name,
      required this.time,
      required this.emoji,
      required this.color,
      required this.isNext});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isNext
            ? color.withValues(alpha: isDark ? 0.2 : 0.08)
            : (isDark ? AppColors.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isNext
                ? color.withValues(alpha: 0.4)
                : (isDark ? const Color(0xFF1E3045) : const Color(0xFFE8F5EE))),
        boxShadow: isNext
            ? [
                BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]
            : [],
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 14),
        Expanded(
            child: Text(name,
                style: TextStyle(
                    fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 16,
                    color: isNext ? color : null))),
        if (isNext)
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8)),
            child: Text('Next',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ),
        Text(_fmt12(time),
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isNext ? color : null)),
      ]),
    );
  }

  String _fmt12(String t) {
    if (t == '--:--') return t;
    final p = t.split(':');
    final h = int.parse(p[0]);
    return '${h > 12 ? h - 12 : (h == 0 ? 12 : h)}:${p[1]} ${h >= 12 ? 'PM' : 'AM'}';
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  const _SettingsTile(
      {required this.icon, required this.label, required this.trailing});
  @override
  Widget build(BuildContext context) {
    return NoorCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 14),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 15))),
        trailing,
      ]),
    );
  }
}
