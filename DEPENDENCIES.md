# 📦 Gestion des Dépendances - AirBar

## ⚠️ RÈGLE IMPORTANTE

**NE JAMAIS modifier directement `pubspec.yaml`** ❌

**TOUJOURS modifier `pubspec_mac.yaml` ET `pubspec_windows.yaml`** ✅

---

## 🎯 Pourquoi ?

Le fichier `pubspec.yaml` est **généré automatiquement** par les scripts de bascule :
- `./switch_to_local.sh` → copie `pubspec_mac.yaml` vers `pubspec.yaml`
- `./switch_to_git.sh` → copie `pubspec_windows.yaml` vers `pubspec.yaml`

**Toute modification de `pubspec.yaml` sera ÉCRASÉE** lors du prochain switch !

---

## ✅ Workflow Correct

### Méthode 1 : Script Automatique (Recommandé)

```bash
# Ajouter une nouvelle dépendance
./add_dependency.sh http ^1.0.0

# Le script :
# 1. Ajoute la dépendance aux DEUX templates
# 2. Applique la configuration locale
# 3. Lance flutter pub get
```

### Méthode 2 : Modification Manuelle

#### 1. Éditer les DEUX Templates

**pubspec_mac.yaml** :
```yaml
dependencies:
  # ... autres dépendances ...
  
  # Votre nouvelle dépendance
  http: ^1.0.0  # ✅ Ajout ici
  
  # Stockage local
  get_storage: ^2.1.1
```

**pubspec_windows.yaml** :
```yaml
dependencies:
  # ... autres dépendances ...
  
  # Votre nouvelle dépendance
  http: ^1.0.0  # ✅ Ajout ici aussi !
  
  # Stockage local
  get_storage: ^2.1.1
```

#### 2. Appliquer la Configuration

```bash
# Sur Mac
./switch_to_local.sh

# Sur Windows
.\switch_to_git.ps1
```

#### 3. Commiter les Templates

```bash
git add pubspec_mac.yaml pubspec_windows.yaml
git commit -m "chore: ajout dépendance http"
git push
```

---

## 🔄 Synchronisation des Modifications

### Sur Mac (après ajout de dépendance)

```bash
# 1. Modifier les templates
vim pubspec_mac.yaml      # Ajouter la dépendance
vim pubspec_windows.yaml  # Ajouter la même dépendance

# 2. Appliquer
./switch_to_local.sh

# 3. Commiter
git add pubspec_mac.yaml pubspec_windows.yaml
git commit -m "chore: ajout nouvelle dépendance"
git push
```

### Sur Windows (récupération)

```powershell
# 1. Pull les modifications
git pull origin main

# 2. Les templates sont mis à jour automatiquement
# 3. Appliquer la configuration
.\switch_to_git.ps1
```

---

## 🛠️ Cas d'Usage Courants

### Ajouter une Dépendance

```bash
# Automatique
./add_dependency.sh intl ^0.20.0

# Manuel
# 1. Modifier pubspec_mac.yaml ET pubspec_windows.yaml
# 2. ./switch_to_local.sh
# 3. git add pubspec_*.yaml && git commit -m "..." && git push
```

### Mettre à Jour une Version

**Éditer les DEUX templates :**
```yaml
# Avant
get: ^4.6.6

# Après
get: ^4.7.0  # Dans pubspec_mac.yaml ET pubspec_windows.yaml
```

Puis :
```bash
./switch_to_local.sh
flutter pub get
```

### Retirer une Dépendance

**Supprimer des DEUX templates**, puis :
```bash
./switch_to_local.sh
flutter clean && flutter pub get
```

---

## 🐛 Dépannage

### "J'ai modifié pubspec.yaml par erreur"

**Option 1 : Abandonner les modifications**
```bash
git checkout HEAD -- pubspec.yaml
./switch_to_local.sh
```

**Option 2 : Sauvegarder les modifications**
```bash
# 1. Voir ce qui a changé
diff pubspec.yaml pubspec_mac.yaml

# 2. Reporter manuellement les changements
vim pubspec_mac.yaml      # Ajouter les modifications
vim pubspec_windows.yaml  # Ajouter les modifications

# 3. Réappliquer
./switch_to_local.sh
```

### "Le script me dit que pubspec.yaml est modifié"

C'est normal si vous avez édité `pubspec.yaml` directement.

**Solutions :**
1. **Annuler** (tapez `N`) et reporter dans les templates
2. **Continuer** (tapez `y`) pour écraser (modifications perdues !)

### "Conflit lors du git pull"

```bash
# Garder votre version (les templates sont la source de vérité)
git checkout HEAD -- pubspec.yaml
git pull
./switch_to_local.sh
```

---

## 📋 Checklist Avant Commit

Avant de commiter des modifications de dépendances :

- [ ] ✅ Modifications faites dans `pubspec_mac.yaml`
- [ ] ✅ Modifications faites dans `pubspec_windows.yaml`
- [ ] ✅ Les deux fichiers sont **identiques** (sauf section airbar_backend_client)
- [ ] ✅ `./switch_to_local.sh` exécuté sans erreur
- [ ] ✅ `flutter pub get` réussi
- [ ] ✅ Application démarre sans erreur
- [ ] ❌ `pubspec.yaml` **PAS** dans le commit (ignoré par Git)

---

## 📊 Vue d'Ensemble des Fichiers

```
airbar/
├── pubspec.yaml              ❌ NE PAS MODIFIER (généré automatiquement)
├── pubspec_mac.yaml          ✅ MODIFIER (template Mac)
├── pubspec_windows.yaml      ✅ MODIFIER (template Windows)
├── switch_to_local.sh        🔧 Script de bascule (Mac local)
├── switch_to_git.sh          🔧 Script de bascule (Git)
└── add_dependency.sh         🚀 Helper pour ajouter dépendances
```

**Versionnés dans Git :**
- ✅ `pubspec_mac.yaml`
- ✅ `pubspec_windows.yaml`
- ✅ Scripts `*.sh` et `*.ps1`

**Ignorés par Git (skip-worktree) :**
- ❌ `pubspec.yaml` (généré localement)

---

## 💡 Astuce Pro

Pour vérifier que les deux templates sont synchronisés :

```bash
# Comparer les dépendances (ignorer la ligne airbar_backend_client)
diff -u <(grep -v airbar_backend_client pubspec_mac.yaml) \
        <(grep -v airbar_backend_client pubspec_windows.yaml)

# Aucune différence = ✅ Synchronisés
```

---

## 🎯 Résumé en 3 Points

1. **NE JAMAIS** éditer `pubspec.yaml` directement
2. **TOUJOURS** éditer `pubspec_mac.yaml` ET `pubspec_windows.yaml`
3. **TOUJOURS** relancer le script de switch après modification

**C'est la clé d'un workflow sans conflit !** 🔑
