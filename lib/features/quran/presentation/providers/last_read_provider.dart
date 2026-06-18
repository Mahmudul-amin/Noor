import 'package:flutter_riverpod/flutter_riverpod.dart';

class LastReadState {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;

  LastReadState({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
  });

  LastReadState copyWith({
    int? surahNumber,
    String? surahName,
    int? ayahNumber,
  }) {
    return LastReadState(
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      ayahNumber: ayahNumber ?? this.ayahNumber,
    );
  }
}

class LastReadNotifier extends StateNotifier<LastReadState?> {
  LastReadNotifier() : super(null);

  void updateLastRead({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
  }) {
    state = LastReadState(
      surahNumber: surahNumber,
      surahName: surahName,
      ayahNumber: ayahNumber,
    );
  }
}

final lastReadProvider = StateNotifierProvider<LastReadNotifier, LastReadState?>((ref) {
  return LastReadNotifier();
});
