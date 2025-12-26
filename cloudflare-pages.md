# Cloudflare Pages Deployment Guide

## Using Wrangler CLI (Recommended)

### Prerequisites
1. Install Wrangler (already included as dev dependency)
2. Authenticate with Cloudflare:
   ```bash
   npx wrangler login
   ```

### Deployment

**Deploy to production:**
```bash
npm run deploy
```

**Deploy to preview:**
```bash
npm run deploy:preview
```

The deploy script will:
1. Build the project (`npm run build`)
2. Deploy the `dist` folder to Cloudflare Pages using Wrangler

### First-time Setup

1. **Authenticate:**
   ```bash
   npx wrangler login
   ```
   This will open your browser to authenticate with Cloudflare.

2. **Create a Pages project (first time only):**
   ```bash
   npx wrangler pages project create finer-history
   ```

3. **Deploy:**
   ```bash
   npm run deploy
   ```

## Alternative: Git-based Deployment

If you prefer Git-based automatic deployments:

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

4. **Deploy**
   - Click "Save and Deploy"
   - Cloudflare Pages will automatically build and deploy your site

## SPA Routing

The `_redirects` file ensures that all routes redirect to `index.html` for proper SPA routing. This is automatically handled by Cloudflare Pages.

## Custom Domain

After deployment, you can add a custom domain:
- **Via Wrangler**: Use `wrangler pages domain add <your-domain.com>`
- **Via Dashboard**: Cloudflare Pages dashboard → Your project → Custom domains

