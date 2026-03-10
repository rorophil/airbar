# Guide : Gestion des Produits au Détail / en Vrac

## Vue d'ensemble

Cette fonctionnalité permet de gérer des produits vendus au détail avec plusieurs portions à des prix différents. 
Exemple typique : une bière en fût de 6 litres qui peut être servie en portions de 25cl, 33cl ou 50cl.

## Caractéristiques principales

### 1. Produits en vrac
- **Type de produit** : Activation d'un mode "produit au détail/en vrac"
- **Unité de mesure** : Définition de l'unité (litres, kg, ml, etc.)
- **Quantité totale** : Volume ou poids total par unité de stock (ex: 6 litres pour un fût)

### 2. Portions multiples
- Chaque produit en vrac peut avoir plusieurs portions
- Chaque portion définit :
  - Un nom (ex: "25cl", "33cl", "50cl")
  - Une quantité dans l'unité de base (ex: 0.25, 0.33, 0.50 litres)
  - Un prix spécifique

## Utilisation

### Création d'un produit en vrac

1. **Ouvrir le formulaire de produit**
   - Aller dans Admin → Produits
   - Cliquer sur "Nouveau produit"

2. **Remplir les informations de base**
   - Nom du produit (ex: "Fût Jupiler")
   - Description
   - Catégorie
   - Prix de base (optionnel si vous utilisez des portions)
   - Quantité en stock (nombre d'unités, ex: 3 fûts)
   - Seuil d'alerte

3. **Activer le mode "Produit au détail / en vrac"**
   - Basculer le switch "Produit au détail / en vrac"
   
4. **Définir l'unité et la quantité**
   - Unité de mesure : "litres" (ou kg, ml, etc.)
   - Quantité totale par unité : "6" (pour un fût de 6 litres)

5. **Ajouter les portions**
   - Cliquer sur le bouton "+" dans la section Portions
   - Pour chaque portion, saisir :
     * Nom : "25cl", "33cl", "50cl"
     * Quantité : 0.25, 0.33, 0.50
     * Prix : 2.50€, 3.00€, 4.00€
   - Cliquer sur "Confirmer"
   - Répéter pour chaque portion

6. **Enregistrer le produit**

### Exemple concret : Fût de bière Jupiler

```
Nom : Fût Jupiler
Description : Bière blonde belge en fût
Catégorie : Bières
Stock : 5 fûts
Seuil d'alerte : 2

Mode vrac : ✓ Activé
Unité : litres
Quantité totale : 6

Portions :
- 25cl → 0.25 litres → 2.50€
- 33cl → 0.33 litres → 3.00€
- 50cl → 0.50 litres → 4.00€
```

## Gestion du stock

### Stock en unités complètes
Le stock est géré en nombre d'unités complètes (ex: nombre de fûts).
- Stock = 5 signifie 5 fûts de 6 litres = 30 litres disponibles

### Déduction lors de la vente
Lors de la vente d'une portion :
- Le système calcule combien de "quantité totale" a été consommée
- Exemple : vente de 10 x 25cl = 2.5 litres consommés
- Si c'était le seul fût entamé : reste 3.5 litres (soit 58% d'un fût)

*Note : La gestion détaillée du stock partiel sera implémentée dans une future mise à jour.*

## Structure technique

### Modèles de données

#### Product (modifié)
```dart
class Product {
  // ... champs existants
  bool isBulkProduct;          // Indique si c'est un produit en vrac
  String? bulkUnit;            // Unité de mesure (litres, kg, etc.)
  double? bulkTotalQuantity;   // Quantité totale par unité
}
```

#### ProductPortion (nouveau)
```dart
class ProductPortion {
  int productId;       // Référence au produit
  String name;         // Nom de la portion
  double quantity;     // Quantité en unité de base
  double price;        // Prix de cette portion
  int displayOrder;    // Ordre d'affichage
  bool isActive;       // Portion active/inactive
}
```

### Endpoints API

#### ProductEndpoint
- `createProduct()` : paramètres supplémentaires pour produits en vrac
- `updateProduct()` : gestion des champs bulk

#### ProductPortionEndpoint (nouveau)
- `getProductPortions(productId)` : récupérer toutes les portions
- `createPortion()` : créer une portion
- `updatePortion()` : modifier une portion
- `deletePortion()` : désactiver une portion
- `createMultiplePortions()` : créer plusieurs portions en une fois

### Repositories

#### ProductRepository (modifié)
- Paramètres supplémentaires pour `createProduct()` et `updateProduct()`

#### ProductPortionRepository (nouveau)
- Méthodes pour gérer les portions

## Migration de base de données

La migration `20260309171908034` a été créée et contient :
- Création de la table `product_portions`
- Ajout des colonnes `isBulkProduct`, `bulkUnit`, `bulkTotalQuantity` à `products`

Pour appliquer la migration :
```bash
cd airbar_backend/airbar_backend_server
serverpod create-migration  # Déjà fait
# Puis appliquer via votre système de migration
```

## Limitations actuelles

1. **Gestion du stock partiel** : Le stock est géré en unités complètes
2. **Historique des ventes par portion** : À implémenter
3. **Calcul automatique du stock restant** : À développer

## Évolutions futures

- Gestion détaillée du stock partiel (fûts entamés)
- Tableau de bord des ventes par portion
- Alertes quand une unité est bientôt vide
- Gestion des pertes (fond de fût, etc.)
- Import/export CSV de produits avec portions
