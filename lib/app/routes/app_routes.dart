/// Définition des routes de l'application AirBar
///
/// Centralise toutes les routes pour faciliter la navigation et éviter
/// les erreurs de frappe. Utilisé avec GetX pour la navigation.
///
/// Structure:
/// - Routes publiques (splash, login, config)
/// - Routes utilisateur (/user/*)
/// - Routes admin (/admin/*)
abstract class AppRoutes {
  // === Routes Publiques ===

  /// Page de démarrage / splash screen
  static const SPLASH = '/';

  /// Page de connexion (saisie du code PIN)
  static const LOGIN = '/login';

  /// Page de configuration du serveur (IP:port)
  static const SERVER_CONFIG = '/server-config';

  // === User Routes ===

  /// Page d'accueil utilisateur (non utilisée actuellement)
  static const USER_HOME = '/user';

  /// Boutique - Liste des produits disponibles à l'achat
  static const USER_SHOP = '/user/shop';

  /// Panier - Récapitulatif des articles sélectionnés
  static const USER_CART = '/user/cart';

  /// Validation de commande - Saisie PIN et confirmation
  static const USER_CHECKOUT = '/user/checkout';

  /// Compte utilisateur (non implémenté)
  static const USER_ACCOUNT = '/user/account';

  /// Historique des transactions (non implémenté)
  static const USER_HISTORY = '/user/history';

  // === Admin Routes ===

  /// Tableau de bord administrateur (page d'accueil admin)
  static const ADMIN_DASHBOARD = '/admin';

  /// Liste des utilisateurs
  static const ADMIN_USERS = '/admin/users';

  /// Formulaire création/édition utilisateur
  static const ADMIN_USER_FORM = '/admin/users/form';

  /// Formulaire de crédit/débit de compte utilisateur
  static const ADMIN_USER_CREDIT = '/admin/users/credit';

  /// Liste des produits
  static const ADMIN_PRODUCTS = '/admin/products';

  /// Formulaire création/édition produit
  static const ADMIN_PRODUCT_FORM = '/admin/products/form';

  /// Liste des catégories
  static const ADMIN_CATEGORIES = '/admin/categories';

  /// Formulaire création/édition catégorie
  static const ADMIN_CATEGORY_FORM = '/admin/categories/form';

  /// Gestion du stock (vue et alertes)
  static const ADMIN_STOCK = '/admin/stock';

  /// Réapprovisionnement d'un produit
  static const ADMIN_STOCK_RESTOCK = '/admin/stock/restock';

  /// Historique des transactions
  static const ADMIN_TRANSACTIONS = '/admin/transactions';

  /// Export de données (CSV)
  static const ADMIN_EXPORT = '/admin/export';
}
