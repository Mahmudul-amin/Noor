import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/quran_audio_provider.dart';
import '../providers/last_read_provider.dart';
import '../providers/bookmarks_provider.dart';

// Ayah model
class Ayah {
  final int number;
  final String arabic;
  final String translation;
  final String? bengali;
  final String? audioUrl;
  Ayah({required this.number, required this.arabic, required this.translation, this.bengali, this.audioUrl});
}

// State providers

// Quran reading provider
final _ayahsProvider = FutureProvider.family<List<Ayah>, int>((ref, surahNumber) async {
  try {
    final dio = Dio();
    const perPage = 300; // quran.com max per page

    // ── 1. Paginate all verses ────────────────────────────────
    final List<dynamic> versesData = [];
    int page = 1;
    while (true) {
      final resp = await dio.get(
        'https://api.quran.com/api/v4/verses/by_chapter/$surahNumber',
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
        'https://api.quran.com/api/v4/recitations/7/by_chapter/$surahNumber',
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

      return Ayah(
        number: v['verse_number'] as int,
        arabic: v['text_uthmani'] as String,
        translation: english.replaceAll(RegExp(r'<[^>]*>'), ''),
        bengali: bengali.replaceAll(RegExp(r'<[^>]*>'), ''),
        audioUrl: audioMap[v['verse_key'] as String],
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
  const SurahReadingScreen({super.key, required this.surahNumber, required this.surahName});

  @override
  ConsumerState<SurahReadingScreen> createState() => _SurahReadingScreenState();
}

class _SurahReadingScreenState extends ConsumerState<SurahReadingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _playAyah(int index, String url, String surahName, int ayahNum) async {
    await ref.read(quranAudioProvider.notifier).playAyah(
      surahName: surahName,
      ayahNumber: ayahNum,
      url: url,
    );
  }

  void _scrollToAyah(int index) {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      index * 150.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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

  @override
  Widget build(BuildContext context) {
    final ayahsAsync = ref.watch(_ayahsProvider(widget.surahNumber));
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

    // Update last read state whenever ayah changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lastReadProvider.notifier).updateLastRead(
        surahNumber: widget.surahNumber,
        surahName: widget.surahName,
        ayahNumber: currentAyah + 1,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(children: [
          Text(widget.surahName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text('Surah ${widget.surahNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ]),
        centerTitle: true,
        actions: [
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
        data: (ayahs) => Column(children: [
          // Surah Header — image background if available
          _SurahHeader(
            surahNumber: widget.surahNumber,
            surahName: widget.surahName,
            verseCount: ayahs.length,
            isPlaying: audioState.surahName == widget.surahName && audioState.isPlaying,
            isDark: isDark,
            onPlayTap: () {
              final urls = ayahs.map((a) => a.audioUrl!).whereType<String>().toList();
              ref.read(quranAudioProvider.notifier).playSurah(
                surahName: widget.surahName,
                ayahUrls: urls,
              );
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
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              itemCount: ayahs.length,
              itemBuilder: (ctx, i) {
                final ayah = ayahs[i];
                final isCurrentAyah = i == currentAyah;
                final isPlaying = audioState.audioUrl == ayah.audioUrl && audioState.isPlaying;

                return GestureDetector(
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
                                '${widget.surahNumber}:${ayah.number}',
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
                                    final isCurrentlyBookmarked = ref.read(bookmarksProvider.notifier).isBookmarked(widget.surahNumber, ayah.number);
                                    ref.read(bookmarksProvider.notifier).toggleBookmark(
                                      BookmarkModel(
                                        surahNumber: widget.surahNumber,
                                        surahName: widget.surahName,
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
                                    ref.watch(bookmarksProvider).any((b) => b.surahNumber == widget.surahNumber && b.ayahNumber == ayah.number)
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
              },
            ),
          ),
        ]),
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
  final VoidCallback onPlayTap;

  const _SurahHeader({
    required this.surahNumber,
    required this.surahName,
    required this.verseCount,
    required this.isPlaying,
    required this.isDark,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    // Will load specific surah image if it exists, otherwise falls back to a clean gradient.
    final imagePath = switch (surahNumber) {
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

          if (surahNumber == 1)
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
              bottom: -67,
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
            bottom: surahNumber == 4 ? -10 : -6,
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
