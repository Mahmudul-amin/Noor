import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/noor_widgets.dart';
import '../../providers/habit_provider.dart';

class HabitScreen extends ConsumerWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitProvider);
    final notifier = ref.read(habitProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker'), actions: [
        IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: notifier.resetToday),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Streak
          GradientCard(
            gradient: AppColors.primaryGradient,
            child: Row(children: [
              const Text('🔥', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${state.streak} Day Streak', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Keep it up!', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              ]),
              const Spacer(),
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text('${state.todayPercent.toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // Today checklist
          const SectionHeader(title: "Today's Ibadah"),
          const SizedBox(height: 14),
          NoorCard(
            child: Column(children: [
              _SalahProgress(count: state.salahCount, onIncrement: notifier.incrementSalah),
              const Divider(height: 24),
              _HabitToggle(label: 'Quran Reading', icon: Icons.menu_book_rounded,
                  color: AppColors.fajr, done: state.quranDone, onToggle: notifier.toggleQuran),
              const Divider(height: 24),
              _HabitToggle(label: 'Morning/Evening Dhikr', icon: Icons.brightness_5_rounded,
                  color: AppColors.gold, done: state.dhikrDone, onToggle: notifier.toggleDhikr),
            ]),
          ),
          const SizedBox(height: 28),

          // Weekly chart
          const SectionHeader(title: 'Weekly Progress'),
          const SizedBox(height: 14),
          NoorCard(
            child: SizedBox(
              height: 180,
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barGroups: state.weeklyData.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [BarChartRodData(
                    toY: e.value,
                    color: AppColors.primary,
                    width: 20,
                    borderRadius: BorderRadius.circular(6),
                    backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100,
                        color: isDark ? Colors.white12 : AppColors.primary.withValues(alpha: 0.08)),
                  )],
                )).toList(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      const days = ['Mo','Tu','We','Th','Fr','Sa','Su'];
                      return Text(days[v.toInt() % 7], style: const TextStyle(fontSize: 11));
                    },
                    reservedSize: 22,
                  )),
                ),
              )),
            ),
          ),
        ]),
      ),
    );
  }
}

class _SalahProgress extends StatelessWidget {
  final int count;
  final Future<void> Function() onIncrement;
  const _SalahProgress({required this.count, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.mosque_rounded, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        const Expanded(child: Text('Salah', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
        Text('$count/5', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
      ]),
      const SizedBox(height: 12),
      Row(children: prayers.asMap().entries.map((e) => Expanded(
        child: GestureDetector(
          onTap: e.key < count ? null : () => onIncrement(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: e.key < count ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(e.value[0], textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: e.key < count ? Colors.white : AppColors.primary)),
          ),
        ),
      )).toList()),
    ]);
  }
}

class _HabitToggle extends StatelessWidget {
  final String label; final IconData icon; final Color color;
  final bool done; final VoidCallback onToggle;
  const _HabitToggle({required this.label, required this.icon, required this.color, required this.done, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
      GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: done ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: done ? color : Colors.grey.shade400, width: 2),
          ),
          child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
        ),
      ),
    ]);
  }
}
