#!/bin/bash

# Script pour basculer en mode développement local (Mac)

echo "🔄 Bascule en mode développement local (Mac)..."

# Vérifier si pubspec.yaml a été modifié
if git diff --quiet pubspec.yaml 2>/dev/null; then
  echo "✅ Aucune modification locale détectée"
else
  echo "⚠️  ATTENTION : pubspec.yaml a été modifié localement !"
  echo "📝 Vos modifications seront écrasées."
  echo ""
  echo "💡 Pour ajouter une dépendance :"
  echo "   1. Modifier pubspec_mac.yaml ET pubspec_windows.yaml"
  echo "   2. Puis relancer ce script"
  echo ""
  read -p "Continuer quand même ? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Annulé"
    exit 1
  fi
fi

# Copier la configuration Mac
cp pubspec_mac.yaml pubspec.yaml

# Mettre à jour les dépendances
flutter pub get

echo "✅ Configuration Mac activée !"
echo "📍 Client backend: ../airbar_backend/airbar_backend_client (LOCAL)"
echo ""
echo "💡 Pour revenir à la version Git: ./switch_to_git.sh"
