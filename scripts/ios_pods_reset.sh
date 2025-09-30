#!/usr/bin/env bash
set -euo pipefail

echo "==> iOS Pods reset starting"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

if [[ ! -d ios ]]; then
  echo "-- ios/ folder not found. Attempting to generate platform folders via 'flutter create .'"
  flutter create .
fi

if [[ ! -d ios ]]; then
  echo "Error: ios/ folder still not found after 'flutter create .'. Ensure you're in the project root (contains pubspec.yaml)."
  exit 1
fi

echo "-- flutter clean"
flutter clean || true

echo "-- remove Pods and lockfile"
rm -rf ios/Pods ios/Podfile.lock || true

echo "-- pod deintegrate"
pushd ios >/dev/null
if ! command -v pod >/dev/null 2>&1; then
  echo "Error: CocoaPods 'pod' not found. Install with: sudo gem install cocoapods"
  popd >/dev/null
  exit 1
fi
pod deintegrate || true
popd >/dev/null

echo "-- clean CocoaPods caches"
pod cache clean --all || true

echo "-- remove potentially corrupted trunk repo (will be recreated)"
rm -rf ~/.cocoapods/repos/trunk || true

echo "-- add trunk repo (optional; pod install will recreate if missing)"
pod repo add trunk https://cdn.cocoapods.org/ || true

echo "-- pod install with repo update"
pushd ios >/dev/null
pod install --repo-update
popd >/dev/null

echo "==> iOS Pods reset complete"
