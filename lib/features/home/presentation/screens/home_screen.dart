import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui';
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
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          child: Column(
            children: [
              // Top row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
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
              ),
              const SizedBox(height: 16),
              // Hero Prayer Card (Full Width)
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
    _countdown = _countdownText();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(covariant _HeroPrayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prayerState.nextPrayerTime !=
        widget.prayerState.nextPrayerTime) {
      _tick();
    }
  }

  void _tick() {
    final next = widget.prayerState.nextPrayerTime;
    if (!mounted) return;
    _setCountdown(_countdownText(next));
  }

  String _countdownText([DateTime? nextPrayerTime]) {
    final next = nextPrayerTime ?? widget.prayerState.nextPrayerTime;
    if (next == null) return '--:--:--';
    final diff = next.difference(DateTime.now());
    if (diff.isNegative) return '00:00:00';
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _setCountdown(String value) {
    if (_countdown == value) return;

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _countdown == value) return;
        setState(() => _countdown = value);
      });
      return;
    }

    setState(() => _countdown = value);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Content (left side)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
    );
  }
}

// ══════════════════════════════════════════════════════════════
// QUICK ACTIONS GRID (3 rows × 4 columns - Compact Layout)
// ══════════════════════════════════════════════════════════════
class _QuickActionsGrid extends StatelessWidget {
  final BuildContext ctx;
  const _QuickActionsGrid({required this.ctx});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QAItem(null, 'Quran', '/quran',
          isImage: true, assetPath: 'assets/images/Quran.png'),
      _QAItem(Icons.auto_stories_rounded, 'Printed Quran', '/pdf'),
      _QAItem(null, 'Prayer Times', '/prayer',
          isImage: true, assetPath: 'assets/images/prayer.png'),
      _QAItem(null, 'Qibla', '/qibla',
          isImage: true, assetPath: 'assets/images/qibla.png'),
      _QAItem(null, 'Duas', '/duas',
          isImage: true, assetPath: 'assets/images/dua.png'),
      _QAItem(null, 'Tasbih', '/tasbih',
          isImage: true, assetPath: 'assets/images/tasbih.png'),
      _QAItem(Icons.nights_stay_rounded, 'Ramadan', '/ramadan'),
      _QAItem(Icons.menu_book_rounded, 'Hadith', '/hadith'),
      _QAItem(Icons.calendar_month_rounded, 'Calendar', '/calendar'),
      _QAItem(null, 'Zakat', '/habits',
          isImage: true, assetPath: 'assets/images/zakat.png'),
      _QAItem(Icons.favorite_rounded, 'Donate Us', '/donate'),
      _QAItem(Icons.person_rounded, 'Profile', '/profile'),
    ];

    return Column(
      children: [
        // Row 1: 5 items
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < 5; i++) ...[
              _QuickActionCard(item: actions[i], ctx: ctx),
              if (i < 4) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: 5 items
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 5; i < 10; i++) ...[
              _QuickActionCard(item: actions[i], ctx: ctx),
              if (i < 9) const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // Row 3: remaining items
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 10; i < actions.length; i++) ...[
              _QuickActionCard(item: actions[i], ctx: ctx),
              if (i < actions.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class _QAItem {
  final IconData? icon;
  final String label;
  final String route;
  final bool isImage;
  final String? assetPath;
  const _QAItem(this.icon, this.label, this.route,
      {this.isImage = false, this.assetPath});
}

class _QuickActionCard extends StatelessWidget {
  final _QAItem item;
  final BuildContext ctx;
  const _QuickActionCard({required this.item, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.route == '/pdf') {
          ctx.push('/pdf', extra: {
            'title': 'Printed Quran (Mushaf)',
            'url': 'https://www.pdfquran.com/download/big/big-quran.pdf',
            'image': 'assets/images/Quran.png',
          });
        } else if (item.route == '/ramadan' ||
            item.route == '/home' ||
            item.route == '/quran' ||
            item.route == '/prayer' ||
            item.route == '/duas' ||
            item.route == '/donate' ||
            item.route == '/hadith' ||
            item.route == '/profile' ||
            item.route == '/books') {
          ctx.go(item.route);
        } else {
          ctx.push(item.route);
        }
      },
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            item.isImage
                ? SizedBox(
                    width: 52,
                    height: 50,
                    child: Image.asset(item.assetPath!, fit: BoxFit.contain),
                  )
                : item.label == 'Donate Us'
                    ? SizedBox(
                        width: 38,
                        height: 38,
                        child: Stack(
                          children: [
                            // 1. Green Fingers / Fingers Base (Full Icon in Primary Green)
                            const Icon(
                              Icons.volunteer_activism_rounded,
                              color: AppColors.primary,
                              size: 38,
                            ),
                            // 2. Gold Hand Grip / Palm (Clipped Bottom 42% in Gold on top, no offset shifting!)
                            ClipRect(
                              clipper: _BottomHalfClipper(),
                              child: const Icon(
                                Icons.volunteer_activism_rounded,
                                color: AppColors.gold,
                                size: 38,
                              ),
                            ),
                            // 3. Red Heart overlay on the very top
                            const Positioned(
                              top: 0,
                              right: 2,
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Icon(item.icon, color: AppColors.primary, size: 38),
            const SizedBox(height: 1),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: item.isImage ? FontWeight.bold : FontWeight.w600,
                color: const Color(0xFF111827),
                height: 1.1,
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
        'translation':
            'And whoever relies upon Allah — then He is sufficient for him.',
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
      {
        'text': 'The best of you are those who learn the Quran and teach it.',
        'source': 'Sahih Bukhari'
      },
      {
        'text':
            'None of you truly believes until he loves for his brother what he loves for himself.',
        'source': 'Sahih Bukhari & Muslim'
      },
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
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Row(
          children: [
            _ProgressItem(
              assetPath: 'assets/images/salah.png',
              isImage: true,
              label: 'Salah',
              progress: '${habitState.salahCount} / 5',
              size: 58,
            ),
            _ProgressItem(
              assetPath: 'assets/images/Quran.png',
              isImage: true,
              label: 'Quran',
              progress: habitState.quranDone ? '1 / 1' : '0 / 1',
              size: 54,
            ),
            _ProgressItem(
              assetPath: 'assets/images/dhikr_logo.png',
              isImage: true,
              label: 'Dhikr',
              progress: habitState.dhikrDone ? '100 / 100' : '45 / 100',
              size: 54,
            ),
            _ProgressItem(
              assetPath: 'assets/images/dua.png',
              isImage: true,
              label: 'Duas',
              progress: '2 / 3',
              size: 54,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String progress;
  final bool isImage;
  final String? assetPath;
  final double size;

  const _ProgressItem({
    this.icon,
    required this.label,
    required this.progress,
    this.isImage = false,
    this.assetPath,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 64,
            child: Center(
              child: isImage && assetPath != null
                  ? Image.asset(assetPath!,
                      height: size, width: size, fit: BoxFit.contain)
                  : Icon(icon, color: AppColors.primary, size: size),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            progress,
            style: const TextStyle(
              fontSize: 16,
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(
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
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }
}

class _BottomHalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, size.height * 0.58, size.width, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
