class AppConstants {
  // API
  static const String serverUrl = 'http://localhost:8080/';

  // Storage Keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyUser = 'current_user';
  static const String keyProducts = 'cached_products';
  static const String keyCategories = 'cached_categories';

  // Cache Duration
  static const Duration productsCacheDuration = Duration(minutes: 30);
  static const Duration categoriesCacheDuration = Duration(minutes: 30);

  // Pin
  static const int pinLength = 4;

  // Pagination
  static const int defaultPageSize = 20;

  // Stock Alert
  static const int defaultMinStockAlert = 5;
}
