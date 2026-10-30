import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/reel_video.dart';

/// All local storage lives here (Hive). No backend, no cloud DB.
///
/// Boxes:
///  * `settings` -> { darkMode: bool }
///  * `liked`    -> { "<videoId>": "<json string of video + likedAt>" }
class HiveService {
  HiveService._();

  static const String _settingsBox = 'settings';
  static const String _likedBox = 'liked';
  static const String _darkKey = 'darkMode';

  static late Box _settings;
  static late Box _liked;

  static Future<void> init() async {
    await Hive.initFlutter();
    _settings = await Hive.openBox(_settingsBox);
    _liked = await Hive.openBox(_likedBox);
  }

  // ---- Dark mode ---------------------------------------------------------
  static bool get isDarkMode =>
      _settings.get(_darkKey, defaultValue: true) as bool;

  static Future<void> setDarkMode(bool value) => _settings.put(_darkKey, value);

  // ---- Liked videos ------------------------------------------------------
  /// Newest like first.
  static List<ReelVideo> getLikedVideos() {
    final rows = <MapEntry<int, ReelVideo>>[];
    for (final raw in _liked.values) {
      try {
        final map = jsonDecode(raw as String) as Map<String, dynamic>;
        rows.add(MapEntry(
          (map['likedAt'] as num?)?.toInt() ?? 0,
          ReelVideo.fromJson(map),
        ));
      } catch (_) {
        // skip corrupted rows
      }
    }
    rows.sort((a, b) => b.key.compareTo(a.key));
    return rows.map((e) => e.value).toList();
  }

  static Future<void> saveLiked(ReelVideo video) {
    final map = video.toJson()
      ..['likedAt'] = DateTime.now().millisecondsSinceEpoch;
    return _liked.put(video.id.toString(), jsonEncode(map));
  }

  static Future<void> removeLiked(int id) => _liked.delete(id.toString());
}
