#!/bin/bash

set -e

# Base version name - UPDATE THIS IN ONE PLACE
VERSION_NAME="0.0.4"

# Get git commit count for build number
VERSION_CODE=$(git rev-list --count HEAD 2>/dev/null || echo "1")

VERSION="${VERSION_NAME}+${VERSION_CODE}"
echo "Building version: ${VERSION_NAME} (build ${VERSION_CODE})"

# Update pubspec.yaml with the calculated version
# This ensures pubspec.yaml always matches what we're building
# Use a temporary file for macOS compatibility
sed "s/^version:.*/version: ${VERSION}/" pubspec.yaml > pubspec.yaml.tmp && mv pubspec.yaml.tmp pubspec.yaml

# Get dependencies
flutter pub get

# Build release APK (for direct distribution) with version
flutter build apk --release --build-name="$VERSION_NAME" --build-number="$VERSION_CODE"

# Build release AAB (required for Google Play Store) with version
flutter build appbundle --release --build-name="$VERSION_NAME" --build-number="$VERSION_CODE"

# Copy to dist/ with versioned names
mkdir -p dist
APK_FILE="dist/finer-history-${VERSION_NAME}-${VERSION_CODE}.apk"
AAB_FILE="dist/finer-history-${VERSION_NAME}-${VERSION_CODE}.aab"
cp build/app/outputs/flutter-apk/app-release.apk "${APK_FILE}"
cp build/app/outputs/bundle/release/app-release.aab "${AAB_FILE}"

echo ""
echo "Build complete:"
echo "  Version: ${VERSION_NAME} (build ${VERSION_CODE})"
echo "  APK: ${APK_FILE}"
echo "  AAB: ${AAB_FILE} (for Google Play Store)"

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
