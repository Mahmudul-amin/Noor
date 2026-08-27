import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class QuranAudioState {
  final String? surahName;
  final int? ayahNumber;
  final bool isPlaying;
  final double progress;
  final String? audioUrl;
  final bool isJuz;
  final int? readingId;

  QuranAudioState({
    this.surahName,
    this.ayahNumber,
    this.isPlaying = false,
    this.progress = 0.0,
    this.audioUrl,
    this.isJuz = false,
    this.readingId,
  });

  QuranAudioState copyWith({
    String? surahName,
    int? ayahNumber,
    bool? isPlaying,
    double? progress,
    String? audioUrl,
    bool? isJuz,
    int? readingId,
  }) {
    return QuranAudioState(
      surahName: surahName ?? this.surahName,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      isPlaying: isPlaying ?? this.isPlaying,
      progress: progress ?? this.progress,
      audioUrl: audioUrl ?? this.audioUrl,
      isJuz: isJuz ?? this.isJuz,
      readingId: readingId ?? this.readingId,
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
    if (_currentIndex >= _playlist.length) return;
    
    final url = _playlist[_currentIndex];
    state = state.copyWith(
      audioUrl: url,
      isPlaying: true,
      ayahNumber: _currentIndex + 1, // Simple mapping, assumes playlist is current surah
    );
    
    try {
      if (_player.state == PlayerState.playing || _player.state == PlayerState.paused) {
        await _player.stop();
      }
      await _player.play(UrlSource(url));
    } catch (e) {
      debugPrint('Error playing audio: $e');
      // If it fails to play this ayah, skip to the next one automatically
      if (_currentIndex < _playlist.length - 1) {
        _currentIndex++;
        _playFromPlaylist();
      } else {
        state = state.copyWith(isPlaying: false, progress: 0.0);
      }
    }
  }

  Future<void> playSurah({
    required String surahName,
    required List<String> ayahUrls,
    bool isJuz = false,
    int? readingId,
  }) async {
    _playlist = ayahUrls;
    _currentIndex = 0;
    state = state.copyWith(
      surahName: surahName,
      ayahNumber: 1,
      isJuz: isJuz,
      readingId: readingId,
    );
    await _playFromPlaylist();
  }

  Future<void> playAyah({
    required String surahName,
    required int ayahNumber,
    required String url,
    bool isJuz = false,
    int? readingId,
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
        isJuz: isJuz,
        readingId: readingId,
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

  Future<void> stop() async {
    await _player.stop();
    _playlist = [];
    _currentIndex = 0;
    state = QuranAudioState(); // Reset state completely
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
