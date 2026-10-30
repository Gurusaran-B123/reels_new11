/// Central place for app-wide constants.
class AppConfig {
  AppConfig._();

  static const String appName = 'Reels new11';
  static const String brand = 'deplofree';
  static const String developer = 'Developed by Gurusaran B';

  /// Keep in sync with `version:` in pubspec.yaml.
  static const String version = '1.0.0';

  /// ---------------------------------------------------------------------
  /// PASTE YOUR 3 PEXELS API KEYS HERE  (free: https://www.pexels.com/api/)
  /// The app rotates through them on every request and automatically jumps
  /// to the next key if one is rate-limited (HTTP 429) or rejected (401/403).
  /// ---------------------------------------------------------------------
  static const List<String> pexelsKeys = <String>[
    '58319702-8903d93fec27785a78090fbdb',
    'PASTE_PEXELS_API_KEY_2',
    'PASTE_PEXELS_API_KEY_3',
  ];

  /// Topics used for the default feed (one is picked at random on launch).
  static const List<String> discoverTopics = <String>[
    'nature',
    'travel',
    'city night',
    'food',
    'ocean',
    'dance',
    'fitness',
    'sunset',
    'cars',
    'animals',
    'fashion',
    'street',
  ];

  /// Quick-search chips shown under the search bar.
  static const List<String> quickChips = <String>[
    'Nature',
    'Travel',
    'Food',
    'Dance',
    'Cars',
    'Animals',
    'Fitness',
  ];
}
