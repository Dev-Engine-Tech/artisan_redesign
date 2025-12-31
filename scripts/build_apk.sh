#!/usr/bin/env bash
set -euo pipefail

# Simple helper to build an Android APK for this Flutter project.
#
# Usage:
#   scripts/build_apk.sh [release|debug|profile]
# Defaults to release if not specified.
#
# Notes:
# - For release builds with signing, ensure android/app/key.properties exists
#   and points to a valid keystore (see docs below).
# - For a quick unsigned build, you can run a debug build instead.

CHANNEL="${1:-release}"

echo "==> Running flutter pub get"
flutter pub get

case "$CHANNEL" in
  release)
    echo "==> Building signed/unsigned release APK"
    flutter build apk --release
    ;;
  debug)
    echo "==> Building debug APK"
    flutter build apk --debug
    ;;
  profile)
    echo "==> Building profile APK"
    flutter build apk --profile
    ;;
  *)
    echo "Unknown channel: $CHANNEL (expected: release|debug|profile)" >&2
    exit 1
    ;;
esac

echo "==> Build artifacts:"
ls -lah build/app/outputs/flutter-apk || true

cat << 'INFO'

Signing setup (one-time, for release):
1) Create a keystore (once):
   keytool -genkey -v -keystore android/app/my-release-key.jks \
     -alias upload -keyalg RSA -keysize 2048 -validity 10000

2) Create android/app/key.properties with:
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=my-release-key.jks

3) Ensure android/app/build.gradle reads key.properties for release signing
   (Flutter templates already do this by default).

The built APK will be at:
  build/app/outputs/flutter-apk/app-release.apk  (release)
  build/app/outputs/flutter-apk/app-debug.apk    (debug)

INFO

