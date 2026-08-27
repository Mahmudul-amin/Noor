import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Reciter {
  final int id;
  final String name;
  final String? style;

  Reciter({
    required this.id,
    required this.name,
    this.style,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      id: json['id'] as int,
      name: json['reciter_name'] as String,
      style: json['style'] as String?,
    );
  }
}

final reciterProvider = StateNotifierProvider<ReciterNotifier, int>((ref) {
  return ReciterNotifier();
});

class ReciterNotifier extends StateNotifier<int> {
  static const _key = 'selected_reciter_id';

  ReciterNotifier() : super(7) {
    _loadReciter();
  }

  Future<void> _loadReciter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt(_key);
    if (savedId != null) {
      state = savedId;
    }
  }

  Future<void> setReciter(int id) async {
    state = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, id);
  }
}

final recitersListProvider = FutureProvider<List<Reciter>>((ref) async {
  final dio = Dio();
  final response = await dio.get('https://api.quran.com/api/v4/resources/recitations');
  
  if (response.statusCode == 200) {
    final List<dynamic> recitationsData = response.data['recitations'];
    return recitationsData.map((data) => Reciter.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load reciters');
  }
});
