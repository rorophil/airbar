import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/trace_logger.dart';

/// Service de gestion du stockage local et du cache
///
/// Wrapper autour de GetStorage pour centraliser toutes les opérations
/// de cache (produits, catégories) et de persistance des données.
/// Gère l'expiration automatique du cache.
class StorageService extends GetxService {
  late GetStorage _storage;

  StorageService() {
    Trace.create('StorageService');
  }

  @override
  Future<void> onInit() async {
    Trace.call('StorageService', 'onInit');
    super.onInit();
    await GetStorage.init();
    _storage = GetStorage();
  }

  void saveProducts(List<Map<String, dynamic>> products) {
    Trace.call('StorageService', 'saveProducts');
    _storage.write(AppConstants.keyProducts, {
      'data': products,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  List<Map<String, dynamic>>? getCachedProducts() {
    Trace.call('StorageService', 'getCachedProducts');
    final cached = _storage.read(AppConstants.keyProducts);
    if (cached == null) return null;

    final timestamp = DateTime.parse(cached['timestamp']);
    final now = DateTime.now();

    if (now.difference(timestamp) > AppConstants.productsCacheDuration) {
      return null;
    }

    return List<Map<String, dynamic>>.from(cached['data']);
  }

  void saveCategories(List<Map<String, dynamic>> categories) {
    Trace.call('StorageService', 'saveCategories');
    _storage.write(AppConstants.keyCategories, {
      'data': categories,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  List<Map<String, dynamic>>? getCachedCategories() {
    Trace.call('StorageService', 'getCachedCategories');
    final cached = _storage.read(AppConstants.keyCategories);
    if (cached == null) return null;

    final timestamp = DateTime.parse(cached['timestamp']);
    final now = DateTime.now();

    if (now.difference(timestamp) > AppConstants.categoriesCacheDuration) {
      return null;
    }

    return List<Map<String, dynamic>>.from(cached['data']);
  }

  void clearCache() {
    Trace.call('StorageService', 'clearCache');
    _storage.remove(AppConstants.keyProducts);
    _storage.remove(AppConstants.keyCategories);
  }

  void clearAll() {
    Trace.call('StorageService', 'clearAll');
    _storage.erase();
  }

  void write(String key, dynamic value) {
    Trace.call('StorageService', 'write');
    _storage.write(key, value);
  }

  T? read<T>(String key) {
    Trace.call('StorageService', 'read');
    return _storage.read<T>(key);
  }

  void remove(String key) {
    Trace.call('StorageService', 'remove');
    _storage.remove(key);
  }
}
