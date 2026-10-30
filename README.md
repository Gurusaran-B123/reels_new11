# Reels new11

Instagram-style vertical reels app built with Flutter. Videos come from the Pexels API,
everything else (dark mode, liked videos) is stored locally with Hive. No backend.

## Build the APK

```bash
cd reels_new11
bash setup.sh                       # one time: Android folder, packages, patches, icon
# open lib/config/app_config.dart and paste your 3 Pexels API keys
flutter build apk --release
```

APK: `build/app/outputs/flutter-apk/app-release.apk`

Free Pexels keys: https://www.pexels.com/api/ (one per account/email gives you 3 separate quotas).

## Features

| # | Feature | Where |
|---|---------|-------|
| 1 | Vertical swipe reels (Pexels) | `widgets/reels_pager.dart`, `widgets/reel_item.dart` |
| 2 | Search bar + quick chips | `screens/feed_screen.dart` |
| 3 | Mute/Unmute, Play/Pause, Share, Download (+ Like) | `widgets/reel_item.dart` |
| 4 | Download to gallery (`gallery_saver`) | `services/download_service.dart` |
| 5 | Share (`share_plus`) | `widgets/reel_item.dart` |
| 6 | Hive: dark mode + liked videos | `services/hive_service.dart` |
| 7 | Dark mode toggle | `screens/settings_screen.dart` |
| 8 | Settings: deplofree, Developed by Gurusaran B, version | `screens/settings_screen.dart` |
| 9 | No-internet screen (`connectivity_plus`) | `screens/connectivity_gate.dart` |
| 10 | Local DB only | Hive, no server |
| 11 | Logo colours (pink → purple → orange) | `theme/app_theme.dart` |

Pexels key rotation: `services/pexels_service.dart` (round-robin + automatic fail-over on 429/401/403).

Tip: double-tap a reel to like it. Tap once to play/pause.

## If the gallery_saver build fails

`gallery_saver` is an older plugin. `tools/patch_android.py` fixes the usual Gradle errors
(missing namespace, old compileSdk) and `setup.sh` runs it for you. If you ever run
`flutter clean` + a fresh pub cache and the build complains again, run
`python3 tools/patch_android.py` once more. If it still fails, swap the plugin for
`gal` (maintained) and change only `services/download_service.dart`.

## Change app version

Edit `version:` in `pubspec.yaml` and `AppConfig.version` in `lib/config/app_config.dart`.
