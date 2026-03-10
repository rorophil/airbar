import 'package:get/get.dart';
import '../../services/storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository for product operations
class ProductRepository {
  Client get _client => ServerpodClientProvider.client;
  final _storageService = Get.find<StorageService>();

  /// Get all products
  Future<List<dynamic>> getAllProducts({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = _storageService.read(AppConstants.keyProducts);
        if (cached != null) {
          return cached as List<dynamic>;
        }
      }

      // Fetch from server
      final products = await _client.product.getAllProducts(
        includeDeleted: false,
      );

      // Cache the result
      _storageService.write(AppConstants.keyProducts, products);

      return products;
    } catch (e) {
      print('Get all products error: $e');
      rethrow;
    }
  }

  /// Get products by category
  Future<List<dynamic>> getProductsByCategory(
    int categoryId, {
    bool forceRefresh = false,
  }) async {
    try {
      return await _client.product.getProductsByCategory(categoryId);
    } catch (e) {
      print('Get products by category error: $e');
      rethrow;
    }
  }

  /// Get active products only
  Future<List<dynamic>> getActiveProducts({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = _storageService.read(AppConstants.keyProducts);
        if (cached != null) {
          return (cached as List<dynamic>)
              .where((p) => p.isActive == true)
              .toList();
        }
      }

      final products = await _client.product.getAllProducts(
        includeDeleted: false,
        activeOnly: true,
      );
      return products;
    } catch (e) {
      print('Get active products error: $e');
      rethrow;
    }
  }

  /// Get product by ID
  Future<dynamic> getProductById(int productId) async {
    try {
      return await _client.product.getProductById(productId);
    } catch (e) {
      print('Get product by ID error: $e');
      rethrow;
    }
  }

  /// Create product (admin only)
  Future<dynamic> createProduct({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required int stockQuantity,
    required int minStockAlert,
    String? imageUrl,
    bool isBulkProduct = false,
    String? bulkUnit,
    double? bulkTotalQuantity,
  }) async {
    try {
      return await _client.product.createProduct(
        name,
        description,
        price,
        categoryId,
        stockQuantity,
        minStockAlert,
        imageUrl,
        isBulkProduct: isBulkProduct,
        bulkUnit: bulkUnit,
        bulkTotalQuantity: bulkTotalQuantity,
      );
    } catch (e) {
      print('Create product error: $e');
      rethrow;
    }
  }

  /// Update product (admin only)
  Future<dynamic> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required int minStockAlert,
    String? imageUrl,
    bool? isBulkProduct,
    String? bulkUnit,
    double? bulkTotalQuantity,
    int? stockQuantity,
  }) async {
    try {
      return await _client.product.updateProduct(
        productId,
        name,
        description,
        price,
        categoryId,
        minStockAlert,
        imageUrl,
        isBulkProduct: isBulkProduct,
        bulkUnit: bulkUnit,
        bulkTotalQuantity: bulkTotalQuantity,
        stockQuantity: stockQuantity,
      );
    } catch (e) {
      print('Update product error: $e');
      rethrow;
    }
  }

  /// Delete product (admin only)
  Future<void> deleteProduct(int productId) async {
    try {
      await _client.product.deleteProduct(productId);

      // Clear cache
      _storageService.remove(AppConstants.keyProducts);
    } catch (e) {
      print('Delete product error: $e');
      rethrow;
    }
  }

  /// Toggle product active status (activate/deactivate)
  Future<dynamic> toggleActiveStatus(int productId, bool isActive) async {
    try {
      final result = await _client.product.toggleActiveStatus(
        productId,
        isActive,
      );

      // Clear cache
      _storageService.remove(AppConstants.keyProducts);

      return result;
    } catch (e) {
      print('Toggle active status error: $e');
      rethrow;
    }
  }

  /// Update product stock quantity (admin only)
  Future<dynamic> updateStock(int productId, int newStockQuantity) async {
    try {
      final result = await _client.product.updateStock(
        productId,
        newStockQuantity,
      );

      // Clear cache to force refresh
      _storageService.remove(AppConstants.keyProducts);

      return result;
    } catch (e) {
      print('Update stock error: $e');
      rethrow;
    }
  }

  /// Clear products cache
  Future<void> clearCache() async {
    _storageService.remove(AppConstants.keyProducts);
  }
}
