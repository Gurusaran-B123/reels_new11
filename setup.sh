#!/usr/bin/env bash
# One-time setup: creates the Android project around the Dart code, installs
# packages, patches Android config and generates the launcher icon.
# Usage:  cd reels_new11 && bash setup.sh
set -euo pipefail

command -v flutter >/dev/null || { echo "Flutter not found. Install it from https://docs.flutter.dev/get-started/install"; exit 1; }

# Keep our own files safe while `flutter create` generates the platform folders.
BACKUP="$(mktemp -d)"
cp -r lib assets pubspec.yaml "$BACKUP"/
flutter create --org com.deplofree --project-name reels_new11 --platforms=android .
rm -rf lib assets pubspec.yaml
cp -r "$BACKUP"/lib "$BACKUP"/assets "$BACKUP"/pubspec.yaml .
rm -rf "$BACKUP" test

flutter pub get
python3 tools/patch_android.py
dart run flutter_launcher_icons

echo
echo "Done. Next:"
echo "  1. Put your 3 Pexels keys in lib/config/app_config.dart"
echo "  2. flutter run                      (test on a phone)"
echo "  3. flutter build apk --release      (APK -> build/app/outputs/flutter-apk/app-release.apk)"
