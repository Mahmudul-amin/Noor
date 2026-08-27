import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/quran_data.dart';
import '../widgets/surah_list_item.dart';
import '../widgets/juz_list_item.dart';
import '../widgets/continue_reading_card.dart';
import '../widgets/tab_switcher.dart';
import '../widgets/quran_header.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/last_read_provider.dart';
import '../widgets/audio_player_widget.dart';
import '../providers/bookmarks_provider.dart';

class QuranListScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const QuranListScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends ConsumerState<QuranListScreen> {
  late int _activeTabIndex;
  final List<String> _tabs = ['All Surahs', 'Juz', 'Bookmarks'];

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final lastRead = ref.watch(lastReadProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: const QuranHeader(),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab Switcher
              TabSwitcher(
                tabs: _tabs,
                activeIndex: _activeTabIndex,
                onTabChanged: (index) => setState(() => _activeTabIndex = index),
              ),
              
              // Main content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 180), // Extra bottom padding for player
                  children: [
                    if (_activeTabIndex == 0) ...[
                      // Continue Reading Section
                      ContinueReadingCard(
                        surahName: lastRead?.surahName ?? 'Surah Al-Baqarah',
                        ayahNumber: lastRead?.ayahNumber ?? 1,
                        onTap: () {
                          if (lastRead != null) {
                            context.push('/quran/${lastRead.surahNumber}?name=${lastRead.surahName}');
                          } else {
                            // Default to Al-Baqarah if nothing read yet
                            context.push('/quran/2?name=Al-Baqarah');
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // List Title
                      const Text(
                        'Surah List',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Surah List
                      ...QuranData.surahs.map((s) => SurahListItem(
                        number: s['number'],
                        name: s['name'],
                        translation: s['meaning'],
                        ayahCount: s['verses'],
                        arabicName: s['arabic'],
                        onTap: () => context.push('/quran/${s['number']}?name=${s['name']}'),
                      )),
                    ] else if (_activeTabIndex == 1) ...[
                      // Juz List
                      const Text(
                        'Juz List',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...QuranData.juzList.map((j) => JuzListItem(
                        number: j['number'],
                        name: j['name'],
                        arabicName: j['arabic'],
                        onTap: () => context.push('/quran/juz/${j['number']}?name=${j['name']}'),
                      )),
                    ] else if (_activeTabIndex == 2) ...[
                      // Bookmarks List
                      if (ref.watch(bookmarksProvider).isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Column(
                              children: [
                                Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No bookmarks yet', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        )
                      else
                        ...ref.watch(bookmarksProvider).map((b) => _BookmarkItem(bookmark: b)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          // Floating Audio Player
          Positioned(
            left: 16,
            right: 16,
            bottom: 90, // Positioned above the Bottom Nav Bar
            child: const AudioPlayerWidget(),
          ),
        ],
      ),
    );
  }
}

class _BookmarkItem extends StatelessWidget {
  final BookmarkModel bookmark;
  const _BookmarkItem({required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/quran/${bookmark.surahNumber}?name=${bookmark.surahName}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${bookmark.surahName} : Ayah ${bookmark.ayahNumber}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              bookmark.arabicText,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bookmark.bengaliText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
