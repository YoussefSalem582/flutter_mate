#!/bin/bash

# FlutterMate API Key Setup Script
# Run this after cloning the repository

echo "🔧 FlutterMate API Key Setup"
echo "============================"
echo ""

# Check if .env already exists
if [ -f ".env" ]; then
    echo "✅ .env file already exists"
    read -p "Do you want to overwrite it? (y/N): " overwrite
    if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
        echo "Keeping existing .env file"
        exit 0
    fi
fi

# Copy .env.example to .env
if [ -f ".env.example" ]; then
    cp ".env.example" ".env"
    echo "✅ Created .env file from .env.example"
else
    echo "❌ .env.example not found!"
    exit 1
fi

echo ""
echo "📝 Next Steps:"
echo "1. Edit .env file and add your actual API keys"
echo "2. Get Firebase keys from Firebase Console"
echo "3. Run: flutter pub get"
echo "4. Run: flutter run -d chrome"

echo ""
echo "📚 Documentation:"
echo "- API Key Security: tech_readme_files/API_KEY_SECURITY_GUIDE.md"
echo "- API Keys Setup: tech_readme_files/API_KEYS_SETUP.md"

echo ""
echo "🔒 Security Check:"

# Verify .env is gitignored
if git check-ignore .env > /dev/null 2>&1; then
    echo "✅ .env is properly gitignored"
else
    echo "⚠️  WARNING: .env may not be gitignored!"
    echo "   Add '.env' to your .gitignore file"
fi

echo ""
echo "✨ Setup complete!"
