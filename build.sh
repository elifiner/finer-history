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

# Upload to dropcli.com
echo ""
echo "Uploading to dropcli.com..."
UPLOAD_URL=$(curl --progress-bar --upload-file "${APK_FILE}" "https://dropcli.com/upload")

if [ $? -eq 0 ] && [ -n "$UPLOAD_URL" ]; then
    echo ""
    echo "Upload complete!"
    echo "Download URL: ${UPLOAD_URL}"
else
    echo ""
    echo "Upload failed"
    exit 1
fi
