/// Constantes globales de l'application AirBar
///
/// Définit les valeurs de configuration, clés de stockage,
/// et paramètres par défaut utilisés dans toute l'application.
class AppConstants {
  // === API ===
  /// URL par défaut du serveur Serverpod
  static const String serverUrl = 'http://localhost:8080/';

  // === Storage Keys ===
  /// Clé de stockage pour le token d'authentification
  static const String storageKeyToken = 'auth_token';

  /// Clé de stockage pour l'utilisateur actuellement connecté
  static const String storageKeyUser = 'current_user';

  /// Clé de cache pour la liste des produits
  static const String keyProducts = 'cached_products';

  /// Clé de cache pour la liste des catégories
  static const String keyCategories = 'cached_categories';

  // === Cache Duration ===
  /// Durée de validité du cache des produits (30 minutes)
  static const Duration productsCacheDuration = Duration(minutes: 30);

  /// Durée de validité du cache des catégories (30 minutes)
  static const Duration categoriesCacheDuration = Duration(minutes: 30);

  // === Pin ===
  /// Longueur requise du code PIN utilisateur (4 chiffres)
  static const int pinLength = 4;

  // === Pagination ===
  /// Nombre d'éléments par page par défaut
  static const int defaultPageSize = 20;

  // === Stock Alert ===
  /// Seuil d'alerte de stock par défaut (5 unités)
  static const int defaultMinStockAlert = 5;
}
