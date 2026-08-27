import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../prayer/providers/prayer_provider.dart';
import '../../../quran/presentation/providers/last_read_provider.dart';
import '../../../quran/data/quran_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ════════════════════════════════════════════════════════════════════════════
// TOP-LEVEL DATA MODELS
// ════════════════════════════════════════════════════════════════════════════

class _DuaData {
  const _DuaData(this.arabic, this.translation, this.source);
  final String arabic, translation, source;
}

class _HadithData {
  const _HadithData(this.text, this.source);
  final String text, source;
}

class _GoalData {
  const _GoalData(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _StatData {
  const _StatData(this.icon, this.label, this.value, this.unit);
  final IconData icon;
  final String label, value, unit;
}

const _duas = [
  _DuaData(
    'اللَّهُمَّ إِنَّكَ عَفُوٌّ\nتُحِبُّ العَفْوَ فَاعْفُ عَنِّي',
    'O Allah, You are Most Forgiving, You love to forgive, so forgive me.',
    'Tirmidhi',
  ),
  _DuaData(
    'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً\nوَفِي الآخِرَةِ حَسَنَةً',
    'Our Lord! Grant us good in this world and good in the Hereafter.',
    'Al-Baqarah 2:201',
  ),
  _DuaData(
    'اللَّهُمَّ إِنِّي أَسْأَلُكَ الجَنَّةَ\nوَأَعُوذُ بِكَ مِنَ النَّارِ',
    'O Allah, I ask You for Paradise and seek refuge with You from the Fire.',
    'Abu Dawud',
  ),
  _DuaData(
    'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ\nإِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ',
    'My Lord, forgive me and accept my repentance. You are the Accepting of repentance, the Merciful.',
    'Tirmidhi',
  ),
  _DuaData(
    'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ\nوَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    'O Allah, help me to remember You, to be grateful to You, and to worship You excellently.',
    'Abu Dawud',
  ),
];

const _hadiths = [
  _HadithData(
    '"Whoever fasts Ramadan with faith and seeking reward will have his past sins forgiven."',
    'Sahih Bukhari',
  ),
  _HadithData(
    '"When Ramadan enters, the gates of Paradise are opened, the gates of Hellfire are closed, and the devils are chained."',
    'Sahih Bukhari',
  ),
  _HadithData(
    '"There is in Paradise a gate called Ar-Rayyan, through which only those who fast will enter on the Day of Resurrection."',
    'Sahih Bukhari',
  ),
  _HadithData(
    '"The supplication of the fasting person at the time of breaking fast is not rejected."',
    'Ibn Majah',
  ),
];

const _goalItems = [
  _GoalData(Icons.wb_twilight_rounded, 'Fajr'),
  _GoalData(Icons.menu_book_rounded, 'Quran'),
  _GoalData(Icons.radio_button_checked_rounded, 'Dhikr'),
  _GoalData(Icons.nightlight_round, 'Tahajjud'),
  _GoalData(Icons.light_mode_outlined, 'Dhuhr'),
  _GoalData(Icons.wb_sunny_outlined, 'Asr'),
  _GoalData(Icons.wb_twilight_outlined, 'Maghrib'),
  _GoalData(Icons.dark_mode_rounded, 'Isha'),
];

// ════════════════════════════════════════════════════════════════════════════
// PURE HELPERS
// ════════════════════════════════════════════════════════════════════════════

enum _CountdownMode { suhoor, iftar, done }

/// Format a Duration as HH:mm:ss.
String _fmtDiff(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

/// Convert 24-hour "HH:mm" string to 12-hour "h:mm AM/PM".
String _fmt12(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length < 2) return '--:-- --';
  final h24 = int.tryParse(parts[0]) ?? 0;
  final min = parts[1].padLeft(2, '0');
  final period = h24 < 12 ? 'AM' : 'PM';
  final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
  return '$h12:$min $period';
}

/// Ordinal suffix: 1 → "1st", 2 → "2nd", etc.
String _ordinal(int n) {
  if (n >= 11 && n <= 13) return '${n}th';
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}

/// Compute dynamic Ramadan info from today's date.
/// Known approximate Ramadan start dates (Gregorian).
({
  int hijriYear,
  int day,
  int daysLeft,
  bool isRamadan,
  int daysUntilNext,
  double progress,
}) _ramadanInfo(DateTime now) {
  final starts = [
    (year: 1446, start: DateTime(2025, 3, 1)),
    (year: 1447, start: DateTime(2026, 2, 28)),
    (year: 1448, start: DateTime(2027, 2, 17)),
    (year: 1449, start: DateTime(2028, 2, 6)),
  ];

  final today = DateTime(now.year, now.month, now.day);

  for (final r in starts) {
    final rStart = DateTime(r.start.year, r.start.month, r.start.day);
    final rEnd = rStart.add(const Duration(days: 30));
    if (!today.isBefore(rStart) && today.isBefore(rEnd)) {
      final day = today.difference(rStart).inDays + 1;
      return (
        hijriYear: r.year,
        day: day,
        daysLeft: 30 - day,
        isRamadan: true,
        daysUntilNext: 0,
        progress: (day - 1) / 29.0,
      );
    }
  }

  // Not in Ramadan — find nearest upcoming
  for (final r in starts) {
    final rStart = DateTime(r.start.year, r.start.month, r.start.day);
    if (rStart.isAfter(today)) {
      return (
        hijriYear: r.year,
        day: 0,
        daysLeft: 0,
        isRamadan: false,
        daysUntilNext: rStart.difference(today).inDays,
        progress: 0.0,
      );
    }
  }

  return (
    hijriYear: 1449,
    day: 0,
    daysLeft: 0,
    isRamadan: false,
    daysUntilNext: 365,
    progress: 0.0,
  );
}

// ════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ════════════════════════════════════════════════════════════════════════════

class RamadanScreen extends ConsumerStatefulWidget {
  const RamadanScreen({super.key});

  static const _emerald   = Color(0xFF0B5D4A);
  static const _darkGreen = Color(0xFF083D31);
  static const _deepGreen = Color(0xFF031B17);
  static const _gold      = Color(0xFFD4AF37);
  static const _softGold  = Color(0xFFFFC46B);
  static const _success   = Color(0xFF79D88E);
  static const _ivory     = Color(0xFFF8F6F1);
  static const _text      = Color(0xFFF5F1E8);
  static const _mutedText = Color(0xBFF5F1E8);

  static const _pagePadding = 14.0;
  static const _cardRadius  = 24.0;
  static const _sectionGap  = 10.0;

  @override
  ConsumerState<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends ConsumerState<RamadanScreen> {
  Timer? _timer;
  Timer? _duaTimer;
  DateTime _now = DateTime.now();

  // Togglable goals
  final List<bool> _goals = [true, true, true, false, true, true, true, false];

  // Dua & hadith carousel indices
  int _duaIndex    = 0;
  int _hadithIndex = 0;
  
  bool _fastCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadFastStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    // Auto-rotate duas every 8 seconds
    _duaTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) setState(() => _duaIndex = (_duaIndex + 1) % _duas.length);
    });
  }

  Future<void> _loadFastStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'fast_completed_${_now.year}_${_now.month}_${_now.day}';
    if (mounted) {
      setState(() {
        _fastCompleted = prefs.getBool(key) ?? false;
      });
    }
  }

  Future<void> _toggleFastStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'fast_completed_${_now.year}_${_now.month}_${_now.day}';
    final newValue = !_fastCompleted;
    await prefs.setBool(key, newValue);
    if (mounted) {
      setState(() {
        _fastCompleted = newValue;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _duaTimer?.cancel();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatTime(String? hhmm) {
    if (hhmm == null || hhmm.isEmpty) return '--:-- --';
    return _fmt12(hhmm);
  }

  ({_CountdownMode mode, String timeString, String label}) _getCountdown(
      String? fajr, String? maghrib) {
    if (fajr == null || maghrib == null) {
      return (
        mode: _CountdownMode.iftar,
        timeString: '--:--:--',
        label: 'Iftar in'
      );
    }

    DateTime parsePrayer(String hhmm) {
      final p = hhmm.split(':');
      return DateTime(_now.year, _now.month, _now.day,
          int.tryParse(p[0]) ?? 0, int.tryParse(p[1]) ?? 0);
    }

    final fajrDt    = parsePrayer(fajr);
    final maghribDt = parsePrayer(maghrib);

    if (_now.isBefore(fajrDt)) {
      final diff = fajrDt.difference(_now);
      return (
        mode: _CountdownMode.suhoor,
        timeString: _fmtDiff(diff),
        label: 'Suhoor ends in'
      );
    } else if (_now.isBefore(maghribDt)) {
      final diff = maghribDt.difference(_now);
      return (
        mode: _CountdownMode.iftar,
        timeString: _fmtDiff(diff),
        label: 'Iftar in'
      );
    } else {
      return (
        mode: _CountdownMode.done,
        timeString: 'Allahu Akbar!',
        label: 'Fasting Complete'
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final prayerState = ref.watch(prayerProvider);
    final times       = prayerState.times;
    final info        = _ramadanInfo(_now);
    final cd          = _getCountdown(times?.fajr, times?.maghrib);
    final completedGoals = _goals.where((g) => g).length;

    return Scaffold(
      backgroundColor: RamadanScreen._deepGreen,
      body: Stack(
        children: [
          const Positioned.fill(child: _RamadanBackground()),
          SafeArea(
            child: RefreshIndicator(
              color: RamadanScreen._softGold,
              backgroundColor: RamadanScreen._darkGreen,
              onRefresh: () =>
                  ref.read(prayerProvider.notifier).loadPrayerTimes(),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      RamadanScreen._pagePadding, 10,
                      RamadanScreen._pagePadding, 24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _RamadanTopBar(onMenuTap: () => context.go('/home')),
                        const SizedBox(height: 12),

                        // ── Hero ──────────────────────────────────────────
                        _HeroCard(
                          hijriYear: info.hijriYear,
                          day: info.day,
                          daysLeft: info.daysLeft,
                          isRamadan: info.isRamadan,
                          daysUntilNext: info.daysUntilNext,
                          progress: info.progress,
                        ),
                        const SizedBox(height: RamadanScreen._sectionGap),

                        // ── Countdown + Goals ─────────────────────────────
                        _ResponsiveCardGrid(
                          minChildWidth: 170,
                          children: [
                            _IftarCountdownCard(
                              mode: cd.mode,
                              countdownStr: cd.timeString,
                              countdownLabel: cd.label,
                              suhoorTime: _formatTime(times?.fajr),
                              iftarTime: _formatTime(times?.maghrib),
                              isLoading: prayerState.isLoading,
                              isFastCompleted: _fastCompleted,
                              onToggleFast: _toggleFastStatus,
                            ),
                            _GoalsCard(
                              goals: _goals,
                              completedCount: completedGoals,
                              onToggle: (i) =>
                                  setState(() => _goals[i] = !_goals[i]),
                            ),
                          ],
                        ),
                        const SizedBox(height: RamadanScreen._sectionGap),

                        // ── Quran + Dua ──────────────────────────
                        _ResponsiveCardGrid(
                          minChildWidth: 150,
                          children: [
                            _QuranProgressCard(
                                ramadanDay: info.isRamadan ? info.day : 0),
                            _DuaCard(
                              dua: _duas[_duaIndex],
                              index: _duaIndex,
                              total: _duas.length,
                              onNext: () => setState(() =>
                                  _duaIndex = (_duaIndex + 1) % _duas.length),
                              onPrev: () => setState(() => _duaIndex =
                                  (_duaIndex - 1 + _duas.length) % _duas.length),
                            ),
                          ],
                        ),
                        const SizedBox(height: RamadanScreen._sectionGap),

                        // ── Hadith (Full Width) ──────────────────────────
                        _HadithCard(
                          hadith: _hadiths[_hadithIndex],
                          index: _hadithIndex,
                          total: _hadiths.length,
                          onDotTap: (i) =>
                              setState(() => _hadithIndex = i),
                        ),
                        const SizedBox(height: RamadanScreen._sectionGap),

                        // ── Charity + Last 10 Nights ──────────────────────
                        _ResponsiveCardGrid(
                          minChildWidth: 170,
                          children: [
                            _CharityCard(
                                ramadanDay: info.isRamadan ? info.day : 0),
                            _LastTenNightsCard(
                                ramadanDay: info.isRamadan ? info.day : 0),
                          ],
                        ),
                        const SizedBox(height: RamadanScreen._sectionGap),

                        // ── Statistics ────────────────────────────────────
                        _StatisticsCard(
                          ramadanDay: info.isRamadan ? info.day : 0,
                          goals: _goals,
                        ),
                        const SizedBox(height: RamadanScreen._sectionGap),

                        const _BlessingFooter(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TOP BAR
// ════════════════════════════════════════════════════════════════════════════

class _RamadanTopBar extends StatelessWidget {
  const _RamadanTopBar({required this.onMenuTap});
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _IconTile(icon: Icons.arrow_forward_ios_rounded, onTap: onMenuTap),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ramadan',
                style: GoogleFonts.poppins(
                  color: RamadanScreen._ivory,
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  height: .95,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: .45),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _DecorativeDivider(width: 46),
                  const SizedBox(width: 8),
                  Text(
                    'Blessed Month of Mercy',
                    style: GoogleFonts.poppins(
                      color: RamadanScreen._softGold,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _DecorativeDivider(width: 46),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _IconTile(icon: Icons.notifications_none_rounded, onTap: () {}),
                Positioned(
                  top: -3,
                  right: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: RamadanScreen._softGold,
                      shape: BoxShape.circle,
                    ),
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

// ════════════════════════════════════════════════════════════════════════════
// HERO CARD — drawn CustomPaint, no Image.asset dependency
// ════════════════════════════════════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.hijriYear,
    required this.day,
    required this.daysLeft,
    required this.isRamadan,
    required this.daysUntilNext,
    required this.progress,
  });

  final int hijriYear, day, daysLeft, daysUntilNext;
  final bool isRamadan;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      height: 260,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Custom-drawn mosque + crescent moon background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(RamadanScreen._cardRadius),
              child: CustomPaint(painter: _MoonMosquePainter()),
            ),
          ),
          // Left-side gradient so text is readable
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(RamadanScreen._cardRadius),
                gradient: LinearGradient(
                  colors: [
                    RamadanScreen._darkGreen.withValues(alpha: .97),
                    RamadanScreen._emerald.withValues(alpha: .80),
                    RamadanScreen._deepGreen.withValues(alpha: .02),
                  ],
                  stops: const [0, .55, 1],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _CircularDayProgress(
                  day: isRamadan ? day : 0,
                  total: 30,
                  progress: progress.clamp(0.0, 1.0),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ramadan $hijriYear AH',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: RamadanScreen._softGold,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isRamadan) ...[
                        Text(
                          '${_ordinal(day)} Ramadan',
                          style: const TextStyle(
                            color: RamadanScreen._text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          daysLeft > 0
                              ? '$daysLeft Days Remaining'
                              : 'Last Day of Ramadan',
                          style: const TextStyle(
                            color: RamadanScreen._success,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '$daysUntilNext days until Ramadan',
                          style: const TextStyle(
                            color: RamadanScreen._text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Prepare your heart & soul',
                          style: TextStyle(
                            color: RamadanScreen._success,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const _DecorativeDivider(width: 150),
                      const SizedBox(height: 14),
                      const Text(
                        '"O you who believe!\nFasting is prescribed for you\nas it was prescribed for\nthose before you."',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: RamadanScreen._text,
                          fontSize: 13,
                          height: 1.32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        '(Al-Baqarah 2:183)',
                        style: TextStyle(
                          color: RamadanScreen._softGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

/// Draws a crescent moon + mosque silhouette — no asset files required.
class _MoonMosquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [RamadanScreen._darkGreen, const Color(0xFF0E3E30)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Stars (deterministic positions via trig)
    final starPaint = Paint()
      ..color = RamadanScreen._ivory.withValues(alpha: .65);
    for (var i = 0; i < 32; i++) {
      final x = w * 0.38 +
          (math.sin(i * 12.9898 + 1.0) * 43758.5453).abs() % (w * 0.60);
      final y = (math.cos(i * 78.233 + 0.5) * 24634.6345).abs() % (h * 0.72);
      canvas.drawCircle(Offset(x, y), i % 6 == 0 ? 1.5 : 0.75, starPaint);
    }

    // Crescent moon
    _drawCrescent(canvas, Offset(w * 0.77, h * 0.23), h * 0.155);

    // Mosque silhouette
    _drawMosque(canvas, size);
  }

  void _drawCrescent(Canvas canvas, Offset center, double radius) {
    // Full circle (gold)
    canvas.drawCircle(center, radius,
        Paint()..color = RamadanScreen._softGold);
    // Cutout circle to form crescent
    canvas.drawCircle(
      Offset(center.dx + radius * 0.38, center.dy - radius * 0.08),
      radius * 0.84,
      Paint()..color = const Color(0xFF0E3E30),
    );
    // Glow
    canvas.drawCircle(
      center,
      radius * 1.45,
      Paint()
        ..color = RamadanScreen._softGold.withValues(alpha: .10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
  }

  void _drawMosque(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()
      ..color = RamadanScreen._darkGreen.withValues(alpha: .97)
      ..style = PaintingStyle.fill;

    // Ground
    canvas.drawRect(Rect.fromLTWH(w * 0.38, h * 0.70, w, h * 0.30), fill);

    // Left minaret
    canvas.drawRect(
        Rect.fromLTWH(w * 0.40, h * 0.38, w * 0.038, h * 0.32), fill);
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.399, h * 0.38)
          ..lineTo(w * 0.419, h * 0.29)
          ..lineTo(w * 0.439, h * 0.38)
          ..close(),
        fill);

    // Right minaret
    canvas.drawRect(
        Rect.fromLTWH(w * 0.90, h * 0.38, w * 0.038, h * 0.32), fill);
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.89, h * 0.38)
          ..lineTo(w * 0.919, h * 0.29)
          ..lineTo(w * 0.939, h * 0.38)
          ..close(),
        fill);

    // Left small dome
    final ld = Path()
      ..moveTo(w * 0.455, h * 0.70)
      ..lineTo(w * 0.455, h * 0.64)
      ..arcToPoint(Offset(w * 0.555, h * 0.64),
          radius: Radius.elliptical(w * 0.05, h * 0.055), clockwise: false)
      ..lineTo(w * 0.555, h * 0.70)
      ..close();
    canvas.drawPath(ld, fill);

    // Central large dome
    final cd = Path()
      ..moveTo(w * 0.535, h * 0.70)
      ..lineTo(w * 0.535, h * 0.55)
      ..arcToPoint(Offset(w * 0.805, h * 0.55),
          radius: Radius.elliptical(w * 0.135, h * 0.13), clockwise: false)
      ..lineTo(w * 0.805, h * 0.70)
      ..close();
    canvas.drawPath(cd, fill);

    // Right small dome
    final rd = Path()
      ..moveTo(w * 0.785, h * 0.70)
      ..lineTo(w * 0.785, h * 0.64)
      ..arcToPoint(Offset(w * 0.885, h * 0.64),
          radius: Radius.elliptical(w * 0.05, h * 0.055), clockwise: false)
      ..lineTo(w * 0.885, h * 0.70)
      ..close();
    canvas.drawPath(rd, fill);

    // Gold base-line accent
    canvas.drawLine(
      Offset(w * 0.38, h * 0.70),
      Offset(w, h * 0.70),
      Paint()
        ..color = RamadanScreen._gold.withValues(alpha: .48)
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(w * 0.38, h * 0.70),
      Offset(w, h * 0.70),
      Paint()
        ..color = RamadanScreen._softGold.withValues(alpha: .10)
        ..strokeWidth = 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ════════════════════════════════════════════════════════════════════════════
// CIRCULAR DAY PROGRESS
// ════════════════════════════════════════════════════════════════════════════

class _CircularDayProgress extends StatelessWidget {
  const _CircularDayProgress({
    required this.day,
    required this.total,
    required this.progress,
  });

  final int day, total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      height: 118,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(118),
            painter: _ProgressRingPainter(progress: progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Day',
                  style: TextStyle(
                      color: RamadanScreen._text, fontSize: 16)),
              Text(
                day == 0 ? '--' : '$day',
                style: GoogleFonts.poppins(
                  color: RamadanScreen._text,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  height: .9,
                ),
              ),
              const SizedBox(height: 3),
              Text('of $total',
                  style: const TextStyle(
                      color: RamadanScreen._text, fontSize: 16)),
            ],
          ),
          // Removed the star icon based on user request
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 9;
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..color = RamadanScreen._ivory.withValues(alpha: .16));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(colors: [
          RamadanScreen._softGold,
          RamadanScreen._gold,
          RamadanScreen._softGold,
        ]).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) =>
      old.progress != progress;
}



// ════════════════════════════════════════════════════════════════════════════
// IFTAR / SUHOOR COUNTDOWN CARD
// ════════════════════════════════════════════════════════════════════════════

class _IftarCountdownCard extends StatelessWidget {
  const _IftarCountdownCard({
    required this.mode,
    required this.countdownStr,
    required this.countdownLabel,
    required this.suhoorTime,
    required this.iftarTime,
    required this.isLoading,
    required this.isFastCompleted,
    required this.onToggleFast,
  });

  final _CountdownMode mode;
  final String countdownStr, countdownLabel, suhoorTime, iftarTime;
  final bool isLoading;
  final bool isFastCompleted;
  final VoidCallback onToggleFast;

  @override
  Widget build(BuildContext context) {
    final isDone    = mode == _CountdownMode.done;
    final isSuhoor  = mode == _CountdownMode.suhoor;
    final timeColor = isDone
        ? RamadanScreen._success
        : isSuhoor
            ? RamadanScreen._success
            : RamadanScreen._softGold;

    return _PremiumCard(
      height: 252,
      child: Column(
        children: [
          // Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  countdownLabel,
                  style: GoogleFonts.poppins(
                    color: RamadanScreen._text,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isDone
                    ? Icons.check_circle_rounded
                    : isSuhoor
                        ? Icons.wb_twilight_rounded
                        : Icons.nightlight_round,
                color: timeColor,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Main countdown / status display
          Expanded(
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: RamadanScreen._softGold,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : isDone
                    ? Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onToggleFast,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                    child: Icon(
                                      isFastCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      key: ValueKey(isFastCompleted),
                                      color: isFastCompleted ? RamadanScreen._success : RamadanScreen._mutedText,
                                      size: 38,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isFastCompleted ? 'Allahu Akbar!' : 'Did you fast today?',
                                    style: GoogleFonts.poppins(
                                      color: isFastCompleted ? RamadanScreen._success : RamadanScreen._text,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    isFastCompleted ? 'Fast Complete for Today' : 'Tap to mark as complete',
                                    style: const TextStyle(
                                      color: RamadanScreen._mutedText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            countdownStr,
                            style: GoogleFonts.poppins(
                              color: timeColor,
                              fontSize: 50,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
            ),
          ),
          const _DecorativeDivider(width: double.infinity),
          const SizedBox(height: 10),
          // Suhoor / Iftar times
          Row(
            children: [
              Expanded(
                child: _TimeItem(
                  icon: Icons.wb_twilight_rounded,
                  label: 'Suhoor',
                  time: suhoorTime,
                  highlight: isSuhoor,
                ),
              ),
              const SizedBox(
                  height: 52,
                  child: VerticalDivider(color: RamadanScreen._gold)),
              Expanded(
                child: _TimeItem(
                  icon: Icons.nightlight_round,
                  label: 'Iftar',
                  time: iftarTime,
                  highlight: !isSuhoor && !isDone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeItem extends StatelessWidget {
  const _TimeItem({
    required this.icon,
    required this.label,
    required this.time,
    this.highlight = false,
  });

  final IconData icon;
  final String label, time;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? RamadanScreen._success : RamadanScreen._softGold;
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(time,
              style: GoogleFonts.poppins(
                  color: RamadanScreen._text,
                  fontSize: 23,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// GOALS CARD — interactive tap-to-toggle
// ════════════════════════════════════════════════════════════════════════════

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({
    required this.goals,
    required this.completedCount,
    required this.onToggle,
  });

  final List<bool> goals;
  final int completedCount;
  final void Function(int) onToggle;

  @override
  Widget build(BuildContext context) {
    final allDone = completedCount == goals.length;
    return _PremiumCard(
      height: 252,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Goals",
                      style: GoogleFonts.poppins(
                        color: RamadanScreen._text,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$completedCount/${goals.length} Completed',
                      style: TextStyle(
                        color: allDone
                            ? RamadanScreen._softGold
                            : RamadanScreen._success,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const _RoundIcon(icon: Icons.track_changes_rounded),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 0.62,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goals.length,
              itemBuilder: (context, i) => _GoalBubble(
                goal: _goalItems[i],
                done: goals[i],
                onTap: () => onToggle(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalBubble extends StatelessWidget {
  const _GoalBubble({
    required this.goal,
    required this.done,
    required this.onTap,
  });

  final _GoalData goal;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? RamadanScreen._emerald.withValues(alpha: .9)
                      : RamadanScreen._darkGreen.withValues(alpha: .85),
                  border: Border.all(
                    color: done
                        ? RamadanScreen._success
                        : RamadanScreen._gold.withValues(alpha: .78),
                    width: done ? 1.5 : 1.0,
                  ),
                  boxShadow: done
                      ? [
                          BoxShadow(
                            color:
                                RamadanScreen._success.withValues(alpha: .28),
                            blurRadius: 10,
                          )
                        ]
                      : null,
                ),
                child: Icon(goal.icon,
                    color: done
                        ? RamadanScreen._success
                        : RamadanScreen._softGold,
                    size: 17),
              ),
              Positioned(
                right: -2,
                bottom: -3,
                child: Icon(
                  done ? Icons.check_circle : Icons.circle_outlined,
                  color: done
                      ? RamadanScreen._success
                      : RamadanScreen._gold,
                  size: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              goal.label,
              style: TextStyle(
                color:
                    done ? RamadanScreen._success : RamadanScreen._text,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// QURAN PROGRESS CARD — dynamic from Ramadan day
// ════════════════════════════════════════════════════════════════════════════

class _QuranProgressCard extends ConsumerWidget {
  const _QuranProgressCard({required this.ramadanDay});
  final int ramadanDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastRead = ref.watch(lastReadProvider);
    
    double progress = 0.0;
    int percent = 0;
    int juz = 1;
    int ayahsRead = 0;

    if (lastRead != null) {
      progress = QuranData.getOverallProgress(lastRead.surahNumber, lastRead.ayahNumber);
      percent = (progress * 100).round();
      juz = QuranData.getJuzForAyah(lastRead.surahNumber, lastRead.ayahNumber);
      ayahsRead = QuranData.getAbsoluteAyahNumber(lastRead.surahNumber, lastRead.ayahNumber);
    }

    return _PremiumCard(
      height: 282,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Quran Progress'),
          const SizedBox(height: 18),
          Row(
            children: [
              const _RoundIcon(icon: Icons.menu_book_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    lastRead == null ? 'Juz 1\n0%' : 'Juz $juz\n$percent%',
                    style: GoogleFonts.poppins(
                      color: RamadanScreen._softGold,
                      fontSize: 28,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProgressBar(value: progress),
          const SizedBox(height: 6),
          Text(
            '$ayahsRead / 6236 Ayahs',
            style: const TextStyle(
                color: RamadanScreen._mutedText, fontSize: 11),
          ),
          const SizedBox(height: 12),
          _OutlineButton(
            label: 'Continue Reading',
            onTap: () {
              final lastRead = ref.read(lastReadProvider);
              
              if (lastRead != null) {
                int juzNumber = QuranData.getJuzForAyah(lastRead.surahNumber, lastRead.ayahNumber);
                int indexInJuz = QuranData.getAyahIndexInJuz(lastRead.surahNumber, lastRead.ayahNumber);
                context.push('/quran/juz/$juzNumber?ayah=$indexInJuz&name=Juz%20$juzNumber');
              } else {
                context.go('/quran?tab=1'); // Opens the QuranListScreen directly onto the Juz tab (index 1)
              }
            },
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DUA CARD — swipeable carousel with prev/next buttons
// ════════════════════════════════════════════════════════════════════════════

class _DuaCard extends StatelessWidget {
  const _DuaCard({
    required this.dua,
    required this.index,
    required this.total,
    required this.onNext,
    required this.onPrev,
  });

  final _DuaData dua;
  final int index, total;
  final VoidCallback onNext, onPrev;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      height: 282,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _CardTitle('Daily Dua')),
              const _RoundIcon(icon: Icons.volume_up_rounded, small: true),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dua.arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    color: RamadanScreen._softGold,
                    fontSize: 18,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dua.translation,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RamadanScreen._mutedText,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dua.source,
                  style: const TextStyle(
                    color: RamadanScreen._softGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onPrev,
                child: const Icon(Icons.chevron_left_rounded,
                    color: RamadanScreen._softGold, size: 28),
              ),
              Row(
                children: List.generate(
                  total,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: i == index ? 16 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == index
                          ? RamadanScreen._softGold
                          : RamadanScreen._ivory.withValues(alpha: .25),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onNext,
                child: const Icon(Icons.chevron_right_rounded,
                    color: RamadanScreen._softGold, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// HADITH CARD — tappable pagination dots
// ════════════════════════════════════════════════════════════════════════════

class _HadithCard extends StatelessWidget {
  const _HadithCard({
    required this.hadith,
    required this.index,
    required this.total,
    required this.onDotTap,
  });

  final _HadithData hadith;
  final int index, total;
  final void Function(int) onDotTap;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      height: 194,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: _CardTitle('Daily Hadith')),
              _RoundIcon(icon: Icons.format_quote_rounded, small: true),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    hadith.text,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: RamadanScreen._text,
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hadith.source,
                  style: const TextStyle(
                    color: RamadanScreen._softGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              total,
              (i) => GestureDetector(
                onTap: () => onDotTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == index ? 18 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == index
                        ? RamadanScreen._softGold
                        : RamadanScreen._ivory.withValues(alpha: .28),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CHARITY CARD — dynamic amount based on Ramadan day
// ════════════════════════════════════════════════════════════════════════════

class _CharityCard extends StatelessWidget {
  const _CharityCard({required this.ramadanDay});
  final int ramadanDay;

  @override
  Widget build(BuildContext context) {
    final amount   = ramadanDay * 24.50;
    final progress = (amount / 735.0).clamp(0.0, 1.0);

    return _PremiumCard(
      height: 286,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showArt     = constraints.maxWidth >= 220;
          final artWidth    = showArt ? 92.0 : 0.0;
          final contentWidth = math.max(120.0, constraints.maxWidth - artWidth);

          return FittedBox(
            alignment: Alignment.topLeft,
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: contentWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _CardTitle('Charity Tracker'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const _RoundIcon(
                                icon: Icons.volunteer_activism_rounded),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'This Ramadan',
                                    style: TextStyle(
                                      color: RamadanScreen._text,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '\$${amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: RamadanScreen._softGold,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Monthly Goal \$735',
                          style: TextStyle(
                              color: RamadanScreen._mutedText, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        _ProgressBar(value: progress),
                        const SizedBox(height: 12),
                        _OutlineButton(
                          label: 'Donate Now',
                          icon: Icons.favorite_border_rounded,
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Charity feature coming soon!')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showArt) ...[
                    const SizedBox(width: 10),
                    const _CharityIllustration(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// LAST 10 NIGHTS CARD — dynamic active nights
// ════════════════════════════════════════════════════════════════════════════

class _LastTenNightsCard extends StatelessWidget {
  const _LastTenNightsCard({required this.ramadanDay});
  final int ramadanDay;

  @override
  Widget build(BuildContext context) {
    final nightsStarted = ramadanDay > 20;
    final activeNights  = nightsStarted ? (ramadanDay - 20).clamp(0, 10) : 0;
    final nightLabel = nightsStarted
        ? 'Night $activeNights of 10'
        : ramadanDay == 0
            ? 'Awaiting Ramadan'
            : ramadanDay <= 20
                ? '${21 - ramadanDay} days away'
                : 'Complete';

    return _PremiumCard(
      height: 286,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardTitle('Last 10 Nights'),
                const SizedBox(height: 8),
                Text(
                  nightLabel,
                  style: TextStyle(
                    color: nightsStarted
                        ? RamadanScreen._success
                        : RamadanScreen._mutedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: List.generate(
                    10,
                    (i) => Expanded(
                        child: _NightMarker(index: i, active: i < activeNights)),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Seek Laylatul Qadr in the odd nights:\n21st, 23rd, 25th, 27th, 29th.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RamadanScreen._mutedText,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                _OutlineButton(
                  label: 'View Tracker',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Night tracker coming soon!')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const _LanternArt(),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// STATISTICS CARD — dynamic from Ramadan day + goals
// ════════════════════════════════════════════════════════════════════════════

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard({required this.ramadanDay, required this.goals});
  final int ramadanDay;
  final List<bool> goals;

  @override
  Widget build(BuildContext context) {
    final fasts       = ramadanDay.clamp(0, 30);
    final pages       = ramadanDay * 18;
    final dhikr       = ramadanDay * 270;
    final dhikrStr    = dhikr >= 1000
        ? '${(dhikr / 1000).toStringAsFixed(1)}K'
        : '$dhikr';
    final duas        = ramadanDay + 6;
    final salahDone   = goals.where((g) => g).length;

    final stats = [
      _StatData(Icons.wb_sunny_outlined, 'Fasts\nCompleted', '$fasts', 'Days'),
      _StatData(Icons.menu_book_rounded, 'Quran\nRead', '$pages', 'Pages'),
      _StatData(Icons.radio_button_checked_rounded, 'Dhikr Count',
          dhikrStr, 'Times'),
      _StatData(Icons.fact_check_outlined, "Dua's Read", '$duas', "Dua's"),
      _StatData(Icons.workspace_premium_outlined, 'Salah Today',
          '$salahDone/${goals.length}', 'Prayers'),
    ];

    return _PremiumCard(
      height: 194,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded,
                  color: RamadanScreen._softGold, size: 24),
              SizedBox(width: 10),
              _CardTitle('Ramadan Statistics'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    SizedBox(width: 104, child: _StatItem(stat: stats[i])),
                    if (i != stats.length - 1)
                      Container(
                        width: 1,
                        height: 66,
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        color: RamadanScreen._gold.withValues(alpha: .45),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// BLESSING FOOTER
// ════════════════════════════════════════════════════════════════════════════

class _BlessingFooter extends StatelessWidget {
  const _BlessingFooter();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      height: 136,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Stack(
        children: [
          Positioned(
            left: -8,
            bottom: -16,
            child: Icon(
              Icons.mosque_rounded,
              color: RamadanScreen._softGold.withValues(alpha: .22),
              size: 82,
            ),
          ),
          Positioned(
            right: -4,
            top: -6,
            child: Icon(
              Icons.light_rounded,
              color: RamadanScreen._softGold.withValues(alpha: .40),
              size: 60,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'May Allah accept our fasts, prayers, and good deeds.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: RamadanScreen._softGold,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ramadan Mubarak',
                  style: GoogleFonts.poppins(
                    color: RamadanScreen._success,
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
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

// ════════════════════════════════════════════════════════════════════════════
// UTILITY WIDGETS (shared design system)
// ════════════════════════════════════════════════════════════════════════════

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        color: RamadanScreen._text,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.05,
      ),
    );
  }
}

class _ResponsiveCardGrid extends StatelessWidget {
  const _ResponsiveCardGrid({
    required this.children,
    this.minChildWidth = 250,
  });

  final List<Widget> children;
  final double minChildWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = math.max(1, constraints.maxWidth ~/ minChildWidth);
      final spacing = columns == 1 ? 0.0 : RamadanScreen._sectionGap;
      final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: RamadanScreen._sectionGap,
        children:
            children.map((c) => SizedBox(width: width, child: c)).toList(),
      );
    });
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.child,
    this.height,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final double? height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RamadanScreen._cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RamadanScreen._emerald.withValues(alpha: .9),
            RamadanScreen._darkGreen.withValues(alpha: .98),
          ],
        ),
        border: Border.all(
            color: RamadanScreen._gold.withValues(alpha: .78), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .33),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: RamadanScreen._gold.withValues(alpha: .08),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RamadanBackground extends StatelessWidget {
  const _RamadanBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  RamadanScreen._deepGreen,
                  RamadanScreen._darkGreen,
                  RamadanScreen._deepGreen,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -110,
          left: -80,
          right: -80,
          height: 320,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  RamadanScreen._emerald.withValues(alpha: .44),
                  RamadanScreen._emerald.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: .04,
            child: GridPaper(
              color: RamadanScreen._gold,
              interval: 34,
              divisions: 2,
              subdivisions: 1,
            ),
          ),
        ),
        const Positioned.fill(child: _StarField()),
      ],
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _StarPainter());
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RamadanScreen._softGold.withValues(alpha: .45);
    for (var i = 0; i < 42; i++) {
      final x = (math.sin(i * 12.9898) * 43758.5453).abs() % size.width;
      final y =
          ((math.cos(i * 78.233) * 24634.6345).abs() % 260) + 4;
      canvas.drawCircle(
          Offset(x, y), i % 7 == 0 ? 1.3 : .7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: RamadanScreen._darkGreen.withValues(alpha: .92),
          border:
              Border.all(color: RamadanScreen._gold.withValues(alpha: .68)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .24),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: RamadanScreen._softGold, size: 29),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, this.small = false});

  final IconData icon;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = small ? 38.0 : 54.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: RamadanScreen._darkGreen.withValues(alpha: .8),
        border:
            Border.all(color: RamadanScreen._gold.withValues(alpha: .74)),
        boxShadow: [
          BoxShadow(
            color: RamadanScreen._gold.withValues(alpha: .14),
            blurRadius: 18,
          ),
        ],
      ),
      child: Icon(icon,
          color: RamadanScreen._softGold, size: small ? 20 : 27),
    );
  }
}

class _DecorativeDivider extends StatelessWidget {
  const _DecorativeDivider({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == double.infinity ? null : width,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          RamadanScreen._gold.withValues(alpha: 0),
          RamadanScreen._gold,
          RamadanScreen._gold.withValues(alpha: 0),
        ]),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 7,
        backgroundColor: RamadanScreen._success.withValues(alpha: .42),
        valueColor:
            const AlwaysStoppedAnimation<Color>(RamadanScreen._softGold),
      ),
    );
  }
}

/// Outline action button — fixed: uses nullable [IconData?] to avoid equality bug.
class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    this.icon,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: RamadanScreen._darkGreen.withValues(alpha: .42),
          border:
              Border.all(color: RamadanScreen._gold.withValues(alpha: .55)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: RamadanScreen._softGold, size: 15),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: RamadanScreen._softGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: RamadanScreen._softGold, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CharityIllustration extends StatelessWidget {
  const _CharityIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: RamadanScreen._gold.withValues(alpha: .7)),
              gradient: LinearGradient(colors: [
                RamadanScreen._gold.withValues(alpha: .22),
                RamadanScreen._darkGreen,
              ]),
            ),
            child: const Icon(Icons.favorite_rounded,
                color: RamadanScreen._softGold, size: 30),
          ),
          Positioned(
            top: 6,
            child: Icon(
              Icons.local_florist_rounded,
              color: RamadanScreen._success.withValues(alpha: .8),
              size: 44,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanternArt extends StatelessWidget {
  const _LanternArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
              width: 2,
              height: 118,
              color: RamadanScreen._gold.withValues(alpha: .5)),
          Positioned(
            bottom: 8,
            child: Container(
              width: 48,
              height: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: RadialGradient(colors: [
                  RamadanScreen._softGold.withValues(alpha: .74),
                  RamadanScreen._gold.withValues(alpha: .22),
                  RamadanScreen._deepGreen.withValues(alpha: .88),
                ]),
                border: Border.all(
                    color: RamadanScreen._gold.withValues(alpha: .74)),
                boxShadow: [
                  BoxShadow(
                    color: RamadanScreen._softGold.withValues(alpha: .28),
                    blurRadius: 26,
                  ),
                ],
              ),
              child: const Icon(Icons.light_mode_rounded,
                  color: RamadanScreen._softGold, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _NightMarker extends StatelessWidget {
  const _NightMarker({required this.index, required this.active});

  final int index;
  final bool active;

  @override
  Widget build(BuildContext context) {
    // Odd indices (0,2,4,6,8) = the odd nights 21,23,25,27,29 — Laylatul Qadr candidates
    final isOdd = index % 2 == 0;
    return Container(
      height: 28,
      margin: const EdgeInsets.only(right: 3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? (isOdd
                ? RamadanScreen._softGold
                : RamadanScreen._emerald)
            : RamadanScreen._darkGreen.withValues(alpha: .68),
        border: Border.all(
          color: isOdd
              ? RamadanScreen._gold.withValues(alpha: .90)
              : RamadanScreen._gold.withValues(alpha: .45),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: (isOdd
                          ? RamadanScreen._softGold
                          : RamadanScreen._emerald)
                      .withValues(alpha: .35),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: active
                ? RamadanScreen._deepGreen
                : RamadanScreen._mutedText,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.stat});
  final _StatData stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(stat.icon, color: RamadanScreen._softGold, size: 26),
        const SizedBox(height: 7),
        Text(
          stat.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: RamadanScreen._text,
            fontSize: 11,
            height: 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          stat.value,
          style: GoogleFonts.poppins(
            color: RamadanScreen._softGold,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.unit,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: RamadanScreen._text,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
