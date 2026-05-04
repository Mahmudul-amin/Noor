import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

final _tasbihCountProvider = StateProvider<int>((ref) => 0);
final _tasbihGoalProvider =
    StateProvider<int>((ref) => AppConstants.defaultTasbihGoal);
final _selectedDhikrProvider = StateProvider<int>((ref) => 0);

class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});
  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  final List<Map<String, dynamic>> _dhikrs = [
    {
      'arabic': 'سبحان الله',
      'transliteration': 'Subhan Allah',
      'meaning': 'Glory be to Allah',
      'goal': 33
    },
    {
      'arabic': 'الحمد لله',
      'transliteration': 'Alhamdulillah',
      'meaning': 'All praise to Allah',
      'goal': 33
    },
    {
      'arabic': 'الله أكبر',
      'transliteration': 'Allahu Akbar',
      'meaning': 'Allah is the Greatest',
      'goal': 33
    },
    {
      'arabic': 'لا إله إلا الله',
      'transliteration': 'La ilaha illallah',
      'meaning': 'None worthy of worship except Allah',
      'goal': 100
    },
    {
      'arabic': 'أستغفر الله',
      'transliteration': 'Astaghfirullah',
      'meaning': 'I seek forgiveness from Allah',
      'goal': 100
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _tap() async {
    final count = ref.read(_tasbihCountProvider);
    final goal = ref.read(_tasbihGoalProvider);
    if (count >= goal) return;
    HapticFeedback.lightImpact();
    await _pulse.forward();
    await _pulse.reverse();
    ref.read(_tasbihCountProvider.notifier).state = count + 1;
  }

  void _reset() {
    ref.read(_tasbihCountProvider.notifier).state = 0;
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(_tasbihCountProvider);
    final goal = ref.watch(_tasbihGoalProvider);
    final selectedIdx = ref.watch(_selectedDhikrProvider);
    final dhikr = _dhikrs[selectedIdx];
    final progress = goal > 0 ? count / goal : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isComplete = count >= goal;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasbih'), actions: [
        IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _reset),
      ]),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
        child: Column(children: [
          // Dhikr selector
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _dhikrs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () {
                  ref.read(_selectedDhikrProvider.notifier).state = i;
                  ref.read(_tasbihGoalProvider.notifier).state =
                      _dhikrs[i]['goal'] as int;
                  _reset();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedIdx == i
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.cardDark
                            : const Color(0xFFF0F4F2)),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(_dhikrs[i]['transliteration'] as String,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selectedIdx == i
                              ? Colors.white
                              : AppColors.textMedium)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Arabic dhikr
          Text(dhikr['arabic'] as String,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1.4)),
          const SizedBox(height: 4),
          Text(dhikr['meaning'] as String,
              style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
          const SizedBox(height: 32),

          // Progress ring + counter
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _tap,
                child: AnimatedBuilder(
                  animation: _scale,
                  builder: (ctx, child) =>
                      Transform.scale(scale: _scale.value, child: child),
                  child: Stack(alignment: Alignment.center, children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 10,
                        backgroundColor: isDark
                            ? Colors.white12
                            : AppColors.primary.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation(
                            isComplete ? AppColors.gold : AppColors.primary),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isComplete
                              ? [AppColors.gold, AppColors.goldLight]
                              : [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isComplete
                                    ? AppColors.gold
                                    : AppColors.primary)
                                .withValues(alpha: 0.35),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$count',
                                style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1)),
                            Text('of $goal',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.8))),
                            if (isComplete)
                              const Text('✓ Complete',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                          ]),
                    ),
                  ]),
                ),
              ),
            ),
          ),

          // Tap hint
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
                isComplete
                    ? 'MashaAllah! Tap reset to continue'
                    : 'Tap the circle to count',
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textLight)),
          ),
        ]),
      ),
    );
  }
}
