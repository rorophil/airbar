import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../core/constants/app_constants.dart';
import '../data/repositories/user_repository.dart';

/// Service de gestion de l'état d'authentification
///
/// Gère l'utilisateur actuellement connecté, son rôle,
/// la persistance de la session et le rafraîchissement des données.
/// Accessible globalement via `Get.find<AuthService>()`.
class AuthService extends GetxService {
  final _storage = GetStorage();

  // Lazy getter pour éviter les problèmes d'ordre d'initialisation
  UserRepository get _userRepository => Get.find<UserRepository>();

  /// Utilisateur actuellement connecté (null si non connecté)
  final Rx<User?> currentUser = Rx<User?>(null);

  /// Indique si l'utilisateur est authentifié
  final RxBool isAuthenticated = false.obs;

  /// Indique si une opération d'authentification est en cours
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Chargement de l'utilisateur depuis le stockage au démarrage
    _loadUserFromStorage();
  }

  /// Charge l'utilisateur depuis le stockage local au démarrage de l'app
  ///
  /// Permet de maintenir la session entre les redémarrages.
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

  /// Définit l'utilisateur actuel et met à jour l'état d'authentification
  ///
  /// [user] Utilisateur à définir (null pour déconnecter)
  ///
  /// Si [user] n'est pas null, il est persisté dans le stockage local.
  /// Si [user] est null, les données d'authentification sont supprimées.
  void setUser(User? user) {
    currentUser.value = user;
    isAuthenticated.value = user != null;

    if (user != null) {
      _storage.write(AppConstants.storageKeyUser, user.toJson());
    } else {
      _storage.remove(AppConstants.storageKeyUser);
    }
  }

  /// Efface la session utilisateur (déconnexion)
  ///
  /// Supprime l'utilisateur et le token d'authentification du stockage.
  void clearUser() {
    setUser(null);
    _storage.remove(AppConstants.storageKeyToken);
  }

  /// Vérifie si l'utilisateur connecté est administrateur
  ///
  /// Returns: `true` si connecté et rôle = [UserRole.admin]
  bool get isAdmin =>
      isAuthenticated.value && currentUser.value?.role == UserRole.admin;

  /// Vérifie si l'utilisateur connecté est un utilisateur régulier
  ///
  /// Returns: `true` si connecté et rôle = [UserRole.user]
  bool get isRegularUser =>
      isAuthenticated.value && currentUser.value?.role == UserRole.user;

  /// Rafraîchit les données utilisateur depuis le serveur
  ///
  /// Utile pour mettre à jour le solde après une transaction.
  /// En cas d'erreur, recharge depuis le stockage local.
  Future<void> refreshUser() async {
    try {
      final currentUserId = currentUser.value?.id;
      if (currentUserId == null) {
        print('No user to refresh');
        return;
      }

      // Récupération des données utilisateur mises à jour depuis le serveur
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
