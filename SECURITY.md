# Security Policy

## Reporting a Security Vulnerability

If you discover a security vulnerability in this project, please report it by emailing youssef.sash@gmail.com

Please do **NOT** create a public GitHub issue for security vulnerabilities.

## API Keys and Secrets

This repository uses `.gitignore` to prevent committing sensitive files:

### Protected Files (Never Committed):
- `lib/core/config/api_keys.dart` - Real API keys
- `android/app/google-services.json` - Firebase Android config
- `ios/Runner/GoogleService-Info.plist` - Firebase iOS config
- `lib/firebase_options.dart` - Firebase configuration

### Public Files (Safe to Commit):
- `web/index.html` - **Web Firebase config IS public by design** - Web apps expose these keys in client code. Security is enforced by Firebase Security Rules, not by hiding the keys.

### Example Files (Safe to Commit):
- `lib/core/config/api_keys_example.dart` - Template with placeholder values
- `android/app/google-services.json.example` - Template
- `lib/firebase_options.dart.example` - Template
- `web/index.html.example` - Template

**All example files contain only placeholder values like:**
- `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`
- `your-project-id`
- `123456789-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com`

These are NOT real API keys and cannot be used to access any services.

## Setup Instructions

To set up this project:

1. Copy example files and remove `.example` extension
2. Replace placeholder values with your actual API keys
3. Never commit the real files (they're in `.gitignore`)

See `tech_readme_files/API_KEYS_SETUP.md` for detailed instructions.

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Security Best Practices

- All sensitive configuration files are in `.gitignore`
- Firebase Security Rules are properly configured
- API keys are environment-specific
- Production keys are never committed to repository
