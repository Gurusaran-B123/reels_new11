import 'dart:math';

import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/reel_video.dart';
import '../services/pexels_service.dart';

/// Holds the reel feed: default discover feed or a search, with paging.
class FeedProvider extends ChangeNotifier {
  FeedProvider() {
    loadInitial();
  }

  final PexelsService _service = PexelsService.instance;
  final Random _random = Random();

  final List<ReelVideo> videos = [];
  String? query; // null = discover feed
  String _topic = AppConfig.discoverTopics.first;
  int _page = 1;
  int _generation = 0;
  bool _hasMore = true;

  bool loading = false;
  String? error;

  /// Changes every time the feed is reset, so the pager can rebuild from page 0.
  int session = 0;

  String get activeQuery => query ?? _topic;

  /// Start over. Empty/blank [search] returns to the discover feed.
  Future<void> loadInitial({String? search}) async {
    final trimmed = search?.trim() ?? '';
    query = trimmed.isEmpty ? null : trimmed;
    if (query == null) {
      _topic = AppConfig
          .discoverTopics[_random.nextInt(AppConfig.discoverTopics.length)];
    }
    _generation++;
    session++;
    videos.clear();
    _page = 1;
    _hasMore = true;
    error = null;
    loading = false;
    notifyListeners();
    await _fetch();
  }

  Future<void> loadMore() async {
    if (loading || !_hasMore) return;
    await _fetch();
  }

  Future<void> _fetch() async {
    final gen = _generation;
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.search(activeQuery, page: _page);
      if (gen != _generation) return; // a newer search replaced this one

      final known = videos.map((v) => v.id).toSet();
      videos.addAll(result.where((v) => !known.contains(v.id)));
      _hasMore = result.isNotEmpty;
      _page++;

      if (videos.isEmpty) {
        error = 'No videos found for "$activeQuery".';
      }
    } on PexelsException catch (e) {
      if (gen != _generation) return;
      error = e.message;
    } catch (_) {
      if (gen != _generation) return;
      error = 'Something went wrong. Please try again.';
    }

    if (gen == _generation) {
      loading = false;
      notifyListeners();
    }
  }
}
