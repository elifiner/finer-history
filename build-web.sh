#!/bin/bash

set -e

echo "Building Flutter web app..."

# Get dependencies
flutter pub get

# Build web release
flutter build web --release

# Copy _redirects file for SPA routing (needed for Cloudflare Pages)
cp web/_redirects build/web/_redirects 2>/dev/null || echo "/*    /index.html   200" > build/web/_redirects

echo ""
echo "Web build complete!"
echo "Output directory: build/web"
echo ""
echo "To deploy to Cloudflare Pages:"
echo "1. Install Wrangler CLI: npm install -g wrangler"
echo "2. Login: wrangler login"
echo "3. Deploy: wrangler pages deploy build/web --project-name=finer-history"
echo ""
echo "Or use Cloudflare Pages dashboard:"
echo "1. Go to Cloudflare Dashboard > Pages"
echo "2. Connect your Git repository or upload build/web folder"
echo "3. Set build command: flutter build web --release"
echo "4. Set build output directory: build/web"

