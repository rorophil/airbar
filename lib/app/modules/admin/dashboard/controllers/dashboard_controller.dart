import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/auth_service.dart';

/// Controller du module Dashboard Admin
///
/// Tableau de bord principal pour les administrateurs de l'aéro-club.
/// Fournit la navigation vers tous les modules de gestion:
/// - Utilisateurs (membres, crédits/débits)
/// - Produits (catalogue, prix, stock)
/// - Catégories (organisation du catalogue)
/// - Stock (réapprovisionnement, historique)
/// - Transactions (historique, remboursements)
/// - Export (rapports CSV/Excel)
///
/// Permet aussi aux admins d'accéder à la boutique sans se déconnecter.
///
/// Opérations principales:
/// - Navigation vers les différents modules admin
/// - Accès à la boutique (goToShop)
/// - Déconnexion (logout)
class DashboardController extends GetxController {
  /// Service d'authentification (utilisateur connecté)
  final AuthService _authService = Get.find();

  /// Naviguer vers la gestion des utilisateurs
  void goToUsers() {
    Get.toNamed(AppRoutes.ADMIN_USERS);
  }

  /// Naviguer vers la gestion des produits
  void goToProducts() {
    Get.toNamed(AppRoutes.ADMIN_PRODUCTS);
  }

  /// Naviguer vers la gestion des catégories
  void goToCategories() {
    Get.toNamed(AppRoutes.ADMIN_CATEGORIES);
  }

  /// Naviguer vers la gestion du stock
  void goToStock() {
    Get.toNamed(AppRoutes.ADMIN_STOCK);
  }

  /// Naviguer vers l'historique des transactions
  void goToTransactions() {
    Get.toNamed(AppRoutes.ADMIN_TRANSACTIONS);
  }

  /// Naviguer vers l'export de données
  void goToExport() {
    Get.toNamed(AppRoutes.ADMIN_EXPORT);
  }

  /// Naviguer vers la boutique (en tant qu'utilisateur)
  ///
  /// Permet aux admins d'acheter des produits sans se déconnecter.
  void goToShop() {
    Get.toNamed(AppRoutes.USER_SHOP);
  }

  /// Déconnexion avec confirmation
  ///
  /// Affiche un dialog de confirmation avant de:
  /// 1. Effacer l'utilisateur connecté (AuthService.clearUser)
  /// 2. Naviguer vers l'écran de login (offAllNamed)
  void logout() {
    Get.defaultDialog(
      title: 'Déconnexion',
      middleText: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      textCancel: 'Annuler',
      textConfirm: 'Déconnexion',
      onConfirm: () {
        _authService.clearUser();
        Get.offAllNamed(AppRoutes.LOGIN);
      },
    );
  }

  /// Récupérer le nom de l'administrateur connecté
  ///
  /// Retourne "Prénom Nom" ou "Admin" si non trouvé.
  /// Utilisé pour le message de bienvenue dans le dashboard.
  String get adminName {
    final user = _authService.currentUser.value;
    return user != null ? '${user.firstName} ${user.lastName}' : 'Admin';
  }
}
