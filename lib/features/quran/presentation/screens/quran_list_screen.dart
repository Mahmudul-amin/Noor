import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/quran_data.dart';

class QuranListScreen extends ConsumerStatefulWidget {
  const QuranListScreen({super.key});
  @override
  ConsumerState<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends ConsumerState<QuranListScreen> {
  String _query = '';


  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return QuranData.surahs;
    return QuranData.surahs
        .where((s) =>
            s['name'].toString().toLowerCase().contains(_query.toLowerCase()) ||
            s['arabic'].toString().contains(_query) ||
            s['meaning']
                .toString()
                .toLowerCase()
                .contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32))),
            child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Al-Quran',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                            style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                color: Colors.white.withValues(alpha: 0.85))),
                        const SizedBox(height: 16),
                        // Search
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14)),
                          child: TextField(
                            onChanged: (v) => setState(() => _query = v),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search Surahs...',
                              hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6)),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: Colors.white.withValues(alpha: 0.7)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none),
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ]),
                )),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final s = _filtered[i];
                return _SurahTile(
                    surah: s,
                    onTap: () => context
                        .push('/quran/${s['number']}?name=${s['name']}'));
              },
              childCount: _filtered.length,
            ),
          ),
        ),
      ]),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final Map<String, dynamic> surah;
  final VoidCallback onTap;
  const _SurahTile({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMeccan = surah['type'] == 'Meccan';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  isDark ? const Color(0xFF1E3045) : const Color(0xFFE8F5EE)),
        ),
        child: Row(children: [
          // Number badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child: Center(
                child: Text('${surah['number']}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(surah['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isMeccan ? AppColors.warning : AppColors.fajr)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(surah['type'],
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color:
                                isMeccan ? AppColors.warning : AppColors.fajr)),
                  ),
                  const SizedBox(width: 8),
                  Text('${surah['verses']} verses',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textLight)),
                ]),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(surah['arabic'],
                style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(surah['meaning'],
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textLight)),
          ]),
        ]),
      ),
    );
  }
}
