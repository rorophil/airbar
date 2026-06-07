import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/product_portion_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

/// Classe représentant un article dans le panier de la caisse
///
/// Encapsule un produit, sa quantité et éventuellement une portion (pour les produits en vrac).
/// Fournit des helpers pour calculer le prix effectif et le nom d'affichage.
///
/// Propriétés calculées:
/// - [effectivePrice]: Prix de la portion ou prix du produit de base
/// - [displayName]: Nom avec la portion si applicable (ex: "Bière - 50cl")
/// - [subtotal]: Prix total de la ligne (effectivePrice × quantity)
///
/// Exemples:
/// ```dart
/// // Produit régulier
/// final item = CashSaleItem(product: biere, quantity: 2);
/// // displayName = "Bière", effectivePrice = 3.50, subtotal = 7.00
///
/// // Produit en vrac avec portion
/// final item = CashSaleItem(
///   product: futBiere,
///   quantity: 3,
///   portion: portion50cl
/// );
/// // displayName = "Bière - 50cl", effectivePrice = 2.50, subtotal = 7.50
/// ```
class CashSaleItem {
  /// Le produit commandé
  final Product product;

  /// La quantité commandée (nombre d'unités ou de portions)
  final int quantity;

  /// La portion sélectionnée (pour les produits en vrac uniquement)
  final ProductPortion? portion;

  CashSaleItem({required this.product, required this.quantity, this.portion});

  /// Prix effectif: prix de la portion si définie, sinon prix du produit
  double get effectivePrice => portion?.price ?? product.price;

  /// Nom d'affichage: nom du produit avec portion si applicable
  /// Exemple: "Bière - 50cl" ou simplement "Bière"
  String get displayName =>
      portion != null ? '${product.name} - ${portion!.name}' : product.name;

  /// Sous-total de la ligne: prix effectif × quantité
  double get subtotal => effectivePrice * quantity;
}

/// Controller du module Caisse
class CashierController extends GetxController {
  final _productRepository = ProductRepository();
  final _categoryRepository = CategoryRepository();
  final _portionRepository = Get.find<ProductPortionRepository>();
  final _authService = Get.find<AuthService>();

  // État réactif
  final isLoading = false.obs;
  final products = <Product>[].obs;
  final categories = <ProductCategory>[].obs;
  final cashierCart = <CashSaleItem>[].obs;
  final selectedCategoryId = Rx<int?>(null);
  final searchQuery = ''.obs;

  /// Map des portions par ID de produit (productId → List<ProductPortion>)
  ///
  /// Stocke les portions disponibles pour chaque produit en vrac.
  /// Exemple: productPortions[5] = [Portion(25cl), Portion(50cl), ...]
  /// Utilisé pour afficher les options de taille dans l'interface utilisateur.
  final productPortions = <int, List<ProductPortion>>{}.obs;

  // Getters
  List<Product> get filteredProducts {
    var filtered = products.where((p) => p.isActive).toList();

    // Filter by category
    if (selectedCategoryId.value != null) {
      filtered = filtered
          .where((p) => p.categoryId == selectedCategoryId.value)
          .toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            (p.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  double get total => cashierCart.fold(0.0, (sum, item) => sum + item.subtotal);

  int get sellerId => _authService.currentUser.value!.id!;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Charge les produits et catégories
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // Charger les produits et catégories en parallèle
      final results = await Future.wait([
        _productRepository.getAllProducts(forceRefresh: true),
        _categoryRepository.getAllCategories(forceRefresh: true),
      ]);

      products.value = results[0] as List<Product>;
      categories.value = results[1] as List<ProductCategory>;

      // Charger les portions pour les produits en vrac
      await _loadPortionsForBulkProducts();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les produits: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge les portions pour tous les produits en vrac
  ///
  /// Parcourt tous les produits avec [isBulkProduct] = true et récupère
  /// leurs portions (25cl, 50cl, 1L, etc.) depuis le repository.
  /// Les portions sont stockées dans [productPortions] pour un accès rapide.
  ///
  /// Appelée automatiquement lors du chargement initial des données.
  Future<void> _loadPortionsForBulkProducts() async {
    try {
      final bulkProducts = products.where((p) => p.isBulkProduct).toList();

      for (final product in bulkProducts) {
        if (product.id != null) {
          final portions = await _portionRepository.getProductPortions(
            product.id!,
          );
          productPortions[product.id!] = List<ProductPortion>.from(portions);
        }
      }
    } catch (e) {
      print('Error loading portions: $e');
    }
  }

  /// Récupère les portions disponibles pour un produit donné
  ///
  /// [productId] L'identifiant du produit
  ///
  /// Retourne une liste de portions (ex: 25cl, 50cl pour la bière)
  /// ou une liste vide si le produit n'a pas de portions.
  ///
  /// Exemple d'utilisation dans l'UI:
  /// ```dart
  /// final portions = controller.getPortionsForProduct(product.id!);
  /// if (portions.isNotEmpty) {
  ///   // Afficher les options de portions
  /// }
  /// ```
  List<ProductPortion> getPortionsForProduct(int productId) {
    return productPortions[productId] ?? [];
  }

  /// Ajoute un article au panier de la caisse
  ///
  /// [product] Le produit à ajouter
  /// [quantity] La quantité à ajouter (nombre d'unités ou de portions)
  /// [portionId] (Optionnel) L'ID de la portion pour les produits en vrac
  ///
  /// Processus:
  /// 1. Résout la portion si [portionId] est fourni (produits en vrac)
  /// 2. Vérifie le stock disponible (si [trackStock] = true)
  /// 3. Ajoute au panier ou met à jour la quantité si déjà présent
  /// 4. Affiche un snackbar de confirmation
  ///
  /// Gestion du stock:
  /// - Pour les produits réguliers: compare [quantity] avec [stockQuantity]
  /// - Pour les produits en vrac: calcule le stock total (unités + unité entamée)
  /// - Affiche une erreur si stock insuffisant
  ///
  /// Exemple:
  /// ```dart
  /// // Produit régulier
  /// controller.addToCashierCart(biere, 2);
  ///
  /// // Produit en vrac avec portion
  /// controller.addToCashierCart(futBiere, 3, portionId: portion50cl.id);
  /// ```
  void addToCashierCart(Product product, int quantity, {int? portionId}) {
    // Récupérer la portion si fournie
    ProductPortion? portion;
    if (portionId != null) {
      final portions = getPortionsForProduct(product.id!);
      portion = portions.firstWhereOrNull((p) => p.id == portionId);
    }

    // Vérifier le stock disponible
    if (product.trackStock) {
      double requiredQuantity = quantity.toDouble();
      if (portion != null) {
        requiredQuantity = quantity * portion.quantity;
      }

      double availableStock;
      if (product.isBulkProduct && product.bulkTotalQuantity != null) {
        availableStock =
            (product.stockQuantity * product.bulkTotalQuantity!) +
            (product.currentUnitRemaining ?? 0);
      } else {
        availableStock = product.stockQuantity.toDouble();
      }

      if (availableStock < requiredQuantity) {
        Get.snackbar(
          'Stock insuffisant',
          'Disponible: ${availableStock.toStringAsFixed(2)}${product.bulkUnit ?? ''}, Requis: ${requiredQuantity.toStringAsFixed(2)}${product.bulkUnit ?? ''}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    // Vérifier si l'article existe déjà dans le panier
    final existingIndex = cashierCart.indexWhere(
      (item) =>
          item.product.id == product.id && item.portion?.id == portion?.id,
    );

    if (existingIndex >= 0) {
      // Mettre à jour la quantité
      final existingItem = cashierCart[existingIndex];
      cashierCart[existingIndex] = CashSaleItem(
        product: existingItem.product,
        quantity: existingItem.quantity + quantity,
        portion: existingItem.portion,
      );
    } else {
      // Ajouter nouvel article
      cashierCart.add(
        CashSaleItem(product: product, quantity: quantity, portion: portion),
      );
    }

    Get.snackbar(
      'Ajouté',
      '${quantity}x ${portion != null ? '${product.name} - ${portion.name}' : product.name}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  /// Met à jour la quantité d'un article dans le panier
  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(index);
      return;
    }

    final item = cashierCart[index];

    // Vérifier le stock disponible
    if (item.product.trackStock) {
      double requiredQuantity = newQuantity.toDouble();
      if (item.portion != null) {
        requiredQuantity = newQuantity * item.portion!.quantity;
      }

      double availableStock;
      if (item.product.isBulkProduct &&
          item.product.bulkTotalQuantity != null) {
        availableStock =
            (item.product.stockQuantity * item.product.bulkTotalQuantity!) +
            (item.product.currentUnitRemaining ?? 0);
      } else {
        availableStock = item.product.stockQuantity.toDouble();
      }

      if (availableStock < requiredQuantity) {
        Get.snackbar(
          'Stock insuffisant',
          'Maximum disponible: ${availableStock.toStringAsFixed(2)}${item.product.bulkUnit ?? ''}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    cashierCart[index] = CashSaleItem(
      product: item.product,
      quantity: newQuantity,
      portion: item.portion,
    );
  }

  /// Supprime un article du panier
  void removeFromCart(int index) {
    cashierCart.removeAt(index);
  }

  /// Vide le panier
  void clearCart() {
    Get.defaultDialog(
      title: 'Vider le panier',
      middleText: 'Voulez-vous vraiment vider le panier ?',
      textConfirm: 'Oui',
      textCancel: 'Non',
      onConfirm: () {
        cashierCart.clear();
        Get.back();
      },
    );
  }

  /// Filtre par catégorie
  void filterByCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
  }

  /// Met à jour la recherche
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Navigation vers le checkout
  void goToCheckout() {
    if (cashierCart.isEmpty) {
      Get.snackbar(
        'Panier vide',
        'Ajoutez des articles avant de valider',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      AppRoutes.CASHIER_CHECKOUT,
      arguments: {'cart': cashierCart.toList(), 'total': total},
    );
  }

  /// Retour au dashboard avec confirmation si panier non vide
  void goBackToDashboard() {
    if (cashierCart.isNotEmpty) {
      Get.defaultDialog(
        title: 'Quitter le mode caisse',
        middleText:
            'Le panier contient des articles. Voulez-vous vraiment quitter ?',
        textConfirm: 'Oui',
        textCancel: 'Non',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // Fermer la dialog
          _navigateToDashboard();
        },
      );
    } else {
      _navigateToDashboard();
    }
  }

  /// Navigation robuste vers le dashboard
  void _navigateToDashboard() {
    // Vérifier si l'utilisateur est admin
    if (_authService.currentUser.value?.role == UserRole.admin) {
      // Si admin, aller au dashboard admin
      Get.offAllNamed(AppRoutes.ADMIN_DASHBOARD);
    } else {
      // Sinon, retour à la boutique utilisateur
      Get.offAllNamed(AppRoutes.USER_SHOP);
    }
  }
}
