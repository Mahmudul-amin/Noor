import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
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
        children: [
          _HijriCalendarTab(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: (sel, foc) =>
                setState(() { _selectedDay = sel; _focusedDay = foc; }),
            onPageChanged: (day) => setState(() => _focusedDay = day),
          ),
          _EnglishCalendarTab(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: (sel, foc) =>
                setState(() { _selectedDay = sel; _focusedDay = foc; }),
            onPageChanged: (day) => setState(() => _focusedDay = day),
          ),
          _BanglaCalendarTab(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: (sel, foc) =>
                setState(() { _selectedDay = sel; _focusedDay = foc; }),
            onPageChanged: (day) => setState(() => _focusedDay = day),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────
HijriCalendar _toHijri(DateTime date) =>
    HijriCalendar.fromDate(date);

String _banglaDigit(int n) {
  const d = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return n.toString().split('').map((c) => d[int.parse(c)]).join();
}

const _hijriMonthNames = [
  'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
  "Jumada al-Ula", "Jumada al-Akhirah", 'Rajab', "Sha'ban",
  'Ramadan', 'Shawwal', "Dhul Qi'dah", "Dhul Hijjah"
];

const _banglaMonthNames = [
  'বৈশাখ', 'জ্যৈষ্ঠ', 'আষাঢ়', 'শ্রাবণ', 'ভাদ্র', 'আশ্বিন',
  'কার্তিক', 'অগ্রহায়ণ', 'পৌষ', 'মাঘ', 'ফাল্গুন', 'চৈত্র'
];

/// Gregorian → Bangla date (approximate but standard algorithm)
({int day, int month, int year}) _toBangla(DateTime date) {
  // Bangla year = Gregorian year - 594 before April 14, else - 593
  final isAfterBanglaNewYear =
      date.month > 4 || (date.month == 4 && date.day >= 14);
  final bYear = date.year - (isAfterBanglaNewYear ? 593 : 594);

  // Month start dates in Gregorian (month, day)
  const starts = [
    (4, 14), (5, 15), (6, 15), (7, 16), (8, 16), (9, 16),
    (10, 16), (11, 15), (12, 15), (1, 14), (2, 13), (3, 14),
  ];

  int bMonth = 12;
  for (int i = starts.length - 1; i >= 0; i--) {
    final sm = starts[i].$1;
    final sd = starts[i].$2;
    final cmp = date.month * 100 + date.day;
    final bcmp = sm * 100 + sd;
    if (cmp >= bcmp) { bMonth = i + 1; break; }
  }

  // Calculate day within Bangla month
  final sm = starts[bMonth - 1].$1;
  final sd = starts[bMonth - 1].$2;
  final yr = (bMonth >= 10) ? (isAfterBanglaNewYear ? date.year + 1 : date.year) : date.year;
  final startDate = DateTime(yr, sm, sd);
  final bDay = date.difference(startDate).inDays + 1;

  return (day: bDay.clamp(1, 31), month: bMonth, year: bYear);
}

// ─────────────────────────────────────────────────────────────
// TODAY BANNER
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

// ─────────────────────────────────────────────────────────────
// HIJRI CALENDAR TAB
// ─────────────────────────────────────────────────────────────
class _HijriCalendarTab extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(DateTime) onPageChanged;

  const _HijriCalendarTab({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final todayH = _toHijri(DateTime.now());
    final todayStr =
        '${todayH.hDay} ${_hijriMonthNames[(todayH.hMonth - 1).clamp(0, 11)]} ${todayH.hYear} AH';

    return SingleChildScrollView(
      child: Column(
        children: [
          _TodayBanner(label: 'Today (Hijri)', dateStr: todayStr),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: focusedDay,
                selectedDayPredicate: (d) => isSameDay(d, selectedDay),
                onDaySelected: onDaySelected,
                onPageChanged: onPageChanged,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                calendarBuilders: CalendarBuilders(
                  headerTitleBuilder: (context, day) {
                    final h = _toHijri(day);
                    final mName = _hijriMonthNames[(h.hMonth - 1).clamp(0, 11)];
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(mName,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold)),
                          Text('${h.hYear} AH',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    final h = _toHijri(day);
                    return _HijriDayCell(
                      gregDay: day.day,
                      hijriDay: h.hDay,
                      isSelected: false,
                      isToday: false,
                      isFriday: day.weekday == DateTime.friday,
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    final h = _toHijri(day);
                    return _HijriDayCell(
                      gregDay: day.day,
                      hijriDay: h.hDay,
                      isSelected: true,
                      isToday: false,
                      isFriday: day.weekday == DateTime.friday,
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final h = _toHijri(day);
                    return _HijriDayCell(
                      gregDay: day.day,
                      hijriDay: h.hDay,
                      isSelected: false,
                      isToday: true,
                      isFriday: day.weekday == DateTime.friday,
                    );
                  },
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle:
                      const TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HijriDayCell extends StatelessWidget {
  final int gregDay;
  final int hijriDay;
  final bool isSelected;
  final bool isToday;
  final bool isFriday;

  const _HijriDayCell({
    required this.gregDay,
    required this.hijriDay,
    required this.isSelected,
    required this.isToday,
    required this.isFriday,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.transparent;
    Color textColor =
        isFriday ? AppColors.primary : const Color(0xFF374151);
    if (isToday) { bg = AppColors.primary; textColor = Colors.white; }
    if (isSelected) { bg = AppColors.gold; textColor = Colors.white; }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$gregDay',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
          Text('$hijriDay',
              style: TextStyle(
                  fontSize: 9,
                  color: isSelected || isToday
                      ? Colors.white70
                      : AppColors.gold)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ENGLISH CALENDAR TAB
// ─────────────────────────────────────────────────────────────
class _EnglishCalendarTab extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(DateTime) onPageChanged;

  const _EnglishCalendarTab({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    final todayStr = '${now.day} ${months[now.month - 1]} ${now.year}';

    return SingleChildScrollView(
      child: Column(
        children: [
          _TodayBanner(label: 'Today (Gregorian)', dateStr: todayStr),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: focusedDay,
                selectedDayPredicate: (d) => isSameDay(d, selectedDay),
                onDaySelected: onDaySelected,
                onPageChanged: onPageChanged,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  weekendTextStyle:
                      const TextStyle(color: AppColors.primary),
                ),
              ),
            ),
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
class _BanglaCalendarTab extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(DateTime) onPageChanged;

  const _BanglaCalendarTab({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final todayB = _toBangla(DateTime.now());
    final todayStr =
        '${_banglaDigit(todayB.day)} ${_banglaMonthNames[todayB.month - 1]} ${_banglaDigit(todayB.year)}';

    return SingleChildScrollView(
      child: Column(
        children: [
          _TodayBanner(label: 'আজকের তারিখ (বাংলা)', dateStr: todayStr),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: focusedDay,
                selectedDayPredicate: (d) => isSameDay(d, selectedDay),
                onDaySelected: onDaySelected,
                onPageChanged: onPageChanged,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                calendarBuilders: CalendarBuilders(
                  headerTitleBuilder: (context, day) {
                    final b = _toBangla(day);
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_banglaMonthNames[b.month - 1],
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF006D44))),
                          Text(_banglaDigit(b.year),
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    final b = _toBangla(day);
                    return _BanglaDayCell(
                      gregDay: day.day,
                      banglaDay: b.day,
                      isSelected: false,
                      isToday: false,
                      isFriday: day.weekday == DateTime.friday,
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    final b = _toBangla(day);
                    return _BanglaDayCell(
                      gregDay: day.day,
                      banglaDay: b.day,
                      isSelected: true,
                      isToday: false,
                      isFriday: day.weekday == DateTime.friday,
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final b = _toBangla(day);
                    return _BanglaDayCell(
                      gregDay: day.day,
                      banglaDay: b.day,
                      isSelected: false,
                      isToday: true,
                      isFriday: day.weekday == DateTime.friday,
                    );
                  },
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle:
                      const TextStyle(color: Color(0xFF006D44)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BanglaDayCell extends StatelessWidget {
  final int gregDay;
  final int banglaDay;
  final bool isSelected;
  final bool isToday;
  final bool isFriday;

  const _BanglaDayCell({
    required this.gregDay,
    required this.banglaDay,
    required this.isSelected,
    required this.isToday,
    required this.isFriday,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.transparent;
    Color textColor =
        isFriday ? const Color(0xFF006D44) : const Color(0xFF374151);
    if (isToday) { bg = const Color(0xFF006D44); textColor = Colors.white; }
    if (isSelected) { bg = AppColors.gold; textColor = Colors.white; }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$gregDay',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
          Text(_banglaDigit(banglaDay),
              style: TextStyle(
                  fontSize: 9,
                  color: isSelected || isToday
                      ? Colors.white70
                      : const Color(0xFF006D44))),
        ],
      ),
    );
  }
}
