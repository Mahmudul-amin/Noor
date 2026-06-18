import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with TickerProviderStateMixin {
  static const _deepEmerald = Color(0xFF022C22);
  static const _softGold = Color(0xFFE8C76A);
  static const _textWhite = Color(0xFFF7F7F7);

  late final AnimationController _tapController;
  late final AnimationController _floatController;
  late final AnimationController _shimmerController;
  AnimationController? _completionController;

  int _count = 0;
  int _goal = 99;
  int _todayCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _tabIndex = 0;
  bool _vibrationOn = true;
  String _dhikr = 'SubhanAllah';
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _completionController = _createCompletionController();
    _loadState();
  }

  AnimationController _createCompletionController() {
    return AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  AnimationController get _completion =>
      _completionController ??= _createCompletionController();

  @override
  void dispose() {
    _tapController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    _completionController?.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _count = prefs.getInt('tasbih_count') ?? 0;
      _goal = prefs.getInt('tasbih_goal') ?? 99;
      _todayCount = prefs.getInt('tasbih_today_count') ?? 0;
      _currentStreak = prefs.getInt('tasbih_current_streak') ?? 0;
      _bestStreak = prefs.getInt('tasbih_best_streak') ?? 0;
      _dhikr = prefs.getString('tasbih_dhikr') ?? 'SubhanAllah';
      _vibrationOn = prefs.getBool('tasbih_vibration') ?? true;
      _history = prefs.getStringList('tasbih_history') ?? [];
    });
  }

  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', _count);
    await prefs.setInt('tasbih_goal', _goal);
    await prefs.setInt('tasbih_today_count', _todayCount);
    await prefs.setInt('tasbih_current_streak', _currentStreak);
    await prefs.setInt('tasbih_best_streak', _bestStreak);
    await prefs.setString('tasbih_dhikr', _dhikr);
    await prefs.setBool('tasbih_vibration', _vibrationOn);
    await prefs.setStringList('tasbih_history', _history);
  }

  Future<void> _increment() async {
    if (_vibrationOn) HapticFeedback.mediumImpact();
    _tapController.forward(from: 0);
    var completedRound = false;
    setState(() {
      _count++;
      _todayCount++;
      if (_count >= _goal) {
        completedRound = true;
        _currentStreak++;
        _bestStreak = math.max(_bestStreak, _currentStreak);
        _history.insert(
          0,
          'Completed $_goal $_dhikr • ${DateTime.now().month}/${DateTime.now().day}',
        );
        if (_history.length > 12) _history = _history.take(12).toList();
        _count = 0;
      }
    });
    if (completedRound) {
      _completion.forward(from: 0).whenComplete(() {
        if (mounted) _completion.reset();
      });
    }
    await _persistState();
  }

  Future<void> _reset() async {
    if (_count > 0) {
      _history.insert(
        0,
        'Saved $_count $_dhikr • ${DateTime.now().month}/${DateTime.now().day}',
      );
      if (_history.length > 12) _history = _history.take(12).toList();
    }
    setState(() => _count = 0);
    HapticFeedback.mediumImpact();
    await _persistState();
  }

  Future<void> _editDhikr() async {
    final controller = TextEditingController(text: _dhikr);
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _PremiumDialog(
        title: 'Edit Dhikr',
        child: TextField(
          controller: controller,
          autofocus: true,
          cursorColor: Colors.black87,
          style: GoogleFonts.poppins(color: Colors.black87),
          decoration: _dialogInputDecoration('Dhikr name'),
        ),
        onSave: () => Navigator.pop(context, controller.text.trim()),
      ),
    );
    if (value == null || value.isEmpty) return;
    setState(() => _dhikr = value);
    await _persistState();
  }

  Future<void> _editGoal() async {
    final controller = TextEditingController(text: '$_goal');
    final value = await showDialog<int>(
      context: context,
      builder: (_) => _PremiumDialog(
        title: 'Edit Goal',
        child: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          cursorColor: Colors.black87,
          style: GoogleFonts.poppins(color: Colors.black87),
          decoration: _dialogInputDecoration('Goal count'),
        ),
        onSave: () => Navigator.pop(context, int.tryParse(controller.text)),
      ),
    );
    if (value == null || value <= 0) return;
    setState(() => _goal = value);
    await _persistState();
  }

  InputDecoration _dialogInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.black54),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: _softGold.withValues(alpha: 0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _softGold, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepEmerald,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: _TasbihBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final mediaWidth = MediaQuery.sizeOf(context).width;
                final width = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : mediaWidth;
                final ringSize =
                    (width * 0.88).clamp(300.0, 430.0).toDouble();
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, -10 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _TasbihHeader(
                          onVibrationTap: () async {
                            setState(() => _vibrationOn = !_vibrationOn);
                            await _persistState();
                          },
                          vibrationOn: _vibrationOn,
                        ),
                      ),
                      const SizedBox(height: 26),
                      _ModeSwitcher(
                        selectedIndex: _tabIndex,
                        onChanged: (index) => setState(() => _tabIndex = index),
                      ),
                      const SizedBox(height: 26),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 360),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _tabIndex == 0
                            ? Column(
                                key: const ValueKey('tasbih-tab'),
                                children: [
                                  AnimatedBuilder(
                                    animation: Listenable.merge([
                                      _floatController,
                                      _tapController,
                                      _shimmerController,
                                      _completion,
                                    ]),
                                    builder: (context, _) {
                                      final pulse = math.sin(
                                            _tapController.value * math.pi,
                                          ) *
                                          0.045;
                                      final float = math.sin(
                                            _floatController.value * math.pi,
                                          ) *
                                          7;
                                      return Transform.translate(
                                        offset: Offset(0, float),
                                        child: Transform.scale(
                                          scale: 1 + pulse,
                                          child: TasbihRing(
                                            size: ringSize,
                                            count: _count,
                                            goal: _goal,
                                            dhikr: _dhikr,
                                            shimmer: _shimmerController.value,
                                            completionGlow: _completion.value,
                                            onTap: _increment,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  _ControlsCard(
                                    dhikr: _dhikr,
                                    goal: _goal,
                                    onReset: _reset,
                                    onEditDhikr: _editDhikr,
                                    onEditGoal: _editGoal,
                                  ),
                                  const SizedBox(height: 18),
                                  _StatisticsCard(
                                    todayCount: _todayCount,
                                    streak: _currentStreak,
                                    bestStreak: _bestStreak,
                                  ),
                                  const SizedBox(height: 18),
                                  const _QuoteCard(),
                                ],
                              )
                            : _HistoryPanel(
                                key: const ValueKey('history-tab'),
                                history: _history,
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TasbihHeader extends StatelessWidget {
  final VoidCallback onVibrationTap;
  final bool vibrationOn;

  const _TasbihHeader({
    required this.onVibrationTap,
    required this.vibrationOn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlowButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFE8C76A), Color(0xFFFFE9A6), Color(0xFFD4AF37)],
                ).createShader(bounds),
                child: Text(
                  'Tasbih',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    shadows: [
                      const Shadow(
                        color: Color(0x88D4AF37),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Remember Allah',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              const _IslamicDivider(),
            ],
          ),
        ),
        GlowButton(
          icon: vibrationOn ? Icons.vibration_rounded : Icons.notifications_off_rounded,
          onTap: onVibrationTap,
        ),
      ],
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _ModeSwitcher({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 32,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ModeTab(
            icon: Icons.blur_circular_rounded,
            label: 'Tasbih',
            active: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _ModeTab(
            icon: Icons.history_rounded,
            label: 'History',
            active: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ModeTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: active
                ? LinearGradient(
                    colors: [
                      const Color(0xFF0B5D4B).withValues(alpha: 0.82),
                      const Color(0xFF013328).withValues(alpha: 0.72),
                    ],
                  )
                : null,
            border: Border.all(
              color: active
                  ? const Color(0xFFD4AF37).withValues(alpha: 0.5)
                  : Colors.transparent,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF0B5D4B).withValues(alpha: 0.55),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: active ? const Color(0xFFE8C76A) : Colors.white60,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: active ? const Color(0xFFFFE9A6) : Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TasbihRing extends StatelessWidget {
  final double size;
  final int count;
  final int goal;
  final String dhikr;
  final double shimmer;
  final double completionGlow;
  final VoidCallback onTap;

  const TasbihRing({
    super.key,
    required this.size,
    required this.count,
    required this.goal,
    required this.dhikr,
    required this.shimmer,
    required this.completionGlow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size + 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.03,
              child: Container(
                width: size * 0.76,
                height: size * 0.76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B5D4B).withValues(alpha: 0.45),
                      blurRadius: 72,
                      spreadRadius: 18,
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _TasbihRingPainter(
                  count: count,
                  goal: goal,
                  shimmer: shimmer,
                  completionGlow: completionGlow,
                ),
              ),
            ),
            Positioned(
              top: size * 0.04,
              child: _AllahMedallion(
                size: size * 0.16,
                glow: completionGlow,
              ),
            ),
            Positioned(
              top: size * 0.27,
              child: SizedBox(
                width: size * 0.66,
                child: Column(
                  children: [
                    Text(
                      dhikr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFE8C76A),
                        fontSize:
                            (size * 0.064).clamp(20.0, 28.0).toDouble(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CounterText(value: count),
                    const SizedBox(height: 10),
                    Text(
                      'Tap anywhere\nto count',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.64),
                        fontSize: 16,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag_rounded,
                          color: const Color(0xFF33D69F),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Goal $goal',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF33D69F),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasbihRingPainter extends CustomPainter {
  final int count;
  final int goal;
  final double shimmer;
  final double completionGlow;

  _TasbihRingPainter({
    required this.count,
    required this.goal,
    required this.shimmer,
    required this.completionGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.width / 2 + 10);
    final radius = size.width * 0.39;
    final beadCount = math.min(math.max(goal, 1), 33);
    final progress = _phaseProgress(
      currentCount: completionGlow > 0 ? goal : count,
      goal: goal,
      beadCount: beadCount,
    );
    final maxBeadRadius = size.width * 0.036;
    final beadRadius = math
        .min(maxBeadRadius, (math.pi * radius * 2) / (beadCount * 2.45))
        .clamp(2.4, maxBeadRadius)
        .toDouble();
    final separatorPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (int i = 0; i < beadCount; i++) {
      final angle = -math.pi / 2 + ((i + 0.5) / beadCount) * math.pi * 2;
      final pos = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final nextAngle = -math.pi / 2 + ((i + 1) / beadCount) * math.pi * 2;
      final sep = Offset(
        center.dx + math.cos(nextAngle) * radius,
        center.dy + math.sin(nextAngle) * radius,
      );
      if (beadRadius >= 4) {
        canvas.drawCircle(sep, beadRadius * 0.18, separatorPaint);
      }
      canvas.drawCircle(pos + const Offset(0, 5), beadRadius, shadowPaint);

      final highlight = (math.sin((shimmer * math.pi * 2) + i * 0.55) + 1) / 2;
      final isComplete = i < progress.completedBeads;
      final completeColors = _phaseColors(progress.phaseIndex, highlight);
      final beadPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.38, -0.45),
          radius: 0.86,
          colors: isComplete ? completeColors : _baseBeadColors(highlight),
          stops: const [0.02, 0.45, 1],
        ).createShader(Rect.fromCircle(center: pos, radius: beadRadius));

      canvas.drawCircle(pos, beadRadius, beadPaint);
      canvas.drawCircle(
        pos,
        beadRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = (isComplete ? Colors.white : const Color(0xFFFFD979))
              .withValues(alpha: isComplete ? 0.72 : 0.48),
      );
      canvas.drawCircle(
        pos.translate(-beadRadius * 0.28, -beadRadius * 0.34),
        beadRadius * 0.22,
        Paint()..color = Colors.white.withValues(alpha: 0.28),
      );
    }

    final tasselAnchor = Offset(center.dx + radius * 0.78, center.dy + radius * 0.68);
    final cordPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tasselAnchor, tasselAnchor + const Offset(30, 42), cordPaint);
    canvas.drawCircle(tasselAnchor + const Offset(15, 20), 8, separatorPaint);
    canvas.drawCircle(
      tasselAnchor + const Offset(34, 50),
      20,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFE8C76A), Color(0xFF704900)],
        ).createShader(Rect.fromCircle(center: tasselAnchor + const Offset(34, 50), radius: 22)),
    );

    final tasselTop = tasselAnchor + const Offset(34, 70);
    final tasselPaint = Paint()
      ..color = const Color(0xFF063E31)
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;
    for (int i = -10; i <= 10; i++) {
      canvas.drawLine(
        tasselTop,
        tasselTop + Offset(i * 2.8, 82 + i.abs() * 1.2),
        tasselPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TasbihRingPainter oldDelegate) {
    return oldDelegate.count != count ||
        oldDelegate.goal != goal ||
        oldDelegate.shimmer != shimmer ||
        oldDelegate.completionGlow != completionGlow;
  }

  _PhaseProgress _phaseProgress({
    required int currentCount,
    required int goal,
    required int beadCount,
  }) {
    final safeGoal = math.max(goal, 1);
    final safeCount = currentCount.clamp(0, safeGoal).toInt();
    if (safeCount == 0) {
      return const _PhaseProgress(phaseIndex: 0, completedBeads: 0);
    }

    final phaseIndex = safeCount <= 33
        ? 0
        : safeCount <= 66
            ? 1
            : 2;
    final phaseStart = phaseIndex == 0
        ? 1
        : phaseIndex == 1
            ? 34
            : 67;
    final phaseEnd = phaseIndex == 0
        ? math.min(safeGoal, 33)
        : phaseIndex == 1
            ? math.min(safeGoal, 66)
            : safeGoal;
    final phaseLength = math.max(phaseEnd - phaseStart + 1, 1);
    final phaseCount = (safeCount - phaseStart + 1).clamp(0, phaseLength);
    final completedBeads = phaseCount <= 0
        ? 0
        : math
            .max(1, ((phaseCount / phaseLength) * beadCount).floor())
            .clamp(0, beadCount)
            .toInt();

    return _PhaseProgress(
      phaseIndex: phaseIndex,
      completedBeads: completedBeads,
    );
  }

  List<Color> _baseBeadColors(double highlight) {
    return [
      Color.lerp(const Color(0xFF92F1C9), Colors.white, highlight * 0.18)!,
      const Color(0xFF08724F),
      const Color(0xFF003B2B),
    ];
  }

  List<Color> _phaseColors(int phaseIndex, double highlight) {
    switch (phaseIndex) {
      case 1:
        return [
          Color.lerp(const Color(0xFFA8F7FF), Colors.white, highlight * 0.18)!,
          const Color(0xFF1CB6C9),
          const Color(0xFF075B77),
        ];
      case 2:
        return [
          Color.lerp(const Color(0xFFFFB4A8), Colors.white, highlight * 0.16)!,
          const Color(0xFFE74C3C),
          const Color(0xFF7F1D1D),
        ];
      default:
        return [
          Color.lerp(const Color(0xFFFFF0A8), Colors.white, highlight * 0.18)!,
          const Color(0xFFE8C76A),
          const Color(0xFF9F6E05),
        ];
    }
  }
}

class _PhaseProgress {
  final int phaseIndex;
  final int completedBeads;

  const _PhaseProgress({
    required this.phaseIndex,
    required this.completedBeads,
  });
}

class _AllahMedallion extends StatelessWidget {
  final double size;
  final double glow;

  const _AllahMedallion({required this.size, required this.glow});

  @override
  Widget build(BuildContext context) {
    final glowStrength = glow <= 0
        ? 0.0
        : (0.65 + ((math.sin(glow * math.pi * 10) + 1) * 0.175))
            .clamp(0.0, 1.0)
            .toDouble();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF0B5D4B), Color(0xFF01251D)],
        ),
        border: Border.all(color: const Color(0xFFE8C76A), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          if (glowStrength > 0) ...[
            BoxShadow(
              color: const Color(0xFFFFE9A6).withValues(alpha: 0.65 * glowStrength),
              blurRadius: 28 + (34 * glowStrength),
              spreadRadius: 5 + (14 * glowStrength),
            ),
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.42 * glowStrength),
              blurRadius: 58 + (46 * glowStrength),
              spreadRadius: 18 + (22 * glowStrength),
            ),
          ],
        ],
      ),
      child: Center(
        child: Text(
          'الله',
          style: GoogleFonts.amiri(
            color: const Color(0xFFE8C76A),
            fontSize: size * 0.5,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class CounterText extends StatelessWidget {
  final int value;

  const CounterText({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween<double>(begin: 0.82, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Text(
        '$value',
        style: GoogleFonts.poppins(
          color: const Color(0xFFF7F7F7),
          fontSize: 92,
          height: 0.92,
          fontWeight: FontWeight.w700,
          shadows: [
            Shadow(
              color: const Color(0xFFE8C76A).withValues(alpha: 0.24),
              blurRadius: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsCard extends StatelessWidget {
  final String dhikr;
  final int goal;
  final VoidCallback onReset;
  final VoidCallback onEditDhikr;
  final VoidCallback onEditGoal;

  const _ControlsCard({
    required this.dhikr,
    required this.goal,
    required this.onReset,
    required this.onEditDhikr,
    required this.onEditGoal,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: _EditableValue(
              label: 'Dhikr',
              value: dhikr,
              onEdit: onEditDhikr,
            ),
          ),
          GlowButton(
            size: 88,
            radius: 44,
            icon: Icons.restart_alt_rounded,
            label: 'Reset',
            onTap: onReset,
          ),
          Expanded(
            child: _EditableValue(
              label: 'Goal',
              value: '$goal',
              alignEnd: true,
              onEdit: onEditGoal,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableValue extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;
  final VoidCallback onEdit;

  const _EditableValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE8C76A).withValues(alpha: 0.32),
              ),
              color: Colors.white.withValues(alpha: 0.04),
            ),
            child: const Icon(Icons.edit_rounded, color: Color(0xFFE8C76A), size: 18),
          ),
        ),
      ],
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  final int todayCount;
  final int streak;
  final int bestStreak;

  const _StatisticsCard({
    required this.todayCount,
    required this.streak,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          StatCard(icon: Icons.workspace_premium_rounded, value: todayCount, label: 'Today'),
          _VerticalGlowLine(),
          StatCard(icon: Icons.local_fire_department_rounded, value: streak, label: 'Streak'),
          _VerticalGlowLine(),
          StatCard(icon: Icons.calendar_month_rounded, value: bestStreak, label: 'Best Streak'),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFE8C76A), size: 26),
          const SizedBox(height: 12),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 520),
            builder: (_, animated, __) => Text(
              '$animated',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF102E2B), Color(0xFF031A15)],
              ),
              border: Border.all(color: const Color(0xFFE8C76A).withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.mosque_rounded, color: Color(0xFFE8C76A), size: 38),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '“Verily, in the remembrance of Allah do hearts find rest.”',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '— Surah Ar-Ra’d (13:28)',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF33D69F),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  final List<String> history;

  const _HistoryPanel({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved Sessions',
            style: GoogleFonts.poppins(
              color: const Color(0xFFE8C76A),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  'No sessions yet',
                  style: GoogleFonts.poppins(color: Colors.white60),
                ),
              ),
            )
          else
            ...history.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withValues(alpha: 0.045),
                    border: Border.all(
                      color: const Color(0xFFE8C76A).withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFFE8C76A), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GlowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double radius;
  final String? label;

  const GlowButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 60,
    this.radius = 18,
    this.label,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 130),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.035),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFE8C76A).withValues(alpha: 0.38),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: _pressed ? 0.34 : 0.12),
                blurRadius: _pressed ? 26 : 16,
                offset: const Offset(0, 7),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: const Color(0xFFE8C76A), size: widget.label == null ? 28 : 30),
              if (widget.label != null) ...[
                const SizedBox(height: 3),
                Text(
                  widget.label!,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFE8C76A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                const Color(0xFF0B5D4B).withValues(alpha: 0.13),
                Colors.black.withValues(alpha: 0.16),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFE8C76A).withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TasbihBackground extends StatelessWidget {
  const _TasbihBackground();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 0.9,
            colors: [
              Color(0xFF0B5D4B),
              Color(0xFF013328),
              Color(0xFF011A15),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _GeometryTexturePainter()),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.05,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.58),
                  ],
                  stops: const [0.48, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeometryTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8C76A).withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    const step = 42.0;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final path = Path()
          ..moveTo(x + step / 2, y)
          ..lineTo(x + step, y + step / 2)
          ..lineTo(x + step / 2, y + step)
          ..lineTo(x, y + step / 2)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IslamicDivider extends StatelessWidget {
  const _IslamicDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 42, height: 1, color: const Color(0xFFD4AF37).withValues(alpha: 0.45)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.blur_circular_rounded, color: Color(0xFFD4AF37), size: 12),
        ),
        Container(width: 42, height: 1, color: const Color(0xFFD4AF37).withValues(alpha: 0.45)),
      ],
    );
  }
}

class _VerticalGlowLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 76,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFFE8C76A).withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _PremiumDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onSave;

  const _PremiumDialog({
    required this.title,
    required this.child,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: const Color(0xFFE8C76A),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            child,
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF022C22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
