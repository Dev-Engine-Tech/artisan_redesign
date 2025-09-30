#!/usr/bin/env bash
set -euo pipefail

# Pin gRPC-Core in Podfile to a stable version to avoid CDN podspec corruption.
# Usage: ./scripts/ios_pods_pin_grpc_core.sh [pin|unpin]

ACTION="${1:-pin}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PODFILE="$PROJECT_ROOT/ios/Podfile"

if [[ ! -f "$PODFILE" ]]; then
  echo "Error: Podfile not found at $PODFILE"
  exit 1
fi

if [[ "$ACTION" == "pin" ]]; then
  echo "==> Pinning gRPC-Core to 1.62.2 in Podfile"
  if ! grep -q "pod 'gRPC-Core'" "$PODFILE"; then
    # Insert after the target 'Runner' do line
    awk '/target \'Runner\' do/ { print; print "  pod \'gRPC-Core\', \'1.62.2\'"; next }1' "$PODFILE" > "$PODFILE.tmp"
    mv "$PODFILE.tmp" "$PODFILE"
  else
    # Update existing pin
    sed -i.bak "s/pod 'gRPC-Core'.*/pod 'gRPC-Core', '1.62.2'/" "$PODFILE"
  fi
elif [[ "$ACTION" == "unpin" ]]; then
  echo "==> Removing gRPC-Core pin from Podfile"
  sed -i.bak "/pod 'gRPC-Core'/d" "$PODFILE"
else
  echo "Usage: $0 [pin|unpin]"
  exit 1
fi

echo "-- Running pod install --repo-update"
pushd "$PROJECT_ROOT/ios" >/dev/null
pod install --repo-update
popd >/dev/null

echo "==> Done"

