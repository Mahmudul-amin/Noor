import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkModel {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String arabicText;
  final String bengaliText;

  BookmarkModel({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.arabicText,
    required this.bengaliText,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkModel &&
          runtimeType == other.runtimeType &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber;

  @override
  int get hashCode => surahNumber.hashCode ^ ayahNumber.hashCode;
}

class BookmarksNotifier extends StateNotifier<List<BookmarkModel>> {
  BookmarksNotifier() : super([]);

  void toggleBookmark(BookmarkModel bookmark) {
    if (state.any((b) => b.surahNumber == bookmark.surahNumber && b.ayahNumber == bookmark.ayahNumber)) {
      state = state.where((b) => !(b.surahNumber == bookmark.surahNumber && b.ayahNumber == bookmark.ayahNumber)).toList();
    } else {
      state = [...state, bookmark];
    }
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    return state.any((b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber);
  }
}

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, List<BookmarkModel>>((ref) {
  return BookmarksNotifier();
});
