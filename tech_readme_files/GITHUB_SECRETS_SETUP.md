# GitHub Secrets Setup Guide

## 🔐 Setting Up Repository Secrets

To use tokenized API keys in GitHub Actions, you need to add secrets to your repository.

---

## 📋 Step-by-Step Instructions

### 1. Navigate to Repository Settings

1. Go to your repository: `https://github.com/YoussefSalem582/flutter_mate`
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret** button

### 2. Add Required Secrets

Add the following secrets one by one:

#### **FIREBASE_API_KEY_WEB** (Optional)
- **Name:** `FIREBASE_API_KEY_WEB`
- **Value:** Your Firebase Web API key (e.g., `AIzaSyCPCEK_KS_3mYqVWWQvBW1QuaturMYvv68`)
- **Note:** If not set, uses hardcoded fallback value

#### **OPENAI_API_KEY** (Optional - for AI features)
- **Name:** `OPENAI_API_KEY`
- **Value:** Your OpenAI API key (e.g., `sk-...`)
- **Note:** Only needed if you use AI assistant features

---

## 🎯 Current Workflow Configuration

The GitHub Actions workflow (`.github/workflows/deploy.yml`) is configured to:

1. ✅ **Use secrets if available** - Injects them via `--dart-define`
2. ✅ **Fall back to defaults** - Uses hardcoded values from `api_keys.dart` if secrets not set
3. ✅ **Set production flag** - Always builds with `PRODUCTION=true`

### Build Command:
```yaml
flutter build web --release \
  --base-href /flutter_mate/ \
  --dart-define=FIREBASE_API_KEY_WEB=${FIREBASE_WEB_KEY:-fallback} \
  --dart-define=OPENAI_API_KEY=${OPENAI_KEY:-fallback} \
  --dart-define=PRODUCTION=true
```

---

## 🔑 Recommended Secrets to Add

### Required for Full Functionality:
- `FIREBASE_API_KEY_WEB` - For web authentication
- `FIREBASE_API_KEY_ANDROID` - For Android builds (future)

### Optional (Based on Features):
- `OPENAI_API_KEY` - For AI assistant features
- `STRIPE_PUBLISHABLE_KEY` - For payment processing
- `GOOGLE_CLIENT_ID_WEB` - For Google Sign-In

---

## 🛡️ Security Best Practices

### ✅ DO:
- ✅ Use different API keys for production vs development
- ✅ Rotate secrets regularly
- ✅ Use GitHub's environment protection rules
- ✅ Review secret access permissions
- ✅ Use organization secrets for multiple repos

### ❌ DON'T:
- ❌ Share secrets via chat/email
- ❌ Log secret values in GitHub Actions
- ❌ Use personal API keys for team projects
- ❌ Commit secrets to code (even in private repos)

---

## 🔍 Verifying Secrets Are Working

### Check GitHub Actions Logs

1. Go to **Actions** tab in your repository
2. Click on the latest workflow run
3. Expand the build step
4. Look for the build command - secrets will show as `***`

### Successful Build Output:
```
flutter build web --release \
  --base-href /flutter_mate/ \
  --dart-define=FIREBASE_API_KEY_WEB=*** \
  --dart-define=PRODUCTION=true
```

---

## 📝 Adding a New Secret (Quick Reference)

```
1. GitHub Repository → Settings
2. Secrets and variables → Actions
3. New repository secret
4. Name: SECRET_NAME
5. Value: your_secret_value
6. Add secret
```

---

## 🎬 Video Tutorial

**GitHub Official Documentation:**
- [Creating encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Using secrets in GitHub Actions](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)

---

## 🚀 After Adding Secrets

### Test the Workflow:

1. **Commit and push any change:**
   ```bash
   git add .
   git commit -m "Test deployment with secrets"
   git push
   ```

2. **Monitor the workflow:**
   - Go to **Actions** tab
   - Watch the deployment
   - Check if secrets are being used (shown as `***`)

3. **Verify deployment:**
   - Visit: `https://youssefsalem582.github.io/flutter_mate/`
   - Test authentication
   - Check browser console for any errors

---

## 🔧 Troubleshooting

### Issue: Secrets not working
**Symptoms:** Build uses fallback values even though secrets are set

**Solution:**
1. Check secret names match exactly (case-sensitive)
2. Ensure secrets are in the correct repository
3. Re-run the workflow (Actions → Re-run jobs)
4. Check workflow permissions

### Issue: Workflow fails after adding secrets
**Symptoms:** Build fails with error about --dart-define

**Solution:**
1. Check secret values don't contain special characters that need escaping
2. Verify the syntax in `deploy.yml` is correct
3. Check Flutter version supports `--dart-define`

---

## 📊 Secret Status Checklist

Track which secrets you've configured:

- [ ] `FIREBASE_API_KEY_WEB` - Firebase Web API key
- [ ] `FIREBASE_API_KEY_ANDROID` - Firebase Android API key (future)
- [ ] `OPENAI_API_KEY` - OpenAI API access
- [ ] `STRIPE_PUBLISHABLE_KEY` - Stripe payments
- [ ] `GOOGLE_CLIENT_ID_WEB` - Google OAuth
- [ ] `GOOGLE_CLIENT_ID_ANDROID` - Google OAuth Android

---

## 🎯 Current Configuration

**Repository:** `YoussefSalem582/flutter_mate`  
**Workflow File:** `.github/workflows/deploy.yml`  
**Deployment URL:** `https://youssefsalem582.github.io/flutter_mate/`

**Default Behavior:**
- ✅ Works without any secrets (uses fallback values)
- ✅ Automatically uses secrets when available
- ✅ Always deploys to GitHub Pages on push to `main`

---

## 💡 Pro Tips

1. **Test locally first:**
   ```bash
   flutter build web --release \
     --dart-define=FIREBASE_API_KEY_WEB=your_key \
     --dart-define=PRODUCTION=true
   ```

2. **Use environment secrets** for staging/production separation
3. **Add comments** to remember what each secret is for
4. **Document expiration dates** for rotated secrets
5. **Use GitHub CLI** to manage secrets programmatically:
   ```bash
   gh secret set FIREBASE_API_KEY_WEB --body "your_key_here"
   ```

---

**Last Updated:** October 28, 2025  
**Version:** 1.0.0
