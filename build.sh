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
APK_FILE="dist/finer-history-${VERSION}.apk"
cp build/app/outputs/flutter-apk/app-release.apk "${APK_FILE}"

echo "Build complete: ${APK_FILE}"

# Upload to elifiner.com via scp
echo ""
echo "Uploading to elifiner.com..."
rsync --progress "${APK_FILE}" elifiner.com:/var/www/html/files/apps/history/

if [ $? -eq 0 ]; then
    echo ""
    echo "Upload complete!"
    echo "File available at: https://files.elifiner.com/apps/history/finer-history-${VERSION}.apk"
else
    echo ""
    echo "Upload failed"
    exit 1
fi
