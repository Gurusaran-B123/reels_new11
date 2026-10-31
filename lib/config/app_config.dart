/// Central place for app-wide constants.
class AppConfig {
  AppConfig._();

  static const String appName = 'Reels new11';
  static const String brand = 'deplofree';
  static const String developer = 'Developed by Gurusaran B';

  /// Keep in sync with `version:` in pubspec.yaml.
  static const String version = '1.0.0';

  /// ---------------------------------------------------------------------
  /// PASTE YOUR PIXABAY API KEYS HERE  (free: https://pixabay.com/api/docs/)
  /// Up to 3 keys. If you have only 1 or 2, just leave the others as they are.
  /// The app rotates through them on every request and automatically jumps
  /// to the next key if one is rate-limited (HTTP 429) or rejected.
  /// ---------------------------------------------------------------------
  static const List<String> pixabayKeys = <String>[
    '58319702-8903d93fec27785a78090fbdb',
    'PASTE_PIXABAY_API_KEY_2',
    'PASTE_PIXABAY_API_KEY_3',
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
