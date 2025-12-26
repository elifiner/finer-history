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

# Deploy to Cloudflare Pages
echo "Deploying to Cloudflare Pages..."
if command -v wrangler &> /dev/null; then
    wrangler pages deploy build/web --project-name=finer-history
    if [ $? -eq 0 ]; then
        echo ""
        echo "Deployment complete!"
    else
        echo ""
        echo "Deployment failed. Make sure you're logged in: wrangler login"
        exit 1
    fi
else
    echo "Wrangler CLI not found. Install it with: npm install -g wrangler"
    echo "Then login with: wrangler login"
    echo "And deploy manually with: wrangler pages deploy build/web --project-name=finer-history"
    exit 1
fi

