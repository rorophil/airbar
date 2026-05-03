#!/bin/bash

# Script pour ajouter une dépendance aux DEUX templates

if [ $# -lt 1 ]; then
  echo "Usage: ./add_dependency.sh <package_name> [version]"
  echo "Exemple: ./add_dependency.sh http ^1.0.0"
  exit 1
fi

PACKAGE=$1
VERSION=${2:-"^1.0.0"}

echo "📦 Ajout de la dépendance : $PACKAGE: $VERSION"
echo ""

# Ajouter à pubspec_mac.yaml
echo "1️⃣  Ajout à pubspec_mac.yaml..."
if grep -q "^  $PACKAGE:" pubspec_mac.yaml; then
  echo "   ⚠️  $PACKAGE existe déjà dans pubspec_mac.yaml"
else
  # Ajouter avant la ligne "  # Stockage local" (ou à la fin de dependencies)
  sed -i.bak "/# Stockage local/i\\
  $PACKAGE: $VERSION\\
" pubspec_mac.yaml
  rm pubspec_mac.yaml.bak
  echo "   ✅ Ajouté à pubspec_mac.yaml"
fi

# Ajouter à pubspec_windows.yaml
echo "2️⃣  Ajout à pubspec_windows.yaml..."
if grep -q "^  $PACKAGE:" pubspec_windows.yaml; then
  echo "   ⚠️  $PACKAGE existe déjà dans pubspec_windows.yaml"
else
  sed -i.bak "/# Stockage local/i\\
  $PACKAGE: $VERSION\\
" pubspec_windows.yaml
  rm pubspec_windows.yaml.bak
  echo "   ✅ Ajouté à pubspec_windows.yaml"
fi

echo ""
echo "3️⃣  Application de la configuration..."
./switch_to_local.sh

echo ""
echo "✅ Dépendance ajoutée avec succès !"
echo "💡 N'oubliez pas de commiter pubspec_mac.yaml et pubspec_windows.yaml"
