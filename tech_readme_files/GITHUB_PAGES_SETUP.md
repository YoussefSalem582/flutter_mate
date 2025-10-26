# GitHub Pages Setup Guide

## Enable GitHub Pages for FlutterMate

Follow these steps to activate your documentation website:

### 1. Go to Repository Settings

1. Visit: https://github.com/YoussefSalem582/flutter_mate
2. Click on **Settings** tab (top right)

### 2. Navigate to Pages Section

1. In the left sidebar, scroll down and click **Pages**
2. You'll see "GitHub Pages" configuration

### 3. Configure Source

Under "Build and deployment":
- **Source:** Select "Deploy from a branch"
- **Branch:** Select `main`
- **Folder:** Select `/docs`
- Click **Save**

### 4. Wait for Deployment

- GitHub will automatically build and deploy your site
- This usually takes 1-3 minutes
- You'll see a message: "Your site is ready to be published at https://youssefsalem582.github.io/flutter_mate/"

### 5. Verify Deployment

Once deployed, visit:
**https://youssefsalem582.github.io/flutter_mate/**

You should see your beautiful documentation site! 🎉

### 6. Custom Domain (Optional)

If you have a custom domain:
1. Add a `CNAME` file in the `docs/` folder with your domain
2. Configure DNS records at your domain provider
3. Update "Custom domain" in GitHub Pages settings

### 7. Enable HTTPS (Automatic)

GitHub automatically provides HTTPS for your site. Just check:
- ✅ "Enforce HTTPS" (should be enabled by default)

## Troubleshooting

### Site not loading?

- Wait a few more minutes for initial deployment
- Check the Actions tab for build status
- Ensure `/docs` folder exists in main branch

### 404 Error?

- Verify `index.html` exists in `/docs` folder
- Check file permissions
- Clear browser cache and try again

### Styling issues?

- Check browser console for errors
- Verify all CSS is inline or in external files
- Test locally by opening `docs/index.html` in browser

## Making Updates

After editing documentation files:

```bash
git add docs/
git commit -m "docs: update documentation"
git push origin main
```

GitHub Pages will automatically rebuild within 1-2 minutes!

## What You Get

✅ Beautiful landing page at https://youssefsalem582.github.io/flutter_mate/
✅ Professional documentation hosting
✅ Free SSL certificate (HTTPS)
✅ Automatic deployment on every push
✅ SEO-friendly URLs
✅ Mobile responsive design

## Next Steps

1. **Share the link** on social media
2. **Add to README badges** (already done! ✅)
3. **Update documentation** as needed
4. **Monitor analytics** (optional: add Google Analytics)

---

**Your documentation site is now live!** 🚀

Visit: https://youssefsalem582.github.io/flutter_mate/
