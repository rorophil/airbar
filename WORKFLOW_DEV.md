# 🔄 Workflow de Développement AirBar - Mac & Windows

**Date:** 3 mai 2026  
**Auteur:** Guide de développement multi-plateforme

---

## 🎯 Vue d'Ensemble

Votre setup actuel :
- **Mac** : Développement principal + Serveur Serverpod
- **Windows (Parallels)** : Test de l'application cliente
- **GitHub** : Stockage des sources

---

## 📁 Structure Git Recommandée

### Repositories GitHub

```
https://github.com/rorophil/airbar           # Frontend Flutter
https://github.com/rorophil/airbar_backend    # Backend Serverpod
```

### Structure Locale

**Sur Mac :**
```
~/development/codage en flutter/
├── airbar/                    # App Flutter
└── airbar_backend/            # Backend
    ├── airbar_backend_client/
    └── airbar_backend_server/
```

**Sur Windows (Parallels) :**
```
C:\Users\...\airbar\           # App Flutter UNIQUEMENT
```

---

## 🔧 Configuration Initiale

### 1. Sur Mac (Développement)

#### pubspec.yaml - Mode Développement Local
```yaml
dependencies:
  # Serverpod
  serverpod_flutter: ^3.3.1
  serverpod_auth_client: ^3.3.1
  airbar_backend_client:
    path: ../airbar_backend/airbar_backend_client  # ✅ LOCAL
```

#### Configuration Serveur
- **Hôte:** `localhost` (ou `10.211.55.2` si test depuis Windows)
- **Port:** `8080`
- Stocké dans SharedPreferences (pas dans Git)

### 2. Sur Windows (Parallels)

#### Configuration à Appliquer
1. Cloner UNIQUEMENT le repository `airbar` :
   ```powershell
   git clone https://github.com/rorophil/airbar.git
   cd airbar
   ```

2. **IMPORTANT** : Modifier `pubspec.yaml` LOCALEMENT pour utiliser Git :
   ```yaml
   dependencies:
     airbar_backend_client:
       git:
         url: https://github.com/rorophil/airbar_backend.git
         path: airbar_backend_client  # ✅ GIT
   ```

3. Configuration de l'app (dans l'interface) :
   - **Hôte:** `10.211.55.2` (IP du Mac sur réseau Parallels)
   - **Port:** `8080`

---

## 🔄 Workflow Quotidien

### Développement sur Mac

#### 1. Modification du Code

```bash
# Terminal 1 : Serveur
cd ~/development/codage\ en\ flutter/airbar_backend/airbar_backend_server
dart run bin/main.dart

# Terminal 2 : App Flutter (test local)
cd ~/development/codage\ en\ flutter/airbar
flutter run -d chrome  # ou -d macos
```

#### 2. Après Modification du Backend (Protocol)

```bash
# Régénérer le client Serverpod
cd airbar_backend/airbar_backend_server
serverpod generate

# Commit backend
git add .
git commit -m "feat: ajout endpoint XYZ"
git push origin main

# Retour au frontend
cd ../../airbar
flutter pub get  # Recharge le client local
```

#### 3. Commit des Modifications Frontend

```bash
cd airbar
git add .
git commit -m "feat: nouvelle fonctionnalité ABC"
git push origin main
```

### Synchronisation sur Windows

#### 1. Pull des Modifications

```powershell
# Sur Windows (Parallels)
cd C:\Users\...\airbar
git pull origin main
flutter pub get  # Télécharge la nouvelle version du client depuis Git
```

#### 2. Test de l'App

```powershell
flutter run -d windows
# L'app se connecte automatiquement à 10.211.55.2:8080
# (configuration stockée localement)
```

---

## 📝 Gestion du pubspec.yaml

### Problème : Deux Versions

- **Mac (dev)** : `path: ../airbar_backend/airbar_backend_client`
- **Windows** : `git: https://github.com/rorophil/airbar_backend.git`

### Solution : .gitignore Partiel + Branches

#### Option 1 : Ignorer les Modifications Locales (RECOMMANDÉ)

**Sur Mac :**
```bash
# Après avoir modifié pubspec.yaml pour le dev local
git update-index --skip-worktree pubspec.yaml
```

**Sur Windows :**
```powershell
# Après avoir modifié pubspec.yaml pour utiliser Git
git update-index --skip-worktree pubspec.yaml
```

**Avantage :** Git ignore vos modifications locales du pubspec.yaml

**Pour commiter des vraies modifications du pubspec.yaml :**
```bash
git update-index --no-skip-worktree pubspec.yaml
# Faire vos modifications
git add pubspec.yaml
git commit -m "chore: mise à jour dépendances"
git push
# Remettre en skip-worktree
git update-index --skip-worktree pubspec.yaml
```

#### Option 2 : Scripts de Basculement

Créer deux scripts :

**pubspec_dev.yaml** (version Mac locale)
**pubspec_prod.yaml** (version Git)

```bash
# Basculer en mode dev
cp pubspec_dev.yaml pubspec.yaml

# Basculer en mode prod
cp pubspec_prod.yaml pubspec.yaml
```

---

## 🚀 Workflow Complet : Exemple

### Scénario : Ajouter une nouvelle fonctionnalité

#### 1. Sur Mac : Développement

```bash
# 1. Créer une branche
cd airbar
git checkout -b feature/nouvelle-fonctionnalite

# 2. Coder la fonctionnalité
# ... modifications du code ...

# 3. Si modification du backend nécessaire
cd ../airbar_backend/airbar_backend_server
# ... modifier les endpoints/modèles ...
serverpod generate

# 4. Commit backend
git add .
git commit -m "feat: nouveau endpoint pour fonctionnalité"
git push origin main

# 5. Commit frontend
cd ../../airbar
git add .
git commit -m "feat: implémentation nouvelle fonctionnalité"
git push origin feature/nouvelle-fonctionnalite

# 6. Créer Pull Request sur GitHub
# 7. Merger après review
```

#### 2. Sur Windows : Test de la Fonctionnalité

```powershell
# 1. Pull des modifications
cd C:\Users\...\airbar
git pull origin main

# 2. Mettre à jour les dépendances
flutter pub get  # Télécharge le nouveau client backend

# 3. Tester
flutter run -d windows
```

---

## ⚙️ Configuration Serveur : Détails Techniques

### ServerConfigService (Déjà Implémenté)

Votre app stocke la config via `SharedPreferences` :

```dart
// Sur Mac (localhost)
ServerConfigService.setServerConfig('localhost', 8080);

// Sur Windows (IP du Mac)
ServerConfigService.setServerConfig('10.211.55.2', 8080);
```

**Stockage :**
- Mac : `~/Library/Preferences/...`
- Windows : `C:\Users\...\AppData\Local\...`

**Pas versionné dans Git** ✅

---

## 🔐 Fichiers à NE PAS Versionner

Vérifiez votre `.gitignore` :

```gitignore
# Déjà présents
*.iml
.idea/
.DS_Store
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
pubspec.lock  # ⚠️ À débattre selon projet

# Configuration locale
*.local
.env.local

# Fichiers spécifiques
# pubspec.yaml  # Si vous utilisez skip-worktree
```

---

## 📊 Résumé des Commandes Essentielles

### Mac (Développement)

```bash
# Démarrer le serveur
cd airbar_backend/airbar_backend_server
dart run bin/main.dart

# Après modif backend
serverpod generate

# Test app locale
cd ../../airbar
flutter run -d chrome

# Push modifications
git add .
git commit -m "feat: ..."
git push origin main
```

### Windows (Test)

```powershell
# Récupérer modifications
git pull origin main
flutter pub get

# Lancer app
flutter run -d windows
```

---

## 🐛 Dépannage

### "Bad Request" après pull

```bash
# Sur Windows
flutter clean
flutter pub get
flutter run
```

### "Cannot connect to server"

**Vérifier :**
1. Serveur Mac actif : `lsof -i :8080` (sur Mac)
2. IP correcte dans l'app : `10.211.55.2`
3. Ping depuis Windows : `ping 10.211.55.2`
4. Firewall Mac désactivé (ou port 8080 autorisé)

### Conflit pubspec.yaml

```bash
# Garder votre version locale
git checkout HEAD -- pubspec.yaml
git update-index --skip-worktree pubspec.yaml
```

---

## 🎯 Checklist Avant Commit

### Backend

- [ ] `serverpod generate` exécuté
- [ ] Migrations créées si nécessaire
- [ ] Serveur démarre sans erreur
- [ ] Endpoints testés

### Frontend

- [ ] `flutter pub get` après modif backend
- [ ] Pas d'erreurs de compilation
- [ ] Tests passent
- [ ] Config serveur testée (Mac ET Windows si possible)

---

## 📌 Notes Importantes

1. **NE PAS** commiter la configuration IP (déjà dans SharedPreferences)
2. **TOUJOURS** utiliser la version locale du client sur Mac (dev)
3. **TOUJOURS** utiliser la version Git du client sur Windows (prod)
4. **TOUJOURS** push le backend AVANT le frontend
5. **TOUJOURS** tester sur Windows après modifications majeures

---

## 🔗 Liens Utiles

- [Serverpod Docs](https://serverpod.dev/)
- [Flutter Docs](https://flutter.dev/)
- [GetX Docs](https://pub.dev/packages/get)

---

**Dernière mise à jour :** 3 mai 2026
