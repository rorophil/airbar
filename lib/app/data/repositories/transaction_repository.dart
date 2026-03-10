import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository for transaction operations
class TransactionRepository {
  Client get _client => ServerpodClientProvider.client;

  /// Checkout - Create purchase transaction
  Future<dynamic> checkout({required int userId, required String pin}) async {
    try {
      return await _client.transaction.checkout(userId, pin);
    } catch (e) {
      print('Checkout error: $e');
      rethrow;
    }
  }

  /// Get user transactions
  Future<List<dynamic>> getUserTransactions(
    int userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _client.transaction.getUserTransactions(
        userId,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      print('Get user transactions error: $e');
      rethrow;
    }
  }

  /// Get all transactions (admin only)
  Future<List<dynamic>> getAllTransactions({
    dynamic type,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _client.transaction.getAllTransactions(
        limit: limit,
        offset: offset,
        type: type,
      );
    } catch (e) {
      print('Get all transactions error: $e');
      rethrow;
    }
  }

  /// Refund transaction (admin only)
  Future<dynamic> refundTransaction({
    required int transactionId,
    required String notes,
  }) async {
    try {
      return await _client.transaction.refundTransaction(transactionId, notes);
    } catch (e) {
      print('Refund transaction error: $e');
      rethrow;
    }
  }

  /// Get transaction items
  Future<List<dynamic>> getTransactionItems(int transactionId) async {
    try {
      return await _client.transaction.getTransactionItems(transactionId);
    } catch (e) {
      print('Get transaction items error: $e');
      rethrow;
    }
  }
}
