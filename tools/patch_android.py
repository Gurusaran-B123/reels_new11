#!/usr/bin/env python3
"""Android fixes needed for this app. Run from the project root (setup.sh does it).

1. AndroidManifest.xml  -> permissions, app label, legacy storage flag.
2. gallery_saver plugin -> add `namespace` + newer compileSdk so it builds with
   current Android Gradle Plugin (the plugin is old and has no namespace).
"""
import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse

ROOT = Path.cwd()


def patch_manifest() -> None:
    path = ROOT / "android/app/src/main/AndroidManifest.xml"
    if not path.exists():
        sys.exit("AndroidManifest.xml not found - run `flutter create` first.")
    text = path.read_text(encoding="utf-8")

    permissions = [
        '<uses-permission android:name="android.permission.INTERNET"/>',
        '<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>',
        '<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29"/>',
        '<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>',
        '<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>',
    ]
    missing = [p for p in permissions if p.split('"')[1] not in text]
    if missing:
        block = "\n    ".join(missing) + "\n\n    "
        text = text.replace("<application", block + "<application", 1)

    text = re.sub(r'android:label="[^"]*"', 'android:label="Reels new11"', text, count=1)

    if "requestLegacyExternalStorage" not in text:
        text = text.replace(
            "<application",
            '<application\n        android:requestLegacyExternalStorage="true"',
            1,
        )
    path.write_text(text, encoding="utf-8")
    print("[ok] AndroidManifest.xml patched")


def patch_gallery_saver() -> None:
    cfg = ROOT / ".dart_tool/package_config.json"
    if not cfg.exists():
        print("[skip] run `flutter pub get` first, then re-run this script")
        return
    packages = json.loads(cfg.read_text())["packages"]
    entry = next((p for p in packages if p["name"] == "gallery_saver"), None)
    if not entry:
        print("[skip] gallery_saver not in dependencies")
        return

    pkg_dir = Path(unquote(urlparse(entry["rootUri"]).path))
    if not pkg_dir.is_absolute():
        pkg_dir = (cfg.parent / entry["rootUri"]).resolve()
    gradle = pkg_dir / "android/build.gradle"
    manifest = pkg_dir / "android/src/main/AndroidManifest.xml"
    if not gradle.exists():
        print("[skip] gallery_saver android/build.gradle not found")
        return

    g = gradle.read_text()
    m = manifest.read_text() if manifest.exists() else ""
    pkg_match = re.search(r'package="([^"]+)"', m)
    namespace = pkg_match.group(1) if pkg_match else "carnegietechnologies.gallery_saver"

    if "namespace" not in g:
        g = re.sub(r"android\s*\{", f"android {{\n    namespace '{namespace}'", g, count=1)
    g = re.sub(r"compileSdkVersion\s+\d+", "compileSdkVersion 34", g)

    # Java and Kotlin must target the same JVM version (Kotlin follows JDK 17).
    if "VERSION_17" not in g:
        g = re.sub(r"compileOptions\s*\{[^}]*\}", "", g)
        g = re.sub(
            r"android\s*\{",
            "android {\n    compileOptions {\n"
            "        sourceCompatibility JavaVersion.VERSION_17\n"
            "        targetCompatibility JavaVersion.VERSION_17\n    }",
            g,
            count=1,
        )
    gradle.write_text(g)

    if pkg_match:
        manifest.write_text(re.sub(r'\s+package="[^"]+"', "", m, count=1))
    print(f"[ok] gallery_saver patched (namespace {namespace})")


if __name__ == "__main__":
    patch_manifest()
    patch_gallery_saver()
