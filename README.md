# AirBar - Gestion de Bar d'Aéro-club

Application Flutter complète de gestion de bar pour aéro-club avec système de compte, portions multiples et gestion intelligente du stock.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![GetX](https://img.shields.io/badge/GetX-4.6.5-8A2BE2)
![Serverpod](https://img.shields.io/badge/Serverpod-3.3.1-FF6B35)

## 🎯 Fonctionnalités

### Pour les Membres
- ✅ Authentification par code PIN (4 chiffres)
- ✅ Consultation du solde de compte
- ✅ Navigation par catégories de produits
- ✅ **Produits en vrac** avec portions multiples (ex: bière fût → 25cl/33cl/50cl)
- ✅ Panier d'achat avec gestion des quantités
- ✅ Checkout instantané avec débit du solde
- ✅ Historique des transactions

### Pour les Administrateurs
- 🔐 Gestion complète des utilisateurs (création, modification, solde)
- 📦 Gestion des produits et catégories
- 🍺 **Gestion par unités physiques** (fûts, caisses) avec tracking d'unité entamée
- 💰 Système de crédit/débit de compte
- 📊 Historique des mouvements de stock
- 🔄 Système de remboursement
- 📈 Alertes de stock automatiques

## 🚀 Installation et Démarrage

### Prérequis

- Flutter SDK 3.x
- Dart SDK 3.x
- Backend Serverpod en cours d'exécution (voir [airbar_backend](https://github.com/rorophil/airbar_backend))

### Installation

```bash
# Cloner le repository
git clone https://github.com/rorophil/airbar.git
cd airbar

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Configuration du Backend

Au premier lancement, l'application vous demandera l'URL du serveur backend :

```
http://localhost:8080  # Pour développement local
```

## 📱 Architecture

### Stack Technique

- **Framework:** Flutter 3.x
- **State Management:** GetX 4.6.5
- **Backend Client:** Serverpod Client 3.3.1
- **Routing:** GetX Navigation
- **Storage:** GetStorage + SharedPreferences
- **UI:** Material Design 3 avec ScreenUtil (responsive)

### Structure du Projet

```
lib/
├── main.dart
└── app/
    ├── core/                    # Configuration, constantes, thèmes
    ├── data/
    │   ├── providers/          # Serverpod client provider
    │   ├── repositories/       # Couche d'accès aux données
    │   └── services/           # Services (auth, storage)
    ├── modules/
    │   ├── auth/               # Authentification PIN
    │   ├── admin/              # Modules administrateur
    │   │   ├── dashboard/
    │   │   ├── users/
    │   │   ├── products/
    │   │   └── stock/
    │   └── user/               # Modules utilisateur
    │       ├── shop/           # Boutique et portions
    │       ├── cart/           # Panier
    │       └── transactions/   # Historique
    └── routes/                 # Configuration routing GetX
```

### Pattern Repository

```dart
// Exemple : ProductRepository
class ProductRepository {
  Client get _client => ServerpodClientProvider.client;
  
  Future<List<Product>> getAllProducts() async {
    // Cache local + appels backend
  }
}
```

## 🍺 Gestion des Produits en Vrac

### Concept Innovant : Unités Physiques

Le système gère les produits en vrac par **unités physiques réelles** :

**Exemple : Fût de bière 6L**
```dart
Product(
  name: 'Fût Jupiler',
  stockQuantity: 5,              // 5 fûts complets non ouverts
  currentUnitRemaining: 4.25,    // 4.25L dans le fût actuel
  bulkTotalQuantity: 6.0,        // Capacité : 6L par fût
  bulkUnit: 'litres',
)
```

**Stock total disponible :** `(5 × 6L) + 4.25L = 34.25 litres`

### Portions Multiples

Chaque produit en vrac peut avoir plusieurs portions avec prix différents :

```dart
ProductPortion(
  name: '25cl',
  quantity: 0.25,  // en litres
  price: 2.50,
)

ProductPortion(
  name: '50cl',
  quantity: 0.50,
  price: 4.00,
)
```

### Gestion Intelligente du Stock

**Scénario 1 : L'unité entamée suffit**
- Client achète 2×25cl (0.5L)
- `currentUnitRemaining: 4.25L → 3.75L`
- Pas d'ouverture de nouveau fût

**Scénario 2 : Ouverture d'un nouveau fût**
- Client achète 20×25cl (5L)
- `currentUnitRemaining: 4.25L` insuffisant
- Système ouvre 1 nouveau fût
- `stockQuantity: 5 → 4` fûts
- `currentUnitRemaining: 5.25L` (6L - 0.75L manquant)

Voir `information/synthese-evolution-stock-mars-2026.md` pour les détails complets.

## 🔐 Authentification

Système d'authentification par code PIN à 4 chiffres :

```dart
// Hash SHA256 stocké en base
final hashedPin = sha256.convert(utf8.encode(pin)).toString();
```

**Sécurité :**
- ✅ PIN hashé (SHA256)
- ✅ Sessions avec timeout
- ✅ Séparation des rôles (User/Admin)
- ✅ Vérification backend de tous les droits

## 📊 Écrans Principaux

### Module Utilisateur

#### 1. Shop (Boutique)
- Grille de produits avec images
- Filtrage par catégorie
- Recherche
- **Portions inline** : toutes les portions visibles directement
- Ajout rapide au panier

#### 2. Cart (Panier)
- Liste des articles avec nom + portion
- Prix effectif par article (prix de la portion)
- Modification des quantités
- Vérification de stock en temps réel
- Total avec compte à rebours du solde

#### 3. Transactions
- Historique complet
- Détails par transaction
- Affichage des portions achetées

### Module Admin

#### 1. Dashboard
- Vue d'ensemble (utilisateurs, produits, transactions)
- Statistiques rapides
- Accès rapide aux fonctions principales

#### 2. Users Management
- Liste des utilisateurs avec solde
- Création/modification
- Crédit/débit de compte
- Gestion des rôles

#### 3. Products Management
- CRUD produits
- **Mode vrac avec portions**
- Upload d'images
- Gestion du stock par unités

#### 4. Stock Management
- Vue globale du stock
- Réapprovisionnement (ajout d'unités)
- Ajustements d'inventaire
- Historique des mouvements

## 📚 Documentation Complète

Le dossier `information/` contient :

1. **`documentation-complete.md`**  
   Documentation initiale complète du projet (architecture, modèles, endpoints)

2. **`guide-produits-en-vrac.md`**  
   Guide utilisateur pour la création et gestion des produits en vrac

3. **`synthese-evolution-stock-mars-2026.md`**  
   Synthèse technique détaillée de l'évolution vers la gestion par unités physiques

## 🧪 Tests

```bash
# Lancer les tests
flutter test

# Tests avec coverage
flutter test --coverage
```

## 📦 Dépendances Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management & Navigation
  get: ^4.6.5
  get_storage: ^2.1.1
  
  # Backend
  airbar_backend_client:
    path: ../airbar_backend/airbar_backend_client
  serverpod_auth_client: ^3.3.1
  serverpod_flutter: ^3.3.1
  
  # UI
  flutter_screenutil: ^5.9.0
  intl: ^0.18.1
  
  # Storage
  shared_preferences: ^2.2.2
```

## 🔗 Liens

- [Backend Repository](https://github.com/rorophil/airbar_backend)
- [Serverpod Documentation](https://docs.serverpod.dev)
- [GetX Documentation](https://pub.dev/packages/get)

## 🏗️ Évolutions Récentes

### Mars 2026 : Gestion par Unités Physiques

**Migration majeure** du système de stock :
- ✅ Passage de quantités fractionnelles à unités physiques
- ✅ Tracking de l'unité actuellement ouverte
- ✅ Ouverture automatique de nouvelles unités
- ✅ Vérification de stock intelligente
- ✅ Remboursements avec reconversion automatique

**Impact :**
- Inventaire physique = inventaire informatique
- Gestion simplifiée pour les opérateurs
- Alertes pertinentes sur unités complètes
- Base pour évolutions futures (FIFO, traçabilité par lot)

## 📝 Contributeurs

Développé pour la gestion moderne d'un bar d'aéro-club avec focus sur :
- 🎯 UX simplifiée (portions inline, checkout rapide)
- 📦 Réalisme de la gestion de stock
- 🔒 Sécurité (auth, rôles, validation backend)
- 📱 Responsive design (mobile, tablette)

---

**Version:** 2.0  
**Dernière mise à jour:** 10 mars 2026  
**License:** Private
