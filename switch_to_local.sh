#!/bin/bash

# Script pour basculer en mode développement local (Mac)

echo "🔄 Bascule en mode développement local (Mac)..."

# Copier la configuration Mac
cp pubspec_mac.yaml pubspec.yaml

# Mettre à jour les dépendances
flutter pub get

echo "✅ Configuration Mac activée !"
echo "📍 Client backend: ../airbar_backend/airbar_backend_client (LOCAL)"
echo ""
echo "💡 Pour revenir à la version Git: ./switch_to_git.sh"
