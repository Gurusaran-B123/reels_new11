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

/// Talks to the Pexels Videos API and rotates between up to 3 API keys.
///
/// * Every successful request moves to the next key (round-robin), which
///   spreads the hourly quota across all keys.
/// * If a key is rate-limited (429) or rejected (401/403) the request is
///   immediately retried with the next key.
class PexelsService {
  PexelsService._();
  static final PexelsService instance = PexelsService._();

  static const String _base = 'https://api.pexels.com/videos';
  int _keyIndex = 0;

  List<String> get _keys => AppConfig.pexelsKeys
      .map((k) => k.trim())
      .where((k) => k.isNotEmpty && !k.startsWith('PASTE_'))
      .toList();

  /// Portrait videos for a topic / user search.
  Future<List<ReelVideo>> search(
    String query, {
    int page = 1,
    int perPage = 15,
  }) {
    return _get('$_base/search', {
      'query': query,
      'orientation': 'portrait',
      'size': 'medium',
      'page': '$page',
      'per_page': '$perPage',
    });
  }

  Future<List<ReelVideo>> _get(String url, Map<String, String> params) async {
    final keys = _keys;
    if (keys.isEmpty) {
      throw PexelsException(
        'Add your Pexels API keys in lib/config/app_config.dart',
      );
    }

    final uri = Uri.parse(url).replace(queryParameters: params);
    String lastReason = 'Could not load videos.';

    for (var attempt = 0; attempt < keys.length; attempt++) {
      final key = keys[_keyIndex % keys.length];
      try {
        final res = await http
            .get(uri, headers: {'Authorization': key})
            .timeout(const Duration(seconds: 15));

        if (res.statusCode == 200) {
          _keyIndex = (_keyIndex + 1) % keys.length; // round-robin
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final list = (data['videos'] as List?) ?? const [];
          return list
              .whereType<Map>()
              .map((e) => ReelVideo.tryParse(Map<String, dynamic>.from(e)))
              .whereType<ReelVideo>()
              .toList();
        }

        if (res.statusCode == 429 ||
            res.statusCode == 401 ||
            res.statusCode == 403) {
          lastReason = res.statusCode == 429
              ? 'Pexels limit reached on all keys. Try again in a bit.'
              : 'A Pexels API key was rejected. Check your keys.';
          _keyIndex = (_keyIndex + 1) % keys.length; // fail over to next key
          continue;
        }

        throw PexelsException('Pexels error (${res.statusCode}). Try again.');
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
