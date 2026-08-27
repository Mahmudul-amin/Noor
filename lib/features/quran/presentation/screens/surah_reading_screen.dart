import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/quran_audio_provider.dart';
import '../providers/last_read_provider.dart';
import '../providers/bookmarks_provider.dart';
import '../providers/reciter_provider.dart';
import '../../data/quran_data.dart';

// Ayah model
class Ayah {
  final int number;
  final int surahNumber;
  final String arabic;
  final String translation;
  final String? bengali;
  final String? audioUrl;
  Ayah({required this.number, required this.surahNumber, required this.arabic, required this.translation, this.bengali, this.audioUrl});
}

// State providers

typedef QuranParams = ({int id, bool isJuz});

// Quran reading provider
final _ayahsProvider = FutureProvider.family<List<Ayah>, QuranParams>((ref, params) async {
  try {
    final dio = Dio();
    const perPage = 300; // quran.com max per page
    
    final endpointType = params.isJuz ? 'by_juz' : 'by_chapter';
    final reciterId = ref.watch(reciterProvider);

    // ── 1. Paginate all verses ────────────────────────────────
    final List<dynamic> versesData = [];
    int page = 1;
    while (true) {
      final resp = await dio.get(
        'https://api.quran.com/api/v4/verses/$endpointType/${params.id}',
        queryParameters: {
          'language': 'en',
          'translations': '20,161', // 20: Sahih Int'l (EN), 161: Taisirul Quran (BN)
          'fields': 'text_uthmani,verse_key',
          'per_page': perPage,
          'page': page,
        },
      );
      final batch = resp.data['verses'] as List;
      versesData.addAll(batch);

      final meta = resp.data['pagination'] as Map<String, dynamic>?;
      final totalPages = meta?['total_pages'] as int? ?? 1;
      if (page >= totalPages) break;
      page++;
    }

    // ── 2. Paginate all audio files ───────────────────────────
    final List<dynamic> audioData = [];
    page = 1;
    while (true) {
      final resp = await dio.get(
        'https://api.quran.com/api/v4/recitations/$reciterId/$endpointType/${params.id}',
        queryParameters: {
          'per_page': perPage,
          'page': page,
        },
      );
      final batch = resp.data['audio_files'] as List;
      audioData.addAll(batch);

      final meta = resp.data['pagination'] as Map<String, dynamic>?;
      final totalPages = meta?['total_pages'] as int? ?? 1;
      if (page >= totalPages) break;
      page++;
    }

    // ── 3. Build audio lookup map ─────────────────────────────
    final audioMap = <String, String>{
      for (var item in audioData)
        item['verse_key'] as String: 'https://verses.quran.com/${item['url']}',
    };

    // ── 4. Map to Ayah models ─────────────────────────────────
    return List.generate(versesData.length, (i) {
      final v = versesData[i];
      final translations = v['translations'] as List;

      String english = '';
      String bengali = '';
      for (var t in translations) {
        if (t['resource_id'] == 20) english = t['text'] as String? ?? '';
        if (t['resource_id'] == 161) bengali = t['text'] as String? ?? '';
      }

      final verseKey = v['verse_key'] as String;
      final parsedSurahNumber = int.parse(verseKey.split(':')[0]);

      return Ayah(
        number: v['verse_number'] as int,
        surahNumber: parsedSurahNumber,
        arabic: v['text_uthmani'] as String,
        translation: english.replaceAll(RegExp(r'<[^>]*>'), ''),
        bengali: bengali.replaceAll(RegExp(r'<[^>]*>'), ''),
        audioUrl: audioMap[verseKey],
      );
    });
  } catch (e) {
    debugPrint('Quran API Error: $e');
    return [];
  }
});


final _currentAyahProvider = StateProvider<int>((ref) => 0);
final _showTranslationProvider = StateProvider<bool>((ref) => true);

class SurahReadingScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final String surahName;
  final int? initialAyahNumber;
  final bool isJuz;
  
  const SurahReadingScreen({
    super.key, 
    required this.surahNumber, 
    required this.surahName, 
    this.initialAyahNumber,
    this.isJuz = false,
  });

  @override
  ConsumerState<SurahReadingScreen> createState() => _SurahReadingScreenState();
}

class _SurahReadingScreenState extends ConsumerState<SurahReadingScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool _scrolledToInitial = false;

  @override
  void initState() {
    super.initState();
    // Listen to position changes to accurately track last-read ayah
    _itemPositionsListener.itemPositions.addListener(_onPositionChanged);
  }

  void _onPositionChanged() {
    if (!mounted) return;
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final topIndex = positions
        .where((p) => p.itemTrailingEdge > 0)
        .reduce((a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b)
        .index;
    
    final asyncAyahs = ref.read(_ayahsProvider((id: widget.surahNumber, isJuz: widget.isJuz)));
    asyncAyahs.whenData((ayahs) {
      if (topIndex >= 0 && topIndex < ayahs.length) {
        final ayah = ayahs[topIndex];
        
        String sName = widget.surahName;
        if (widget.isJuz) {
          final sData = QuranData.surahs.firstWhere(
            (s) => s['number'] == ayah.surahNumber, 
            orElse: () => {'name': 'Unknown'}
          );
          sName = sData['name'] as String;
        }

        ref.read(lastReadProvider.notifier).updateLastRead(
          surahNumber: ayah.surahNumber,
          surahName: sName,
          ayahNumber: ayah.number,
        );
      }
    });
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onPositionChanged);
    super.dispose();
  }

  Future<void> _playAyah(int index, String url, String surahName, int ayahNum) async {
    await ref.read(quranAudioProvider.notifier).playAyah(
      surahName: surahName,
      ayahNumber: ayahNum,
      url: url,
      isJuz: widget.isJuz,
      readingId: widget.surahNumber,
    );
  }

  void _scrollToAyah(int index) {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showAyahDetails(Ayah ayah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ayah ${ayah.number}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text(
                      ayah.arabic,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 30,
                        height: 1.8,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildTranslationSection('English Translation', ayah.translation),
                    const SizedBox(height: 24),
                    _buildTranslationSection('Bengali Translation', ayah.bengali ?? 'Translation unavailable'),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  void _showReciterSelection(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final recitersAsync = ref.watch(recitersListProvider);
          final selectedReciterId = ref.watch(reciterProvider);

          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) => Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Choose Reciter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: recitersAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      error: (err, stack) => Center(child: Text('Error loading reciters', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                      data: (reciters) => ListView.builder(
                        controller: scrollController,
                        itemCount: reciters.length,
                        itemBuilder: (context, index) {
                          final reciter = reciters[index];
                          final isSelected = reciter.id == selectedReciterId;
                          return ListTile(
                            title: Text(reciter.name, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            subtitle: reciter.style != null ? Text(reciter.style!, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)) : null,
                            trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                            onTap: () {
                              ref.read(reciterProvider.notifier).setReciter(reciter.id);
                              Navigator.pop(context);
                              // Stop currently playing audio
                              ref.read(quranAudioProvider.notifier).stop();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ayahsAsync = ref.watch(_ayahsProvider((id: widget.surahNumber, isJuz: widget.isJuz)));
    final showTranslation = ref.watch(_showTranslationProvider);
    final audioState = ref.watch(quranAudioProvider);

    // Sync current ayah from audio player if playing this surah
    if (audioState.surahName == widget.surahName && audioState.isPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentAyahIdx = audioState.ayahNumber != null ? audioState.ayahNumber! - 1 : 0;
        if (ref.read(_currentAyahProvider) != currentAyahIdx) {
          ref.read(_currentAyahProvider.notifier).state = currentAyahIdx;
          _scrollToAyah(currentAyahIdx);
        }
      });
    }

    final currentAyah = ref.watch(_currentAyahProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;


    return Scaffold(
      appBar: AppBar(
        title: Column(children: [
          Text(widget.surahName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text(widget.isJuz ? 'Juz ${widget.surahNumber}' : 'Surah ${widget.surahNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ]),
        centerTitle: true,
        actions: [
          CurvedTextUnderIcon(
            onTap: () => _showReciterSelection(context, isDark),
            isDark: isDark,
          ),
          IconButton(
            icon: Icon(showTranslation ? Icons.translate_rounded : Icons.translate_outlined, color: AppColors.primary),
            onPressed: () => ref.read(_showTranslationProvider.notifier).state = !showTranslation,
          ),
        ],
      ),
      body: ayahsAsync.when(
        loading: () => const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Loading Surah...'),
        ])),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ayahs) {
          // One-shot: jump to the initial ayah once after data loads & list mounts
          if (!_scrolledToInitial) {
            final initial = widget.initialAyahNumber;
            if (initial != null && initial > 1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _itemScrollController.isAttached) {
                  _itemScrollController.jumpTo(
                    index: (initial - 1).clamp(0, ayahs.length - 1),
                  );
                  _scrolledToInitial = true;
                }
              });
            } else {
              _scrolledToInitial = true;
            }
          }

          return Column(children: [
          // Surah Header — image background if available
          _SurahHeader(
            surahNumber: widget.surahNumber,
            surahName: widget.surahName,
            verseCount: ayahs.length,
            isPlaying: audioState.surahName == widget.surahName && audioState.isPlaying,
            isDark: isDark,
            isJuz: widget.isJuz,
            onPlayTap: () {
              final isPlayingThis = audioState.surahName == widget.surahName && audioState.isPlaying;
              final isPausedThis = audioState.surahName == widget.surahName && !audioState.isPlaying && audioState.progress > 0.0;

              if (isPlayingThis) {
                ref.read(quranAudioProvider.notifier).pause();
              } else if (isPausedThis) {
                ref.read(quranAudioProvider.notifier).togglePlay();
              } else {
                final urls = ayahs.map((a) => a.audioUrl!).whereType<String>().toList();
                ref.read(quranAudioProvider.notifier).playSurah(
                  surahName: widget.surahName,
                  ayahUrls: urls,
                  isJuz: widget.isJuz,
                  readingId: widget.surahNumber,
                );
              }
            },
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(children: [
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ayahs.isEmpty ? 0 : (currentAyah + 1) / ayahs.length,
                  minHeight: 5,
                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              )),
              const SizedBox(width: 10),
              Text('${currentAyah + 1}/${ayahs.length}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w600)),
            ]),
          ),
          // Ayah list
          Expanded(
            child: ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              itemPositionsListener: _itemPositionsListener,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              itemCount: ayahs.length,
              initialScrollIndex: () {
                final initial = widget.initialAyahNumber;
                if (initial != null && initial > 1) {
                  return (initial - 1).clamp(0, ayahs.length - 1);
                }
                return 0;
              }(),
              itemBuilder: (ctx, i) {
                final ayah = ayahs[i];
                final isCurrentAyah = i == currentAyah;
                final isPlaying = audioState.audioUrl == ayah.audioUrl && audioState.isPlaying;

                final actualSurahNumber = ayah.surahNumber;
                final actualSurahData = QuranData.surahs.firstWhere(
                  (s) => s['number'] == actualSurahNumber, 
                  orElse: () => {'name': 'Surah $actualSurahNumber', 'arabic': ''}
                );
                final actualSurahName = actualSurahData['name'] as String;
                final actualSurahArabic = actualSurahData['arabic'] as String?;

                final bool showSurahDivider = widget.isJuz && (i == 0 || ayahs[i].surahNumber != ayahs[i - 1].surahNumber);

                Widget ayahWidget = GestureDetector(
                  onTap: () {
                    ref.read(_currentAyahProvider.notifier).state = i;
                    _showAyahDetails(ayah);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16), // Spacing between each ayah card
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/ayah_background.png'),
                        fit: BoxFit.fill, // Stretches perfectly to the bounds without cropping
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Ayah Number & Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCurrentAyah ? AppColors.primary : (isDark ? Colors.white10 : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$actualSurahNumber:${ayah.number}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrentAyah ? Colors.white : AppColors.textLight,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                if (ayah.audioUrl != null)
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _playAyah(i, ayah.audioUrl!, widget.surahName, ayah.number),
                                    icon: Icon(
                                      isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    final isCurrentlyBookmarked = ref.read(bookmarksProvider.notifier).isBookmarked(actualSurahNumber, ayah.number);
                                    ref.read(bookmarksProvider.notifier).toggleBookmark(
                                      BookmarkModel(
                                        surahNumber: actualSurahNumber,
                                        surahName: actualSurahName,
                                        ayahNumber: ayah.number,
                                        arabicText: ayah.arabic,
                                        bengaliText: ayah.bengali ?? '',
                                      ),
                                    );

                                    // Show instant feedback message
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(!isCurrentlyBookmarked ? 'Bookmark Added' : 'Bookmark Removed'),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        width: 180,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        backgroundColor: AppColors.primary.withValues(alpha: 0.9),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    ref.watch(bookmarksProvider).any((b) => b.surahNumber == actualSurahNumber && b.ayahNumber == ayah.number)
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_outline_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Arabic Text
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            ayah.arabic,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 28,
                              height: 2.0,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (showTranslation) ...[
                          const SizedBox(height: 24),
                          // English Translation
                          Text(
                            ayah.translation,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: isDark ? Colors.white70 : const Color(0xFF374151),
                            ),
                          ),
                          if (ayah.bengali != null) ...[
                            const SizedBox(height: 12),
                            // Bengali Translation
                            Text(
                              ayah.bengali!,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                );

                if (showSurahDivider) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (i > 0) const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
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
                          children: [
                            Text(
                              actualSurahName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                            if (actualSurahArabic != null && actualSurahArabic.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                actualSurahArabic,
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ]
                        ),
                      ),
                      ayahWidget,
                    ],
                  );
                }

                return ayahWidget;
              },
            ),
          ),
        ]);
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SURAH HEADER — pure image, no text overlay
// ══════════════════════════════════════════════════════════════
class _SurahHeader extends StatelessWidget {
  final int surahNumber;
  final String surahName;
  final int verseCount;
  final bool isPlaying;
  final bool isDark;
  final bool isJuz;
  final VoidCallback onPlayTap;

  const _SurahHeader({
    required this.surahNumber,
    required this.surahName,
    required this.verseCount,
    required this.isPlaying,
    required this.isDark,
    required this.isJuz,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    // Will load specific surah/juz image if it exists, otherwise falls back to a clean gradient.
    final imagePath = isJuz 
        ? 'assets/images/juz $surahNumber.png'
        : switch (surahNumber) {
            2 => 'assets/images/Surah_2_header.png',
            3 => 'assets/images/Surah_3_header.png',
            4 => 'assets/images/Surah_4_header.png',
            _ => 'assets/images/surah_${surahNumber}_header.png',
          };

    return SizedBox(
      width: double.infinity,
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF0D2B1A), const Color(0xFF1A4731)]
                        : [AppColors.primary, const Color(0xFF1A6B40)],
                  ),
                ),
              ),
            ),
          ),

          if (surahNumber == 1 && !isJuz)
            Positioned(
              left: -18,
              right: 48,
              bottom: -40,
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/Beside_play_button_space.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            )
          else
            Positioned(
              left: -24,
              right: 44,
              bottom: (isJuz && (surahNumber == 7 || surahNumber == 8 || surahNumber == 9)) ? -74 : -69,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/bismillah.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),

          // Play Button Overlay
          Positioned(
            right: 20,
            bottom: isJuz ? -11 : (surahNumber == 4 ? -10 : -6),
            child: GestureDetector(
              onTap: onPlayTap,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurvedTextUnderIcon extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const CurvedTextUnderIcon({super.key, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 76,
        height: 56,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Image.asset(
                'assets/images/Reciter options logo.png',
                width: 40,
                height: 40,
              ),
            ),
            CustomPaint(
              size: const Size(76, 56),
              painter: ArcTextPainter(
                text: "Choose Reciter",
                textStyle: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
                radius: 25.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArcTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final double radius;

  ArcTextPainter({
    required this.text,
    required this.textStyle,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Translate to center of widget, slightly shifted up to make room for bottom text
    canvas.translate(size.width / 2, size.height / 2 - 4);
    
    double totalAngle = 0;
    List<TextPainter> painters = [];
    
    // Add extra letter spacing by artificially inflating width slightly
    const letterSpacing = 1.0; 

    for (int i = 0; i < text.length; i++) {
      final span = TextSpan(style: textStyle, text: text[i]);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      painters.add(tp);
      totalAngle += ((tp.width + letterSpacing) / radius);
    }

    double currentAngle = (math.pi / 2) + (totalAngle / 2);

    for (int i = 0; i < text.length; i++) {
      final tp = painters[i];
      final charAngle = (tp.width + letterSpacing) / radius;
      
      final angle = currentAngle - charAngle / 2;
      
      canvas.save();
      canvas.translate(radius * math.cos(angle), radius * math.sin(angle));
      canvas.rotate(angle - math.pi / 2);
      
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
      
      currentAngle -= charAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
