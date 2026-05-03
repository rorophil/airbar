#!/bin/bash

# Script pour basculer en mode Git (Windows/Production)

echo "🔄 Bascule en mode Git (Windows/Production)..."

# Copier la configuration Git
cp pubspec_windows.yaml pubspec.yaml

# Mettre à jour les dépendances
flutter pub get

echo "✅ Configuration Git activée !"
echo "📍 Client backend: GitHub (GIT)"
echo ""
echo "💡 Pour revenir à la version locale: ./switch_to_local.sh"
