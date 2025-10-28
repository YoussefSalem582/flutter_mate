# FlutterMate API Key Setup Script
# Run this after cloning the repository

Write-Host "🔧 FlutterMate API Key Setup" -ForegroundColor Cyan
Write-Host "============================`n" -ForegroundColor Cyan

# Check if .env already exists
if (Test-Path ".env") {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
    $overwrite = Read-Host "Do you want to overwrite it? (y/N)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "Keeping existing .env file" -ForegroundColor Yellow
        exit 0
    }
}

# Copy .env.example to .env
if (Test-Path ".env.example") {
    Copy-Item ".env.example" ".env"
    Write-Host "✅ Created .env file from .env.example" -ForegroundColor Green
} else {
    Write-Host "❌ .env.example not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`n📝 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Edit .env file and add your actual API keys" -ForegroundColor White
Write-Host "2. Get Firebase keys from Firebase Console" -ForegroundColor White
Write-Host "3. Run: flutter pub get" -ForegroundColor White
Write-Host "4. Run: flutter run -d chrome" -ForegroundColor White

Write-Host "`n📚 Documentation:" -ForegroundColor Yellow
Write-Host "- API Key Security: tech_readme_files/API_KEY_SECURITY_GUIDE.md" -ForegroundColor White
Write-Host "- API Keys Setup: tech_readme_files/API_KEYS_SETUP.md" -ForegroundColor White

Write-Host "`n🔒 Security Check:" -ForegroundColor Yellow

# Verify .env is gitignored
$gitignoreCheck = git check-ignore .env 2>$null
if ($gitignoreCheck -eq ".env") {
    Write-Host "✅ .env is properly gitignored" -ForegroundColor Green
} else {
    Write-Host "⚠️  WARNING: .env may not be gitignored!" -ForegroundColor Red
    Write-Host "   Add '.env' to your .gitignore file" -ForegroundColor Red
}

Write-Host "`n✨ Setup complete!" -ForegroundColor Green
