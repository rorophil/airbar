import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository for authentication operations
class AuthRepository {
  Client get _client => ServerpodClientProvider.client;
  final _authService = Get.find<AuthService>();

  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Call auth endpoint
      final user = await _client.auth.login(email, password);

      if (user != null) {
        // Store user info
        _authService.setUser(user);

        return {'success': true, 'user': user};
      }

      return {
        'success': false,
        'error': 'Email ou mot de passe incorrect, ou compte désactivé',
      };
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'error': 'Erreur de connexion. Veuillez réessayer.',
      };
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _client.authenticationKeyManager!.remove();
      _authService.clearUser();
    } catch (e) {
      // Log error but don't throw
      print('Logout error: $e');
    }
  }

  /// Validate PIN for checkout
  Future<bool> validatePin(int userId, String pin) async {
    try {
      return await _client.auth.validatePin(userId, pin);
    } catch (e) {
      print('Validate PIN error: $e');
      return false;
    }
  }

  /// Change PIN
  Future<bool> changePin(int userId, String oldPin, String newPin) async {
    try {
      await _client.auth.changePin(userId, oldPin, newPin);
      return true;
    } catch (e) {
      print('Change PIN error: $e');
      return false;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final authKey = await _client.authenticationKeyManager!.get();
      return authKey != null;
    } catch (e) {
      return false;
    }
  }

  /// Get current auth key
  Future<String?> getAuthKey() async {
    try {
      return await _client.authenticationKeyManager!.get();
    } catch (e) {
      return null;
    }
  }
}
