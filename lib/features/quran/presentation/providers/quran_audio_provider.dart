import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

class QuranAudioState {
  final String? surahName;
  final int? ayahNumber;
  final bool isPlaying;
  final double progress;
  final String? audioUrl;

  QuranAudioState({
    this.surahName,
    this.ayahNumber,
    this.isPlaying = false,
    this.progress = 0.0,
    this.audioUrl,
  });

  QuranAudioState copyWith({
    String? surahName,
    int? ayahNumber,
    bool? isPlaying,
    double? progress,
    String? audioUrl,
  }) {
    return QuranAudioState(
      surahName: surahName ?? this.surahName,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      isPlaying: isPlaying ?? this.isPlaying,
      progress: progress ?? this.progress,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}

class QuranAudioNotifier extends StateNotifier<QuranAudioState> {
  final AudioPlayer _player = AudioPlayer();
  List<String> _playlist = [];
  int _currentIndex = 0;

  QuranAudioNotifier() : super(QuranAudioState()) {
    _player.onPositionChanged.listen((pos) {
      _player.getDuration().then((duration) {
        if (duration != null && duration.inMilliseconds > 0) {
          state = state.copyWith(
            progress: pos.inMilliseconds / duration.inMilliseconds,
          );
        }
      });
    });

    _player.onPlayerComplete.listen((_) {
      if (_currentIndex < _playlist.length - 1) {
        _currentIndex++;
        _playFromPlaylist();
      } else {
        state = state.copyWith(isPlaying: false, progress: 0.0);
      }
    });
  }

  Future<void> _playFromPlaylist() async {
    final url = _playlist[_currentIndex];
    state = state.copyWith(
      audioUrl: url,
      isPlaying: true,
      ayahNumber: _currentIndex + 1, // Simple mapping, assumes playlist is current surah
    );
    await _player.stop();
    await _player.play(UrlSource(url));
  }

  Future<void> playSurah({
    required String surahName,
    required List<String> ayahUrls,
  }) async {
    _playlist = ayahUrls;
    _currentIndex = 0;
    state = state.copyWith(
      surahName: surahName,
      ayahNumber: 1,
    );
    await _playFromPlaylist();
  }

  Future<void> playAyah({
    required String surahName,
    required int ayahNumber,
    required String url,
  }) async {
    _playlist = [url];
    _currentIndex = 0;
    if (state.audioUrl == url && state.isPlaying) {
      await pause();
    } else if (state.audioUrl == url && !state.isPlaying) {
      await _player.resume();
      state = state.copyWith(isPlaying: true);
    } else {
      await _player.stop();
      state = QuranAudioState(
        surahName: surahName,
        ayahNumber: ayahNumber,
        audioUrl: url,
        isPlaying: true,
      );
      await _player.play(UrlSource(url));
    }
  }

  Future<void> togglePlay() async {
    if (state.audioUrl == null) return;
    if (state.isPlaying) {
      await pause();
    } else {
      await _player.resume();
      state = state.copyWith(isPlaying: true);
    }
  }

  Future<void> pause() async {
    await _player.pause();
    state = state.copyWith(isPlaying: false);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final quranAudioProvider = StateNotifierProvider<QuranAudioNotifier, QuranAudioState>((ref) {
  return QuranAudioNotifier();
});
