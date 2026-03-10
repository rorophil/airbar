import 'package:get/get.dart';
import '../../services/storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository for category operations
class CategoryRepository {
  Client get _client => ServerpodClientProvider.client;
  final _storageService = Get.find<StorageService>();

  /// Get all categories
  Future<List<dynamic>> getAllCategories({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = _storageService.read(AppConstants.keyCategories);
        if (cached != null) {
          return cached as List<dynamic>;
        }
      }

      // Fetch from server
      final categories = await _client.category.getCategories();

      // Cache the result
      _storageService.write(AppConstants.keyCategories, categories);

      return categories;
    } catch (e) {
      print('Get all categories error: $e');
      rethrow;
    }
  }

  /// Get category by ID
  Future<dynamic> getCategoryById(int categoryId) async {
    try {
      // Get all categories and filter
      final categories = await getAllCategories();
      return categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => null,
      );
    } catch (e) {
      print('Get category by ID error: $e');
      rethrow;
    }
  }

  /// Create category (admin only)
  Future<dynamic> createCategory({
    required String name,
    required String description,
    String? iconName,
    int displayOrder = 0,
  }) async {
    try {
      final category = await _client.category.createCategory(
        name,
        description,
        iconName,
        displayOrder,
      );

      // Clear cache
      _storageService.remove(AppConstants.keyCategories);

      return category;
    } catch (e) {
      print('Create category error: $e');
      rethrow;
    }
  }

  /// Update category (admin only)
  Future<dynamic> updateCategory({
    required int categoryId,
    required String name,
    required String description,
    String? iconName,
    int displayOrder = 0,
  }) async {
    try {
      final category = await _client.category.updateCategory(
        categoryId,
        name,
        description,
        iconName,
        displayOrder,
      );

      // Clear cache
      _storageService.remove(AppConstants.keyCategories);

      return category;
    } catch (e) {
      print('Update category error: $e');
      rethrow;
    }
  }

  /// Delete category (admin only)
  Future<void> deleteCategory(int categoryId) async {
    try {
      await _client.category.deleteCategory(categoryId);

      // Clear cache
      _storageService.remove(AppConstants.keyCategories);
    } catch (e) {
      print('Delete category error: $e');
      rethrow;
    }
  }

  /// Clear categories cache
  Future<void> clearCache() async {
    _storageService.remove(AppConstants.keyCategories);
  }
}
