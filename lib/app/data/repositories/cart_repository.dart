import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository for cart operations
class CartRepository {
  Client get _client => ServerpodClientProvider.client;

  /// Get user cart
  Future<List<dynamic>> getUserCart(int userId) async {
    try {
      return await _client.cart.getCart(userId);
    } catch (e) {
      print('Get user cart error: $e');
      rethrow;
    }
  }

  /// Add item to cart
  Future<dynamic> addToCart({
    required int userId,
    required int productId,
    required int quantity,
    int? productPortionId,
  }) async {
    try {
      return await _client.cart.addToCart(
        userId,
        productId,
        quantity,
        productPortionId: productPortionId,
      );
    } catch (e) {
      print('Add to cart error: $e');
      rethrow;
    }
  }

  /// Update cart item quantity
  Future<dynamic> updateCartItem({
    required int userId,
    required int productId,
    required int quantity,
    int? productPortionId,
  }) async {
    try {
      return await _client.cart.updateCartItem(
        userId,
        productId,
        quantity,
        productPortionId: productPortionId,
      );
    } catch (e) {
      print('Update cart item error: $e');
      rethrow;
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart({
    required int userId,
    required int productId,
    int? productPortionId,
  }) async {
    try {
      await _client.cart.removeFromCart(
        userId,
        productId,
        productPortionId: productPortionId,
      );
    } catch (e) {
      print('Remove from cart error: $e');
      rethrow;
    }
  }

  /// Clear entire cart
  Future<void> clearCart(int userId) async {
    try {
      await _client.cart.clearCart(userId);
    } catch (e) {
      print('Clear cart error: $e');
      rethrow;
    }
  }

  /// Calculate cart total
  Future<double> calculateCartTotal(List<dynamic> cartItems) async {
    try {
      double total = 0.0;
      for (var item in cartItems) {
        total += (item.product?.price ?? 0.0) * item.quantity;
      }
      return total;
    } catch (e) {
      print('Calculate cart total error: $e');
      return 0.0;
    }
  }
}
