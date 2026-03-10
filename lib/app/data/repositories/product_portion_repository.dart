import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository for product portion operations
class ProductPortionRepository {
  Client get _client => ServerpodClientProvider.client;

  /// Get all portions for a product
  Future<List<dynamic>> getProductPortions(
    int productId, {
    bool activeOnly = true,
  }) async {
    try {
      return await _client.productPortion.getProductPortions(
        productId,
        activeOnly: activeOnly,
      );
    } catch (e) {
      print('Get product portions error: $e');
      rethrow;
    }
  }

  /// Get portion by ID
  Future<ProductPortion?> getPortionById(int portionId) async {
    try {
      return await _client.productPortion.getPortionById(portionId);
    } catch (e) {
      print('Get portion by ID error: $e');
      rethrow;
    }
  }

  /// Create product portion
  Future<dynamic> createPortion({
    required int productId,
    required String name,
    required double quantity,
    required double price,
    int displayOrder = 0,
  }) async {
    try {
      return await _client.productPortion.createPortion(
        productId,
        name,
        quantity,
        price,
        displayOrder: displayOrder,
      );
    } catch (e) {
      print('Create portion error: $e');
      rethrow;
    }
  }

  /// Update product portion
  Future<dynamic> updatePortion({
    required int portionId,
    required String name,
    required double quantity,
    required double price,
    int? displayOrder,
  }) async {
    try {
      return await _client.productPortion.updatePortion(
        portionId,
        name,
        quantity,
        price,
        displayOrder: displayOrder,
      );
    } catch (e) {
      print('Update portion error: $e');
      rethrow;
    }
  }

  /// Delete/Deactivate portion
  Future<void> deletePortion(int portionId) async {
    try {
      await _client.productPortion.deletePortion(portionId);
    } catch (e) {
      print('Delete portion error: $e');
      rethrow;
    }
  }
}
