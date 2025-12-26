# Cloudflare Pages Deployment Guide

## Deployment Steps

1. **Push to GitHub/GitLab/Bitbucket**
   ```bash
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **Connect to Cloudflare Pages**
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
   - Navigate to Pages
   - Click "Create a project"
   - Connect your Git repository

3. **Build Settings**
   - **Framework preset**: Vite
   - **Build command**: `npm run build`
   - **Build output directory**: `dist`
   - **Root directory**: `/` (or leave empty)

4. **Environment Variables** (if needed)
   - None required for this project

5. **Deploy**
   - Click "Save and Deploy"
   - Cloudflare Pages will automatically build and deploy your site

## SPA Routing

The `_redirects` file ensures that all routes redirect to `index.html` for proper SPA routing. This is automatically handled by Cloudflare Pages.

## Custom Domain

After deployment, you can add a custom domain in the Cloudflare Pages dashboard under your project settings.

