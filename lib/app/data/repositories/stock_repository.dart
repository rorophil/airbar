import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository for stock management operations
class StockRepository {
  Client get _client => ServerpodClientProvider.client;

  /// Restock product (admin only)
  Future<dynamic> restockProduct({
    required int productId,
    required double quantity,
    required int adminUserId,
    String? notes,
  }) async {
    try {
      return await _client.stock.restockProduct(
        productId,
        quantity,
        adminUserId,
        notes,
      );
    } catch (e) {
      print('Restock product error: $e');
      rethrow;
    }
  }

  /// Adjust stock (admin only)
  Future<dynamic> adjustStock({
    required int productId,
    required double adjustment,
    required int adminUserId,
    required String reason,
  }) async {
    try {
      return await _client.stock.adjustStock(
        productId,
        adjustment,
        adminUserId,
        reason,
      );
    } catch (e) {
      print('Adjust stock error: $e');
      rethrow;
    }
  }

  /// Get stock history for a product
  Future<List<dynamic>> getStockHistory({
    required int productId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _client.stock.getStockHistory(
        productId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('Get stock history error: $e');
      rethrow;
    }
  }

  /// Get all stock movements (admin only)
  Future<List<dynamic>> getAllStockMovements({
    dynamic type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _client.stock.getAllStockMovements(
        type: type,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      print('Get all stock movements error: $e');
      rethrow;
    }
  }

  /// Get products with low stock
  Future<List<dynamic>> getLowStockProducts() async {
    try {
      return await _client.stock.getLowStockProducts();
    } catch (e) {
      print('Get low stock products error: $e');
      rethrow;
    }
  }
}
