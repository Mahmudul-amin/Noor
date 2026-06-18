import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../../core/constants/app_colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('en');
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F14),
        foregroundColor: Colors.white,
        title: const Text(
          'Islamic Calendar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: '🌙 Hijri'),
            Tab(text: '📅 English'),
            Tab(text: '🌿 Bangla'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _HijriCalendarTab(),
          _EnglishCalendarTab(),
          _BanglaCalendarTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────
class _TodayBanner extends StatelessWidget {
  final String label;
  final String dateStr;
  const _TodayBanner({required this.label, required this.dateStr});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F9D58), Color(0xFF0D3B24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.today_rounded, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text(dateStr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> dayHeaders;
  final int daysInMonth;
  final int startingWeekday; // 0 = Sunday, 1 = Monday, etc.
  final int currentDay; // 1-based, -1 if not current month
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Color accentColor;
  final String Function(int) digitConverter;
  final Map<int, String>? subtitleForDay;

  const _CalendarGrid({
    required this.title,
    required this.subtitle,
    required this.dayHeaders,
    required this.daysInMonth,
    required this.startingWeekday,
    required this.currentDay,
    required this.onPrev,
    required this.onNext,
    this.accentColor = AppColors.primary,
    required this.digitConverter,
    this.subtitleForDay,
  });

  @override
  Widget build(BuildContext context) {
    // Generate grid cells
    final cells = <Widget>[];
    
    // Empty cells for offset
    for (int i = 0; i < startingWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }
    
    // Day cells
    for (int d = 1; d <= daysInMonth; d++) {
      final isToday = d == currentDay;
      final gridIndex = startingWeekday + d - 1;
      final isFriday = (gridIndex % 7 == 5);
      
      Color bgColor = isToday ? accentColor : Colors.transparent;
      Color textColor = isToday 
          ? Colors.white 
          : (isFriday ? accentColor : const Color(0xFF374151));

      cells.add(
        Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                digitConverter(d),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                  color: textColor,
                ),
              ),
              if (subtitleForDay != null && subtitleForDay!.containsKey(d))
                Text(
                  subtitleForDay![d]!,
                  style: TextStyle(
                    fontSize: 9,
                    color: isToday ? Colors.white70 : accentColor,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onPrev,
                  icon: Icon(Icons.chevron_left_rounded, color: accentColor, size: 28),
                ),
                Column(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onNext,
                  icon: Icon(Icons.chevron_right_rounded, color: accentColor, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Day Headers
            Row(
              children: dayHeaders.map((d) {
                final isFri = d == 'Fri' || d == 'শু' || d == 'Jum';
                return Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isFri ? accentColor : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            
            // Calendar Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: cells.length,
              itemBuilder: (context, index) => cells[index],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ENGLISH CALENDAR TAB
// ─────────────────────────────────────────────────────────────
class _EnglishCalendarTab extends StatefulWidget {
  const _EnglishCalendarTab();
  @override
  State<_EnglishCalendarTab> createState() => _EnglishCalendarTabState();
}

class _EnglishCalendarTabState extends State<_EnglishCalendarTab> {
  late DateTime focusedMonth;
  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    focusedMonth = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    final todayStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    
    final daysInMonth = DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final startingWeekday = focusedMonth.weekday % 7; // Sunday=0
    final isCurrentMonth = focusedMonth.year == now.year && focusedMonth.month == now.month;

    return SingleChildScrollView(
      child: Column(
        children: [
          _TodayBanner(label: 'Today (Gregorian)', dateStr: todayStr),
          _CalendarGrid(
            title: months[focusedMonth.month - 1],
            subtitle: '${focusedMonth.year}',
            dayHeaders: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
            daysInMonth: daysInMonth,
            startingWeekday: startingWeekday,
            currentDay: isCurrentMonth ? now.day : -1,
            onPrev: () => setState(() => focusedMonth = DateTime(focusedMonth.year, focusedMonth.month - 1, 1)),
            onNext: () => setState(() => focusedMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 1)),
            digitConverter: (d) => '$d',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HIJRI CALENDAR TAB
// ─────────────────────────────────────────────────────────────
class _HijriCalendarTab extends StatefulWidget {
  const _HijriCalendarTab();
  @override
  State<_HijriCalendarTab> createState() => _HijriCalendarTabState();
}

class _HijriCalendarTabState extends State<_HijriCalendarTab> {
  late int focusedHYear;
  late int focusedHMonth;
  late HijriCalendar todayH;

  static const _hijriMonthNames = [
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
    "Jumada al-Ula", "Jumada al-Akhirah", 'Rajab', "Sha'ban",
    'Ramadan', 'Shawwal', "Dhul Qi'dah", "Dhul Hijjah"
  ];

  @override
  void initState() {
    super.initState();
    todayH = HijriCalendar.now();
    focusedHYear = todayH.hYear;
    focusedHMonth = todayH.hMonth;
  }

  void _prev() {
    setState(() {
      if (focusedHMonth == 1) {
        focusedHMonth = 12;
        focusedHYear--;
      } else {
        focusedHMonth--;
      }
    });
  }

  void _next() {
    setState(() {
      if (focusedHMonth == 12) {
        focusedHMonth = 1;
        focusedHYear++;
      } else {
        focusedHMonth++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayStr =
        '${todayH.hDay} ${_hijriMonthNames[(todayH.hMonth - 1).clamp(0, 11)]} ${todayH.hYear} AH';

    final h = HijriCalendar();
    final firstDayGreg = h.hijriToGregorian(focusedHYear, focusedHMonth, 1);
    final daysInMonth = h.getDaysInMonth(focusedHYear, focusedHMonth);
    final startingWeekday = firstDayGreg.weekday % 7; // Sunday=0
    
    final isCurrentMonth = focusedHYear == todayH.hYear && focusedHMonth == todayH.hMonth;

    // Generate Gregorian sub-labels for each Hijri day
    final gregorianSubs = <int, String>{};
    for (int d = 1; d <= daysInMonth; d++) {
      final gDate = firstDayGreg.add(Duration(days: d - 1));
      gregorianSubs[d] = '${gDate.day}';
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _TodayBanner(label: 'Today (Hijri)', dateStr: todayStr),
          _CalendarGrid(
            title: _hijriMonthNames[(focusedHMonth - 1).clamp(0, 11)],
            subtitle: '$focusedHYear AH',
            dayHeaders: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
            daysInMonth: daysInMonth,
            startingWeekday: startingWeekday,
            currentDay: isCurrentMonth ? todayH.hDay : -1,
            onPrev: _prev,
            onNext: _next,
            accentColor: AppColors.gold,
            digitConverter: (d) => '$d',
            subtitleForDay: gregorianSubs,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BANGLA CALENDAR TAB
// ─────────────────────────────────────────────────────────────
class _BanglaCalendarTab extends StatefulWidget {
  const _BanglaCalendarTab();
  @override
  State<_BanglaCalendarTab> createState() => _BanglaCalendarTabState();
}

class _BanglaCalendarTabState extends State<_BanglaCalendarTab> {
  late int focusedBYear;
  late int focusedBMonth;
  late _BanglaDate todayB;

  static const _banglaMonthNames = [
    'বৈশাখ', 'জ্যৈষ্ঠ', 'আষাঢ়', 'শ্রাবণ', 'ভাদ্র', 'আশ্বিন',
    'কার্তিক', 'অগ্রহায়ণ', 'পৌষ', 'মাঘ', 'ফাল্গুন', 'চৈত্র'
  ];

  @override
  void initState() {
    super.initState();
    todayB = _BanglaDate.fromGregorian(DateTime.now());
    focusedBYear = todayB.year;
    focusedBMonth = todayB.month;
  }

  void _prev() {
    setState(() {
      if (focusedBMonth == 1) {
        focusedBMonth = 12;
        focusedBYear--;
      } else {
        focusedBMonth--;
      }
    });
  }

  void _next() {
    setState(() {
      if (focusedBMonth == 12) {
        focusedBMonth = 1;
        focusedBYear++;
      } else {
        focusedBMonth++;
      }
    });
  }

  String _banglaDigit(int n) {
    const d = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final todayStr =
        '${_banglaDigit(todayB.day)} ${_banglaMonthNames[todayB.month - 1]} ${_banglaDigit(todayB.year)}';

    final daysInMonth = _BanglaDate.daysInMonth(focusedBYear, focusedBMonth);
    final firstDayGreg = _BanglaDate.toGregorian(focusedBYear, focusedBMonth, 1);
    final startingWeekday = firstDayGreg.weekday % 7;
    
    final isCurrentMonth = focusedBYear == todayB.year && focusedBMonth == todayB.month;

    final gregorianSubs = <int, String>{};
    for (int d = 1; d <= daysInMonth; d++) {
      final gDate = firstDayGreg.add(Duration(days: d - 1));
      gregorianSubs[d] = '${gDate.day}';
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _TodayBanner(label: 'আজকের তারিখ (বাংলা)', dateStr: todayStr),
          _CalendarGrid(
            title: _banglaMonthNames[focusedBMonth - 1],
            subtitle: _banglaDigit(focusedBYear),
            dayHeaders: const ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শু', 'শনি'],
            daysInMonth: daysInMonth,
            startingWeekday: startingWeekday,
            currentDay: isCurrentMonth ? todayB.day : -1,
            onPrev: _prev,
            onNext: _next,
            accentColor: const Color(0xFF006D44),
            digitConverter: _banglaDigit,
            subtitleForDay: gregorianSubs,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BanglaDate {
  final int day;
  final int month;
  final int year;

  const _BanglaDate(this.day, this.month, this.year);

  static int daysInMonth(int bYear, int bMonth) {
    if (bMonth >= 1 && bMonth <= 6) return 31;
    if (bMonth >= 7 && bMonth <= 10) return 30;
    if (bMonth == 12) return 30;
    // Month 11 (Falgun)
    // Gregorian year for Falgun is bYear + 594
    final gYear = bYear + 594;
    final isLeap = (gYear % 4 == 0 && gYear % 100 != 0) || (gYear % 400 == 0);
    return isLeap ? 30 : 29;
  }

  static DateTime toGregorian(int bYear, int bMonth, int bDay) {
    // Baishakh 1 is always April 14 of (bYear + 593)
    final gYearStart = bYear + 593;
    var date = DateTime(gYearStart, 4, 14);
    
    // Add full months
    for (int m = 1; m < bMonth; m++) {
      date = date.add(Duration(days: daysInMonth(bYear, m)));
    }
    
    // Add days
    date = date.add(Duration(days: bDay - 1));
    return date;
  }

  static _BanglaDate fromGregorian(DateTime date) {
    final isAfterBanglaNewYear = date.month > 4 || (date.month == 4 && date.day >= 14);
    final bYear = date.year - (isAfterBanglaNewYear ? 593 : 594);
    
    int bMonth = 1;
    var currentStart = DateTime(bYear + 593, 4, 14);
    
    while (true) {
      final daysInThisMonth = daysInMonth(bYear, bMonth);
      final nextStart = currentStart.add(Duration(days: daysInThisMonth));
      
      // If date is before the start of the *next* month, it belongs to bMonth
      if (date.isBefore(nextStart)) {
        final bDay = date.difference(currentStart).inDays + 1;
        return _BanglaDate(bDay, bMonth, bYear);
      }
      
      bMonth++;
      currentStart = nextStart;
    }
  }
}
