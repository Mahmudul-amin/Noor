import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../providers/prayer_provider.dart';

// ─────────────────────────── Main Screen ────────────────────────────────────

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  Timer? _timer;
  DateTime _now = DateTime.now();
  final Set<String> _enabledNotifications = {'Fajr', 'Dhuhr', 'Maghrib'};

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _PrayerPalette.darkMode(isDark);

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: palette.background,
          body: Stack(
            children: [
              Positioned.fill(child: _PatternBackdrop(color: palette.gold)),
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _PrayerHeader(
                            palette: palette,
                            onMenuTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/home');
                              }
                            },
                            onLocationTap: () =>
                                ref.read(prayerProvider.notifier).loadPrayerTimes(),
                          ).animate().fadeIn(duration: 420.ms).slideY(begin: -0.08),
                          const SizedBox(height: 20),
                          _HeroPrayerCard(
                            state: state,
                            now: _now,
                            glow: _glowController.value,
                            palette: palette,
                          ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.08),
                          const SizedBox(height: 16),
                          if (state.isLoading)
                            _LoadingCard(palette: palette)
                          else
                            _PrayerTimelineCard(
                              palette: palette,
                              prayers: _prayersFor(state),
                              activeName: state.nextPrayerName,
                              enabledNotifications: _enabledNotifications,
                              onToggle: (name) {
                                setState(() {
                                  if (_enabledNotifications.contains(name)) {
                                    _enabledNotifications.remove(name);
                                  } else {
                                    _enabledNotifications.add(name);
                                  }
                                });
                              },
                            ).animate().fadeIn(delay: 140.ms).slideY(begin: 0.08),
                          const SizedBox(height: 16),
                          _InfoCard(
                            palette: palette,
                            hijri: _hijriDate(),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08),
                          const SizedBox(height: 16),
                          _TahajjudCard(palette: palette)
                              .animate()
                              .fadeIn(delay: 260.ms)
                              .slideY(begin: 0.08),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_PrayerItem> _prayersFor(PrayerState state) {
    final times = state.times;
    return [
      _PrayerItem('Fajr', times?.fajr ?? '--:--', Icons.wb_twilight_outlined),
      _PrayerItem('Sunrise', times?.sunrise ?? '--:--', Icons.wb_sunny_outlined),
      _PrayerItem('Dhuhr', times?.dhuhr ?? '--:--', Icons.light_mode_outlined),
      _PrayerItem('Asr', times?.asr ?? '--:--', Icons.filter_drama_outlined),
      _PrayerItem('Maghrib', times?.maghrib ?? '--:--', Icons.wb_sunny_outlined),
      _PrayerItem('Isha', times?.isha ?? '--:--', Icons.nights_stay_outlined),
    ];
  }

  String _hijriDate() {
    final hijri = HijriCalendar.now();
    return '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH';
  }
}

// ─────────────────────────── Color Palette ─────────────────────────────────

class _PrayerPalette {
  final Color background;
  final Color card;
  final Color green;
  final Color darkGreen;
  final Color gold;
  final Color lightGold;
  final Color text;
  final Color muted;
  final Color border;
  final Color shadow;

  const _PrayerPalette({
    required this.background,
    required this.card,
    required this.green,
    required this.darkGreen,
    required this.gold,
    required this.lightGold,
    required this.text,
    required this.muted,
    required this.border,
    required this.shadow,
  });

  factory _PrayerPalette.darkMode(bool isDark) {
    return const _PrayerPalette(
      background: Color(0xFF021B17),
      card: Color(0xFF032A24),
      green: Color(0xFF0B5C4B),
      darkGreen: Color(0xFF032A24),
      gold: Color(0xFFD6A64B),
      lightGold: Color(0xFFEBC978),
      text: Color(0xFFF8F5EF),
      muted: Color.fromRGBO(255, 255, 255, 0.60),
      border: Color.fromRGBO(214, 166, 75, 0.30),
      shadow: Color.fromRGBO(8, 80, 60, 0.45),
    );
  }
}

// ─────────────────────────── Header ────────────────────────────────────────

class _PrayerHeader extends StatelessWidget {
  final _PrayerPalette palette;
  final VoidCallback onMenuTap;
  final VoidCallback onLocationTap;

  const _PrayerHeader({
    required this.palette,
    required this.onMenuTap,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SquareButton(icon: Icons.chevron_left_rounded, palette: palette, onTap: onMenuTap),
        Expanded(
          child: Column(
            children: [
              Text(
                'Prayer Times',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  color: palette.text,
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Ornament(color: palette.gold),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Stay connected with your prayers',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: palette.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  _Ornament(color: palette.gold),
                ],
              ),
            ],
          ),
        ),
        _SquareButton(icon: Icons.location_on_outlined, palette: palette, onTap: onLocationTap),
      ],
    );
  }
}

// ──────────────────────── Hero Prayer Card ──────────────────────────────────

class _HeroPrayerCard extends StatelessWidget {
  final PrayerState state;
  final DateTime now;
  final double glow;
  final _PrayerPalette palette;

  const _HeroPrayerCard({
    required this.state,
    required this.now,
    required this.glow,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      palette: palette,
      radius: 24,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 260,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Arch pattern background
              CustomPaint(painter: _ArchPatternPainter(palette)),
              // Golden atmospheric glow behind mosque
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 240,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.2, 0.2),
                      radius: 0.9,
                      colors: [
                        palette.lightGold.withValues(alpha: 0.25),
                        palette.green.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Mosque illustration – right half
              Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                width: 230,
                child: Image.asset(
                  'assets/images/mosque.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomRight,
                ),
              ),
              // Left-to-right gradient fade so text is always readable
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      stops: const [0.0, 0.50, 0.72, 1.0],
                      colors: [
                        palette.card,
                        palette.card.withValues(alpha: 0.90),
                        palette.card.withValues(alpha: 0.40),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Text column — left side
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: 120,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date
                      Text(
                        DateFormat('EEEE, d MMMM yyyy').format(now),
                        style: GoogleFonts.inter(
                          color: palette.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Hijri
                      Text(
                        _hijriText(),
                        style: GoogleFonts.inter(
                          color: palette.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: palette.gold, size: 14),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              state.times?.location ?? 'Makkah, Saudi Arabia',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: palette.gold,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: palette.gold, size: 14),
                        ],
                      ),
                      const Spacer(),
                      // Next Prayer pill
                      _NextPrayerPanel(
                        palette: palette,
                        name: state.nextPrayerName,
                        countdown: _countdownText(state.nextPrayerTime, now),
                        glow: glow,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hijriText() {
    final hijri = HijriCalendar.now();
    return '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH';
  }

  String _countdownText(DateTime? next, DateTime now) {
    if (next == null) return '--:--:--';
    final diff = next.difference(now);
    final safeDiff = diff.isNegative ? Duration.zero : diff;
    final h = safeDiff.inHours.toString().padLeft(2, '0');
    final m = (safeDiff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (safeDiff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

// ──────────────────────── Next Prayer Panel ─────────────────────────────────

class _NextPrayerPanel extends StatelessWidget {
  final _PrayerPalette palette;
  final String name;
  final String countdown;
  final double glow;

  const _NextPrayerPanel({
    required this.palette,
    required this.name,
    required this.countdown,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    final pulse = 0.55 + (glow * 0.45);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: palette.background.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: palette.gold.withValues(alpha: 0.06 + pulse * 0.10),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Moon badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.green.withValues(alpha: 0.40),
                  boxShadow: [
                    BoxShadow(
                      color: palette.gold.withValues(alpha: 0.10 + glow * 0.18),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(Icons.nights_stay_rounded, color: palette.gold, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next Prayer',
                    style: GoogleFonts.inter(
                      color: palette.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    name,
                    style: GoogleFonts.cinzel(
                      color: palette.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    countdown,
                    style: GoogleFonts.inter(
                      color: palette.gold,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────── Prayer Timeline Card ──────────────────────────────

class _PrayerTimelineCard extends StatelessWidget {
  final _PrayerPalette palette;
  final List<_PrayerItem> prayers;
  final String activeName;
  final Set<String> enabledNotifications;
  final ValueChanged<String> onToggle;

  const _PrayerTimelineCard({
    required this.palette,
    required this.prayers,
    required this.activeName,
    required this.enabledNotifications,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      palette: palette,
      radius: 24,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(
        children: [
          // Vertical timeline accent line
          Positioned(
            left: 32,
            top: 28,
            bottom: 28,
            child: Container(width: 1, color: palette.gold.withValues(alpha: 0.22)),
          ),
          Column(
            children: [
              for (var i = 0; i < prayers.length; i++) ...[
                _PrayerTimelineRow(
                  palette: palette,
                  item: prayers[i],
                  isActive: prayers[i].name == activeName,
                  notificationsOn: enabledNotifications.contains(prayers[i].name),
                  onToggle: () => onToggle(prayers[i].name),
                ).animate().fadeIn(delay: (60 + i * 40).ms),
                if (i != prayers.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 64, right: 16),
                    child: Divider(
                      height: 1,
                      color: palette.gold.withValues(alpha: 0.10),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerTimelineRow extends StatelessWidget {
  final _PrayerPalette palette;
  final _PrayerItem item;
  final bool isActive;
  final bool notificationsOn;
  final VoidCallback onToggle;

  const _PrayerTimelineRow({
    required this.palette,
    required this.item,
    required this.isActive,
    required this.notificationsOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isActive ? palette.gold.withValues(alpha: 0.06) : Colors.transparent,
      ),
      child: Row(
        children: [
          // Icon circle (sits on the timeline line)
          SizedBox(
            width: 46,
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? palette.gold.withValues(alpha: 0.18)
                      : palette.background.withValues(alpha: 0.65),
                  border: Border.all(
                    color: isActive
                        ? palette.gold.withValues(alpha: 0.55)
                        : palette.border,
                  ),
                ),
                child: Icon(
                  item.icon,
                  size: 18,
                  color: isActive ? palette.gold : palette.muted.withValues(alpha: 0.70),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Prayer name
          Expanded(
            child: Text(
              item.name,
              style: GoogleFonts.inter(
                color: isActive ? palette.text : palette.muted,
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          // Prayer time
          Text(
            _fmt12(item.time),
            style: GoogleFonts.inter(
              color: isActive ? palette.gold : palette.muted.withValues(alpha: 0.80),
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          // Notification bell
          _NotificationButton(palette: palette, active: notificationsOn, onTap: onToggle),
        ],
      ),
    );
  }

  String _fmt12(String t) {
    if (t == '--:--' || !t.contains(':')) return t;
    final p = t.split(':');
    final h = int.tryParse(p[0]) ?? 0;
    final m = p[1].padLeft(2, '0');
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m ${h >= 12 ? 'PM' : 'AM'}';
  }
}

// ──────────────────────── Info Card ─────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final _PrayerPalette palette;
  final String hijri;

  const _InfoCard({required this.palette, required this.hijri});

  @override
  Widget build(BuildContext context) {
    final items = [
      _InfoItem(Icons.explore_outlined, 'Qibla Direction', '248°'),
      _InfoItem(Icons.near_me_outlined, 'Qibla Distance', '1247 km'),
      _InfoItem(Icons.nights_stay_outlined, 'Islamic Calendar', hijri),
      _InfoItem(Icons.schedule_outlined, 'Juristic Method', 'Muslim World\nLeague'),
    ];

    return _GlassCard(
      palette: palette,
      radius: 24,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(child: _InfoCell(palette: palette, item: items[i])),
            if (i != items.length - 1)
              Container(width: 1, height: 60, color: palette.border),
          ],
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final _PrayerPalette palette;
  final _InfoItem item;

  const _InfoCell({required this.palette, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(item.icon, color: palette.muted, size: 24),
        const SizedBox(height: 8),
        Text(
          item.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: palette.muted,
            fontSize: 10,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          item.value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: palette.gold,
            fontSize: 14,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────── Tahajjud Card ─────────────────────────────────────

class _TahajjudCard extends StatelessWidget {
  final _PrayerPalette palette;

  const _TahajjudCard({required this.palette});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      palette: palette,
      radius: 24,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: arch/lantern illustration fills column height
              SizedBox(
                width: 130,
                child: Image.asset(
                  'assets/images/tahajjud.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                ),
              ),
              // Right: text + button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 14, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tahajjud Time',
                        style: GoogleFonts.cinzel(
                          color: palette.text,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'The best time to pray is during the last third of the night.',
                        style: GoogleFonts.inter(
                          color: palette.muted,
                          fontSize: 13,
                          height: 1.55,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: palette.text,
                                side: BorderSide(color: palette.border),
                                minimumSize: const Size(0, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              child: const Text('Set Reminder'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {},
                              child: Ink(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: palette.background.withValues(alpha: 0.60),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: palette.border),
                                ),
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  color: palette.text,
                                  size: 21,
                                ),
                              ),
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
      ),
    );
  }
}

// ──────────────────────── Shared Widgets ────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final _PrayerPalette palette;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const _GlassCard({
    required this.palette,
    required this.child,
    required this.padding,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: palette.card.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final _PrayerPalette palette;
  final VoidCallback onTap;
  const _SquareButton({
    required this.icon,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(icon, color: palette.text, size: 24),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final _PrayerPalette palette;
  final bool active;
  final VoidCallback onTap;

  const _NotificationButton({
    required this.palette,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: active ? 1 : 0.95,
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.background.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: Icon(
              active ? Icons.volume_up_outlined : Icons.volume_off_outlined,
              color: active ? palette.gold : palette.muted.withValues(alpha: 0.60),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _Ornament extends StatelessWidget {
  final Color color;
  const _Ornament({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(32, 8), painter: _OrnamentPainter(color));
  }
}

class _LoadingCard extends StatelessWidget {
  final _PrayerPalette palette;
  const _LoadingCard({required this.palette});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      palette: palette,
      radius: 24,
      padding: const EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator(color: palette.gold)),
    );
  }
}

// ──────────────────────── Data Models ───────────────────────────────────────

class _PrayerItem {
  final String name;
  final String time;
  final IconData icon;
  const _PrayerItem(this.name, this.time, this.icon);
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem(this.icon, this.label, this.value);
}

// ──────────────────────── Background Pattern ─────────────────────────────────

class _PatternBackdrop extends StatelessWidget {
  final Color color;
  const _PatternBackdrop({required this.color});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _BackgroundPatternPainter(color));
}

class _BackgroundPatternPainter extends CustomPainter {
  final Color color;
  _BackgroundPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    const step = 36.0;
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
  bool shouldRepaint(covariant _BackgroundPatternPainter old) => old.color != color;
}

class _ArchPatternPainter extends CustomPainter {
  final _PrayerPalette palette;
  _ArchPatternPainter(this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    // Soft golden radial glow on the right half where the mosque image lives
    final rect = Offset(size.width * 0.44, -size.height * 0.1) &
        Size(size.width * 0.65, size.height * 1.2);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          palette.lightGold.withValues(alpha: 0.18),
          palette.gold.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _ArchPatternPainter old) => false;
}

class _OrnamentPainter extends CustomPainter {
  final Color color;
  _OrnamentPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2 + 5, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 - 5, size.height / 2)
      ..close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _OrnamentPainter old) => false;
}
