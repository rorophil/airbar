import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/cart_repository.dart';
import '../../../../data/repositories/product_portion_repository.dart';
import '../../../../services/auth_service.dart';

class ShopController extends GetxController {
  final ProductRepository _productRepository = Get.find();
  final CategoryRepository _categoryRepository = Get.find();
  final CartRepository _cartRepository = Get.find();
  final ProductPortionRepository _portionRepository = Get.find();
  final AuthService _authService = Get.find();

  // Observables
  final isLoading = false.obs;
  final categories = <ProductCategory>[].obs;
  final allProducts = <Product>[].obs;
  final filteredProducts = <Product>[].obs;
  final selectedCategoryId = Rxn<int>();
  final searchQuery = ''.obs;
  final cartItemCount = 0.obs;
  final productPortions = <int, List<ProductPortion>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadCartCount();
  }

  /// Load categories and products
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      // Load categories and products in parallel
      final results = await Future.wait([
        _categoryRepository.getAllCategories(forceRefresh: true),
        _productRepository.getActiveProducts(forceRefresh: true),
      ]);

      categories.assignAll(List<ProductCategory>.from(results[0]));
      allProducts.assignAll(List<Product>.from(results[1]));

      // Load portions for bulk products
      await _loadPortionsForBulkProducts();

      // Initial filter
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

  /// Load portions for bulk products
  Future<void> _loadPortionsForBulkProducts() async {
    try {
      final bulkProducts = allProducts.where((p) => p.isBulkProduct).toList();
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

  /// Get portions for a product
  List<ProductPortion> getPortionsForProduct(int productId) {
    return productPortions[productId] ?? [];
  }

  /// Load cart item count
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

  /// Filter products by category and search query
  void filterProducts() {
    var result = allProducts.toList();

    // Filter by category
    if (selectedCategoryId.value != null) {
      result = result
          .where((p) => p.categoryId == selectedCategoryId.value)
          .toList();
    }

    // Filter by search query
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

  /// Select category filter
  void selectCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
    filterProducts();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterProducts();
  }

  /// Add product to cart
  Future<void> addToCart(
    Product product,
    int quantity, {
    int? productPortionId,
  }) async {
    try {
      final userId = _authService.currentUser.value?.id;
      if (userId == null) {
        Get.snackbar(
          'Erreur',
          'Utilisateur non connecté',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check stock availability with actual quantity needed
      double requiredStock = quantity.toDouble();

      if (productPortionId != null) {
        // For bulk products with portions, calculate actual stock needed
        final portions = getPortionsForProduct(product.id!);
        final portion = portions.firstWhereOrNull(
          (p) => p.id == productPortionId,
        );

        if (portion != null) {
          // Calculate actual stock: quantity of portions × quantity per portion
          requiredStock = quantity * portion.quantity;
        }
      }

      if (product.stockQuantity < requiredStock) {
        Get.snackbar(
          'Stock insuffisant',
          'Il ne reste que ${product.stockQuantity.toStringAsFixed(2)} ${product.isBulkProduct ? "litre(s)" : "unité(s)"} en stock',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _cartRepository.addToCart(
        userId: userId,
        productId: product.id!,
        quantity: quantity,
        productPortionId: productPortionId,
      );

      // Update cart count
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

  /// Navigate to cart
  Future<void> goToCart() async {
    await Get.toNamed('/user/cart');
    // Reload cart count when returning from cart
    await loadCartCount();
  }

  /// Navigate to admin dashboard (for admin users)
  void goToAdminDashboard() {
    Get.toNamed('/admin/dashboard');
  }

  /// Check if current user is admin
  bool get isAdmin => _authService.isAdmin;

  /// Get category for a product
  ProductCategory? getCategoryForProduct(Product product) {
    return categories.firstWhereOrNull((cat) => cat.id == product.categoryId);
  }

  /// Get icon for category
  IconData getIconForCategory(ProductCategory? category) {
    if (category == null) return Icons.help_outline;

    // Map category names or iconNames to appropriate icons
    final categoryName = category.name.toLowerCase();
    final iconName = category.iconName?.toLowerCase();

    // Check iconName first if it exists
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
