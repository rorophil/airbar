# 📘 Guide d'Installation Complet - AirBar sur Windows (Production)

**Version:** 1.0  
**Date:** 8 juin 2026  
**Système cible:** Windows 10/11 Pro ou Server 2019/2022 (vierge)

---

## 📋 Table des Matières

1. [Prérequis Matériels](#prérequis-matériels)
2. [Installation des Outils de Base](#étape-1--installation-des-outils-de-base)
3. [Installation de Docker Desktop](#étape-2--installation-de-docker-desktop)
4. [Installation de Flutter SDK](#étape-3--installation-de-flutter-sdk)
5. [Installation du Backend (Production)](#étape-4--installation-du-backend-production)
6. [Installation du Frontend](#étape-5--installation-du-frontend)
7. [Configuration et Démarrage](#étape-6--configuration-et-démarrage)
8. [Tests et Vérification](#étape-7--tests-et-vérification)
9. [Maintenance et Dépannage](#maintenance-et-dépannage)

---

## 🖥️ Prérequis Matériels

### Configuration Minimale Recommandée

- **Système:** Windows 10/11 Pro, Enterprise ou Server 2019/2022
- **Processeur:** Intel/AMD 4 cœurs @ 2.5 GHz
- **RAM:** 8 GB minimum (16 GB recommandé pour production)
- **Disque:** 100 GB d'espace libre (SSD recommandé)
- **Réseau:** Connexion Internet (pour téléchargements initiaux)
- **Droits:** Compte administrateur requis

### Vérifications Préalables

1. **Activer la virtualisation dans le BIOS:**
   - Redémarrer et entrer dans le BIOS (F2, F10, DEL selon fabricant)
   - Activer **Intel VT-x** ou **AMD-V**
   - Sauvegarder et redémarrer

2. **Vérifier Windows:**
   ```powershell
   # Ouvrir PowerShell en tant qu'administrateur
   systeminfo | findstr /C:"Système d'exploitation"
   ```
   → Doit afficher Windows 10/11 Pro/Enterprise ou Server

---

## 📥 ÉTAPE 1 : Installation des Outils de Base

### 1.1 Installation de Git pour Windows

**Pourquoi ?** Nécessaire pour cloner les repositories du projet.

1. **Télécharger Git:**
   - Aller sur: https://git-scm.com/download/win
   - Télécharger **"64-bit Git for Windows Setup"**

2. **Installer Git:**
   - Exécuter le fichier téléchargé (`Git-2.xx.x-64-bit.exe`)
   - Options recommandées:
     - ✅ **"Git from the command line and also from 3rd-party software"**
     - ✅ **"Use bundled OpenSSH"**
     - ✅ **"Use the OpenSSL library"**
     - ✅ **"Checkout Windows-style, commit Unix-style line endings"**
     - ✅ **"Use MinTTY"**
     - ✅ **"Default (fast-forward or merge)"**
   - Installer et terminer

3. **Vérification:**
   ```powershell
   # Ouvrir PowerShell (pas besoin d'administrateur)
   git --version
   ```
   → Résultat attendu: `git version 2.xx.x.windows.x`

### 1.2 Installation de 7-Zip (Optionnel mais recommandé)

1. **Télécharger:** https://www.7-zip.org/
2. **Installer:** `7z2409-x64.exe` (version 64-bit)
3. **Utilité:** Extraction d'archives pour Flutter SDK

---

## 🐳 ÉTAPE 2 : Installation de Docker Desktop

**Pourquoi ?** Docker gère PostgreSQL, Redis et le serveur backend en production.

### 2.1 Activer WSL 2 (Windows Subsystem for Linux)

1. **Ouvrir PowerShell en tant qu'administrateur**

2. **Activer WSL:**
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   ```

3. **Activer Virtual Machine Platform:**
   ```powershell
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

4. **Redémarrer Windows**

5. **Définir WSL 2 comme version par défaut:**
   ```powershell
   wsl --set-default-version 2
   ```

6. **Installer un kernel WSL 2 (si demandé):**
   - Télécharger: https://aka.ms/wsl2kernel
   - Installer `wsl_update_x64.msi`

### 2.2 Téléchargement de Docker Desktop

1. Aller sur: **https://www.docker.com/products/docker-desktop/**
2. Cliquer sur **"Download for Windows"**
3. Télécharger `Docker Desktop Installer.exe` (~600 MB)

### 2.3 Installation de Docker Desktop

1. **Exécuter en tant qu'administrateur:** `Docker Desktop Installer.exe`

2. **Options d'installation:**
   - ✅ **"Use WSL 2 instead of Hyper-V"** (IMPORTANT)
   - ✅ **"Add shortcut to desktop"**

3. **Cliquer sur "Ok"** et attendre (5-10 min)

4. **Cliquer sur "Close and restart"**

### 2.4 Configuration Docker Desktop

1. **Après redémarrage, lancer Docker Desktop** depuis le bureau

2. **Accepter les conditions** d'utilisation (Terms of Service)

3. **Passer le tutoriel** (Skip tutorial)

4. **Configuration des ressources:**
   - Cliquer sur l'icône engrenage ⚙️ (Settings)
   - Aller dans **"Resources"** → **"Advanced"**
   - Allouer:
     - **CPUs:** 4 (minimum 2)
     - **Memory:** 4 GB (minimum 2 GB)
     - **Swap:** 1 GB
     - **Disk image size:** 64 GB
   - Cliquer **"Apply & Restart"**

### 2.5 Vérification Docker

```powershell
# Ouvrir PowerShell (mode normal)
docker --version
docker-compose --version

# Tester Docker
docker run hello-world
```

**Résultat attendu:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

---

## 🎯 ÉTAPE 3 : Installation de Flutter SDK

**Pourquoi ?** Nécessaire pour compiler et exécuter l'application frontend.

### 3.1 Téléchargement de Flutter

1. Aller sur: **https://docs.flutter.dev/get-started/install/windows**
2. Télécharger **"flutter_windows_3.x.x-stable.zip"** (~1 GB)

### 3.2 Extraction et Installation

1. **Créer un dossier pour Flutter:**
   ```powershell
   mkdir C:\src
   cd C:\src
   ```

2. **Extraire l'archive:**
   - Copier `flutter_windows_xxx-stable.zip` dans `C:\src\`
   - Clic droit → **"Extraire tout..."** → Extraire dans `C:\src\`
   - Résultat: `C:\src\flutter\`

### 3.3 Ajouter Flutter au PATH

1. **Rechercher "Variables d'environnement"** dans le menu Démarrer
2. Cliquer sur **"Modifier les variables d'environnement système"**
3. Cliquer sur **"Variables d'environnement..."**
4. Dans **"Variables système"**, trouver **"Path"** et cliquer **"Modifier"**
5. Cliquer **"Nouveau"** et ajouter: `C:\src\flutter\bin`
6. Cliquer **"OK"** sur toutes les fenêtres
7. **Fermer et rouvrir PowerShell**

### 3.4 Vérification et Configuration Flutter

```powershell
# Vérifier Flutter
flutter --version

# Exécuter le diagnostic Flutter
flutter doctor

# Accepter les licences Android (si nécessaire)
flutter doctor --android-licenses
```

**Résultat attendu:**
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on Microsoft Windows...)
[✓] Windows Version (Installed version of Windows is version 10 or higher)
[!] Chrome - develop for the web
[!] Visual Studio - develop for Windows (pas encore installé)
```

### 3.5 Installation de Visual Studio Build Tools (pour Windows Desktop)

**Si vous voulez compiler pour Windows Desktop:**

1. Télécharger: **https://visualstudio.microsoft.com/downloads/**
2. Télécharger **"Build Tools for Visual Studio 2022"**
3. Installer avec les workloads:
   - ✅ **"Desktop development with C++"**
   - ✅ **"Windows 10/11 SDK"**

**OU utiliser Visual Studio Community** (IDE complet):
1. Télécharger **Visual Studio Community 2022**
2. Installer avec:
   - ✅ **"Desktop development with C++"**
   - ✅ **"Universal Windows Platform development"**

**Re-vérifier:**
```powershell
flutter doctor
```
→ Doit afficher `[✓] Visual Studio`

---

## 🔧 ÉTAPE 4 : Installation du Backend (Production)

### 4.1 Préparation des Dossiers

```powershell
# Créer le dossier principal du projet
cd C:\
mkdir airbar_production
cd airbar_production
```

### 4.2 Clonage du Repository Backend

```powershell
# Cloner le repository
git clone https://github.com/rorophil/airbar_backend.git

# Naviguer dans le dossier serveur
cd airbar_backend\airbar_backend_server
```

### 4.3 Vérification de la Structure

```powershell
dir
```

**Vous devez voir:**
```
bin/
config/
lib/
migrations/
web/
docker-compose.yaml
Dockerfile
pubspec.yaml
README.md
```

### 4.4 Configuration de Production

#### 4.4.1 Modifier le fichier docker-compose.yaml

```powershell
notepad docker-compose.yaml
```

**Remplacer le contenu complet par:**

```yaml
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: pgvector/pgvector:pg16
    container_name: airbar_postgres_prod
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_DB: airbar_backend
      POSTGRES_PASSWORD: "${POSTGRES_PASSWORD:-VotreMotDePasseSecurise123!}"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - airbar_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: airbar_redis_prod
    restart: unless-stopped
    ports:
      - "6379:6379"
    command: redis-server --requirepass "${REDIS_PASSWORD:-VotreMotDePasseRedis456!}"
    volumes:
      - redis_data:/data
    networks:
      - airbar_network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # AirBar Backend Server
  airbar_server:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: airbar_backend_prod
    restart: unless-stopped
    ports:
      - "8080:8080"  # API Server
      - "8081:8081"  # Insights Server
      - "8082:8082"  # Web Server
    environment:
      - runmode=production
      - serverid=prod-001
      - logging=normal
      - role=monolith
      # Database
      - DATABASE_HOST=postgres
      - DATABASE_PORT=5432
      - DATABASE_NAME=airbar_backend
      - DATABASE_USER=postgres
      - DATABASE_PASSWORD=${POSTGRES_PASSWORD:-VotreMotDePasseSecurise123!}
      # Redis
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - REDIS_PASSWORD=${REDIS_PASSWORD:-VotreMotDePasseRedis456!}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - airbar_network

networks:
  airbar_network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
```

**Sauvegarder et fermer Notepad**

#### 4.4.2 Modifier config/production.yaml

```powershell
notepad config\production.yaml
```

**Remplacer le contenu par:**

```yaml
# Configuration Production - AirBar
# Date: 2026-06-08

# Configuration for the main API server
apiServer:
  port: 8080
  publicHost: localhost
  publicPort: 8080
  publicScheme: http

# Configuration for the Insights server
insightsServer:
  port: 8081
  publicHost: localhost
  publicPort: 8081
  publicScheme: http

# Configuration for the web server
webServer:
  port: 8082
  publicHost: localhost
  publicPort: 8082
  publicScheme: http

# Database configuration
database:
  host: postgres
  port: 5432
  name: airbar_backend
  user: postgres
  requireSsl: false

# Redis configuration
redis:
  enabled: true
  host: redis
  port: 6379

# Request configuration
maxRequestSize: 524288

# Logging configuration
sessionLogs:
  consoleEnabled: true
  persistentEnabled: true

# Future call configuration
futureCallExecutionEnabled: true
```

**Sauvegarder et fermer**

#### 4.4.3 Créer un fichier .env (Optionnel mais recommandé)

```powershell
notepad .env
```

**Ajouter:**
```env
# Mots de passe de production - NE PAS COMMITER !
POSTGRES_PASSWORD=VotreMotDePassePostgreSQLTresSecurise789!
REDIS_PASSWORD=VotreMotDePasseRedisTresSecurise012!
```

**Sauvegarder et fermer**

**Ajouter .env au .gitignore:**
```powershell
echo .env >> .gitignore
```

### 4.5 Construction et Démarrage du Backend

#### 4.5.1 Build des images Docker

```powershell
# S'assurer d'être dans le bon dossier
cd C:\airbar_production\airbar_backend\airbar_backend_server

# Construire les images Docker
docker-compose build
```

**Temps estimé:** 5-15 minutes (dépend de la connexion internet)

#### 4.5.2 Démarrer les services

```powershell
# Démarrer tous les services en arrière-plan
docker-compose up -d
```

**Vérifier les logs:**
```powershell
# Voir les logs du serveur
docker-compose logs -f airbar_server

# Logs PostgreSQL
docker-compose logs -f postgres

# Logs Redis
docker-compose logs -f redis
```

**Appuyer sur `Ctrl+C` pour quitter les logs**

#### 4.5.3 Vérification du Backend

```powershell
# Vérifier que les conteneurs sont actifs
docker-compose ps
```

**Résultat attendu:**
```
NAME                      STATUS    PORTS
airbar_backend_prod       Up        0.0.0.0:8080->8080/tcp, ...
airbar_postgres_prod      Up        0.0.0.0:5432->5432/tcp
airbar_redis_prod         Up        0.0.0.0:6379->6379/tcp
```

**Tester l'API:**
```powershell
# Ouvrir un navigateur et aller sur:
http://localhost:8080
```

→ Devrait afficher la page d'accueil Serverpod ou un message JSON

**Tester la connexion à PostgreSQL:**
```powershell
docker exec -it airbar_postgres_prod psql -U postgres -d airbar_backend -c "\dt"
```

→ Devrait lister les tables de la base de données

---

## 📱 ÉTAPE 5 : Installation du Frontend

### 5.1 Clonage du Repository Frontend

```powershell
# Retour au dossier principal
cd C:\airbar_production

# Cloner le repository frontend
git clone https://github.com/rorophil/airbar.git

# Naviguer dans le dossier
cd airbar
```

### 5.2 Installation des Dépendances Flutter

```powershell
# Installer les packages
flutter pub get
```

**Temps estimé:** 2-5 minutes

### 5.3 Configuration de l'Application

#### 5.3.1 Vérifier la configuration Serverpod

```powershell
notepad lib\main.dart
```

**Vérifier que ServerpodClientProvider pointe vers le bon serveur:**
```dart
// Dans main.dart, vérifier la configuration
// Si vous utilisez localhost (même machine)
const String serverUrl = 'http://localhost:8080';

// Si vous accédez depuis un autre appareil sur le réseau
// const String serverUrl = 'http://IP_DU_SERVEUR:8080';
```

**L'application utilise ServerConfigService pour configurer dynamiquement le serveur**
→ Pas de modification nécessaire, la config se fait via l'interface

### 5.4 Compilation et Test

#### 5.4.1 Test en mode Web (Chrome)

```powershell
# Lancer l'application en mode web
flutter run -d chrome
```

**Résultat attendu:**
- Le navigateur Chrome s'ouvre automatiquement
- L'application AirBar se charge
- Écran de connexion affiché

#### 5.4.2 Test en mode Windows Desktop

```powershell
# Lancer l'application Windows
flutter run -d windows
```

**Résultat attendu:**
- Compilation de l'application Windows (1-3 min la première fois)
- Fenêtre de l'application s'ouvre
- Écran de connexion affiché

#### 5.4.3 Build de Production (Windows)

```powershell
# Créer un exécutable de production
flutter build windows --release

# L'exécutable est créé dans:
# build\windows\x64\runner\Release\
```

**Tester l'exécutable:**
```powershell
.\build\windows\x64\runner\Release\airbar.exe
```

#### 5.4.4 Build de Production (Web)

```powershell
# Créer une version web de production
flutter build web --release

# Les fichiers sont dans:
# build\web\
```

**Pour déployer sur un serveur web:**
- Copier le contenu de `build\web\` sur votre serveur HTTP
- Configurer le serveur pour servir `index.html`

---

## ⚙️ ÉTAPE 6 : Configuration et Démarrage

### 6.1 Configuration Serveur dans l'Application

1. **Lancer l'application** (web ou Windows)

2. **Sur l'écran de connexion:**
   - Cliquer sur le bouton **"Configuration serveur"** (en bas)

3. **Entrer les paramètres:**
   - **Hôte:** `localhost` (si backend sur la même machine)
   - **Port:** `8080`
   - Cliquer **"Tester la connexion"**

**Si connexion réussie:** ✅ Message de succès

**Si échec:**
- Vérifier que le backend est démarré: `docker-compose ps`
- Vérifier les logs: `docker-compose logs -f airbar_server`
- Vérifier le pare-feu Windows (autoriser port 8080)

### 6.2 Première Connexion

**Compte administrateur par défaut:**
- **Code PIN:** `123456`
- **Rôle:** Administrateur

**⚠️ IMPORTANT:** Changez ce PIN dès la première connexion !

### 6.3 Configuration du Pare-feu Windows

**Si l'application doit être accessible depuis d'autres machines du réseau:**

```powershell
# Ouvrir PowerShell en tant qu'administrateur

# Autoriser le port 8080 (API)
New-NetFirewallRule -DisplayName "AirBar API" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow

# Autoriser le port 8081 (Insights)
New-NetFirewallRule -DisplayName "AirBar Insights" -Direction Inbound -Protocol TCP -LocalPort 8081 -Action Allow

# Autoriser le port 8082 (Web)
New-NetFirewallRule -DisplayName "AirBar Web" -Direction Inbound -Protocol TCP -LocalPort 8082 -Action Allow
```

### 6.4 Démarrage Automatique des Services

#### 6.4.1 Créer un script de démarrage

```powershell
notepad C:\airbar_production\start_airbar.ps1
```

**Contenu:**
```powershell
# Script de démarrage AirBar
Write-Host "=== Démarrage AirBar Backend ===" -ForegroundColor Green

# Naviguer vers le dossier backend
Set-Location C:\airbar_production\airbar_backend\airbar_backend_server

# Démarrer Docker Desktop (si pas déjà démarré)
Write-Host "Vérification de Docker..." -ForegroundColor Yellow
$dockerStatus = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Démarrage de Docker Desktop..." -ForegroundColor Yellow
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    Start-Sleep -Seconds 15
}

# Démarrer les services
Write-Host "Démarrage des services Docker..." -ForegroundColor Yellow
docker-compose up -d

# Attendre que les services soient prêts
Write-Host "Attente de la disponibilité des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Vérifier le statut
Write-Host "Statut des services:" -ForegroundColor Green
docker-compose ps

Write-Host "`n=== AirBar Backend démarré avec succès ===" -ForegroundColor Green
Write-Host "API disponible sur: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Insights disponible sur: http://localhost:8081" -ForegroundColor Cyan
Write-Host "`nPour voir les logs: docker-compose logs -f" -ForegroundColor Yellow
```

**Sauvegarder et fermer**

#### 6.4.2 Créer un script d'arrêt

```powershell
notepad C:\airbar_production\stop_airbar.ps1
```

**Contenu:**
```powershell
# Script d'arrêt AirBar
Write-Host "=== Arrêt AirBar Backend ===" -ForegroundColor Red

Set-Location C:\airbar_production\airbar_backend\airbar_backend_server

# Arrêter les services
Write-Host "Arrêt des services Docker..." -ForegroundColor Yellow
docker-compose down

Write-Host "`n=== AirBar Backend arrêté ===" -ForegroundColor Green
```

**Sauvegarder et fermer**

#### 6.4.3 Utilisation des scripts

```powershell
# Démarrer AirBar
PowerShell -ExecutionPolicy Bypass -File C:\airbar_production\start_airbar.ps1

# Arrêter AirBar
PowerShell -ExecutionPolicy Bypass -File C:\airbar_production\stop_airbar.ps1
```

#### 6.4.4 Créer des raccourcis Bureau (Optionnel)

1. **Clic droit sur le bureau** → Nouveau → Raccourci

2. **Emplacement:**
   ```
   PowerShell -ExecutionPolicy Bypass -File C:\airbar_production\start_airbar.ps1
   ```

3. **Nom:** `Démarrer AirBar`

4. **Répéter pour l'arrêt**

---

## ✅ ÉTAPE 7 : Tests et Vérification

### 7.1 Tests Fonctionnels de Base

#### Test 1: Connexion
1. Lancer l'application
2. Entrer PIN: `123456`
3. ✅ Devrait afficher le Dashboard Admin

#### Test 2: Gestion Utilisateurs
1. Aller dans **Admin** → **Utilisateurs**
2. Créer un nouvel utilisateur:
   - Prénom: `Test`
   - Nom: `Utilisateur`
   - Code PIN: `999999`
   - Rôle: `Utilisateur`
   - Solde initial: `50.00€`
3. ✅ Utilisateur créé avec succès

#### Test 3: Gestion Produits
1. Aller dans **Admin** → **Catégories**
2. Créer une catégorie: `Boissons`
3. Aller dans **Admin** → **Produits**
4. Créer un produit:
   - Nom: `Coca-Cola`
   - Prix: `2.50€`
   - Stock: `50`
   - Catégorie: `Boissons`
5. ✅ Produit créé avec succès

#### Test 4: Transaction (Achat)
1. Se déconnecter
2. Se connecter avec PIN: `999999`
3. Aller dans la **Boutique**
4. Ajouter 2× Coca-Cola au panier
5. Valider le panier
6. Entrer PIN: `999999`
7. ✅ Transaction réussie
8. ✅ Solde débité de 5.00€
9. ✅ Stock réduit de 2

### 7.2 Tests de Performance

```powershell
# Tester la charge du serveur
# (Nécessite installation de Apache Bench ou similaire)

# Exemple avec curl (simple test)
for ($i=1; $i -le 10; $i++) {
    curl http://localhost:8080
}
```

### 7.3 Vérification des Logs

```powershell
# Logs du serveur backend
docker-compose logs airbar_server

# Logs PostgreSQL
docker-compose logs postgres

# Logs Redis
docker-compose logs redis

# Suivre les logs en temps réel
docker-compose logs -f --tail=50
```

### 7.4 Vérification de la Base de Données

```powershell
# Se connecter à PostgreSQL
docker exec -it airbar_postgres_prod psql -U postgres -d airbar_backend

# Lister les tables
\dt

# Vérifier les utilisateurs
SELECT id, "firstName", "lastName", role, balance FROM "user";

# Vérifier les produits
SELECT id, name, price, "stockQuantity" FROM product;

# Vérifier les transactions
SELECT id, "userId", "totalAmount", timestamp FROM transaction ORDER BY timestamp DESC LIMIT 10;

# Quitter
\q
```

### 7.5 Tests de Sécurité de Base

#### Test 1: Vérification des PINs hashés
```sql
-- Dans psql
SELECT id, "firstName", "hashedPin" FROM "user";
-- ✅ Les PINs ne doivent JAMAIS être en clair
```

#### Test 2: Vérification des transactions
```sql
SELECT * FROM transaction WHERE "totalAmount" > 0 AND type = 'purchase';
-- ✅ Aucune transaction d'achat avec montant positif
```

---

## 🔧 Maintenance et Dépannage

### Commandes Utiles

#### Gestion des Services Docker

```powershell
# Démarrer les services
docker-compose up -d

# Arrêter les services
docker-compose down

# Redémarrer un service spécifique
docker-compose restart airbar_server

# Voir le statut
docker-compose ps

# Voir les logs
docker-compose logs -f

# Reconstruire les images
docker-compose build --no-cache

# Nettoyer les volumes (⚠️ SUPPRIME LES DONNÉES!)
docker-compose down -v
```

#### Sauvegardes PostgreSQL

```powershell
# Créer une sauvegarde
docker exec airbar_postgres_prod pg_dump -U postgres airbar_backend > backup_$(Get-Date -Format "yyyyMMdd_HHmmss").sql

# Restaurer une sauvegarde
docker exec -i airbar_postgres_prod psql -U postgres airbar_backend < backup_20260608_120000.sql
```

#### Mise à Jour du Backend

```powershell
cd C:\airbar_production\airbar_backend

# Récupérer les dernières modifications
git pull

cd airbar_backend_server

# Reconstruire l'image
docker-compose build airbar_server

# Redémarrer le service
docker-compose up -d airbar_server
```

#### Mise à Jour du Frontend

```powershell
cd C:\airbar_production\airbar

# Récupérer les dernières modifications
git pull

# Mettre à jour les dépendances
flutter pub get

# Reconstruire
flutter build windows --release
```

### Problèmes Courants

#### Problème 1: "Docker daemon is not running"

**Solution:**
```powershell
# Démarrer Docker Desktop manuellement
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
Start-Sleep -Seconds 15
```

#### Problème 2: "Port 8080 already in use"

**Solution:**
```powershell
# Trouver le processus utilisant le port
netstat -ano | findstr :8080

# Tuer le processus (remplacer PID par le numéro trouvé)
taskkill /PID <PID> /F
```

#### Problème 3: "Cannot connect to backend"

**Solutions:**
1. Vérifier que le backend est démarré:
   ```powershell
   docker-compose ps
   ```

2. Vérifier les logs:
   ```powershell
   docker-compose logs airbar_server
   ```

3. Tester la connexion:
   ```powershell
   curl http://localhost:8080
   ```

4. Vérifier le pare-feu Windows

#### Problème 4: "Database connection failed"

**Solutions:**
```powershell
# Vérifier que PostgreSQL est actif
docker-compose ps postgres

# Voir les logs
docker-compose logs postgres

# Redémarrer PostgreSQL
docker-compose restart postgres

# Vérifier la connexion
docker exec -it airbar_postgres_prod psql -U postgres -c "SELECT version();"
```

#### Problème 5: "Out of memory" ou lenteurs

**Solutions:**
1. Augmenter les ressources Docker:
   - Docker Desktop → Settings → Resources
   - Augmenter RAM et CPU

2. Nettoyer Docker:
   ```powershell
   # Nettoyer les images inutilisées
   docker system prune -a

   # Nettoyer les volumes inutilisés (⚠️ prudence)
   docker volume prune
   ```

### Monitoring et Logs

#### Créer un dossier de logs

```powershell
mkdir C:\airbar_production\logs

# Exporter les logs quotidiennement
docker-compose logs --no-color > "C:\airbar_production\logs\backend_$(Get-Date -Format 'yyyyMMdd').log"
```

#### Script de monitoring (optionnel)

```powershell
notepad C:\airbar_production\monitor.ps1
```

**Contenu:**
```powershell
while ($true) {
    Clear-Host
    Write-Host "=== Monitoring AirBar ===" -ForegroundColor Green
    Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Yellow
    
    # Statut Docker
    Write-Host "Services Docker:" -ForegroundColor Cyan
    docker-compose ps
    
    # Utilisation CPU et RAM
    Write-Host "`nRessources système:" -ForegroundColor Cyan
    docker stats --no-stream
    
    # Espace disque
    Write-Host "`nEspace disque:" -ForegroundColor Cyan
    docker system df
    
    Start-Sleep -Seconds 30
}
```

**Utilisation:**
```powershell
PowerShell -ExecutionPolicy Bypass -File C:\airbar_production\monitor.ps1
```

---

## 📊 Checklist de Déploiement

### Avant le Déploiement

- [ ] Windows 10/11 Pro/Enterprise ou Server installé
- [ ] Virtualisation activée dans le BIOS
- [ ] WSL 2 installé et configuré
- [ ] Docker Desktop installé et fonctionnel
- [ ] Flutter SDK installé et dans le PATH
- [ ] Git installé
- [ ] Visual Studio Build Tools installé (pour Windows Desktop)

### Configuration Backend

- [ ] Repository `airbar_backend` cloné
- [ ] `docker-compose.yaml` configuré
- [ ] `config/production.yaml` configuré
- [ ] Fichier `.env` créé avec mots de passe sécurisés
- [ ] Images Docker construites
- [ ] Services démarrés avec succès
- [ ] Tests de connexion réussis

### Configuration Frontend

- [ ] Repository `airbar` cloné
- [ ] Dépendances installées (`flutter pub get`)
- [ ] Configuration serveur testée
- [ ] Connexion backend vérifiée
- [ ] Application compilée (Windows ou Web)
- [ ] Tests fonctionnels réussis

### Sécurité

- [ ] PIN administrateur par défaut changé
- [ ] Mots de passe PostgreSQL et Redis changés
- [ ] Fichier `.env` dans `.gitignore`
- [ ] Pare-feu Windows configuré
- [ ] Sauvegardes configurées

### Production

- [ ] Scripts de démarrage/arrêt créés
- [ ] Raccourcis bureau créés
- [ ] Tests de charge effectués
- [ ] Monitoring en place
- [ ] Documentation mise à jour
- [ ] Formation des utilisateurs effectuée

---

## 🔐 Bonnes Pratiques de Sécurité

### 1. Mots de Passe Forts

- **PostgreSQL:** Au moins 20 caractères, mix majuscules/minuscules/chiffres/symboles
- **Redis:** Au moins 20 caractères
- **PINs utilisateurs:** Minimum 6 chiffres, éviter séquences (123456, 000000)

### 2. Sauvegardes Régulières

```powershell
# Script de sauvegarde automatique
# À exécuter via Planificateur de tâches Windows

$backupDir = "C:\airbar_production\backups"
$date = Get-Date -Format "yyyyMMdd_HHmmss"

# Créer le dossier si inexistant
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir
}

# Sauvegarde PostgreSQL
docker exec airbar_postgres_prod pg_dump -U postgres airbar_backend > "$backupDir\db_backup_$date.sql"

# Compresser (si 7-Zip installé)
& "C:\Program Files\7-Zip\7z.exe" a "$backupDir\db_backup_$date.7z" "$backupDir\db_backup_$date.sql"
Remove-Item "$backupDir\db_backup_$date.sql"

# Supprimer les sauvegardes de plus de 30 jours
Get-ChildItem $backupDir -Filter "*.7z" | Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-30) } | Remove-Item
```

### 3. Mises à Jour Régulières

- **Windows Update:** Activer les mises à jour automatiques
- **Docker Desktop:** Vérifier mensuellement
- **Flutter SDK:** `flutter upgrade` tous les 3 mois
- **AirBar:** `git pull` hebdomadaire

### 4. Monitoring

- Surveiller l'utilisation disque (`docker system df`)
- Vérifier les logs quotidiennement
- Monitorer les ressources CPU/RAM
- Alertes sur échecs de services

---

## 📞 Support et Ressources

### Documentation Officielle

- **Serverpod:** https://serverpod.dev/
- **Flutter:** https://docs.flutter.dev/
- **Docker:** https://docs.docker.com/
- **PostgreSQL:** https://www.postgresql.org/docs/

### Commandes de Diagnostic

```powershell
# Informations système
systeminfo

# Version Windows
winver

# Informations Docker
docker version
docker info

# Informations Flutter
flutter doctor -v

# État des services
docker-compose ps
docker-compose logs --tail=100

# Connexion réseau
ipconfig
ping localhost
netstat -an | findstr :8080
```

### Fichiers de Configuration Clés

- Backend: `C:\airbar_production\airbar_backend\airbar_backend_server\config\production.yaml`
- Docker: `C:\airbar_production\airbar_backend\airbar_backend_server\docker-compose.yaml`
- Environnement: `C:\airbar_production\airbar_backend\airbar_backend_server\.env`
- Frontend: `C:\airbar_production\airbar\pubspec.yaml`

---

## 🎉 Conclusion

Vous avez maintenant un système AirBar complet et fonctionnel sur Windows !

**Prochaines étapes recommandées:**

1. **Personnalisation:**
   - Ajouter vos produits et catégories
   - Créer les comptes utilisateurs
   - Configurer les alertes de stock

2. **Sécurisation:**
   - Changer tous les mots de passe par défaut
   - Configurer les sauvegardes automatiques
   - Activer le pare-feu

3. **Optimisation:**
   - Monitorer les performances
   - Ajuster les ressources Docker si nécessaire
   - Optimiser la base de données

4. **Formation:**
   - Former les administrateurs
   - Former les utilisateurs finaux
   - Documenter les procédures spécifiques à votre aéro-club

**Bon déploiement ! ✈️🍺**

---

**Document créé le:** 8 juin 2026  
**Version:** 1.0  
**Auteur:** Guide d'installation AirBar  
**Dernière mise à jour:** 8 juin 2026
