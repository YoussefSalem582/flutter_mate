# GitHub Pages Deployment

This Flutter web app is configured to automatically deploy to GitHub Pages.

## Setup Instructions

1. **Enable GitHub Pages**
   - Go to your repository Settings
   - Navigate to Pages (under Code and automation)
   - Under "Source", select "GitHub Actions"

2. **Push to main branch**
   ```bash
   git add .
   git commit -m "Setup GitHub Pages deployment"
   git push origin main
   ```

3. **Access your app**
   - After the workflow completes, your app will be available at:
   - `https://youssefsamem582.github.io/flutter_mate/`

## Manual Build (Optional)

To build the web version locally:

```bash
# Build for GitHub Pages (with base href)
flutter build web --release --base-href /flutter_mate/

# The built files will be in build/web/
```

## Workflow

The GitHub Actions workflow (`.github/workflows/deploy.yml`) will:
- Trigger on every push to the main branch
- Install Flutter
- Build the web app
- Deploy to GitHub Pages

## Notes

- The `--base-href /flutter_mate/` flag is important for GitHub Pages
- Update the repository name in the workflow if you rename the repo
- The first deployment may take a few minutes

## Troubleshooting

If the deployment fails:
1. Check the Actions tab for error details
2. Ensure GitHub Pages is enabled in Settings
3. Verify the workflow has necessary permissions
4. Make sure the repository is public (or you have GitHub Pro for private repos)
