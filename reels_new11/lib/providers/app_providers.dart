import 'package:flutter/material.dart';

import '../models/reel_video.dart';
import '../services/hive_service.dart';

/// Dark mode (persisted in Hive).
class ThemeProvider extends ChangeNotifier {
  bool _dark = HiveService.isDarkMode;

  bool get isDark => _dark;
  ThemeMode get mode => _dark ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDark(bool value) async {
    _dark = value;
    notifyListeners();
    await HiveService.setDarkMode(value);
  }
}

/// Liked videos (persisted in Hive).
class LikesProvider extends ChangeNotifier {
  LikesProvider() {
    _videos = HiveService.getLikedVideos();
    _ids = _videos.map((v) => v.id).toSet();
  }

  late List<ReelVideo> _videos;
  late Set<int> _ids;

  List<ReelVideo> get videos => List.unmodifiable(_videos);
  bool isLiked(int id) => _ids.contains(id);

  Future<void> toggle(ReelVideo video) async {
    if (_ids.contains(video.id)) {
      _ids.remove(video.id);
      _videos.removeWhere((v) => v.id == video.id);
      notifyListeners();
      await HiveService.removeLiked(video.id);
    } else {
      _ids.add(video.id);
      _videos.insert(0, video);
      notifyListeners();
      await HiveService.saveLiked(video);
    }
  }
}

/// Global mute switch shared by every reel.
class MuteProvider extends ChangeNotifier {
  bool _muted = false;
  bool get muted => _muted;

  void toggle() {
    _muted = !_muted;
    notifyListeners();
  }
}
