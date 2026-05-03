# Script PowerShell pour basculer en mode développement local (Mac)

Write-Host "🔄 Bascule en mode développement local (Mac)..." -ForegroundColor Cyan

# Copier la configuration Mac
Copy-Item pubspec_mac.yaml pubspec.yaml -Force

# Mettre à jour les dépendances
flutter pub get

Write-Host ""
Write-Host "✅ Configuration Mac activée !" -ForegroundColor Green
Write-Host "📍 Client backend: ../airbar_backend/airbar_backend_client (LOCAL)" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Configuration serveur à utiliser:" -ForegroundColor Blue
Write-Host "   Hôte: localhost" -ForegroundColor White
Write-Host "   Port: 8080" -ForegroundColor White
