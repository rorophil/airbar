# 📄 Documentation complète - Docker, Dockerfile et Docker Compose

**Date :** 19 mars 2026  
**Projet :** Airbar Backend (Serverpod)

---

## 1️⃣ Explication du Dockerfile (lignes 2-4)

### Code analysé
```dockerfile
FROM dart:3.8.0 AS build
WORKDIR /app
COPY . .
```

### Explication
- **`FROM dart:3.8.0 AS build`** : Utilise l'image officielle Dart 3.8.0 et nomme cette étape "build"
- **`WORKDIR /app`** : Définit `/app` comme répertoire de travail (créé automatiquement)
- **`COPY . .`** : Copie tout le contenu local vers `/app` dans le conteneur

---

## 2️⃣ Dockerfile complet - Architecture multi-stage

### Stage 1 : Build (compilation)
```dockerfile
FROM dart:3.8.0 AS build
WORKDIR /app
COPY . .
RUN dart pub get
RUN dart compile exe bin/main.dart -o bin/server
```
- Image Dart complète (~500MB)
- Installation des dépendances
- Compilation en exécutable natif

### Stage 2 : Production (runtime)
```dockerfile
FROM alpine:latest
ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

COPY --from=build /runtime/ /
COPY --from=build /app/bin/server server
COPY --from=build /app/config/ config/
COPY --from=build /app/web/ web/
COPY --from=build /app/migrations/ migrations/
COPY --from=build /app/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml

EXPOSE 8080 8081 8082

ENTRYPOINT ./server --mode=$runmode --server-id=$serverid --logging=$logging --role=$role
```
- Image Alpine ultra-légère (~5MB)
- Copie uniquement l'exécutable compilé et ressources nécessaires
- Configuration via variables d'environnement

### ✅ Avantages
- **Image finale légère** : ~20-50MB au lieu de 500MB
- **Performance** : exécutable natif (pas d'interprétation)
- **Sécurité** : surface d'attaque réduite

---

## 3️⃣ Docker Compose - Configuration actuelle

### Services disponibles

#### Développement
```yaml
postgres:          # Port 8090
  - DB: airbar_backend
  - User: postgres
  - Password: JN2w8w360Q0mLywsXHv8wNHuDiY64RWg

redis:             # Port 8091
  - Password: DR6ltcbUbGaYVlOcPN4ARXESCrt7p1LS
```

#### Tests
```yaml
postgres_test:     # Port 9090
  - DB: airbar_backend_test
  - Password: dHNjhnRTbV73Nwd7VAabLVLl740Ht2Aj

redis_test:        # Port 9091
  - Password: aOo7byqFbKR0JbF-CBG4q7AKIwvhGUjt
```

### Commandes essentielles
```bash
# Démarrer tous les services
docker-compose up -d

# Démarrer uniquement dev
docker-compose up -d postgres redis

# Arrêter
docker-compose down

# Logs en temps réel
docker-compose logs -f

# Voir l'état
docker-compose ps

# Supprimer les données (ATTENTION!)
docker-compose down -v
```

---

## 4️⃣ Intégration Dockerfile + Docker Compose

### Configuration actuelle
❌ **Pas de lien** : docker-compose utilise uniquement des images officielles (PostgreSQL, Redis)

### Configuration recommandée
✅ **Ajout du serveur Dart** au docker-compose.yaml :

```yaml
services:
  # Serveur backend Dart
  airbar_server:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
      - "8081:8081"
      - "8082:8082"
    environment:
      - runmode=production
      - serverid=default
      - logging=normal
      - role=monolith
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  # Development services
  postgres:
    image: pgvector/pgvector:pg16
    ports:
      - "8090:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_DB: airbar_backend
      POSTGRES_PASSWORD: "JN2w8w360Q0mLywsXHv8wNHuDiY64RWg"
    volumes:
      - airbar_backend_data:/var/lib/postgresql/data

  redis:
    image: redis:6.2.6
    ports:
      - "8091:6379"
    command: redis-server --requirepass "DR6ltcbUbGaYVlOcPN4ARXESCrt7p1LS"
    environment:
      - REDIS_REPLICATION_MODE=master

  # Test services
  postgres_test:
    image: pgvector/pgvector:pg16
    ports:
      - "9090:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_DB: airbar_backend_test
      POSTGRES_PASSWORD: "dHNjhnRTbV73Nwd7VAabLVLl740Ht2Aj"
    volumes:
      - airbar_backend_test_data:/var/lib/postgresql/data

  redis_test:
    image: redis:6.2.6
    ports:
      - "9091:6379"
    command: redis-server --requirepass "aOo7byqFbKR0JbF-CBG4q7AKIwvhGUjt"
    environment:
      - REDIS_REPLICATION_MODE=master

volumes:
  airbar_backend_data:
  airbar_backend_test_data:
```

### Commandes après modification
```bash
# Build et démarrer
docker-compose up -d --build

# Rebuild uniquement le serveur
docker-compose build airbar_server
docker-compose up -d airbar_server

# Redémarrer sans rebuild
docker-compose restart airbar_server
```

---

## 5️⃣ Recompilation : Oui ou Non ?

### ❌ NON, pas à chaque redémarrage !

#### Quand le code est compilé
```bash
docker-compose build          # ← Compilation ICI (une fois)
docker-compose up -d --build  # ← Compilation ICI (une fois)
```

#### Quand le code N'est PAS compilé
```bash
docker-compose up -d          # ✅ Lance l'exécutable existant
docker-compose restart        # ✅ Lance l'exécutable existant
docker-compose stop/start     # ✅ Lance l'exécutable existant
```

### Tableau récapitulatif

| Commande | Reconstruction ? | Recompilation ? | Temps |
|----------|------------------|-----------------|-------|
| `docker-compose up -d` | ❌ | ❌ | ~2-5 sec |
| `docker-compose restart` | ❌ | ❌ | ~2-5 sec |
| `docker-compose up -d --build` | ✅ | ✅ | ~1-3 min |
| `docker-compose build` | ✅ | ✅ | ~1-3 min |

### 💡 Optimisation : .dockerignore
Créer un fichier `.dockerignore` pour éviter de copier des fichiers inutiles :

```dockerignore
.dart_tool/
.packages
build/
.idea/
*.log
.git/
.gitignore
README.md
docker-compose.yaml
Dockerfile
```

---

## 6️⃣ Workflows recommandés

### 🔧 Développement local (recommandé)
```bash
# 1. Bases de données en Docker
cd airbar_backend/airbar_backend_server
docker-compose up -d postgres redis

# 2. Serveur Dart directement (hot reload)
dart run bin/main.dart

# 3. Application Flutter (dans un autre terminal)
cd ../../airbar
flutter run -d chrome
```

**Avantages** :
- ✅ Hot reload disponible
- ✅ Débogage facile
- ✅ Modifications instantanées
- ✅ Logs directement dans le terminal

### 🚀 Production (Docker complet)
```bash
# 1. Build initial (une fois)
cd airbar_backend/airbar_backend_server
docker-compose build

# 2. Démarrer tous les services
docker-compose up -d

# 3. Vérifier l'état
docker-compose ps
docker-compose logs -f airbar_server

# 4. Redémarrer après modifications du code
docker-compose build airbar_server
docker-compose up -d airbar_server
```

### 🧪 Tests
```bash
# Démarrer services de test
docker-compose up -d postgres_test redis_test

# Lancer les tests
dart test

# Arrêter services de test
docker-compose stop postgres_test redis_test
```

---

## 7️⃣ Architecture complète

```
┌─────────────────────────────────────────────────┐
│          Docker Compose Orchestration           │
│                                                 │
│  ┌─────────────┐  ┌──────────┐  ┌───────────┐ │
│  │   Serveur   │  │PostgreSQL│  │   Redis   │ │
│  │    Dart     │  │ +pgvector│  │           │ │
│  │  (Docker    │  │          │  │           │ │
│  │   file)     │  │  :8090   │  │  :8091    │ │
│  │  :8080-8082 │  └──────────┘  └───────────┘ │
│  └─────────────┘                               │
│        ↓                                        │
│  ┌─────────────────────────────────────┐       │
│  │   Exécutable Dart compilé (Alpine)  │       │
│  │   • config/                         │       │
│  │   • web/                            │       │
│  │   • migrations/                     │       │
│  └─────────────────────────────────────┘       │
└─────────────────────────────────────────────────┘
               ↑
               │ API Calls via Serverpod Client
               │
    ┌──────────┴──────────┐
    │  Flutter App (Web)  │
    │  ProductsController │
    │  (GetX + Repo)      │
    └─────────────────────┘
```

---

## 8️⃣ ProductsController - Vue d'ensemble Flutter

### Responsabilités
- 📋 Gestion de la liste des produits (CRUD)
- 🔍 Recherche et filtrage
- 📦 Gestion du stock
- ✅ Activation/désactivation
- 🗂️ Filtrage par catégories

### Architecture
```dart
ProductsController (GetX)
    ↓
ProductRepository
    ↓
Serverpod Client (airbar_backend_client)
    ↓ HTTP/WebSocket
Backend Server (Dart)
    ↓
PostgreSQL + Redis
```

### Méthodes principales

#### Chargement des données
```dart
loadData()              // Charge produits + catégories en parallèle
refresh()               // Recharge les données (pull-to-refresh)
filterProducts()        // Applique les filtres localement
```

#### Actions CRUD
```dart
createProduct()         // Navigation vers formulaire création
editProduct(product)    // Navigation vers formulaire édition
deleteProduct(product)  // Soft delete avec dialog de confirmation
toggleActiveStatus()    // Activer/désactiver un produit
```

#### Gestion du stock
```dart
manageStock(product)    // Dialog de gestion avec +10/-10
updateStock(id, qty)    // Appel API pour mise à jour
```

#### Recherche & Filtrage
```dart
updateSearchQuery(q)    // Recherche par nom/description
selectCategory(id)      // Filtre par catégorie
clearSearch()           // Reset de la recherche
getCategoryName(id)     // Helper pour affichage
```

### Pattern utilisé
- **GetX** : State management réactif avec `.obs`
- **Repository Pattern** : Séparation logique métier / accès données
- **Observables** : Mise à jour automatique de l'UI
- **Future.wait** : Chargement parallèle optimisé

---

## 9️⃣ Commandes de référence rapide

### Docker Compose
```bash
# Navigation
cd airbar_backend/airbar_backend_server

# Gestion des services
docker-compose up -d                    # Démarrer en arrière-plan
docker-compose up -d postgres redis     # Démarrer services spécifiques
docker-compose down                     # Arrêter et supprimer
docker-compose down -v                  # + supprimer volumes (données)
docker-compose stop                     # Arrêter sans supprimer
docker-compose start                    # Redémarrer services arrêtés

# Build
docker-compose build                    # Rebuild tous les services
docker-compose build airbar_server      # Rebuild serveur uniquement
docker-compose up -d --build            # Build + start

# Monitoring
docker-compose ps                       # État des services
docker-compose logs -f                  # Tous les logs
docker-compose logs -f airbar_server    # Logs serveur uniquement
docker-compose logs -f --tail=100       # 100 dernières lignes

# Redémarrage
docker-compose restart                  # Restart tous
docker-compose restart airbar_server    # Restart serveur uniquement
```

### Docker
```bash
# Images
docker images                           # Liste des images
docker rmi <image_id>                   # Supprimer une image
docker image prune                      # Supprimer images non utilisées

# Conteneurs
docker ps                               # Conteneurs actifs
docker ps -a                            # Tous les conteneurs
docker rm <container_id>                # Supprimer un conteneur

# Nettoyage
docker system prune                     # Nettoyer (conteneurs, networks, images)
docker system prune -a                  # Nettoyage complet
docker volume prune                     # Supprimer volumes non utilisés
```

### Dart / Serverpod
```bash
# Développement
dart pub get                            # Installer dépendances
dart run bin/main.dart                  # Lancer serveur local
dart run serverpod_cli:serverpod        # CLI Serverpod

# Compilation
dart compile exe bin/main.dart          # Compiler en exécutable
dart compile exe bin/main.dart -o server # Compiler avec nom spécifique

# Tests
dart test                               # Lancer tous les tests
dart test test/integration_test.dart    # Test spécifique

# Génération de code
serverpod generate                      # Générer protocol classes
```

### Flutter
```bash
# Développement
flutter run -d chrome                   # Lancer en mode web
flutter run -d macos                    # Lancer sur macOS
flutter run --release                   # Mode release

# Build
flutter build web                       # Build web production
flutter build macos                     # Build macOS
flutter build apk                       # Build Android

# Maintenance
flutter clean                           # Nettoyage complet
flutter pub get                         # Installer dépendances
flutter pub upgrade                     # Mettre à jour dépendances

# Analyse
flutter analyze                         # Analyser le code
flutter doctor                          # Vérifier configuration
```

---

## 🔟 Troubleshooting (Problèmes courants)

### ❌ Docker ne démarre pas
```bash
# Vérifier que Docker Desktop est lancé
docker ps

# Si erreur de port déjà utilisé
lsof -i :8080  # Voir quel process utilise le port
kill -9 <PID>  # Tuer le process
```

### ❌ Erreur de connexion à PostgreSQL
```bash
# Vérifier que le service tourne
docker-compose ps

# Vérifier les logs
docker-compose logs postgres

# Recréer le conteneur
docker-compose down
docker-compose up -d postgres
```

### ❌ Données perdues après `docker-compose down`
```bash
# Toujours utiliser les volumes Docker
# NE PAS utiliser -v sauf si vous voulez supprimer les données

# Backup de la base
docker exec -t airbar_backend_postgres pg_dump -U postgres airbar_backend > backup.sql

# Restore
docker exec -i airbar_backend_postgres psql -U postgres airbar_backend < backup.sql
```

### ❌ Image Docker trop lourde
```bash
# Vérifier la taille
docker images

# Créer .dockerignore avec fichiers à exclure
# Utiliser multi-stage build (déjà fait dans notre Dockerfile)
```

### ❌ Hot reload ne fonctionne pas
```bash
# Hot reload ne fonctionne PAS avec Docker
# Solution : Lancer Dart directement
dart run bin/main.dart

# Les bases de données restent en Docker
docker-compose up -d postgres redis
```

---

## 1️⃣1️⃣ Configuration des fichiers Serverpod

### config/development.yaml
```yaml
# Database
database:
  host: localhost
  port: 8090
  name: airbar_backend
  user: postgres
  password: 'JN2w8w360Q0mLywsXHv8wNHuDiY64RWg'

# Redis
redis:
  enabled: true
  host: localhost
  port: 8091
  password: 'DR6ltcbUbGaYVlOcPN4ARXESCrt7p1LS'

# Ports
apiServer:
  port: 8080
  publicHost: localhost
  publicPort: 8080

webServer:
  port: 8081
  publicHost: localhost
  publicPort: 8081

insightsServer:
  port: 8082
  publicHost: localhost
  publicPort: 8082
```

### config/production.yaml
```yaml
# Production config with environment variables
database:
  host: ${DB_HOST}
  port: ${DB_PORT}
  name: ${DB_NAME}
  user: ${DB_USER}
  password: ${DB_PASSWORD}

redis:
  enabled: true
  host: ${REDIS_HOST}
  port: ${REDIS_PORT}
  password: ${REDIS_PASSWORD}
```

---

## 1️⃣2️⃣ Checklist de déploiement

### Avant de déployer

- [ ] Tests passent : `dart test`
- [ ] Code analysé : `dart analyze`
- [ ] Génération protocol : `serverpod generate`
- [ ] Variables d'environnement configurées
- [ ] Fichiers sensibles dans `.gitignore`
- [ ] Docker Compose testé localement
- [ ] Backup de la base de données existante

### Déploiement

- [ ] Pull du code : `git pull`
- [ ] Build de l'image : `docker-compose build`
- [ ] Arrêt des anciens services : `docker-compose down`
- [ ] Démarrage : `docker-compose up -d`
- [ ] Vérification : `docker-compose ps`
- [ ] Tests de santé : `curl localhost:8080/health`
- [ ] Monitoring des logs : `docker-compose logs -f`

### Après déploiement

- [ ] Vérifier les endpoints API
- [ ] Tester l'application Flutter
- [ ] Vérifier les logs pour erreurs
- [ ] Monitorer les performances
- [ ] Documenter les changements

---

## 📚 Ressources

### Documentation officielle
- [Docker Docs](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Dart Language](https://dart.dev/)
- [Serverpod](https://serverpod.dev/)
- [Flutter](https://flutter.dev/)
- [GetX](https://pub.dev/packages/get)

### Outils
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Postman](https://www.postman.com/) (tests API)
- [DBeaver](https://dbeaver.io/) (client PostgreSQL)

---

**✅ Document généré le 19 mars 2026**  
**📦 Projet Airbar - Backend Serverpod avec Flutter**
