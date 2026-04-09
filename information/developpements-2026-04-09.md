# Développements du 9 avril 2026

## 🎯 Vue d'ensemble

Plusieurs fonctionnalités importantes ont été ajoutées au système de gestion des utilisateurs et des produits, ainsi qu'une correction critique du système d'authentification. Une nouvelle option permet maintenant de désactiver la gestion de stock pour certains produits (produits en libre service).

---

## 🔧 Corrections de bugs

### Correction du système de login (CRITIQUE)

**Problème :** Les tentatives de connexion échouées provoquaient des erreurs internes du serveur (HTTP 500).

**Cause :** Dans `auth_endpoint.dart`, la méthode `login` lançait des exceptions (`throw Exception()`) puis les relançait avec `rethrow`, ce qui causait des erreurs serveur au lieu de retourner une réponse propre.

**Solution :**
- La méthode `login` retourne maintenant `null` en cas d'échec au lieu de lancer des exceptions
- Les logs indiquent la raison de l'échec pour le débogage
- Le client reçoit une réponse HTTP 200 avec `null` (pas d'erreur serveur)
- Message d'erreur client amélioré : "Email ou mot de passe incorrect, ou compte désactivé"

**Fichiers modifiés :**
- `airbar_backend/airbar_backend_server/lib/src/endpoints/auth/auth_endpoint.dart`
- `airbar/lib/app/data/repositories/auth_repository.dart`

---

## ✨ Nouvelles fonctionnalités

### 1. Réactivation d'utilisateurs désactivés

**Description :** Les administrateurs peuvent désormais réactiver un utilisateur qui a été désactivé précédemment.

**Fonctionnalités :**
- Bouton "Réactiver" (✅ vert) qui remplace le bouton "Désactiver" pour les utilisateurs inactifs
- Dialogue de confirmation avant réactivation
- Les utilisateurs inactifs sont affichés avec :
  - Opacité réduite (50%)
  - Fond gris clair
  - Badge rouge "Utilisateur désactivé"
- Le bouton "Créditer" est désactivé pour les utilisateurs inactifs

**Backend :**
```dart
Future<void> reactivateUser(Session session, int userId) async {
  final user = await protocol.User.db.findById(session, userId);
  user.isActive = true;
  user.updatedAt = DateTime.now();
  await protocol.User.db.updateRow(session, user);
}
```

**Fichiers modifiés :**
- Backend : `airbar_backend_server/lib/src/endpoints/auth/user_endpoint.dart`
- Repository : `airbar/lib/app/data/repositories/user_repository.dart`
- Controller : `airbar/lib/app/modules/admin/users/controllers/users_controller.dart`
- Vue : `airbar/lib/app/modules/admin/users/views/users_view.dart`

---

### 2. Réinitialisation de mot de passe

**Description :** Les administrateurs peuvent réinitialiser le mot de passe de n'importe quel utilisateur.

**Fonctionnalités :**
- Bouton "Réinitialiser mot de passe" 🔓 (orange) sur chaque carte utilisateur
- Dialogue avec deux champs :
  - Nouveau mot de passe
  - Confirmation du mot de passe
- Icônes 👁️ pour afficher/masquer les mots de passe
- Validation :
  - Mot de passe non vide
  - Confirmation identique au mot de passe
- Le mot de passe est hashé avec SHA256 avant stockage

**Backend :**
```dart
Future<void> resetPassword(
  Session session,
  int userId,
  String newPassword,
) async {
  final user = await protocol.User.db.findById(session, userId);
  user.passwordHash = _hashPassword(newPassword);
  user.updatedAt = DateTime.now();
  await protocol.User.db.updateRow(session, user);
}
```

**Controller - Dialogue avec visibilité :**
```dart
StatefulBuilder(
  builder: (context, setState) {
    return AlertDialog(
      // ... champs avec suffixIcon pour toggle visibility
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible
              ? Icons.visibility_off
              : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            isPasswordVisible = !isPasswordVisible;
          });
        },
      ),
    );
  },
)
```

**Fichiers ajoutés/modifiés :**
- Backend : `airbar_backend_server/lib/src/endpoints/auth/user_endpoint.dart`
- Repository : `airbar/lib/app/data/repositories/user_repository.dart`
- Controller : `airbar/lib/app/modules/admin/users/controllers/users_controller.dart`
- Vue : `airbar/lib/app/modules/admin/users/views/users_view.dart`

---

### 3. Réinitialisation du code PIN

**Description :** Les administrateurs peuvent réinitialiser le code PIN de n'importe quel utilisateur.

**Fonctionnalités :**
- Bouton "Réinitialiser code PIN" 📌 (orange foncé) sur chaque carte utilisateur
- Dialogue avec deux champs :
  - Nouveau code PIN
  - Confirmation du code PIN
- Clavier numérique activé automatiquement
- Limite de 6 caractères
- Icônes 👁️ pour afficher/masquer les codes PIN
- Validation :
  - Code PIN non vide
  - Confirmation identique au code PIN
- Le PIN est hashé avec SHA256 avant stockage

**Backend :**
```dart
Future<void> resetPin(
  Session session,
  int userId,
  String newPin,
) async {
  final user = await protocol.User.db.findById(session, userId);
  user.pin = _hashPassword(newPin);
  user.updatedAt = DateTime.now();
  await protocol.User.db.updateRow(session, user);
}
```

**Spécificités du dialogue PIN :**
- `keyboardType: TextInputType.number` - Clavier numérique
- `maxLength: 6` - Limite à 6 caractères
- Même système de visibilité que pour les mots de passe

**Fichiers ajoutés/modifiés :**
- Backend : `airbar_backend_server/lib/src/endpoints/auth/user_endpoint.dart`
- Repository : `airbar/lib/app/data/repositories/user_repository.dart`
- Controller : `airbar/lib/app/modules/admin/users/controllers/users_controller.dart`
- Vue : `airbar/lib/app/modules/admin/users/views/users_view.dart`

---

### 4. Produits sans gestion de stock (trackStock)

**Description :** Possibilité de désactiver la gestion de stock pour certains produits (produits en libre service, produits virtuels, etc.).

**Fonctionnalités :**
- Nouveau champ `trackStock` (boolean, défaut: `true`) dans le modèle Product
- Switch "Gérer le stock" dans le formulaire de création/édition de produit
- Désactivation automatique des champs de stock quand `trackStock = false` :
  - Quantité en stock (grisé avec message ⚠️)
  - Seuil d'alerte (grisé avec message ⚠️)
  - Quantité dans l'unité ouverte pour produits en vrac (grisé avec message ⚠️)
- Affichage adapté dans toute l'application

**Comportement lors de l'achat :**

Pour les produits avec `trackStock = false` :
- ❌ Pas de validation de stock (achat toujours possible)
- ❌ Pas de déduction de stock
- ❌ Pas de création de StockMovement
- ❌ Pas d'alertes de stock faible
- ❌ Pas de restauration de stock lors de remboursement

Pour les produits avec `trackStock = true` (comportement normal) :
- ✅ Validation du stock disponible
- ✅ Déduction du stock après achat
- ✅ Création de StockMovement
- ✅ Alertes de stock faible
- ✅ Restauration du stock lors de remboursement

**Backend - Modèle Product :**
```yaml
# product.spy.yaml
trackStock: bool, default=true # If false, stock management is disabled
```

**Backend - Validation lors du checkout :**
```dart
// transaction_endpoint.dart
if (product.trackStock) {
  // Calculer le stock disponible
  double availableStock;
  if (product.isBulkProduct && ...) {
    availableStock = (product.stockQuantity * product.bulkTotalQuantity!) + 
                     (product.currentUnitRemaining ?? 0);
  } else {
    availableStock = product.stockQuantity.toDouble();
  }
  
  if (availableStock < requiredStockQuantity) {
    throw Exception('Stock insuffisant...');
  }
}
```

**Backend - Déduction de stock :**
```dart
// transaction_endpoint.dart
if (product != null && product.trackStock) {
  // Logique de déduction de stock
  // Création de StockMovement
}
```

**Backend - Endpoints de gestion du stock :**
```dart
// stock_endpoint.dart
if (!product.trackStock) {
  throw Exception('Ce produit n\'a pas de gestion de stock activée');
}
```

**Frontend - Formulaire de produit :**
```dart
// product_form_view.dart
Obx(
  () => SwitchListTile(
    title: const Text('Gérer le stock'),
    subtitle: Text(
      controller.trackStock.value
          ? 'Stock suivi et alertes activées'
          : 'Pas de gestion de stock (produit en libre service)',
    ),
    value: controller.trackStock.value,
    onChanged: (value) {
      controller.trackStock.value = value;
    },
  ),
),
```

**Frontend - Liste des produits :**
```dart
// products_view.dart
Text(
  product.trackStock ? '${product.stockQuantity}' : 'N/A',
  style: TextStyle(
    color: product.trackStock ? stockColor : AppColors.textHint,
  ),
),
```

**Frontend - Gestion du stock :**
```dart
// stock_controller.dart
Color getStockColor(Product product) {
  if (!product.trackStock) {
    return const Color(0xFF9E9E9E); // Grey
  }
  // ... logique normale
}

String getStockStatus(Product product) {
  if (!product.trackStock) {
    return 'Stock non géré';
  }
  // ... logique normale
}
```

**Frontend - Vue de stock :**
```dart
// stock_view.dart - Section seuil d'alerte
Text(
  product.trackStock ? '${product.minStockAlert}' : 'N/A',
  style: TextStyle(
    color: product.trackStock ? AppColors.textPrimary : Colors.grey[400],
  ),
),

// Bouton de réapprovisionnement
if (!product.trackStock)
  Container(
    // Message d'information grisé
    child: Text('Gestion de stock désactivée pour ce produit'),
  )
else
  ElevatedButton(/* Bouton Réapprovisionner */),
```

**Frontend - Protection du réapprovisionnement :**
```dart
// restock_controller.dart
@override
void onInit() {
  super.onInit();
  final args = Get.arguments;
  if (args != null) {
    product = args['product'];
    
    if (product != null && !product!.trackStock) {
      Get.back();
      Get.snackbar(
        'Erreur',
        'La gestion de stock est désactivée pour ce produit',
      );
    }
  }
}
```

**Migration de base de données :**
```sql
-- Migration 20260409193413854
ALTER TABLE "products" ADD COLUMN "trackStock" boolean NOT NULL DEFAULT true;
```

**Fichiers modifiés :**

Backend :
- `airbar_backend_server/lib/src/models/shop/product.spy.yaml`
- `airbar_backend_server/lib/src/endpoints/shop/product_endpoint.dart`
- `airbar_backend_server/lib/src/endpoints/stock/stock_endpoint.dart`
- `airbar_backend_server/lib/src/endpoints/transactions/transaction_endpoint.dart`
- `airbar_backend_server/migrations/20260409193413854/` (nouvelle migration)

Frontend :
- `airbar/lib/app/data/repositories/product_repository.dart`
- `airbar/lib/app/modules/admin/products/controllers/product_form_controller.dart`
- `airbar/lib/app/modules/admin/products/views/product_form_view.dart`
- `airbar/lib/app/modules/admin/products/views/products_view.dart`
- `airbar/lib/app/modules/admin/stock/controllers/stock_controller.dart`
- `airbar/lib/app/modules/admin/stock/controllers/restock_controller.dart`
- `airbar/lib/app/modules/admin/stock/views/stock_view.dart`

**Branches Git :**
- Backend : `feature/track-stock-option` (commit: afb6672)
- Frontend : `feature/track-stock-option` (commit: a338bae)

---

## 🎨 Améliorations de l'interface utilisateur

### Carte utilisateur - Nouvelle disposition

**Ligne 1 - Informations principales :**
- Avatar avec initiales
- Nom, prénom, email
- Badge de rôle (Admin/User)

**Ligne 2 - Solde :**
- Icône portefeuille
- Montant du solde

**Ligne 3 - Actions principales :**
- Bouton "Créditer" (vert)
- Bouton "Modifier" (bleu)
- Bouton "Désactiver" (rouge) OU "Réactiver" (vert) selon l'état
- Bouton "Supprimer définitivement" (rouge foncé)

**Ligne 4 - Actions de sécurité :**
- Bouton "Réinitialiser mot de passe" (orange)
- Bouton "Réinitialiser code PIN" (orange foncé)

### Indicateurs visuels des utilisateurs inactifs

- **Opacité :** 50% (via `Opacity` widget)
- **Couleur de fond :** Gris clair (`Colors.grey.shade200`)
- **Badge :** Rouge avec icône de blocage et texte "Utilisateur désactivé"
- **Actions limitées :** Le bouton "Créditer" est désactivé

---

## 🔐 Sécurité

### Hashing des données sensibles

Toutes les données sensibles (mots de passe et codes PIN) sont hashées avec SHA256 :

```dart
String _hashPassword(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

### Logs de sécurité

Les actions de sécurité sont loguées côté serveur :
- `session.log('Password reset for user ${user.id}', level: LogLevel.info);`
- `session.log('PIN reset for user ${user.id}', level: LogLevel.info);`
- `session.log('Login failed: incorrect password for user ${user.id}', level: LogLevel.info);`

---

## 📊 Workflow de gestion des utilisateurs

### Cas d'usage : Utilisateur qui a oublié ses identifiants

1. **Admin ouvre la liste des utilisateurs**
2. **Trouve l'utilisateur concerné**
3. **Clique sur "Réinitialiser mot de passe"** ou **"Réinitialiser code PIN"**
4. **Entre et confirme le nouveau mot de passe/PIN** (avec possibilité de visualiser)
5. **Valide**
6. **L'utilisateur peut se connecter avec ses nouveaux identifiants**

### Cas d'usage : Réactivation d'un compte

1. **Admin voit un utilisateur grisé avec badge "Utilisateur désactivé"**
2. **Clique sur le bouton "Réactiver" (✅ vert)**
3. **Confirme dans le dialogue**
4. **L'utilisateur redevient actif** et peut se connecter

---

## 📊 Workflow de gestion des produits

### Cas d'usage : Création d'un produit en libre service

1. **Admin ouvre la liste des produits**
2. **Clique sur "Nouveau produit"**
3. **Remplit les informations de base** (nom, prix, catégorie)
4. **Désactive le switch "Gérer le stock"**
5. **Les champs de stock deviennent grisés** avec message ⚠️
6. **Enregistre le produit**
7. **Le produit est disponible à l'achat sans limite de quantité**

### Cas d'usage : Conversion d'un produit géré vers non géré

1. **Admin souhaite passer un produit en libre service** (ex: café, eau)
2. **Ouvre la modification du produit**
3. **Désactive "Gérer le stock"**
4. **Enregistre**
5. **Le produit n'apparaît plus dans les alertes de stock**
6. **Le bouton "Réapprovisionner" devient un message d'information**
7. **Les achats ne déduisent plus le stock**

### Cas d'usage : Affichage des produits sans gestion de stock

**Liste des produits :**
- Icône de stock grisée
- Affiche "N/A" au lieu de la quantité
- Badge "Actif" normal

**Vue Stock :**
- Couleur grise pour l'indicateur de stock
- Statut "Stock non géré"
- Seuil d'alerte affiché en "N/A" avec fond grisé
- Bouton "Réapprovisionner" remplacé par message d'info
- Exclus des alertes de stock faible

**Lors d'un achat :**
- Produit disponible à l'achat normalement
- Aucune vérification de stock
- Aucune déduction après l'achat
- Transaction créée normalement mais sans StockMovement

---

## 🧪 Tests recommandés

### Test 1 : Login échoué
- ✅ Tenter de se connecter avec un mauvais mot de passe
- ✅ Vérifier qu'aucune erreur serveur n'apparaît (pas de HTTP 500)
- ✅ Vérifier le message d'erreur côté client

### Test 2 : Réactivation d'utilisateur
- ✅ Désactiver un utilisateur
- ✅ Vérifier l'affichage grisé avec badge
- ✅ Réactiver l'utilisateur
- ✅ Vérifier que l'utilisateur peut se connecter à nouveau

### Test 3 : Réinitialisation de mot de passe
- ✅ Cliquer sur "Réinitialiser mot de passe"
- ✅ Tester la visibilité du mot de passe (icône œil)
- ✅ Tester la validation (champs vides, confirmation incorrecte)
- ✅ Réinitialiser avec succès
- ✅ Se connecter avec le nouveau mot de passe

### Test 4 : Réinitialisation de code PIN
- ✅ Cliquer sur "Réinitialiser code PIN"
- ✅ Vérifier le clavier numérique
- ✅ Vérifier la limite de 6 caractères
- ✅ Tester la visibilité du PIN (icône œil)
- ✅ Réinitialiser avec succès
- ✅ Utiliser le nouveau PIN au checkout

### Test 5 : Produit sans gestion de stock
- ✅ Créer un nouveau produit avec "Gérer le stock" désactivé
- ✅ Vérifier que les champs de stock sont grisés avec messages ⚠️
- ✅ Vérifier l'affichage "N/A" dans la liste des produits
- ✅ Vérifier que le produit n'apparaît pas dans les alertes de stock faible
- ✅ Acheter le produit et vérifier qu'aucun stock n'est déduit
- ✅ Vérifier qu'aucun StockMovement n'est créé
- ✅ Dans la vue Stock, vérifier l'affichage grisé et le message "Stock non géré"
- ✅ Vérifier que le bouton "Réapprovisionner" est remplacé par un message d'info

### Test 6 : Activation/désactivation de la gestion de stock
- ✅ Créer un produit avec gestion de stock activée
- ✅ Modifier le produit pour désactiver la gestion de stock
- ✅ Vérifier que l'interface s'adapte correctement
- ✅ Réactiver la gestion de stock
- ✅ Vérifier le retour au comportement normal

---

## 📝 Notes techniques

### Génération du code Serverpod

Après chaque modification des endpoints backend, exécuter :
```bash
cd airbar_backend/airbar_backend_server
serverpod generate
```

Puis synchroniser le client Flutter :
```bash
cd ../../airbar
flutter pub get
```

### Pattern utilisé : StatefulBuilder

Pour gérer l'état local de visibilité des mots de passe/PIN dans les dialogues :
```dart
StatefulBuilder(
  builder: (context, setState) {
    // setState local au dialogue, pas au controller
    return AlertDialog(...);
  },
)
```

Avantage : Pas besoin d'observables GetX pour un état temporaire de dialogue.

---

## 🚀 Déploiement

### Checklist avant déploiement

- [x] Code backend généré avec `serverpod generate`
- [x] Dépendances Flutter synchronisées
- [x] Pas d'erreurs de compilation
- [x] Logs de sécurité en place
- [x] Validation des saisies utilisateur
- [x] Messages d'erreur clairs et en français
- [x] Migration de base de données créée (20260409193413854)

### Redémarrage requis

- ✅ Serveur backend (pour les nouvelles méthodes ET appliquer la migration)
- ✅ Application Flutter (pour les nouvelles interfaces)

### Migration de base de données

La migration `20260409193413854` sera appliquée automatiquement au démarrage du serveur :
```bash
cd airbar_backend/airbar_backend_server
dart run bin/main.dart --apply-migrations
```

**⚠️ Important :** La migration ajoute la colonne `trackStock` avec une valeur par défaut `true` pour tous les produits existants, ce qui maintient le comportement actuel.

---

## 📚 Documentation associée

- Guide principal : `/information/documentation-complete.md`
- Guide Docker : `/information/guide-docker-dockerfile-compose.md`
- Instructions Copilot : `/.github/copilot-instructions.md`

---

## 👥 Impact utilisateurs

### Pour les administrateurs
- ✅ Plus de contrôle sur les comptes utilisateurs
- ✅ Gestion simplifiée des mots de passe/PIN oubliés
- ✅ Possibilité de réactiver des comptes sans intervention technique
- ✅ Interface intuitive avec indicateurs visuels clairs
- ✅ Flexibilité pour gérer des produits en libre service sans contraintes de stock
- ✅ Distinction visuelle claire entre produits gérés et non gérés

### Pour les utilisateurs finaux
- ✅ Récupération rapide en cas d'oubli de mot de passe/PIN
- ✅ Pas besoin de contacter le support technique
- ✅ Comptes désactivés peuvent être réactivés facilement
- ✅ Disponibilité garantie pour les produits en libre service (jamais de rupture)

---

**Développements réalisés le 9 avril 2026**  
**Version du projet : AirBar 1.0 (post-évolution stock)**

---

## 📌 Résumé des fonctionnalités ajoutées

### Gestion des utilisateurs
1. ✅ Correction critique du système de login (HTTP 500 → HTTP 200)
2. ✅ Réactivation d'utilisateurs désactivés
3. ✅ Réinitialisation de mot de passe par l'admin
4. ✅ Réinitialisation de code PIN par l'admin

### Gestion des produits
5. ✅ Option pour désactiver la gestion de stock (`trackStock`)
   - Produits en libre service
   - Pas de validation de stock lors de l'achat
   - Pas de déduction de stock
   - Interface adaptée avec indicateurs visuels

### Base de données
- Migration `20260409193413854` : Ajout colonne `trackStock`

### Git
- Branches : `feature/track-stock-option`
- Commits :
  - Backend : `afb6672` - feat: add trackStock field to Product model
  - Frontend : `a338bae` - feat: add UI support for trackStock field
