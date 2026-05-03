# Script PowerShell pour basculer en mode Git (Windows/Production)

Write-Host "🔄 Bascule en mode Git (Windows/Production)..." -ForegroundColor Cyan

# Copier la configuration Git
Copy-Item pubspec_windows.yaml pubspec.yaml -Force

# Mettre à jour les dépendances
flutter pub get

Write-Host ""
Write-Host "✅ Configuration Git activée !" -ForegroundColor Green
Write-Host "📍 Client backend: GitHub (GIT)" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Configuration serveur à utiliser:" -ForegroundColor Blue
Write-Host "   Hôte: 10.211.55.2" -ForegroundColor White
Write-Host "   Port: 8080" -ForegroundColor White
