import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/constants/app_constants.dart';

/// Service for local storage management and caching
class StorageService extends GetxService {
  late GetStorage _storage;

  @override
  Future<void> onInit() async {
    super.onInit();
    await GetStorage.init();
    _storage = GetStorage();
  }

  /// Save products to cache
  void saveProducts(List<Map<String, dynamic>> products) {
    _storage.write(AppConstants.keyProducts, {
      'data': products,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get cached products if not expired
  List<Map<String, dynamic>>? getCachedProducts() {
    final cached = _storage.read(AppConstants.keyProducts);
    if (cached == null) return null;

    final timestamp = DateTime.parse(cached['timestamp']);
    final now = DateTime.now();

    if (now.difference(timestamp) > AppConstants.productsCacheDuration) {
      return null; // Cache expired
    }

    return List<Map<String, dynamic>>.from(cached['data']);
  }

  /// Save categories to cache
  void saveCategories(List<Map<String, dynamic>> categories) {
    _storage.write(AppConstants.keyCategories, {
      'data': categories,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get cached categories if not expired
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

  /// Clear all cache
  void clearCache() {
    _storage.remove(AppConstants.keyProducts);
    _storage.remove(AppConstants.keyCategories);
  }

  /// Clear all storage (including auth data)
  void clearAll() {
    _storage.erase();
  }

  /// Generic write method
  void write(String key, dynamic value) {
    _storage.write(key, value);
  }

  /// Generic read method
  T? read<T>(String key) {
    return _storage.read<T>(key);
  }

  /// Generic remove method
  void remove(String key) {
    _storage.remove(key);
  }
}
