import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../core/constants/app_constants.dart';
import '../data/repositories/user_repository.dart';

/// Service for managing authentication state
class AuthService extends GetxService {
  final _storage = GetStorage();

  // Lazy getter to avoid initialization order issues
  UserRepository get _userRepository => Get.find<UserRepository>();

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  /// Load user from local storage on app startup
  void _loadUserFromStorage() {
    try {
      final userData = _storage.read(AppConstants.storageKeyUser);
      if (userData != null && userData is Map<String, dynamic>) {
        currentUser.value = User.fromJson(userData);
        isAuthenticated.value = true;
      }
    } catch (e) {
      print('Error loading user from storage: $e');
    }
  }

  /// Set the current user and update authentication state
  void setUser(User? user) {
    currentUser.value = user;
    isAuthenticated.value = user != null;

    if (user != null) {
      _storage.write(AppConstants.storageKeyUser, user.toJson());
    } else {
      _storage.remove(AppConstants.storageKeyUser);
    }
  }

  /// Clear user session
  void clearUser() {
    setUser(null);
    _storage.remove(AppConstants.storageKeyToken);
  }

  /// Check if user is admin
  bool get isAdmin =>
      isAuthenticated.value && currentUser.value?.role == UserRole.admin;

  /// Check if user is regular user
  bool get isRegularUser =>
      isAuthenticated.value && currentUser.value?.role == UserRole.user;

  /// Refresh user data from server
  Future<void> refreshUser() async {
    try {
      final currentUserId = currentUser.value?.id;
      if (currentUserId == null) {
        print('No user to refresh');
        return;
      }

      // Fetch updated user data from server
      final updatedUser = await _userRepository.getUserById(currentUserId);

      if (updatedUser != null) {
        setUser(updatedUser as User);
        print('User refreshed successfully');
      }
    } catch (e) {
      print('Error refreshing user: $e');
      // Si l'erreur est critique, on peut recharger depuis le storage
      _loadUserFromStorage();
    }
  }
}
