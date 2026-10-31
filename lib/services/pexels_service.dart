import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/reel_video.dart';

class PexelsException implements Exception {
  PexelsException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Talks to the Pixabay Videos API and rotates between up to 3 API keys.
///
/// (The file and class keep their old "Pexels" names so no other file has to
/// change. They now use Pixabay.)
///
/// * Every successful request moves to the next key (round-robin).
/// * If a key is rate-limited (429) or rejected (400/401/403) the request is
///   retried immediately with the next key.
class PexelsService {
  PexelsService._();
  static final PexelsService instance = PexelsService._();

  static const String _endpoint = 'https://pixabay.com/api/videos/';
  int _keyIndex = 0;

  List<String> get _keys => AppConfig.pixabayKeys
      .map((k) => k.trim())
      .where((k) => k.isNotEmpty && !k.startsWith('PASTE_'))
      .toList();

  Future<List<ReelVideo>> search(
    String query, {
    int page = 1,
    int perPage = 20,
  }) async {
    final keys = _keys;
    if (keys.isEmpty) {
      throw PexelsException(
        'Add your Pixabay API keys in lib/config/app_config.dart',
      );
    }

    String lastReason = 'Could not load videos.';

    for (var attempt = 0; attempt < keys.length; attempt++) {
      final key = keys[_keyIndex % keys.length];
      final uri = Uri.parse(_endpoint).replace(queryParameters: {
        'key': key,
        'q': query,
        'video_type': 'all',
        'safesearch': 'true',
        'page': '$page',
        'per_page': '$perPage',
      });

      try {
        final res = await http.get(uri).timeout(const Duration(seconds: 15));

        if (res.statusCode == 200) {
          _keyIndex = (_keyIndex + 1) % keys.length; // round-robin
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final hits = (data['hits'] as List?) ?? const [];
          return hits
              .whereType<Map>()
              .map((e) => ReelVideo.tryParsePixabay(Map<String, dynamic>.from(e)))
              .whereType<ReelVideo>()
              .toList();
        }

        // Asking for a page past the last one is not a key problem.
        if (res.statusCode == 400 && res.body.toLowerCase().contains('range')) {
          return <ReelVideo>[];
        }

        if (res.statusCode == 429 ||
            res.statusCode == 400 ||
            res.statusCode == 401 ||
            res.statusCode == 403) {
          lastReason = res.statusCode == 429
              ? 'Pixabay limit reached on all keys. Try again in a minute.'
              : 'A Pixabay API key was rejected. Check your keys.';
          _keyIndex = (_keyIndex + 1) % keys.length; // fail over to next key
          continue;
        }

        throw PexelsException('Pixabay error (${res.statusCode}). Try again.');
      } on PexelsException {
        rethrow;
      } catch (_) {
        lastReason = 'Network problem while loading videos.';
        _keyIndex = (_keyIndex + 1) % keys.length;
      }
    }
    throw PexelsException(lastReason);
  }
}
