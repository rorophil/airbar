# 🚀 Guide de Configuration Rapide - AirBar

## 📱 Configuration sur Mac (Développement)

### 1. Installation Initiale

```bash
# Cloner les deux repositories
git clone https://github.com/rorophil/airbar.git
git clone https://github.com/rorophil/airbar_backend.git

# Vérifier la structure
cd airbar
ls -la  # Doit contenir: switch_to_local.sh, switch_to_git.sh
```

### 2. Activer la Configuration Locale

```bash
# Basculer en mode développement local
./switch_to_local.sh
```

**Résultat :**
- ✅ Utilise `../airbar_backend/airbar_backend_client` (local)
- ✅ Hot reload du backend disponible
- ✅ Modifications immédiates

### 3. Configuration du Serveur

Dans l'app (écran de login → Configuration serveur) :
- **Hôte:** `localhost`
- **Port:** `8080`

---

## 💻 Configuration sur Windows (Parallels)

### 1. Installation Initiale

```powershell
# Cloner UNIQUEMENT le frontend
git clone https://github.com/rorophil/airbar.git
cd airbar
```

### 2. Activer la Configuration Git

**Option A : Script PowerShell** (créer `switch_to_git.ps1`)
```powershell
# Copier pubspec_windows.yaml vers pubspec.yaml
Copy-Item pubspec_windows.yaml pubspec.yaml
flutter pub get
Write-Host "✅ Configuration Git activée !" -ForegroundColor Green
```

**Option B : Manuel**
```powershell
copy pubspec_windows.yaml pubspec.yaml
flutter pub get
```

### 3. Configuration du Serveur

Dans l'app (écran de login → Configuration serveur) :
- **Hôte:** `10.211.55.2` (IP du Mac)
- **Port:** `8080`

### 4. Vérifier la Connexion

```powershell
# Tester la connexion au serveur Mac
ping 10.211.55.2

# Tester l'API (dans navigateur)
# http://10.211.55.2:8080
```

---

## 🔄 Workflow Quotidien

### Sur Mac

```bash
# 1. Démarrer le backend
cd airbar_backend/airbar_backend_server
dart run bin/main.dart

# 2. Développer et tester
cd ../../airbar
flutter run -d chrome

# 3. Après modif backend
cd ../airbar_backend/airbar_backend_server
serverpod generate
git add . && git commit -m "feat: ..." && git push

# 4. Commit frontend
cd ../../airbar
git add . && git commit -m "feat: ..." && git push
```

### Sur Windows

```powershell
# Synchroniser les modifications
git pull origin main
flutter pub get

# Lancer l'app
flutter run -d windows
```

---

## 🐛 Dépannage Express

### Mac : "Cannot find airbar_backend_client"

```bash
# Vérifier que vous êtes en mode local
./switch_to_local.sh
```

### Windows : "Cannot connect to server"

1. **Vérifier IP du Mac :**
   ```bash
   # Sur Mac
   ifconfig | grep "inet " | grep -v 127.0.0.1
   # Chercher : 10.211.55.X
   ```

2. **Tester connexion :**
   ```powershell
   # Sur Windows
   ping 10.211.55.2
   curl http://10.211.55.2:8080
   ```

3. **Vérifier serveur actif :**
   ```bash
   # Sur Mac
   lsof -i :8080
   ```

### "Bad Request" après pull

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📋 Checklist de Configuration

### Mac ✅
- [ ] Repositories clonés (airbar + airbar_backend)
- [ ] Script `switch_to_local.sh` exécuté
- [ ] Backend démarre sur port 8080
- [ ] Config serveur : `localhost:8080`

### Windows ✅
- [ ] Repository cloné (airbar uniquement)
- [ ] `pubspec_windows.yaml` copié vers `pubspec.yaml`
- [ ] `flutter pub get` exécuté
- [ ] Config serveur : `10.211.55.2:8080`
- [ ] Ping vers Mac fonctionne

---

## 🔗 Liens Utiles

- **Documentation Complète:** [WORKFLOW_DEV.md](WORKFLOW_DEV.md)
- **Backend GitHub:** https://github.com/rorophil/airbar_backend
- **Frontend GitHub:** https://github.com/rorophil/airbar

---

**Temps de setup :** ~5 minutes par plateforme  
**Support :** Voir documentation complète pour workflows avancés
