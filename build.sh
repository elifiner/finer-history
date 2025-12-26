#!/bin/bash

set -e

# Get git commit count for version
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
VERSION="0.0.1-${COMMIT_COUNT}"

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Copy to dist/ with versioned name
mkdir -p dist
cp build/app/outputs/flutter-apk/app-release.apk "dist/finer-history-${VERSION}.apk"

echo "Build complete: dist/finer-history-${VERSION}.apk"
