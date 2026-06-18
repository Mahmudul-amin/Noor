import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RamadanScreen extends StatelessWidget {
  const RamadanScreen({super.key});

  static const _emerald = Color(0xFF0B5D4A);
  static const _darkGreen = Color(0xFF083D31);
  static const _deepGreen = Color(0xFF031B17);
  static const _gold = Color(0xFFD4AF37);
  static const _softGold = Color(0xFFFFC46B);
  static const _success = Color(0xFF79D88E);
  static const _ivory = Color(0xFFF8F6F1);
  static const _text = Color(0xFFF5F1E8);
  static const _mutedText = Color(0xBFF5F1E8);

  static const _pagePadding = 14.0;
  static const _cardRadius = 24.0;
  static const _sectionGap = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepGreen,
      body: Stack(
        children: [
          const Positioned.fill(child: _RamadanBackground()),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    _pagePadding,
                    10,
                    _pagePadding,
                    110,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _RamadanTopBar(onMenuTap: () => context.go('/home')),
                        const SizedBox(height: 12),
                        const _RamadanProgressHero(),
                        const SizedBox(height: _sectionGap),
                        const _ResponsiveCardGrid(
                          minChildWidth: 170,
                          children: [
                            _IftarCountdownCard(),
                            _GoalsCard(),
                          ],
                        ),
                        const SizedBox(height: _sectionGap),
                        const _ResponsiveCardGrid(
                          minChildWidth: 112,
                          children: [
                            _QuranProgressCard(),
                            _DailyDuaCard(),
                            _DailyHadithCard(),
                          ],
                        ),
                        const SizedBox(height: _sectionGap),
                        const _ResponsiveCardGrid(
                          minChildWidth: 170,
                          children: [
                            _CharityCard(),
                            _LastTenNightsCard(),
                          ],
                        ),
                        const SizedBox(height: _sectionGap),
                        const _StatisticsCard(),
                        const SizedBox(height: _sectionGap),
                        const _BlessingFooter(),
                      ],
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
            child: _IconTile(icon: Icons.menu_rounded, onTap: onMenuTap),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ramadan',
                style: GoogleFonts.cormorantGaramond(
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
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _DecorativeDivider(width: 46),
                  const SizedBox(width: 8),
                  Text(
                    'Blessed Month of Mercy',
                    style: GoogleFonts.cormorantGaramond(
                      color: RamadanScreen._softGold,
                      fontSize: 20,
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

class _RamadanProgressHero extends StatelessWidget {
  const _RamadanProgressHero();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      height: 260,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          const Positioned.fill(child: _HeroImage()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(RamadanScreen._cardRadius),
                gradient: LinearGradient(
                  colors: [
                    RamadanScreen._darkGreen.withValues(alpha: .96),
                    RamadanScreen._emerald.withValues(alpha: .82),
                    RamadanScreen._deepGreen.withValues(alpha: .06),
                  ],
                  stops: const [0, .45, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const _CircularDayProgress(),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ramadan 1446 AH',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          color: RamadanScreen._softGold,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '12th Ramadan',
                        style: TextStyle(
                          color: RamadanScreen._text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        '18 Days Remaining',
                        style: TextStyle(
                          color: RamadanScreen._success,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _DecorativeDivider(width: 150),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 8),
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

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RamadanScreen._cardRadius),
      child: Image.asset(
        'assets/images/ramadan_kareem_hero.png',
        fit: BoxFit.cover,
        alignment: Alignment.centerRight,
      ),
    );
  }
}

class _CircularDayProgress extends StatelessWidget {
  const _CircularDayProgress();

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
            painter: _ProgressRingPainter(progress: .4),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Day',
                style: TextStyle(color: RamadanScreen._text, fontSize: 16),
              ),
              Text(
                '12',
                style: GoogleFonts.cormorantGaramond(
                  color: RamadanScreen._text,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  height: .9,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'of 30',
                style: TextStyle(color: RamadanScreen._text, fontSize: 16),
              ),
            ],
          ),
          Positioned(
            right: 0,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: RamadanScreen._softGold,
              size: 20,
              shadows: [
                Shadow(
                  color: RamadanScreen._softGold.withValues(alpha: .8),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
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
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = RamadanScreen._ivory.withValues(alpha: .16);
    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          RamadanScreen._softGold,
          RamadanScreen._gold,
          RamadanScreen._softGold,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, base);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      active,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _IftarCountdownCard extends StatelessWidget {
  const _IftarCountdownCard();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      minHeight: 164,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Iftar in',
                style: GoogleFonts.cormorantGaramond(
                  color: RamadanScreen._text,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.nightlight_round,
                color: RamadanScreen._softGold,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '02:14:35',
              style: GoogleFonts.cormorantGaramond(
                color: RamadanScreen._softGold,
                fontSize: 50,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _DecorativeDivider(width: double.infinity),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _TimeItem(
                  icon: Icons.wb_twilight_rounded,
                  label: 'Suhoor',
                  time: '04:12 AM',
                ),
              ),
              SizedBox(
                  height: 52,
                  child: VerticalDivider(color: RamadanScreen._gold)),
              Expanded(
                child: _TimeItem(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Iftar',
                  time: '06:41 PM',
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
  });

  final IconData icon;
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: RamadanScreen._softGold, size: 25),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: RamadanScreen._softGold,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            time,
            style: GoogleFonts.cormorantGaramond(
              color: RamadanScreen._text,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalsCard extends StatelessWidget {
  const _GoalsCard();

  @override
  Widget build(BuildContext context) {
    const goals = [
      _GoalData(Icons.wb_twilight_rounded, 'Fajr', true),
      _GoalData(Icons.menu_book_rounded, 'Quran', true),
      _GoalData(Icons.radio_button_checked_rounded, 'Dhikr', true),
      _GoalData(Icons.nightlight_round, 'Tahajjud', false),
      _GoalData(Icons.light_mode_outlined, 'Dhuhr', true),
      _GoalData(Icons.wb_sunny_outlined, 'Asr', true),
      _GoalData(Icons.wb_twilight_outlined, 'Maghrib', true),
      _GoalData(Icons.dark_mode_rounded, 'Isha', true),
    ];

    return _PremiumCard(
      minHeight: 164,
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
                      style: GoogleFonts.cormorantGaramond(
                        color: RamadanScreen._text,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '6/8 Completed',
                      style: TextStyle(
                        color: RamadanScreen._success,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const _RoundIcon(icon: Icons.track_changes_rounded),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 9,
            crossAxisSpacing: 8,
            childAspectRatio: .78,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: goals.map((goal) => _GoalBubble(goal: goal)).toList(),
          ),
        ],
      ),
    );
  }
}

class _GoalData {
  const _GoalData(this.icon, this.label, this.done);

  final IconData icon;
  final String label;
  final bool done;
}

class _GoalBubble extends StatelessWidget {
  const _GoalBubble({required this.goal});

  final _GoalData goal;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RamadanScreen._darkGreen.withValues(alpha: .85),
                border: Border.all(
                  color: RamadanScreen._gold.withValues(alpha: .78),
                ),
              ),
              child: Icon(goal.icon, color: RamadanScreen._softGold, size: 23),
            ),
            Positioned(
              right: -2,
              bottom: -3,
              child: Icon(
                goal.done ? Icons.check_circle : Icons.circle_outlined,
                color: goal.done ? RamadanScreen._success : RamadanScreen._gold,
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            goal.label,
            style: const TextStyle(
              color: RamadanScreen._text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuranProgressCard extends StatelessWidget {
  const _QuranProgressCard();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      minHeight: 154,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('Quran Progress'),
          const Spacer(),
          Row(
            children: [
              const _RoundIcon(icon: Icons.menu_book_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Juz 12\n67%',
                    style: GoogleFonts.cormorantGaramond(
                      color: RamadanScreen._softGold,
                      fontSize: 29,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const _ProgressBar(value: .67),
          const SizedBox(height: 12),
          const _OutlineButton(label: 'Continue Reading'),
        ],
      ),
    );
  }
}

class _DailyDuaCard extends StatelessWidget {
  const _DailyDuaCard();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      minHeight: 154,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: _CardTitle('Daily Dua')),
              _RoundIcon(icon: Icons.volume_up_rounded, small: true),
            ],
          ),
          const Spacer(),
          Center(
            child: Text(
              'اللَّهُمَّ إِنَّكَ عَفُوٌّ\nتُحِبُّ العَفْوَ فَاعْفُ عَنِّي',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                color: RamadanScreen._softGold,
                fontSize: 22,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'O Allah, You are Most Forgiving, You love forgiveness, so forgive me.',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: RamadanScreen._mutedText,
              fontSize: 11,
              height: 1.25,
            ),
          ),
          const Spacer(),
          const _OutlineButton(label: 'View Full Dua'),
        ],
      ),
    );
  }
}

class _DailyHadithCard extends StatelessWidget {
  const _DailyHadithCard();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      minHeight: 154,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: _CardTitle('Daily Hadith')),
              _RoundIcon(icon: Icons.format_quote_rounded, small: true),
            ],
          ),
          const Spacer(),
          const Text(
            '"Whoever fasts Ramadan with faith and seeking reward will have his past sins forgiven."',
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: RamadanScreen._text,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sahih Bukhari',
            style: TextStyle(
              color: RamadanScreen._softGold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const _PaginationDots(),
        ],
      ),
    );
  }
}

class _CharityCard extends StatelessWidget {
  const _CharityCard();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      minHeight: 168,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardTitle('Charity Tracker'),
                const Spacer(),
                const Row(
                  children: [
                    _RoundIcon(icon: Icons.volunteer_activism_rounded),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This Ramadan',
                            style: TextStyle(
                              color: RamadanScreen._text,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '\$320.00',
                            style: TextStyle(
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
                const Spacer(),
                const Text(
                  'Daily Goal \$50',
                  style:
                      TextStyle(color: RamadanScreen._mutedText, fontSize: 12),
                ),
                const SizedBox(height: 8),
                const _ProgressBar(value: .68),
                const SizedBox(height: 12),
                const _OutlineButton(
                    label: 'Donate Now', icon: Icons.favorite_border_rounded),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const _CharityIllustration(),
        ],
      ),
    );
  }
}

class _LastTenNightsCard extends StatelessWidget {
  const _LastTenNightsCard();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      minHeight: 168,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardTitle('Last 10 Nights'),
                const SizedBox(height: 8),
                const Text(
                  'Night 2 of 10',
                  style: TextStyle(
                    color: RamadanScreen._success,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    10,
                    (index) => Expanded(child: _NightMarker(index: index)),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Seek Laylatul Qadr in the last ten nights of Ramadan.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RamadanScreen._mutedText,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const Spacer(),
                const _OutlineButton(label: 'View Tracker'),
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

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard();

  @override
  Widget build(BuildContext context) {
    const stats = [
      _StatData(Icons.wb_sunny_outlined, 'Fasts\nCompleted', '12', 'Days'),
      _StatData(Icons.menu_book_rounded, 'Quran\nRead', '24', 'Pages'),
      _StatData(
          Icons.radio_button_checked_rounded, 'Dhikr Count', '3,240', 'Times'),
      _StatData(Icons.fact_check_outlined, "Dua's Read", '18', "Dua's"),
      _StatData(Icons.workspace_premium_outlined, 'Salah Completion', '92%',
          'On Time'),
    ];

    return _PremiumCard(
      minHeight: 132,
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
          const SizedBox(height: 18),
          SingleChildScrollView(
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
        ],
      ),
    );
  }
}

class _BlessingFooter extends StatelessWidget {
  const _BlessingFooter();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      minHeight: 92,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Stack(
        children: [
          Positioned(
            left: -8,
            bottom: -16,
            child: Icon(
              Icons.mosque_rounded,
              color: RamadanScreen._softGold.withValues(alpha: .24),
              size: 82,
            ),
          ),
          Positioned(
            right: -4,
            top: -6,
            child: Icon(
              Icons.light_rounded,
              color: RamadanScreen._softGold.withValues(alpha: .42),
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
                  style: GoogleFonts.cormorantGaramond(
                    color: RamadanScreen._softGold,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ramadan Mubarak',
                  style: GoogleFonts.cormorantGaramond(
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

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.cormorantGaramond(
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = math.max(1, constraints.maxWidth ~/ minChildWidth);
        final spacing = columns == 1 ? 0.0 : RamadanScreen._sectionGap;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: RamadanScreen._sectionGap,
          children: children
              .map((child) => SizedBox(width: width, child: child))
              .toList(),
        );
      },
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.child,
    this.minHeight,
    this.height,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final double? minHeight;
  final double? height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints:
          minHeight == null ? null : BoxConstraints(minHeight: minHeight!),
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
          color: RamadanScreen._gold.withValues(alpha: .78),
          width: 1.1,
        ),
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
            opacity: .045,
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
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarPainter());
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RamadanScreen._softGold.withValues(alpha: .45);
    for (var i = 0; i < 42; i++) {
      final x = (math.sin(i * 12.9898) * 43758.5453).abs() % size.width;
      final y = ((math.cos(i * 78.233) * 24634.6345).abs() % 260) + 4;
      canvas.drawCircle(Offset(x, y), i % 7 == 0 ? 1.3 : .7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
          border: Border.all(color: RamadanScreen._gold.withValues(alpha: .68)),
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
        border: Border.all(color: RamadanScreen._gold.withValues(alpha: .74)),
        boxShadow: [
          BoxShadow(
            color: RamadanScreen._gold.withValues(alpha: .14),
            blurRadius: 18,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: RamadanScreen._softGold,
        size: small ? 20 : 27,
      ),
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
        gradient: LinearGradient(
          colors: [
            RamadanScreen._gold.withValues(alpha: 0),
            RamadanScreen._gold,
            RamadanScreen._gold.withValues(alpha: 0),
          ],
        ),
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

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    this.icon = Icons.chevron_right_rounded,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: RamadanScreen._darkGreen.withValues(alpha: .42),
        border: Border.all(color: RamadanScreen._gold.withValues(alpha: .55)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != Icons.chevron_right_rounded) ...[
            Icon(icon, color: RamadanScreen._softGold, size: 18),
            const SizedBox(width: 8),
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
          const SizedBox(width: 7),
          const Icon(
            Icons.chevron_right_rounded,
            color: RamadanScreen._softGold,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _PaginationDots extends StatelessWidget {
  const _PaginationDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          width: index == 0 ? 8 : 7,
          height: index == 0 ? 8 : 7,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == 0
                ? RamadanScreen._softGold
                : RamadanScreen._ivory.withValues(alpha: .32),
          ),
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
              border:
                  Border.all(color: RamadanScreen._gold.withValues(alpha: .7)),
              gradient: LinearGradient(
                colors: [
                  RamadanScreen._gold.withValues(alpha: .22),
                  RamadanScreen._darkGreen,
                ],
              ),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: RamadanScreen._softGold,
              size: 30,
            ),
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
                gradient: RadialGradient(
                  colors: [
                    RamadanScreen._softGold.withValues(alpha: .74),
                    RamadanScreen._gold.withValues(alpha: .22),
                    RamadanScreen._deepGreen.withValues(alpha: .88),
                  ],
                ),
                border: Border.all(
                    color: RamadanScreen._gold.withValues(alpha: .74)),
                boxShadow: [
                  BoxShadow(
                    color: RamadanScreen._softGold.withValues(alpha: .28),
                    blurRadius: 26,
                  ),
                ],
              ),
              child: const Icon(
                Icons.light_mode_rounded,
                color: RamadanScreen._softGold,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NightMarker extends StatelessWidget {
  const _NightMarker({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final active = index < 2;
    return Container(
      height: 28,
      margin: const EdgeInsets.only(right: 3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? RamadanScreen._softGold
            : RamadanScreen._darkGreen.withValues(alpha: .68),
        border: Border.all(color: RamadanScreen._gold.withValues(alpha: .72)),
        boxShadow: active
            ? [
                BoxShadow(
                  color: RamadanScreen._softGold.withValues(alpha: .3),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: active ? RamadanScreen._deepGreen : RamadanScreen._text,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatData {
  const _StatData(this.icon, this.label, this.value, this.unit);

  final IconData icon;
  final String label;
  final String value;
  final String unit;
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
          style: GoogleFonts.cormorantGaramond(
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
          style: GoogleFonts.cormorantGaramond(
            color: RamadanScreen._text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
