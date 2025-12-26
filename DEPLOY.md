# Deployment Guide

## Cloudflare Pages Deployment

This app can be deployed to Cloudflare Pages using one of the following methods:

### Method 1: Manual Deployment via Wrangler CLI

1. **Install Wrangler CLI** (if not already installed):
   ```bash
   npm install -g wrangler
   ```

2. **Login to Cloudflare**:
   ```bash
   wrangler login
   ```

3. **Build the web app**:
   ```bash
   bash build-web.sh
   ```

4. **Deploy to Cloudflare Pages**:
   ```bash
   wrangler pages deploy build/web --project-name=finer-history
   ```

### Method 2: Cloudflare Pages Dashboard

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com) > Pages
2. Click "Create a project"
3. Choose one of:
   - **Connect to Git**: Connect your GitHub/GitLab repository
     - Build command: `flutter build web --release`
     - Build output directory: `build/web`
     - Root directory: `/` (root of repo)
   - **Upload assets**: Upload the `build/web` folder after running `bash build-web.sh`

### Method 3: GitHub Actions (Automatic)

The repository includes a GitHub Actions workflow (`.github/workflows/deploy-cloudflare.yml`) that automatically deploys to Cloudflare Pages on push to main.

**Setup required:**
1. Add secrets to your GitHub repository:
   - `CLOUDFLARE_API_TOKEN`: Your Cloudflare API token (with Pages:Edit permissions)
   - `CLOUDFLARE_ACCOUNT_ID`: Your Cloudflare account ID

2. The workflow will automatically:
   - Build the Flutter web app
   - Deploy to Cloudflare Pages on every push to `main`

### Notes

- The `_redirects` file is automatically copied to `build/web` during the build process to handle SPA routing
- The app uses Flutter's web build output which is optimized for production
- Cloudflare Pages provides free SSL and CDN distribution automatically

