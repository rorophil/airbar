import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository for user management operations
class UserRepository {
  Client get _client => ServerpodClientProvider.client;

  /// Get all users (admin only)
  Future<List<dynamic>> getAllUsers() async {
    try {
      return await _client.user.getAllUsers();
    } catch (e) {
      print('Get all users error: $e');
      rethrow;
    }
  }

  /// Get user by ID
  Future<dynamic> getUserById(int userId) async {
    try {
      return await _client.user.getUserById(userId);
    } catch (e) {
      print('Get user by ID error: $e');
      rethrow;
    }
  }

  /// Create user (admin only)
  Future<dynamic> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String pin,
    required UserRole role,
  }) async {
    try {
      return await _client.user.createUser(
        email,
        password,
        firstName,
        lastName,
        pin,
        role,
      );
    } catch (e) {
      print('Create user error: $e');
      rethrow;
    }
  }

  /// Update user (admin only)
  Future<dynamic> updateUser({
    required int userId,
    required String email,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    try {
      return await _client.user.updateUser(
        userId,
        email,
        firstName,
        lastName,
        role,
      );
    } catch (e) {
      print('Update user error: $e');
      rethrow;
    }
  }

  /// Deactivate user (admin only)
  Future<void> deactivateUser(int userId) async {
    try {
      await _client.user.deactivateUser(userId);
    } catch (e) {
      print('Deactivate user error: $e');
      rethrow;
    }
  }

  /// Delete user (admin only)
  Future<void> deleteUser(int userId) async {
    try {
      await _client.user.deleteUser(userId);
    } catch (e) {
      print('Delete user error: $e');
      rethrow;
    }
  }

  /// Credit user account (admin only)
  Future<dynamic> creditAccount({
    required int userId,
    required double amount,
    String? notes,
  }) async {
    try {
      return await _client.user.creditAccount(userId, amount, notes);
    } catch (e) {
      print('Credit account error: $e');
      rethrow;
    }
  }
}
