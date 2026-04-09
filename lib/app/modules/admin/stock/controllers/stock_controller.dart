import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/stock_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../services/auth_service.dart';
import '../../../../routes/app_routes.dart';

class StockController extends GetxController {
  final StockRepository _stockRepository = Get.find();
  final ProductRepository _productRepository = Get.find();
  final AuthService _authService = Get.find();

  // Observables
  final isLoading = false.obs;
  final products = <Product>[].obs;
  final lowStockProducts = <Product>[].obs;
  final searchQuery = ''.obs;
  final filteredProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData(forceRefresh: true);
  }

  /// Load products and stock data
  Future<void> loadData({bool forceRefresh = false}) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      // Load all products
      final allProducts = await _productRepository.getAllProducts(
        forceRefresh: forceRefresh,
      );

      products.value = List<Product>.from(allProducts);

      // Filter products with low stock (only for products with stock tracking enabled)
      lowStockProducts.value = products.where((product) {
        return product.trackStock &&
            product.stockQuantity <= product.minStockAlert;
      }).toList();

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

  /// Filter products by search query
  void filterProducts() {
    if (searchQuery.value.isEmpty) {
      filteredProducts.value = products;
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredProducts.value = products.where((product) {
        return product.name.toLowerCase().contains(query) ||
            (product.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterProducts();
  }

  /// Navigate to restock product
  void restockProduct(Product product) {
    Get.toNamed(
      AppRoutes.ADMIN_STOCK_RESTOCK,
      arguments: {'product': product},
    )?.then((result) {
      if (result == true) {
        loadData(forceRefresh: true);
      }
    });
  }

  /// Adjust stock
  Future<void> adjustStock({
    required Product product,
    required int adjustment,
    required String reason,
  }) async {
    try {
      final adminUser = _authService.currentUser.value;
      if (adminUser == null) {
        Get.snackbar(
          'Erreur',
          'Utilisateur non connecté',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _stockRepository.adjustStock(
        productId: product.id!,
        adjustment: adjustment,
        reason: reason,
        adminUserId: adminUser.id!,
      );

      Get.snackbar(
        'Succès',
        'Stock ajusté avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadData(forceRefresh: true);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajuster le stock: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get stock status
  String getStockStatus(Product product) {
    if (!product.trackStock) {
      return 'Stock non géré';
    }
    if (product.stockQuantity == 0) {
      return 'Rupture';
    } else if (product.stockQuantity <= product.minStockAlert) {
      return 'Stock faible';
    } else {
      return 'Stock OK';
    }
  }

  /// Get stock color
  Color getStockColor(Product product) {
    if (!product.trackStock) {
      return const Color(0xFF9E9E9E); // Grey - Stock not tracked
    }
    if (product.stockQuantity == 0) {
      return const Color(0xFFF44336); // Red
    } else if (product.stockQuantity <= product.minStockAlert) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFF4CAF50); // Green
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadData(forceRefresh: true);
  }
}
