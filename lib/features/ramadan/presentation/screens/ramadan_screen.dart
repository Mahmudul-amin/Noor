import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

class RamadanScreen extends ConsumerStatefulWidget {
  const RamadanScreen({super.key});
  @override
  ConsumerState<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends ConsumerState<RamadanScreen> {
  final Map<String, bool> _checklist = {
    'Fajr Prayer': false,
    'Suhoor Eaten': false,
    'Quran Recitation': false,
    'Dhuhr Prayer': false,
    'Asr Prayer': false,
    'Iftar Prepared': false,
    'Maghrib Prayer': false,
    'Tarawih Prayer': false,
    'Isha Prayer': false,
    'Night Dhikr': false,
  };

  final _suhoorTime = '04:30 AM';
  final _iftarTime  = '06:24 PM';

  String _countdown(String targetTime) {
    final now = DateTime.now();
    final parts = targetTime.replaceAll(' AM','').replaceAll(' PM','').split(':');
    int h = int.parse(parts[0]);
    if (targetTime.contains('PM') && h != 12) h += 12;
    if (targetTime.contains('AM') && h == 12) h = 0;
    final target = DateTime(now.year, now.month, now.day, h, int.parse(parts[1]));
    var diff = target.difference(now);
    if (diff.isNegative) diff = Duration.zero;
    final hh = diff.inHours.toString().padLeft(2,'0');
    final mm = (diff.inMinutes % 60).toString().padLeft(2,'0');
    final ss = (diff.inSeconds % 60).toString().padLeft(2,'0');
    return '$hh:$mm:$ss';
  }

  final _duas = [
    {'arabic': 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي', 'transliteration': 'Allahumma innaka afuwwun tuhibbul afwa fa\'fu anni', 'meaning': 'O Allah, You are Forgiving and love forgiveness, so forgive me.'},
    {'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً', 'transliteration': 'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan', 'meaning': 'Our Lord, give us good in this world and good in the hereafter.'},
    {'arabic': 'اللَّهُمَّ اجْعَلْنِي مِمَّنْ تَقَبَّلْتَ صِيَامَهُمْ', 'transliteration': 'Allahumma ij\'alni mimman taqabbalta siyamahum', 'meaning': 'O Allah, make me among those whose fasting You accept.'},
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.ramadanBg,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: SafeArea(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              const Text('🌙', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ramadan Kareem', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.gold)),
                const Text('رمضان كريم', style: TextStyle(fontFamily: 'Amiri', fontSize: 16, color: AppColors.goldLight)),
              ]),
            ]),
            const SizedBox(height: 24),

            // Countdown cards
            Row(children: [
              Expanded(child: _CountdownCard(label: 'Suhoor', time: _suhoorTime, emoji: '🌅', color: AppColors.fajr, countdown: _countdown(_suhoorTime))),
              const SizedBox(width: 14),
              Expanded(child: _CountdownCard(label: 'Iftar', time: _iftarTime, emoji: '🌇', color: AppColors.gold, countdown: _countdown(_iftarTime))),
            ]),
            const SizedBox(height: 28),

            // Checklist
            _SectionHeader(title: "Today's Checklist"),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(color: AppColors.ramadanCard, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2))),
              child: Column(children: _checklist.entries.toList().asMap().entries.map((entry) {
                final i = entry.key;
                final k = entry.value.key;
                final v = entry.value.value;
                return Column(children: [
                  if (i > 0) const Divider(height: 1, color: Color(0xFF2A3F5E)),
                  ListTile(
                    leading: GestureDetector(
                      onTap: () => setState(() => _checklist[k] = !v),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: v ? AppColors.gold : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: v ? AppColors.gold : Colors.white30, width: 2),
                        ),
                        child: v ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                      ),
                    ),
                    title: Text(k, style: TextStyle(color: v ? Colors.white54 : Colors.white, fontSize: 14,
                        decoration: v ? TextDecoration.lineThrough : null)),
                  ),
                ]);
              }).toList()),
            ),
            const SizedBox(height: 28),

            // Progress
            _SectionHeader(title: 'Today\'s Progress'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.ramadanCard, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.2))),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${_checklist.values.where((v) => v).length}/${_checklist.length} completed',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('${(_checklist.values.where((v) => v).length / _checklist.length * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _checklist.values.where((v) => v).length / _checklist.length,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // Duas
            _SectionHeader(title: 'Ramadan Du\'as'),
            const SizedBox(height: 14),
            ..._duas.map((dua) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.ramadanCard, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.15))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(dua['arabic']!, textDirection: TextDirection.rtl, style: const TextStyle(fontFamily: 'Amiri', fontSize: 18, color: Colors.white, height: 1.8)),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(dua['transliteration']!, style: TextStyle(fontSize: 12, color: AppColors.gold.withValues(alpha: 0.9), fontStyle: FontStyle.italic)),
                  const SizedBox(height: 4),
                  Text(dua['meaning']!, style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4)),
                ])),
              ]),
            )),
            const SizedBox(height: 110),
          ]),
        ))),
      ]),
    );
  }
}

class _CountdownCard extends StatefulWidget {
  final String label, time, emoji, countdown;
  final Color color;
  const _CountdownCard({required this.label, required this.time, required this.emoji, required this.color, required this.countdown});
  @override
  State<_CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<_CountdownCard> {
  late String _cd;
  @override
  void initState() { super.initState(); _cd = widget.countdown; _tick(); }
  void _tick() { Future.doWhile(() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return false;
    setState(() => _cd = widget.countdown); return true;
  }); }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ramadanCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: widget.color.withValues(alpha: 0.15), blurRadius: 16)],
      ),
      child: Column(children: [
        Text(widget.emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(widget.label, style: TextStyle(color: widget.color, fontWeight: FontWeight.w700, fontSize: 13)),
        Text(widget.time, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 10),
        Text(_cd, style: TextStyle(color: widget.color, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gold));
}
