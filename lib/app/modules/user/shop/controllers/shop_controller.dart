import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/cart_repository.dart';
import '../../../../data/repositories/product_portion_repository.dart';
import '../../../../services/auth_service.dart';

/// Controller du module Shop (Boutique utilisateur)
///
/// Gère l'affichage et le filtrage des produits disponibles à la vente.
/// Permet aux utilisateurs de parcourir le catalogue, rechercher des produits
/// et les ajouter au panier.
///
/// État géré:
/// - [isLoading]: Indicateur de chargement des données
/// - [categories]: Liste des catégories de produits
/// - [allProducts]: Tous les produits actifs (non supprimés)
/// - [filteredProducts]: Produits filtrés selon catégorie et recherche
/// - [selectedCategoryId]: ID de la catégorie sélectionnée (null = toutes)
/// - [searchQuery]: Texte de recherche
/// - [cartItemCount]: Nombre d'articles dans le panier (badge)
/// - [productPortions]: Map des portions par produit (pour produits en vrac)
///
/// Opérations principales:
/// - [loadData()]: Charge catégories + produits + portions
/// - [filterProducts()]: Filtre selon catégorie et recherche
/// - [addToCart()]: Ajoute un produit au panier (avec gestion de portions)
/// - [loadCartCount()]: Met à jour le badge du panier
class ShopController extends GetxController {
  /// Repository pour les opérations sur les produits
  final ProductRepository _productRepository = Get.find();

  /// Repository pour les catégories
  final CategoryRepository _categoryRepository = Get.find();

  /// Repository pour le panier
  final CartRepository _cartRepository = Get.find();

  /// Repository pour les portions de produits en vrac
  final ProductPortionRepository _portionRepository = Get.find();

  /// Service d'authentification (utilisateur connecté)
  final AuthService _authService = Get.find();

  /// Indicateur de chargement des données
  final isLoading = false.obs;

  /// Liste de toutes les catégories disponibles
  final categories = <ProductCategory>[].obs;

  /// Liste de tous les produits actifs (isActive = true)
  final allProducts = <Product>[].obs;

  /// Liste des produits filtrés selon la catégorie et la recherche
  final filteredProducts = <Product>[].obs;

  /// ID de la catégorie sélectionnée (null = toutes les catégories)
  final selectedCategoryId = Rxn<int>();

  /// Texte de recherche pour filtrer les produits
  final searchQuery = ''.obs;

  /// Nombre d'articles dans le panier (pour le badge)
  final cartItemCount = 0.obs;

  /// Map des portions par ID de produit (productId → List<ProductPortion>)
  final productPortions = <int, List<ProductPortion>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Chargement initial des données
    loadData();
    loadCartCount();
  }

  /// Charger les catégories, produits et portions
  ///
  /// Processus:
  /// 1. Charge en parallèle les catégories et produits actifs (forceRefresh)
  /// 2. Charge les portions pour tous les produits en vrac (boucle async)
  /// 3. Applique le filtre initial (affiche tous les produits)
  ///
  /// Utilise forceRefresh: true pour éviter les problèmes de cache.
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // Chargement parallèle pour optimiser les performances
      final results = await Future.wait([
        _categoryRepository.getAllCategories(forceRefresh: true),
        _productRepository.getActiveProducts(forceRefresh: true),
      ]);

      // Assignation des résultats
      categories.assignAll(List<ProductCategory>.from(results[0]));
      allProducts.assignAll(List<Product>.from(results[1]));

      // Chargement des portions pour les produits en vrac
      await _loadPortionsForBulkProducts();

      // Filtre initial (affiche tous les produits)
      filterProducts();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les données: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Charger les portions pour les produits en vrac
  ///
  /// Pour chaque produit avec isBulkProduct = true, charge la liste
  /// des portions disponibles (ex: 25cl, 50cl, 1L pour la bière).
  ///
  /// Stocke le résultat dans productPortions[productId].
  Future<void> _loadPortionsForBulkProducts() async {
    try {
      // Récupération de tous les produits en vrac
      final bulkProducts = allProducts.where((p) => p.isBulkProduct).toList();

      // Chargement des portions pour chaque produit
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

  /// Récupérer les portions d'un produit
  ///
  /// [productId] ID du produit
  ///
  /// Retourne la liste des portions si le produit en a, sinon liste vide.
  /// Utilisé dans l'UI pour afficher les options de taille (25cl, 50cl, etc.).
  List<ProductPortion> getPortionsForProduct(int productId) {
    return productPortions[productId] ?? [];
  }

  /// Charger le nombre d'articles dans le panier
  ///
  /// Récupère le panier de l'utilisateur connecté et met à jour
  /// le badge affiché sur l'icône panier.
  ///
  /// Appelé au chargement et après chaque ajout au panier.
  Future<void> loadCartCount() async {
    try {
      final userId = _authService.currentUser.value?.id;
      if (userId != null) {
        final cartItems = await _cartRepository.getUserCart(userId);
        cartItemCount.value = cartItems.length;
      }
    } catch (e) {
      print('Error loading cart count: $e');
    }
  }

  /// Filtrer les produits selon la catégorie et la recherche
  ///
  /// Applique deux filtres successifs:
  /// 1. Filtre par catégorie (si selectedCategoryId != null)
  /// 2. Filtre par texte de recherche (nom ou description)
  ///
  /// Le résultat est stocké dans filteredProducts (observable).
  void filterProducts() {
    var result = allProducts.toList();

    // Filtre par catégorie
    if (selectedCategoryId.value != null) {
      result = result
          .where((p) => p.categoryId == selectedCategoryId.value)
          .toList();
    }

    // Filtre par recherche (insensible à la casse)
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                (p.description?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    filteredProducts.assignAll(result);
  }

  /// Sélectionner une catégorie pour le filtre
  ///
  /// [categoryId] ID de la catégorie (null = toutes les catégories)
  ///
  /// Appelle filterProducts() pour mettre à jour l'affichage.
  void selectCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
    filterProducts();
  }

  /// Mettre à jour le texte de recherche
  ///
  /// [query] Texte saisi par l'utilisateur
  ///
  /// Appelle filterProducts() pour mettre à jour l'affichage en temps réel.
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterProducts();
  }

  /// Ajouter un produit au panier
  ///
  /// [product] Le produit à ajouter
  /// [quantity] Nombre d'unités ou de portions
  /// [productPortionId] ID de la portion (optionnel, pour produits en vrac)
  ///
  /// Processus:
  /// 1. Vérification de l'authentification
  /// 2. Calcul du stock requis (avec portions si applicable)
  /// 3. Validation du stock disponible:
  ///    - Produits en vrac: stock total = (stockQuantity × bulkTotalQuantity) + currentUnitRemaining
  ///    - Produits réguliers: stock total = stockQuantity
  /// 4. Ajout au panier via CartRepository
  /// 5. Mise à jour du badge panier
  ///
  /// IMPORTANT: Pour les produits en vrac avec portions, la quantité demandée
  /// est multipliée par la quantité de la portion (ex: 2 portions de 50cl = 1L requis).
  Future<void> addToCart(
    Product product,
    int quantity, {
    int? productPortionId,
  }) async {
    try {
      // Vérification de l'authentification
      final userId = _authService.currentUser.value?.id;
      if (userId == null) {
        Get.snackbar(
          'Erreur',
          'Utilisateur non connecté',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Calcul du stock requis (quantité réelle nécessaire)
      double requiredStock = quantity.toDouble();

      if (productPortionId != null) {
        // Pour les produits en vrac avec portions:
        // requiredStock = nombre de portions × quantité par portion
        // Ex: 2 portions de 50cl = 2 × 0.5L = 1.0L requis
        final portions = getPortionsForProduct(product.id!);
        final portion = portions.firstWhereOrNull(
          (p) => p.id == productPortionId,
        );

        if (portion != null) {
          requiredStock = quantity * portion.quantity;
        }
      }

      // Calcul du stock total disponible
      double availableStock = 0.0;

      if (product.isBulkProduct && product.bulkTotalQuantity != null) {
        // Produits en vrac: total = (unités complètes × capacité) + unité entamée
        // Ex: 5 fûts de 6L + 4.25L ouvert = (5 × 6) + 4.25 = 34.25L
        availableStock =
            (product.stockQuantity * product.bulkTotalQuantity!) +
            (product.currentUnitRemaining ?? 0.0);

        // Vérification du stock disponible
        if (availableStock < requiredStock) {
          Get.snackbar(
            'Stock insuffisant',
            'Il ne reste que ${availableStock.toStringAsFixed(2)} ${product.bulkUnit ?? "L"} en stock',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      } else {
        // Produits réguliers: validation directe sur stockQuantity
        if (product.stockQuantity < quantity) {
          Get.snackbar(
            'Stock insuffisant',
            'Il ne reste que ${product.stockQuantity} unité(s) en stock',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      // Ajout au panier via le repository
      await _cartRepository.addToCart(
        userId: userId,
        productId: product.id!,
        quantity: quantity,
        productPortionId: productPortionId,
      );

      // Mise à jour du badge panier
      await loadCartCount();

      Get.snackbar(
        'Succès',
        '${product.name} ajouté au panier',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter au panier: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Naviguer vers le panier
  ///
  /// Après le retour du panier, recharge le nombre d'articles (badge).
  Future<void> goToCart() async {
    await Get.toNamed('/user/cart');
    // Rechargement du badge après modification du panier
    await loadCartCount();
  }

  /// Naviguer vers le dashboard administrateur
  ///
  /// Accessible uniquement si l'utilisateur connecté a le rôle admin.
  /// Permet aux admins d'accéder à la gestion sans se déconnecter.
  void goToAdminDashboard() {
    Get.toNamed('/admin/dashboard');
  }

  /// Vérifie si l'utilisateur connecté est administrateur
  ///
  /// Utilisé pour afficher/masquer le bouton d'accès au dashboard admin.
  bool get isAdmin => _authService.isAdmin;

  /// Récupérer la catégorie d'un produit
  ///
  /// [product] Le produit dont on veut la catégorie
  ///
  /// Retourne la catégorie correspondante ou null si non trouvée.
  ProductCategory? getCategoryForProduct(Product product) {
    return categories.firstWhereOrNull((cat) => cat.id == product.categoryId);
  }

  /// Récupérer l'icône appropriée pour une catégorie
  ///
  /// [category] La catégorie (peut être null)
  ///
  /// Retourne l'IconData correspondant au nom de la catégorie.
  /// Mapping:
  /// - Bière → Icons.sports_bar
  /// - Soft/Boissons → Icons.local_drink
  /// - Snacks → Icons.fastfood
  /// - Etc.
  ///
  /// Par défaut: Icons.help_outline
  IconData getIconForCategory(ProductCategory? category) {
    if (category == null) return Icons.help_outline;

    // Mapping nom/iconName → icône
    final categoryName = category.name.toLowerCase();
    final iconName = category.iconName?.toLowerCase();

    // Vérification de iconName en priorité
    if (iconName != null) {
      switch (iconName) {
        case 'beer':
        case 'biere':
          return Icons.sports_bar;
        case 'wine':
        case 'vin':
          return Icons.wine_bar;
        case 'cocktail':
          return Icons.local_bar;
        case 'soft':
        case 'soda':
          return Icons.local_drink;
        case 'coffee':
        case 'cafe':
          return Icons.local_cafe;
        case 'snack':
        case 'food':
        case 'nourriture':
          return Icons.fastfood;
        case 'dessert':
          return Icons.cake;
        case 'water':
        case 'eau':
          return Icons.water_drop;
      }
    }

    // Fallback to category name
    if (categoryName.contains('bière') || categoryName.contains('beer')) {
      return Icons.sports_bar;
    } else if (categoryName.contains('vin') || categoryName.contains('wine')) {
      return Icons.wine_bar;
    } else if (categoryName.contains('cocktail')) {
      return Icons.local_bar;
    } else if (categoryName.contains('soft') || categoryName.contains('soda')) {
      return Icons.local_drink;
    } else if (categoryName.contains('café') ||
        categoryName.contains('coffee')) {
      return Icons.local_cafe;
    } else if (categoryName.contains('snack') ||
        categoryName.contains('nourriture')) {
      return Icons.fastfood;
    } else if (categoryName.contains('dessert') ||
        categoryName.contains('gâteau')) {
      return Icons.cake;
    } else if (categoryName.contains('eau') || categoryName.contains('water')) {
      return Icons.water_drop;
    } else if (categoryName.contains('sans catégorie') ||
        categoryName.contains('uncategorized')) {
      return Icons.help_outline;
    }

    // Default icon
    return Icons.local_drink;
  }

  /// Logout
  void logout() {
    Get.defaultDialog(
      title: 'Déconnexion',
      middleText: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      textCancel: 'Annuler',
      textConfirm: 'Déconnexion',
      onConfirm: () {
        _authService.clearUser();
        Get.offAllNamed('/login');
      },
    );
  }

  /// Refresh data
  Future<void> refresh() async {
    await _authService.refreshUser();
    await loadData();
    await loadCartCount();
  }
}
