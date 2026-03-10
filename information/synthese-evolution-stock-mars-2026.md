# Synthèse des Évolutions - Mars 2026
**Gestion Avancée du Stock par Unités pour Produits en Vrac**

**Dates:** 9-10 mars 2026  
**Objectif:** Refonte complète du système de gestion de stock pour gérer les produits en vrac par unités physiques (fûts, bouteilles) plutôt que par quantités fractionnelles

---

## 🎯 Contexte et Problématique

### Situation Initiale (avant 9 mars)

Le système gérait les stocks de produits en vrac de manière **fractionnelle** :
- `stockQuantity: double` représentait la quantité totale disponible (ex: 34.25 litres)
- Vente de portions → déduction directe de la quantité fractionnelle
- **Problème identifié:** Ne correspondait pas à la réalité physique du stockage

### Exemple du Problème

**Fût de bière 6L avec portions 25cl/33cl/50cl :**
- Stock initial : `stockQuantity = 34.25L`
- Vente de 2×25cl = 0.5L
- Nouveau stock : `34.25 - 0.5 = 33.75L`

**Limites :**
- ❌ Impossible de savoir combien de fûts complets non ouverts
- ❌ Impossible de savoir combien reste dans le fût entamé
- ❌ Gestion physique des fûts difficile (réapprovisionnement, inventaire)
- ❌ Ne reflète pas la réalité d'un bar (on ouvre un fût à la fois)

### Besoin Exprimé

> "Quand toutes les portions d'une unité sont vendues ou qu'il reste moins d'une portion disponible dans l'unité, le système passe à l'unité suivante et décompte une unité dans le stock"

---

## 🚀 Solution Implémentée : Gestion par Unités

### Nouveau Modèle de Données

#### Product - Modifications du modèle

**Avant (gestion fractionnelle) :**
```yaml
stockQuantity: double, default=0      # Quantité totale en litres/kg
minStockAlert: double, default=5
```

**Après (gestion par unités) :**
```yaml
stockQuantity: int, default=0                    # Nombre d'unités complètes NON OUVERTES
minStockAlert: int, default=5                    # Alerte sur nombre d'unités
currentUnitRemaining: double?                     # Quantité restante dans l'unité ENTAMÉE
bulkUnit: String?                                # "litres", "kg", etc.
bulkTotalQuantity: double?                       # Capacité d'une unité (ex: 6L par fût)
```

### Logique de Gestion du Stock

#### État du Stock - Exemple Concret

**Fût de bière Jupiler 6L :**
```
stockQuantity: 5          → 5 fûts complets non ouverts en réserve
currentUnitRemaining: 4.25 → 4.25L restants dans le fût actuellement ouvert
bulkTotalQuantity: 6.0    → Capacité d'un fût = 6 litres

Stock total disponible = (5 × 6L) + 4.25L = 34.25 litres
```

#### Scénarios de Vente

##### Scénario 1 : L'unité entamée suffit
**Client achète 2×50cl = 1 litre**

État avant :
- `stockQuantity = 5` fûts
- `currentUnitRemaining = 4.25L`

Traitement :
```dart
if (currentUnitRemaining >= requiredQuantity) {
  currentUnitRemaining = 4.25 - 1.0 = 3.25L
  // Pas de décompte de fût
}
```

État après :
- `stockQuantity = 5` fûts (inchangé)
- `currentUnitRemaining = 3.25L`

---

##### Scénario 2 : L'unité entamée est insuffisante
**Client achète 10×50cl = 5 litres**

État avant :
- `stockQuantity = 5` fûts
- `currentUnitRemaining = 4.25L`

Traitement :
```dart
if (currentUnitRemaining < requiredQuantity) {
  // Utiliser ce qui reste dans le fût actuel
  usedFromCurrent = 4.25L
  remaining = 5.0 - 4.25 = 0.75L
  
  // Ouvrir un nouveau fût pour compléter
  unitsNeeded = ceil(0.75 / 6.0) = 1 fût
  stockQuantity -= 1  // Décompte 1 fût
  
  // Calculer ce qui reste dans le nouveau fût
  totalFromNewUnit = 1 × 6.0 = 6.0L
  currentUnitRemaining = 6.0 - 0.75 = 5.25L
}
```

État après :
- `stockQuantity = 4` fûts (1 fût ouvert)
- `currentUnitRemaining = 5.25L`

---

##### Scénario 3 : Aucune unité entamée
**Client achète 3×25cl = 0.75L (premier service de la journée)**

État avant :
- `stockQuantity = 5` fûts
- `currentUnitRemaining = null` (aucun fût ouvert)

Traitement :
```dart
if (currentUnitRemaining == null || currentUnitRemaining == 0) {
  unitsNeeded = ceil(0.75 / 6.0) = 1 fût
  stockQuantity -= 1  // Ouverture d'un nouveau fût
  
  totalFromUnit = 1 × 6.0 = 6.0L
  currentUnitRemaining = 6.0 - 0.75 = 5.25L
}
```

État après :
- `stockQuantity = 4` fûts (1 fût ouvert)
- `currentUnitRemaining = 5.25L`

---

#### Scénario 4 : Ouvrir plusieurs unités d'un coup
**Client achète 30×50cl = 15 litres (événement spécial)**

État avant :
- `stockQuantity = 5` fûts
- `currentUnitRemaining = 2.0L`

Traitement :
```dart
usedFromCurrent = 2.0L
remaining = 15.0 - 2.0 = 13.0L

unitsNeeded = ceil(13.0 / 6.0) = 3 fûts
stockQuantity -= 3  // Ouverture de 3 nouveaux fûts

totalFromNewUnits = 3 × 6.0 = 18.0L
currentUnitRemaining = 18.0 - 13.0 = 5.0L
```

État après :
- `stockQuantity = 2` fûts (3 fûts ouverts)
- `currentUnitRemaining = 5.0L`

Notes de mouvement : "Vente 30×50cl (3 unité(s) entamée(s))"

---

### Vérification de Stock Disponible

#### Frontend - Calcul du Stock Total

Les contrôleurs `shop_controller.dart` et `cart_controller.dart` calculent le stock disponible :

```dart
double availableStock = 0.0;

if (product.isBulkProduct && product.bulkTotalQuantity != null) {
  // Stock total = unités complètes + unité entamée
  availableStock = (product.stockQuantity * product.bulkTotalQuantity!) + 
                   (product.currentUnitRemaining ?? 0.0);
  
  // Exemple: (5 × 6L) + 4.25L = 34.25L
  
  if (availableStock < requiredStock) {
    Get.snackbar('Stock insuffisant', 
      'Il ne reste que ${availableStock.toStringAsFixed(2)} ${product.bulkUnit} en stock');
  }
}
```

#### Message Utilisateur

- Produit en vrac : "Il ne reste que **34.25 litres** en stock"
- Produit unitaire : "Il ne reste que **5 unités** en stock"

---

## 🔄 Gestion des Remboursements

### Logique de Restauration du Stock

Lors du remboursement d'une transaction, le stock est restauré dans l'unité entamée :

```dart
if (product.isBulkProduct && item.stockDeduction != null) {
  // Ajouter à l'unité entamée
  product.currentUnitRemaining = (product.currentUnitRemaining ?? 0.0) + item.stockDeduction;
  
  // Si l'unité dépasse la capacité, reconvertir en unités complètes
  if (product.currentUnitRemaining >= product.bulkTotalQuantity!) {
    int completeUnits = (product.currentUnitRemaining / product.bulkTotalQuantity!).floor();
    product.stockQuantity += completeUnits;
    product.currentUnitRemaining -= (completeUnits * product.bulkTotalQuantity!);
  }
}
```

**Exemple :**
- Remboursement de 8L
- `currentUnitRemaining = 4.5L` → devient `12.5L`
- Conversion : 2 fûts complets (12L) + reste 0.5L
- Résultat : `stockQuantity += 2`, `currentUnitRemaining = 0.5L`

---

## 📊 Audit et Traçabilité

### Mouvements de Stock (StockMovement)

Le champ `quantity` reste en `double` pour l'audit trail précis :

```dart
StockMovement(
  productId: product.id!,
  quantity: -0.75,  // Quantité exacte déduite en litres
  movementType: MovementType.sale,
  notes: 'Vente 3×25cl (unité entamée) - Transaction #1234',
)
```

### Notes de Transaction

Les notes de mouvement sont descriptives :
- `"Vente 2×25cl (unité entamée) - Transaction #1234"` → Pas de nouveau fût ouvert
- `"Vente 10×50cl (1 unité(s) ouverte(s)) - Transaction #1235"` → 1 nouveau fût ouvert
- `"Vente 30×50cl (3 unité(s) entamée(s)) - Transaction #1236"` → 3 nouveaux fûts ouverts

---

## 🗄️ Migrations Base de Données

### Migration 20260310102814506

```sql
BEGIN;

-- Modification des colonnes de stock
ALTER TABLE "products" DROP COLUMN "stockQuantity";
ALTER TABLE "products" DROP COLUMN "minStockAlert";

-- Ajout du nouveau champ pour l'unité entamée
ALTER TABLE "products" ADD COLUMN "currentUnitRemaining" double precision;

-- Recréation avec les bons types
ALTER TABLE "products" ADD COLUMN "stockQuantity" bigint NOT NULL DEFAULT 0;
ALTER TABLE "products" ADD COLUMN "minStockAlert" bigint NOT NULL DEFAULT 5;

COMMIT;
```

**⚠️ Impact :**
- Les données de stock existantes sont perdues lors de cette migration
- Nécessite de réinitialiser les stocks après migration
- Migration destructive nécessitant l'option `--force`

---

## 💻 Modifications du Code

### Backend - Endpoints Modifiés

#### 1. TransactionEndpoint - Logique de checkout

**Fichier:** `transaction_endpoint.dart`

**Modifications principales :**
- Détection si produit en vrac avec portions
- Calcul de la quantité requise (portions × taille portion)
- Gestion de l'unité entamée vs ouverture de nouvelles unités
- Tracking du nombre d'unités consommées
- Notes de transaction détaillées

**Code clé :**
```dart
// Calcul de la quantité nécessaire
double requiredQuantity = cartItem.quantity * portion.quantity;

// Vérifier s'il y a une unité entamée
if (product.currentUnitRemaining != null && product.currentUnitRemaining! > 0) {
  if (product.currentUnitRemaining! >= requiredQuantity) {
    // L'unité actuelle suffit
    product.currentUnitRemaining! -= requiredQuantity;
  } else {
    // Besoin d'ouvrir de nouvelles unités
    double remaining = requiredQuantity - product.currentUnitRemaining!;
    int unitsNeeded = (remaining / product.bulkTotalQuantity!).ceil();
    product.stockQuantity -= unitsNeeded;
    // ... calcul du reste
  }
}
```

#### 2. ProductEndpoint - Types de paramètres

**Changements de signatures :**
```dart
// Avant
Future<Product> createProduct(
  Session session,
  double stockQuantity,
  double minStockAlert,
  ...
)

// Après
Future<Product> createProduct(
  Session session,
  int stockQuantity,      // Unités entières
  int minStockAlert,      // Unités entières
  ...
)
```

#### 3. StockEndpoint - Réapprovisionnement

**Changements :**
- `restockProduct(int quantity)` : ajout d'unités complètes
- `adjustStock(int newQuantity)` : définition du nombre d'unités
- StockMovement.quantity reste en double pour audit

### Frontend - Contrôleurs Modifiés

#### 1. ShopController

**Fichier:** `shop_controller.dart`

**Fonction:** `addToCart()`

**Modifications :**
```dart
// Calcul du stock total disponible
double availableStock = 0.0;

if (product.isBulkProduct && product.bulkTotalQuantity != null) {
  availableStock = (product.stockQuantity * product.bulkTotalQuantity!) + 
                   (product.currentUnitRemaining ?? 0.0);
  
  if (availableStock < requiredStock) {
    Get.snackbar('Stock insuffisant', 
      'Il ne reste que ${availableStock.toStringAsFixed(2)} ${product.bulkUnit} en stock');
    return;
  }
}
```

#### 2. CartController

**Fichier:** `cart_controller.dart`

**Fonction:** `updateQuantity()`

**Modifications identiques :**
- Vérification du stock disponible total
- Messages adaptés au type de produit (vrac vs unitaire)

#### 3. Contrôleurs Admin

**Fichiers modifiés :**
- `product_form_controller.dart` : parsing `int` au lieu de `double`
- `products_controller.dart` : dialogue de gestion du stock avec `int`
- `restock_controller.dart` : quantité de réapprovisionnement en `int`
- `stock_controller.dart` : ajustements en `int`

---

## 📦 Repositories

### Création des Dépôts Git

**Date:** 10 mars 2026

#### Dépôts créés sur GitHub

1. **Frontend Flutter**
   - Repository: https://github.com/rorophil/airbar
   - Branche principale: `main`
   - Commits: Initial + Feature + Style formatting

2. **Backend Serverpod**
   - Repository: https://github.com/rorophil/airbar_backend
   - Branche principale: `main`
   - Commits: Initial + Feature + Style formatting

#### Structure des Commits

**Initial Commit (9 mars):**
- Frontend: "Initial commit: AirBar Flutter app with GetX, portions management, and cart system"
- Backend: "Initial commit: AirBar Serverpod backend with PostgreSQL, auth, portions, cart, and stock management"

**Feature Commit (10 mars):**
- Frontend: "feat: Unit-based stock management for bulk products"
- Backend: "feat: Unit-based stock management - portions now use opened units, automatic unit opening when needed"

**Style Commit (10 mars):**
- Frontend: "style: Format code with Dart formatter"
- Backend: "style: Format transaction endpoint with Dart formatter"

#### Fichiers .gitignore

**Frontend (.gitignore existant) :**
- Fichiers générés Flutter/Dart
- Build artifacts
- IDE settings
- OS files

**Backend (.gitignore créé) :**
```
# Dart/Pub
.dart_tool/
.packages
build/

# Serverpod specific
**/config/passwords.yaml
**/config/firebase_service_account_key.json
**/generated/

# Logs
*.log
backend_log.txt
```

---

## 🧪 Tests et Validation

### Scénarios de Test Recommandés

#### Test 1 : Première Vente de la Journée
**Setup:**
- Produit : Fût Jupiler 6L
- Stock : 10 fûts complets
- currentUnitRemaining : null

**Action:** Vendre 2×25cl (0.5L)

**Résultat attendu:**
- stockQuantity : 9 fûts
- currentUnitRemaining : 5.5L
- Note : "Vente 2×25cl (1 unité(s) ouverte(s))"

---

#### Test 2 : Ventes de la même unité
**Setup:**
- Stock : 9 fûts
- currentUnitRemaining : 5.5L

**Actions successives:**
- Vendre 4×25cl (1L) → Reste 4.5L
- Vendre 8×25cl (2L) → Reste 2.5L
- Vendre 10×25cl (2.5L) → Reste 0L (unité épuisée)

**Résultat attendu:**
- stockQuantity : 9 fûts (inchangé, on a fini le fût entamé)
- currentUnitRemaining : 0L

---

#### Test 3 : Ouverture d'un nouveau fût
**Setup:**
- Stock : 9 fûts
- currentUnitRemaining : 0L

**Action:** Vendre 1×25cl (0.25L)

**Résultat attendu:**
- stockQuantity : 8 fûts (1 nouveau fût ouvert)
- currentUnitRemaining : 5.75L
- Note : "Vente 1×25cl (1 unité(s) ouverte(s))"

---

#### Test 4 : Vente massive (événement)
**Setup:**
- Stock : 8 fûts
- currentUnitRemaining : 5.75L

**Action:** Vendre 50×50cl (25L)

**Calcul:**
- Utilise les 5.75L de l'unité actuelle
- Reste à servir : 25 - 5.75 = 19.25L
- Fûts à ouvrir : ceil(19.25 / 6) = 4 fûts
- Total servi depuis nouveaux fûts : 4 × 6 = 24L
- Reste dans le dernier fût : 24 - 19.25 = 4.75L

**Résultat attendu:**
- stockQuantity : 4 fûts (8 - 4)
- currentUnitRemaining : 4.75L
- Note : "Vente 50×50cl (4 unité(s) entamée(s))"

---

#### Test 5 : Stock insuffisant
**Setup:**
- Stock : 2 fûts
- currentUnitRemaining : 3.0L

**Action:** Vendre 40×50cl (20L)

**Calcul:**
- Stock disponible : (2 × 6) + 3 = 15L
- Quantité demandée : 20L

**Résultat attendu:**
- ❌ Transaction bloquée
- Message : "Stock insuffisant pour Fût Jupiler"
- Stock inchangé

---

#### Test 6 : Remboursement simple
**Setup:**
- Transaction #123 : Vente de 4×25cl (1L)
- Stock actuel : 5 fûts, 4.0L entamé

**Action:** Rembourser la transaction #123

**Résultat attendu:**
- stockQuantity : 5 fûts (inchangé)
- currentUnitRemaining : 5.0L (4.0 + 1.0)
- Balance client créditée

---

#### Test 7 : Remboursement avec reconversion
**Setup:**
- Stock actuel : 3 fûts, 5.5L entamé

**Action:** Rembourser 3L

**Résultat attendu:**
- currentUnitRemaining temporaire : 5.5 + 3.0 = 8.5L
- Conversion : 8.5L = 1 fût complet (6L) + 2.5L
- stockQuantity : 4 fûts (3 + 1)
- currentUnitRemaining : 2.5L

---

## 📈 Avantages de la Solution

### Pour la Gestion

✅ **Inventaire physique réaliste**
- Correspond aux unités stockées physiquement
- Facilite les comptages et vérifications

✅ **Réapprovisionnement simplifié**
- Commande en nombre d'unités (fûts, caisses)
- Réception clairement tracée

✅ **Alertes pertinentes**
- Alerte basée sur le nombre d'unités complètes
- "2 fûts restants" plus parlant que "12.5L restants"

### Pour l'Exploitation

✅ **Traçabilité complète**
- Savoir exactement quand un fût est ouvert
- Historique précis des mouvements

✅ **Optimisation des achats**
- Analyse du nombre de fûts consommés par période
- Prévision basée sur des unités entières

✅ **Gestion de la fraîcheur**
- Savoir depuis combien de temps un fût est ouvert
- Rotation FIFO facilitée

### Pour le Système

✅ **Précision comptable**
- Stock physique = stock informatique
- Moins d'écarts d'inventaire

✅ **Flexibilité**
- Fonctionne pour tous types d'unités (fûts, bouteilles, caisses)
- Adaptable à différentes tailles de portions

✅ **Performance**
- Calculs simples et rapides
- Pas de gestion de décimales complexes pour les unités

---

## 🔮 Évolutions Futures Possibles

### 1. Traçabilité avancée par unité
- Numéro de lot par unité
- Date d'ouverture du fût
- Durée de conservation après ouverture
- Alerte de péremption

### 2. Gestion FIFO automatique
- Premier fût ouvert = premier fût à terminer
- File d'attente des unités ouvertes
- Suggestion automatique de l'unité à servir

### 3. Dashboard d'analyse
- Taux de rotation par produit
- Durée moyenne d'un fût ouvert
- Prévisions de réapprovisionnement
- Graphiques de consommation

### 4. Gestion multi-emplacement
- Stockage cave vs bar
- Transfert d'unités entre emplacements
- Inventaire par zone

### 5. Optimisation des prix
- Prix dégressif selon la taille de portion
- Happy hours automatiques
- Promotions sur fins de fûts

---

## 📝 Notes Techniques

### Compatibilité

- ✅ Serverpod 3.3.1
- ✅ Flutter 3.x
- ✅ PostgreSQL 14+
- ✅ Dart 3.x

### Performance

- Temps de génération Serverpod : ~6-8 secondes
- Migration appliquée : < 1 seconde
- Impact sur temps de transaction : négligeable

### Limitations Connues

1. **Migration destructive**
   - Les données de stock existantes sont perdues
   - Nécessite réinitialisation manuelle des stocks

2. **Pas de gestion de multiple unités ouvertes**
   - On suppose qu'une seule unité est ouverte à la fois
   - Pour gérer plusieurs fûts ouverts : évolution future nécessaire

3. **Alertes stock**
   - Basées uniquement sur unités complètes
   - Ne prend pas en compte l'unité entamée

---

## 🎓 Conclusion

Cette refonte majeure transforme la gestion du stock d'un système purement comptable vers un système réaliste reflétant la réalité physique du stockage et de l'exploitation.

**Impact principal :**
- Meilleure correspondance avec la réalité du terrain
- Gestion simplifiée pour les opérateurs
- Traçabilité améliorée
- Base solide pour des évolutions futures

**Prochaines étapes recommandées :**
1. Tests complets sur environnement de staging
2. Formation des utilisateurs au nouveau système
3. Réinitialisation des stocks en production
4. Surveillance des premiers jours d'exploitation

---

**Dernière mise à jour:** 10 mars 2026  
**Auteur:** Documentation automatique  
**Version:** 2.0 - Gestion par unités complètes
