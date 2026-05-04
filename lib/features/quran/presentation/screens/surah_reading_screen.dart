import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';

// Ayah model
class Ayah {
  final int number;
  final String arabic;
  final String translation;
  Ayah({required this.number, required this.arabic, required this.translation});
}

// Sample ayahs for Al-Fatihah (offline fallback)
final _fatihahAyahs = [
  Ayah(number: 1, arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', translation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.'),
  Ayah(number: 2, arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', translation: 'All praise is due to Allah, Lord of the worlds.'),
  Ayah(number: 3, arabic: 'الرَّحْمَٰنِ الرَّحِيمِ', translation: 'The Entirely Merciful, the Especially Merciful.'),
  Ayah(number: 4, arabic: 'مَالِكِ يَوْمِ الدِّينِ', translation: 'Sovereign of the Day of Recompense.'),
  Ayah(number: 5, arabic: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', translation: 'It is You we worship and You we ask for help.'),
  Ayah(number: 6, arabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', translation: 'Guide us to the straight path -'),
  Ayah(number: 7, arabic: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', translation: 'The path of those upon whom You have bestowed favor, not of those who have earned anger or of those who are astray.'),
];

// Quran reading provider
final _ayahsProvider = FutureProvider.family<List<Ayah>, int>((ref, surahNumber) async {
  if (surahNumber == 1) return _fatihahAyahs;
  try {
    final dio = Dio();
    final resp = await dio.get(
      'https://api.alquran.cloud/v1/surah/$surahNumber/editions/quran-simple,en.asad',
    ).timeout(const Duration(seconds: 8));
    final arabic = resp.data['data'][0]['ayahs'] as List;
    final english = resp.data['data'][1]['ayahs'] as List;
    return List.generate(arabic.length, (i) => Ayah(
      number: arabic[i]['numberInSurah'] as int,
      arabic: arabic[i]['text'] as String,
      translation: english[i]['text'] as String,
    ));
  } catch (_) {
    return _fatihahAyahs;
  }
});

final _currentAyahProvider = StateProvider<int>((ref) => 0);
final _showTranslationProvider = StateProvider<bool>((ref) => true);


class SurahReadingScreen extends ConsumerWidget {
  final int surahNumber;
  final String surahName;
  const SurahReadingScreen({super.key, required this.surahNumber, required this.surahName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahsAsync = ref.watch(_ayahsProvider(surahNumber));
    final showTranslation = ref.watch(_showTranslationProvider);
    final currentAyah = ref.watch(_currentAyahProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(children: [
          Text(surahName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text('Surah $surahNumber', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
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
          // Bismillah header
          if (surahNumber != 9)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 22, color: Colors.white, height: 1.6), textDirection: TextDirection.rtl),
              ),
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              itemCount: ayahs.length,
              itemBuilder: (ctx, i) {
                final ayah = ayahs[i];
                final isCurrentAyah = i == currentAyah;
                return GestureDetector(
                  onTap: () => ref.read(_currentAyahProvider.notifier).state = i,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isCurrentAyah
                          ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06)
                          : (isDark ? AppColors.cardDark : Colors.white),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCurrentAyah ? AppColors.primary.withValues(alpha: 0.4) : (isDark ? const Color(0xFF1E3045) : const Color(0xFFE8F5EE)),
                        width: isCurrentAyah ? 1.5 : 1,
                      ),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      // Ayah number badge
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: isCurrentAyah ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text('${ayah.number}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                  color: isCurrentAyah ? Colors.white : AppColors.primary))),
                        ),
                        const SizedBox(),
                      ]),
                      const SizedBox(height: 12),
                      // Arabic
                      Text(ayah.arabic,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontFamily: 'Amiri', fontSize: 24, height: 2.0, color: AppColors.textDark)),
                      // Translation
                      if (showTranslation) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(ayah.translation,
                              style: TextStyle(fontSize: 14, height: 1.6, fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.white70 : AppColors.textMedium)),
                        ),
                      ],
                    ]),
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
