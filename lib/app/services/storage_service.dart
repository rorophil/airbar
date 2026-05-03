import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/constants/app_constants.dart';

/// Service de gestion du stockage local et du cache
///
/// Wrapper autour de GetStorage pour centraliser toutes les opérations
/// de cache (produits, catégories) et de persistance des données.
/// Gère l'expiration automatique du cache.
class StorageService extends GetxService {
  late GetStorage _storage;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Initialisation de GetStorage
    await GetStorage.init();
    _storage = GetStorage();
  }

  /// Sauvegarde la liste des produits dans le cache avec horodatage
  ///
  /// [products] Liste des produits sérialisés en JSON
  void saveProducts(List<Map<String, dynamic>> products) {
    _storage.write(AppConstants.keyProducts, {
      'data': products,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Récupère les produits du cache si non expirés
  ///
  /// Retourne `null` si le cache n'existe pas ou est expiré
  /// (dépassement de [AppConstants.productsCacheDuration]).
  ///
  /// Returns: Liste des produits ou null si cache invalide
  List<Map<String, dynamic>>? getCachedProducts() {
    final cached = _storage.read(AppConstants.keyProducts);
    if (cached == null) return null;

    // Vérification de l'expiration du cache
    final timestamp = DateTime.parse(cached['timestamp']);
    final now = DateTime.now();

    if (now.difference(timestamp) > AppConstants.productsCacheDuration) {
      return null; // Cache expired
    }

    return List<Map<String, dynamic>>.from(cached['data']);
  }

  /// Sauvegarde la liste des catégories dans le cache avec horodatage
  ///
  /// [categories] Liste des catégories sérialisées en JSON
  void saveCategories(List<Map<String, dynamic>> categories) {
    _storage.write(AppConstants.keyCategories, {
      'data': categories,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Récupère les catégories du cache si non expirées
  ///
  /// Retourne `null` si le cache n'existe pas ou est expiré
  /// (dépassement de [AppConstants.categoriesCacheDuration]).
  ///
  /// Returns: Liste des catégories ou null si cache invalide
  List<Map<String, dynamic>>? getCachedCategories() {
    final cached = _storage.read(AppConstants.keyCategories);
    if (cached == null) return null;

    final timestamp = DateTime.parse(cached['timestamp']);
    final now = DateTime.now();

    if (now.difference(timestamp) > AppConstants.categoriesCacheDuration) {
      return null; // Cache expired
    }

    return List<Map<String, dynamic>>.from(cached['data']);
  }

  /// Efface tout le cache (produits et catégories)
  ///
  /// Utile après une modification des données côté serveur.
  void clearCache() {
    _storage.remove(AppConstants.keyProducts);
    _storage.remove(AppConstants.keyCategories);
  }

  /// Efface tout le stockage local (cache + données d'authentification)
  ///
  /// Attention: Cette opération est destructive et irréversible.
  /// Utilisée lors de la déconnexion complète.
  void clearAll() {
    _storage.erase();
  }

  /// Méthode générique d'écriture dans le stockage
  ///
  /// [key] Clé unique d'identification
  /// [value] Valeur à stocker (doit être sérialisable)
  void write(String key, dynamic value) {
    _storage.write(key, value);
  }

  /// Méthode générique de lecture depuis le stockage
  ///
  /// [T] Type de la valeur attendue
  /// [key] Clé de la valeur à récupérer
  ///
  /// Returns: Valeur typée ou null si inexistante
  T? read<T>(String key) {
    return _storage.read<T>(key);
  }

  /// Méthode générique de suppression d'une clé
  ///
  /// [key] Clé à supprimer du stockage
  void remove(String key) {
    _storage.remove(key);
  }
}
