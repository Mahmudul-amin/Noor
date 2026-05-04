import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../prayer/providers/prayer_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../habit/providers/habit_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final prayerState = ref.watch(prayerProvider);
    final habitState = ref.watch(habitProvider);
    final name = auth.displayName ?? 'Ahmed';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── DARK HEADER ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: _HeaderSection(
                name: name,
                prayerState: prayerState,
              ),
            ),

            // ── BODY CONTENT ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Quick Actions
                  _SectionHeader(
                    title: 'Quick Actions',
                    actionLabel: 'See All',
                    onAction: () {},
                  ),
                  const SizedBox(height: 14),
                  _QuickActionsGrid(ctx: context),
                  const SizedBox(height: 24),

                  // Daily Ayah
                  const _SectionTitle(title: 'Daily Ayah'),
                  const SizedBox(height: 12),
                  const _DailyAyahCard(),
                  const SizedBox(height: 24),

                  // Daily Hadith
                  const _SectionTitle(title: 'Daily Hadith'),
                  const SizedBox(height: 12),
                  const _DailyHadithCard(),
                  const SizedBox(height: 24),

                  // Today's Progress
                  _SectionHeader(
                    title: "Today's Progress",
                    actionLabel: 'View All',
                    onAction: () => context.push('/habits'),
                  ),
                  const SizedBox(height: 12),
                  _TodaysProgressCard(habitState: habitState),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HEADER SECTION (dark bg + hero card)
// ══════════════════════════════════════════════════════════════
class _HeaderSection extends StatelessWidget {
  final String name;
  final PrayerState prayerState;
  const _HeaderSection({required this.name, required this.prayerState});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1F14),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            children: [
              // Top row
              Row(
                children: [
                  // Profile avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white24,
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Greeting
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assalamu Alaikum,',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Notification bell
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Hero Prayer Card
              _HeroPrayerCard(prayerState: prayerState),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HERO PRAYER CARD
// ══════════════════════════════════════════════════════════════
class _HeroPrayerCard extends StatefulWidget {
  final PrayerState prayerState;
  const _HeroPrayerCard({required this.prayerState});

  @override
  State<_HeroPrayerCard> createState() => _HeroPrayerCardState();
}

class _HeroPrayerCardState extends State<_HeroPrayerCard> {
  late String _countdown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _countdown = '--:--:--';
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final next = widget.prayerState.nextPrayerTime;
    if (!mounted || next == null) return;
    final diff = next.difference(DateTime.now());
    if (diff.isNegative) {
      setState(() => _countdown = '00:00:00');
      return;
    }
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    setState(() => _countdown = '$h:$m:$s');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F9D58), Color(0xFF0D3B24), Color(0xFF0D1B2A)],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F9D58).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Mosque silhouette (right side)
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              child: SizedBox(
                width: 155,
                child: CustomPaint(painter: _MosquePainter()),
              ),
            ),
            // Content (left side)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 0, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next Prayer',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.prayerState.nextPrayerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _countdown,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Colors.white70, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.prayerState.nextPrayerTimeFormatted}  •  ${widget.prayerState.times?.location ?? "New York, USA"}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mosque silhouette painter
class _MosquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    // Moon
    final moonPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.18), 22, moonPaint);
    // Crescent overlay
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.12),
      18,
      Paint()..color = const Color(0xFF0D3B24),
    );

    // Stars
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    _drawStar(canvas, Offset(size.width * 0.28, size.height * 0.10), 3, starPaint);
    _drawStar(canvas, Offset(size.width * 0.82, size.height * 0.25), 2.5, starPaint);

    // Main dome
    final domePath = Path();
    final cx = size.width * 0.48;
    final baseY = size.height * 0.92;
    domePath.moveTo(cx - 38, baseY);
    domePath.quadraticBezierTo(cx - 38, baseY - 55, cx, baseY - 68);
    domePath.quadraticBezierTo(cx + 38, baseY - 55, cx + 38, baseY);
    domePath.close();
    canvas.drawPath(domePath, paint);

    // Left minaret
    final lm = Path();
    lm.addRect(Rect.fromLTWH(cx - 62, baseY - 75, 14, 75));
    canvas.drawPath(lm, paint);
    final lmTop = Path();
    lmTop.moveTo(cx - 62, baseY - 75);
    lmTop.lineTo(cx - 55, baseY - 95);
    lmTop.lineTo(cx - 48, baseY - 75);
    lmTop.close();
    canvas.drawPath(lmTop, paint);

    // Right minaret
    final rm = Path();
    rm.addRect(Rect.fromLTWH(cx + 48, baseY - 60, 14, 60));
    canvas.drawPath(rm, paint);
    final rmTop = Path();
    rmTop.moveTo(cx + 48, baseY - 60);
    rmTop.lineTo(cx + 55, baseY - 78);
    rmTop.lineTo(cx + 62, baseY - 60);
    rmTop.close();
    canvas.drawPath(rmTop, paint);

    // Ground
    final groundPaint = Paint()..color = Colors.white.withValues(alpha: 0.06);
    canvas.drawRect(Rect.fromLTWH(0, baseY, size.width, size.height - baseY), groundPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    canvas.drawCircle(center, r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════
// QUICK ACTIONS GRID (2 rows × dynamic)
// ══════════════════════════════════════════════════════════════
class _QuickActionsGrid extends StatelessWidget {
  final BuildContext ctx;
  const _QuickActionsGrid({required this.ctx});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QAItem(Icons.menu_book_rounded, 'Quran', '/quran'),
      _QAItem(Icons.access_time_filled_rounded, 'Prayer Times', '/prayer'),
      _QAItem(Icons.explore_rounded, 'Qibla', '/qibla'),
      _QAItem(Icons.front_hand_rounded, 'Duas', '/ai-chat'),
      _QAItem(Icons.blur_circular_rounded, 'Tasbih', '/tasbih'),
      _QAItem(Icons.calculate_outlined, 'Zakat', '/habits'),
      _QAItem(Icons.calendar_month_rounded, 'Calendar', '/calendar'),
    ];

    return Column(
      children: [
        // Row 1: 4 items
        Row(
          children: [
            for (int i = 0; i < 4; i++) ...[
              Expanded(child: _QuickActionCard(item: actions[i], ctx: ctx)),
              if (i < 3) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // Row 2: 3 items left-aligned
        Row(
          children: [
            Expanded(child: _QuickActionCard(item: actions[4], ctx: ctx)),
            const SizedBox(width: 10),
            Expanded(child: _QuickActionCard(item: actions[5], ctx: ctx)),
            const SizedBox(width: 10),
            Expanded(child: _QuickActionCard(item: actions[6], ctx: ctx)),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

class _QAItem {
  final IconData icon;
  final String label;
  final String route;
  const _QAItem(this.icon, this.label, this.route);
}

class _QuickActionCard extends StatelessWidget {
  final _QAItem item;
  final BuildContext ctx;
  const _QuickActionCard({required this.item, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ctx.push(item.route),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: AppColors.primary, size: 50),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DAILY AYAH CARD
// ══════════════════════════════════════════════════════════════
class _DailyAyahCard extends StatelessWidget {
  const _DailyAyahCard();

  @override
  Widget build(BuildContext context) {
    final ayahs = [
      {
        'surah': 'Surah Al-Baqarah (2:286)',
        'arabic': 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
        'translation': 'Allah does not burden a soul beyond that it can bear.',
        'num': '286',
      },
      {
        'surah': 'Surah Al-Inshirah (94:6)',
        'arabic': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
        'translation': 'Indeed, with hardship comes ease.',
        'num': '6',
      },
      {
        'surah': 'Surah At-Talaq (65:3)',
        'arabic': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
        'translation': 'And whoever relies upon Allah — then He is sufficient for him.',
        'num': '3',
      },
    ];
    final ayah = ayahs[DateTime.now().day % ayahs.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  ayah['surah']!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Icon(Icons.share_outlined,
                    color: Colors.grey.shade400, size: 18),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gold, width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      ayah['num']!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ayah['arabic']!,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.8,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ayah['translation']!,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DAILY HADITH CARD
// ══════════════════════════════════════════════════════════════
class _DailyHadithCard extends StatelessWidget {
  const _DailyHadithCard();

  @override
  Widget build(BuildContext context) {
    final hadiths = [
      {'text': 'The best of you are those who learn the Quran and teach it.', 'source': 'Sahih Bukhari'},
      {'text': 'None of you truly believes until he loves for his brother what he loves for himself.', 'source': 'Sahih Bukhari & Muslim'},
      {'text': 'Smiling at your brother is charity.', 'source': 'At-Tirmidhi'},
    ];
    final h = hadiths[DateTime.now().day % hadiths.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Text(
                  '"',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    h['text']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111827),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    h['source']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.share_outlined, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TODAY'S PROGRESS CARD
// ══════════════════════════════════════════════════════════════
class _TodaysProgressCard extends StatelessWidget {
  final HabitState habitState;
  const _TodaysProgressCard({required this.habitState});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            _ProgressItem(
              icon: Icons.mosque_rounded,
              label: 'Salah',
              progress: '${habitState.salahCount} / 5',
            ),
            _ProgressItem(
              icon: Icons.menu_book_rounded,
              label: 'Quran',
              progress: habitState.quranDone ? '1 / 1' : '0 / 1',
            ),
            _ProgressItem(
              icon: Icons.rotate_right_rounded,
              label: 'Dhikr',
              progress: habitState.dhikrDone ? '100 / 100' : '45 / 100',
            ),
            _ProgressItem(
              icon: Icons.front_hand_rounded,
              label: 'Duas',
              progress: '2 / 3',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String progress;
  const _ProgressItem({
    required this.icon,
    required this.label,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            progress,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'See All',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }
}
