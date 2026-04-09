# Instructions GitHub Copilot - AirBar

**Application de gestion de bar d'aéro-club**  
**Stack:** Flutter + Serverpod + PostgreSQL + GetX  
**Dernière mise à jour:** 9 avril 2026

---

## 🎯 Vue d'Ensemble du Projet

AirBar est une application complète de gestion de bar pour aéro-club permettant :
- Aux **membres** : acheter des produits avec leur solde de compte
- Aux **administrateurs** : gérer utilisateurs, produits, stock, transactions

### Architecture du Workspace

```
airbar/                          # Application Flutter principale (Frontend)
airbar_backend/
  ├── airbar_backend_client/     # Client Serverpod généré automatiquement
  └── airbar_backend_server/     # Serveur Serverpod (Backend)
```

---

## 🏗️ Stack Technique

### Backend
- **Framework:** Serverpod 3.3.1
- **Base de données:** PostgreSQL 14+ (via docker-compose port 8090)
- **Cache:** Redis 6.2.6 (via docker-compose port 8091)
- **Sécurité:** Hashing SHA256 des codes PIN

### Frontend
- **Framework:** Flutter 3.x
- **State Management:** GetX 4.6.5 (state, routing, DI)
- **Cache Local:** GetStorage 2.1.1
- **Responsive:** FlutterScreenUtil 5.9.0
- **Dates:** intl 0.18.1
- **Config Serveur:** SharedPreferences

### Ports Utilisés
- **8080:** API Server (Serverpod)
- **8081:** Web Server (Serverpod)
- **8082:** Insights Server (Serverpod)
- **8090:** PostgreSQL (développement)
- **8091:** Redis (développement)
- **9090:** PostgreSQL (tests)
- **9091:** Redis (tests)

---

## 🎨 Patterns et Conventions

### Architecture Pattern

**Repository Pattern:**
```dart
Controller (GetX) 
  ↓
Repository (Data Layer)
  ↓
Serverpod Client
  ↓ HTTP/WebSocket
Backend Server
  ↓
PostgreSQL + Redis
```

### Structure des Modules GetX

Chaque module suit cette structure :
```
module_name/
  ├── bindings/
  │   └── module_binding.dart       # Injection de dépendances
  ├── controllers/
  │   └── module_controller.dart    # Logique métier + état
  └── views/
      └── module_view.dart          # Interface utilisateur
```

### Conventions de Nommage

**Fichiers:**
- Controllers: `*_controller.dart`
- Views: `*_view.dart`
- Bindings: `*_binding.dart`
- Repositories: `*_repository.dart`
- Services: `*_service.dart`

**Classes:**
- Controllers: `*Controller extends GetxController`
- Views: `*View extends GetView<*Controller>`
- Bindings: `*Binding extends Bindings`

**Variables Observables GetX:**
```dart
// État réactif avec .obs
final isLoading = false.obs;
final products = <Product>[].obs;

// Getters pour faciliter l'accès
bool get isLoading => _isLoading.value;
```

---

## 📦 Domaine Métier: Gestion de Stock

### Concepts Clés

#### 1. Produits Réguliers
- Stock géré en **unités entières** (`int`)
- Vente = déduction directe du stock
- Exemple: bouteille, canette, paquet de chips

#### 2. Produits en Vrac (isBulkProduct = true)
- **`stockQuantity` (int):** Nombre d'unités complètes NON OUVERTES (ex: 5 fûts)
- **`currentUnitRemaining` (double?):** Quantité restante dans l'unité ENTAMÉE (ex: 4.25L)
- **`bulkUnit` (String?):** Unité de mesure ("litres", "kg", etc.)
- **`bulkTotalQuantity` (double?):** Capacité d'une unité (ex: 6L par fût)

**Stock total disponible = (stockQuantity × bulkTotalQuantity) + currentUnitRemaining**

Exemple:
- `stockQuantity = 5` fûts
- `currentUnitRemaining = 4.25L`
- `bulkTotalQuantity = 6L`
- **Total disponible = (5 × 6) + 4.25 = 34.25L**

#### 3. Portions (ProductPortion)
Pour les produits en vrac, définit les tailles de service :
```dart
ProductPortion(
  name: "25cl",
  quantity: 0.25,  // litres
  price: 2.50,     // euros
)
```

#### 4. Produits sans Gestion de Stock (trackStock = false)
- **`trackStock` (bool, default: true):** Active/désactive la gestion de stock
- Pour les produits en libre service (café, eau, etc.) ou virtuels
- Pas de validation de stock lors de l'achat
- Pas de déduction de stock
- Pas de création de StockMovement
- Pas d'alertes de stock faible

**Comportement lors du checkout:**
```dart
// Validation de stock uniquement si trackStock = true
if (product.trackStock) {
  double availableStock;
  if (product.isBulkProduct && product.bulkTotalQuantity != null) {
    availableStock = (product.stockQuantity * product.bulkTotalQuantity!) + 
                     (product.currentUnitRemaining ?? 0);
  } else {
    availableStock = product.stockQuantity.toDouble();
  }
  
  if (availableStock < requiredQuantity) {
    throw Exception('Stock insuffisant...');
  }
}

// Déduction de stock uniquement si trackStock = true
if (product.trackStock) {
  // Logique de déduction de stock
  // Création de StockMovement
}
```

**Interface utilisateur:**
- Champs de stock désactivés et grisés dans le formulaire produit si `trackStock = false`
- Affichage "N/A" au lieu de la quantité dans la liste des produits
- Badge "Stock non géré" dans la vue de gestion du stock
- Bouton "Réapprovisionner" remplacé par un message d'information
- Exclus des alertes de stock faible

**Endpoints de stock:**
```dart
// stock_endpoint.dart - Bloquer les opérations si trackStock = false
if (!product.trackStock) {
  throw Exception('Ce produit n\'a pas de gestion de stock activée');
}
```

### Logique de Déduction du Stock

**Scénario 1 - L'unité entamée suffit:**
```dart
Client achète: 2×50cl = 1L
currentUnitRemaining: 4.25L

Résultat:
currentUnitRemaining = 4.25 - 1.0 = 3.25L
stockQuantity inchangé
```

**Scénario 2 - Besoin d'ouvrir une nouvelle unité:**
```dart
Client achète: 10×50cl = 5L
currentUnitRemaining: 4.25L
bulkTotalQuantity: 6L

Calcul:
- Utilise 4.25L de l'unité actuelle
- Reste à servir: 5 - 4.25 = 0.75L
- Ouvre 1 nouveau fût (ceil(0.75 / 6.0) = 1)
- stockQuantity -= 1
- Nouveau reste: 6.0 - 0.75 = 5.25L

Résultat:
stockQuantity = stockQuantity - 1
currentUnitRemaining = 5.25L
```

**Scénario 3 - Ouverture de plusieurs unités:**
```dart
Client achète: 30×50cl = 15L
currentUnitRemaining: 2.0L
bulkTotalQuantity: 6L

Calcul:
- Utilise 2.0L de l'unité actuelle
- Reste: 15 - 2 = 13L
- Fûts à ouvrir: ceil(13 / 6) = 3
- Total des nouveaux fûts: 3 × 6 = 18L
- Reste dans le dernier: 18 - 13 = 5L

Résultat:
stockQuantity -= 3
currentUnitRemaining = 5.0L
```

### Validation de Stock

**IMPORTANT:** Toujours calculer le stock total disponible pour les produits en vrac :

```dart
double availableStock;
if (product.isBulkProduct && product.bulkTotalQuantity != null) {
  // Stock total = unités complètes + unité entamée
  availableStock = (product.stockQuantity * product.bulkTotalQuantity!) + 
                   (product.currentUnitRemaining ?? 0.0);
} else {
  // Produits réguliers
  availableStock = product.stockQuantity.toDouble();
}

if (availableStock < requiredQuantity) {
  throw Exception('Stock insuffisant...');
}
```

**❌ Erreur fréquente:**
```dart
// NE PAS comparer directement stockQuantity avec requiredQuantity
// pour les produits en vrac !
if (product.stockQuantity < requiredQuantity) { // INCORRECT
  throw Exception('...');
}
```

---

## 🔐 Sécurité et Authentification

### Hashing des PINs

**TOUJOURS utiliser SHA256:**
```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

String _hashPin(String pin) {
  final bytes = utf8.encode(pin);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

**Points de validation:**
- Login (`auth_endpoint.dart`)
- Checkout (`transaction_endpoint.dart`)
- Création/modification utilisateur

### Contrôle d'Accès (Rôles)

```dart
enum UserRole {
  user,    // Utilisateur standard (boutique uniquement)
  admin,   // Administrateur (accès complet)
}

// Vérification côté frontend
if (AuthService.to.currentUser?.role == UserRole.admin) {
  // Afficher options admin
}

// Vérification côté backend (dans chaque endpoint admin)
if (session.auth?.userId == null) {
  throw Exception('Non authentifié');
}
// Ajouter vérification du rôle si nécessaire
```

---

## 🧪 Développement et Workflows

### Démarrage en Mode Développement (Recommandé)

```bash
# Terminal 1: Bases de données Docker
cd airbar_backend/airbar_backend_server
docker-compose up -d postgres redis

# Terminal 2: Backend Dart (hot reload disponible)
dart run bin/main.dart

# Terminal 3: Frontend Flutter
cd ../../airbar
flutter run -d chrome  # ou -d macos
```

**Avantages:** Hot reload, débogage facile, logs directs

### Génération de Code Serverpod

**Après modification des modèles (fichiers .yaml dans `protocol/`):**
```bash
cd airbar_backend/airbar_backend_server
serverpod generate  # Génère les classes protocol + client
```

**Fichiers générés:**
- Backend: `lib/src/generated/`
- Client: `../airbar_backend_client/lib/src/protocol/`

**Puis synchroniser Flutter:**
```bash
cd ../../airbar
flutter pub get
```

### Gestion des Migrations

**Créer une migration:**
```bash
cd airbar_backend/airbar_backend_server
serverpod create-migration

# Si migration destructive (perte de données)
serverpod create-migration --force
```

**Appliquer les migrations:**
Les migrations sont appliquées automatiquement au démarrage du serveur.

### Docker Production

```bash
# Build initial
cd airbar_backend/airbar_backend_server
docker-compose build

# Démarrer tous les services
docker-compose up -d

# Rebuild après modifications du code
docker-compose build airbar_server
docker-compose up -d airbar_server

# Logs
docker-compose logs -f airbar_server
```

---

## 📁 Structure des Repositories

### Repositories Frontend (7 repositories)

```dart
class ProductRepository {
  final _client = ServerpodClientProvider.client;
  final _storage = Get.find<StorageService>().storage;
  
  // Pattern de cache
  Future<List<Product>> getAllProducts({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _storage.read<List>(AppConstants.keyProducts);
      if (cached != null) {
        return cached.map((e) => Product.fromJson(e)).toList();
      }
    }
    
    final products = await _client.product.getAllProducts();
    _storage.write(AppConstants.keyProducts, 
      products.map((e) => e.toJson()).toList());
    return products;
  }
}
```

**Repositories disponibles:**
1. `AuthRepository` - Authentification
2. `UserRepository` - Utilisateurs + crédit/débit compte
3. `ProductRepository` - Produits + gestion stock
4. `CategoryRepository` - Catégories
5. `CartRepository` - Panier
6. `StockRepository` - Mouvements de stock
7. `TransactionRepository` - Transactions + remboursements

### Services Globaux

```dart
// Initialisation dans main.dart (ordre important!)
await GetStorage.init();
Get.put(StorageService(), permanent: true);
Get.put(ServerConfigService(), permanent: true);
await ServerpodClientProvider.initialize();
Get.put(AuthService(), permanent: true);
```

**Services:**
- `StorageService` - Wrapper GetStorage
- `ServerConfigService` - Configuration IP/port serveur
- `AuthService` - Utilisateur connecté (currentUser)

---

## 🎨 UI et Responsive Design

### FlutterScreenUtil

**Initialisation dans build():**
```dart
return ScreenUtilInit(
  designSize: const Size(375, 812),  // iPhone X comme référence
  child: GetMaterialApp(...),
);
```

**Utilisation:**
```dart
// Tailles responsive
height: 200.h,      // Hauteur proportionnelle
width: 100.w,       // Largeur proportionnelle
fontSize: 16.sp,    // Police proportionnelle
padding: EdgeInsets.all(16.w),

// Spacing
SizedBox(height: 16.h),
SizedBox(width: 8.w),
```

### Palette de Couleurs (AppColors)

```dart
static const primary = Color(0xFF2196F3);    // Bleu
static const accent = Color(0xFFFF9800);     // Orange
static const background = Color(0xFFF5F5F5); // Gris clair
static const cardColor = Colors.white;
static const textDark = Color(0xFF212121);
static const textLight = Color(0xFF757575);
static const error = Color(0xFFF44336);      // Rouge
static const success = Color(0xFF4CAF50);    // Vert
```

### Indicateurs de Stock (Produits)

```dart
Color getStockColor(Product product) {
  if (product.stockQuantity == 0) {
    return Colors.red;             // Rupture
  } else if (product.stockQuantity <= product.minStockAlert) {
    return Colors.orange;          // Stock faible
  }
  return Colors.green;             // Stock OK
}
```

---

## 🔄 Routes et Navigation

### Configuration des Routes

**Fichier:** `lib/app/routes/app_routes.dart`
```dart
class Routes {
  // Utilisateur
  static const LOGIN = '/login';
  static const USER_SHOP = '/user/shop';
  static const USER_CART = '/user/cart';
  static const USER_CHECKOUT = '/user/checkout';
  
  // Admin
  static const ADMIN_DASHBOARD = '/admin/dashboard';
  static const ADMIN_USERS = '/admin/users';
  static const ADMIN_PRODUCTS = '/admin/products';
  // ... etc
  
  // Settings
  static const SERVER_CONFIG = '/server-config';
}
```

### Navigation GetX

```dart
// Navigation simple
Get.toNamed(Routes.USER_SHOP);

// Navigation avec paramètres
Get.toNamed(
  Routes.ADMIN_PRODUCT_FORM,
  arguments: {'product': product},  // Édition
);

// Retour avec données
Get.back(result: true);

// Remplacement de route (login → dashboard)
Get.offAllNamed(Routes.ADMIN_DASHBOARD);
```

### Navigation Bidirectionnelle Admin ↔ Boutique

**Dashboard Admin → Boutique:**
```dart
void goToShop() => Get.toNamed(Routes.USER_SHOP);
```

**Boutique → Dashboard Admin (si admin):**
```dart
if (controller.isAdmin)
  IconButton(
    icon: Icon(Icons.admin_panel_settings),
    onPressed: controller.goToAdminDashboard,
  ),
```

**Bénéfice:** Admin peut acheter sans se déconnecter

---

## 🛒 Workflow Checkout (Transaction Atomique)

### Étapes de la Transaction (transaction_endpoint.dart)

```dart
Future<Transaction> checkout(Session session, int userId, String pin) async {
  // 1. Validation utilisateur et PIN
  final user = await User.db.findById(session, userId);
  if (user.hashedPin != _hashPin(pin)) {
    throw Exception('Code PIN incorrect');
  }
  
  // 2. Récupération du panier
  final cartItems = await CartItem.db.find(
    session, 
    where: (t) => t.userId.equals(userId),
  );
  
  // 3. Validation et calcul du stock pour CHAQUE article
  for (final cartItem in cartItems) {
    final product = await Product.db.findById(session, cartItem.productId);
    
    // Calcul de la quantité requise
    double requiredQuantity;
    if (cartItem.productPortionId != null) {
      final portion = await ProductPortion.db.findById(
        session, 
        cartItem.productPortionId!,
      );
      requiredQuantity = cartItem.quantity * portion.quantity;
    } else {
      requiredQuantity = cartItem.quantity.toDouble();
    }
    
    // VALIDATION: Calcul du stock disponible
    double availableStock;
    if (product.isBulkProduct && product.bulkTotalQuantity != null) {
      availableStock = (product.stockQuantity * product.bulkTotalQuantity!) + 
                       (product.currentUnitRemaining ?? 0);
    } else {
      availableStock = product.stockQuantity.toDouble();
    }
    
    if (availableStock < requiredQuantity) {
      throw Exception('Stock insuffisant pour ${product.name}');
    }
  }
  
  // 4. Calcul du montant total
  double totalAmount = 0.0;
  for (final cartItem in cartItems) {
    // ... calcul du prix
    totalAmount += itemTotal;
  }
  
  // 5. Vérification du solde
  if (user.balance < totalAmount) {
    throw Exception('Solde insuffisant');
  }
  
  // 6. Débit du compte
  user.balance -= totalAmount;
  await User.db.updateRow(session, user);
  
  // 7. Création de la transaction
  final transaction = Transaction(
    userId: userId,
    type: TransactionType.purchase,
    totalAmount: -totalAmount,
    timestamp: DateTime.now(),
    balanceAfter: user.balance,
  );
  await Transaction.db.insertRow(session, transaction);
  
  // 8. Création des TransactionItems + déduction stock
  for (final cartItem in cartItems) {
    // ... création TransactionItem
    
    // DÉDUCTION DU STOCK (logique complexe pour produits en vrac)
    if (product.isBulkProduct && cartItem.productPortionId != null) {
      // Logique d'ouverture d'unités (voir section "Domaine Métier")
      // ...
    } else {
      product.stockQuantity -= cartItem.quantity;
    }
    await Product.db.updateRow(session, product);
    
    // Création du mouvement de stock
    // ...
  }
  
  // 9. Vidage du panier
  await CartItem.db.deleteWhere(
    session,
    where: (t) => t.userId.equals(userId),
  );
  
  // 10. Retour de la transaction
  return transaction;
}
```

**IMPORTANT:** Tout est atomique - si une étape échoue, tout est annulé.

---

## 🐛 Erreurs Fréquentes et Solutions

### 1. "Bad Request" après serverpod generate

**Symptômes:** Erreurs API après ajout/modification de méthodes

**Cause:** Serveur utilise encore l'ancien code

**Solution:**
```bash
# 1. Régénérer
cd airbar_backend/airbar_backend_server
serverpod generate

# 2. Redémarrer le serveur
kill -9 $(lsof -ti:8080)
dart run bin/main.dart

# 3. Sync Flutter
cd ../../airbar
flutter pub get
flutter clean && flutter pub get  # Si nécessaire
```

### 2. "Map<String, dynamic> is not a subtype of ProductCategory"

**Symptômes:** Crash lors du chargement depuis le cache

**Cause:** GetStorage retourne des Maps JSON, pas des objets typés

**Solution:**
```dart
// Utiliser forceRefresh: true au démarrage des controllers
@override
void onInit() {
  super.onInit();
  loadData();  // Avec forceRefresh interne
}

// Ou explicitement
await _categoryRepository.getCategories(forceRefresh: true);
```

### 3. Boutons +/- du panier ne réagissent pas

**Symptômes:** L'affichage ne se met pas à jour avec les boutons

**Cause:** Closures capturent anciennes valeurs

**Solution:**
```dart
// ❌ INCORRECT
onPressed: () => controller.updateQuantity(item, item.quantity - 1),

// ✅ CORRECT
onPressed: () {
  final currentItem = controller.cartItems[index];
  controller.updateQuantity(currentItem, currentItem.quantity - 1);
},
```

### 4. "Code PIN incorrect" lors du checkout

**Symptômes:** Login fonctionne, mais checkout échoue

**Cause:** Hash SHA256 non implémenté dans transaction_endpoint

**Solution:** Toujours utiliser la même fonction de hash:
```dart
String _hashPin(String pin) {
  final bytes = utf8.encode(pin);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

### 5. Stock insuffisant alors qu'il y a du stock

**Symptômes:** Rejet de checkout pour produits en vrac avec stock disponible

**Cause:** Comparaison incorrecte unités vs litres

**Solution:** Voir section "Validation de Stock" (calculer availableStock)

---

## 📝 Checklist Avant Commit

### Backend (Serverpod)

- [ ] `serverpod generate` exécuté après modifications
- [ ] Migrations créées si changements de modèles
- [ ] Tests passent: `dart test`
- [ ] Code analysé: `dart analyze`
- [ ] Serveur démarre sans erreur
- [ ] Endpoints testés avec Postman ou client Flutter

### Frontend (Flutter)

- [ ] `flutter pub get` après modifications backend
- [ ] Pas d'erreurs de compilation
- [ ] `flutter analyze` propre
- [ ] Navigation testée
- [ ] Affichage responsive vérifié
- [ ] Messages d'erreur utilisateur clairs

### Général

- [ ] Variables sensibles dans `.gitignore`
- [ ] Commentaires sur logique complexe
- [ ] Nommage cohérent avec conventions
- [ ] Pas de code commenté (supprimer ou documenter pourquoi)

---

## 🔍 Points d'Attention Spécifiques

### Gestion des Catégories

**IMPORTANT:** La catégorie "Sans catégorie" est spéciale:
- Créée automatiquement si absente
- Non supprimable
- `displayOrder: 999` (toujours en dernier)
- Les produits orphelins y sont automatiquement assignés

```dart
// Protection dans deleteCategory()
if (category.name == 'Sans catégorie') {
  throw Exception('Impossible de supprimer la catégorie par défaut');
}

// Déplacement des produits avant suppression
final products = await Product.db.find(
  session,
  where: (t) => t.categoryId.equals(categoryId),
);
for (var product in products) {
  product.categoryId = uncategorizedId;
  await Product.db.updateRow(session, product);
}
```

### Soft Delete des Produits

**Ne JAMAIS supprimer physiquement un produit:**
```dart
// ✅ CORRECT (soft delete)
product.isActive = false;
await Product.db.updateRow(session, product);

// ❌ INCORRECT
await Product.db.deleteRow(session, product);
```

**Raison:** Préserve l'historique des transactions

### Ajustement de Solde (Crédit/Débit)

**Support montants positifs ET négatifs:**
```dart
// Backend - user_endpoint.dart
Future<Transaction> creditAccount(
  Session session,
  int userId,
  double amount,
  String? notes,  // Notes optionnelles
) async {
  if (amount == 0) {
    throw Exception('Le montant ne peut pas être zéro');
  }
  
  // Validation pour débits
  if (amount < 0 && user.balance + amount < 0) {
    throw Exception(
      'Solde insuffisant. Solde actuel: ${user.balance}€'
    );
  }
  
  user.balance += amount;
  // ... création transaction
}
```

**Frontend - Messages dynamiques:**
```dart
final operation = amount > 0 ? 'crédité de' : 'débité de';
Get.snackbar('Succès', 'Compte $operation ${amount.abs()}€');
```

### Configuration Serveur Dynamique

**Permet de changer IP/port sans recompiler:**
```dart
// ServerConfigService
String get serverUrl => 'http://$host:$port/';

// Après changement de config
await ServerpodClientProvider.reinitialize();
```

**Accès:** Bouton en bas de l'écran de login

---

## 📚 Ressources et Documentation

### Documentation Officielle
- [Serverpod](https://serverpod.dev/) - Backend framework
- [Flutter](https://flutter.dev/) - Frontend framework
- [GetX](https://pub.dev/packages/get) - State management
- [Docker Compose](https://docs.docker.com/compose/) - Containerization

### Fichiers de Référence du Projet
- `/information/documentation-complete.md` - Doc complète du projet
- `/information/guide-docker-dockerfile-compose.md` - Guide Docker
- `/information/guide-produits-en-vrac.md` - Gestion produits en vrac
- `/information/synthese-evolution-stock-mars-2026.md` - Évolutions stock

### Outils Recommandés
- **Postman** - Tests API
- **DBeaver** - Client PostgreSQL
- **Redis Insight** - Client Redis
- **Docker Desktop** - Gestion conteneurs

---

## 🚀 Résumé pour Démarrage Rapide

```bash
# 1. Clone des repositories
git clone https://github.com/rorophil/airbar.git
git clone https://github.com/rorophil/airbar_backend.git

# 2. Backend - Démarrer les services
cd airbar_backend/airbar_backend_server
docker-compose up -d postgres redis
dart pub get
dart run bin/main.dart

# 3. Frontend - Dans un nouveau terminal
cd ../../airbar
flutter pub get
flutter run -d chrome

# 4. Configuration initiale
# - Ouvrir http://localhost:PORT dans le navigateur
# - Cliquer "Configuration serveur" en bas du login
# - Entrer: localhost:8080
# - Tester la connexion
```

**Compte admin par défaut (créé au démarrage):**
- PIN: 123456
- Role: admin

---

## ⚠️ Règles Importantes

1. **JAMAIS** comparer directement `stockQuantity` avec `requiredQuantity` pour produits en vrac
2. **TOUJOURS** utiliser SHA256 pour les PINs
3. **TOUJOURS** faire `forceRefresh: true` au démarrage des controllers
4. **TOUJOURS** calculer le stock total (unités + unité entamée) pour validation
5. **TOUJOURS** préserver la catégorie "Sans catégorie"
6. **TOUJOURS** faire un soft delete des produits (`isActive = false`)
7. **JAMAIS** supprimer physiquement des transactions (audit trail)
8. **TOUJOURS** vérifier le solde AVANT de débiter un compte
9. **TOUJOURS** vérifier `product.trackStock` avant toute opération de stock (validation, déduction, réapprovisionnement)

---

**Ce document doit être maintenu à jour avec chaque évolution majeure du projet.**
