import 'package:get/get.dart';
import '../../services/storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository de gestion des produits
///
/// Implémente le pattern Repository pour abstraire l'accès aux données des produits.
/// Gère le cache local via [StorageService] pour améliorer les performances.
///
/// Ce repository gère:
/// - CRUD des produits
/// - Produits réguliers et produits en vrac (bière pression, etc.)
/// - Gestion du stock (avec support trackStock = false)
/// - Activation/désactivation des produits (soft delete)
/// - Cache local avec invalidation automatique
///
/// Pattern de cache:
/// 1. Tentative de lecture depuis le cache si forceRefresh = false
/// 2. Si cache vide ou forceRefresh = true, appel serveur
/// 3. Mise en cache automatique du résultat
/// 4. Invalidation du cache lors des modifications (create, update, delete)
class ProductRepository {
  /// Client Serverpod pour les appels API
  Client get _client => ServerpodClientProvider.client;

  /// Service de stockage local pour le cache
  final _storageService = Get.find<StorageService>();

  /// Récupère tous les produits (actifs et inactifs)
  ///
  /// [forceRefresh] Si `true`, force le rechargement depuis le serveur
  /// en ignorant le cache. Utile après une modification ou au démarrage.
  ///
  /// Returns: Liste de tous les produits
  ///
  /// Throws: Exception en cas d'erreur serveur
  ///
  /// Pattern de cache:
  /// 1. Si forceRefresh = false, tentative de lecture du cache
  /// 2. Si cache trouvé, retour immédiat (économie réseau)
  /// 3. Sinon, appel serveur et mise en cache du résultat
  Future<List<dynamic>> getAllProducts({bool forceRefresh = false}) async {
    try {
      // Vérification du cache d'abord pour économiser la bande passante
      if (!forceRefresh) {
        final cached = _storageService.read(AppConstants.keyProducts);
        if (cached != null) {
          return cached as List<dynamic>;
        }
      }

      // Récupération depuis le serveur si pas de cache ou forceRefresh
      // includeDeleted = false pour exclure les produits supprimés (soft delete)
      final products = await _client.product.getAllProducts(
        includeDeleted: false,
      );

      // Mise en cache pour les prochains appels
      _storageService.write(AppConstants.keyProducts, products);

      return products;
    } catch (e) {
      print('Get all products error: $e');
      rethrow;
    }
  }

  /// Récupère les produits d'une catégorie spécifique
  ///
  /// [categoryId] L'ID de la catégorie
  /// [forceRefresh] Force le rechargement (non implémenté ici, toujours depuis serveur)
  ///
  /// Returns: Liste des produits de la catégorie (actifs et inactifs)
  ///
  /// Throws: Exception si la catégorie n'existe pas ou erreur serveur
  ///
  /// Note: Cette méthode ne gère pas de cache car elle est rarement utilisée
  /// et filtrer le cache serait moins performant qu'un appel direct.
  Future<List<dynamic>> getProductsByCategory(
    int categoryId, {
    bool forceRefresh = false,
  }) async {
    try {
      return await _client.product.getProductsByCategory(categoryId);
    } catch (e) {
      print('Get products by category error: $e');
      rethrow;
    }
  }

  /// Récupère uniquement les produits actifs
  ///
  /// [forceRefresh] Si `true`, force le rechargement depuis le serveur
  ///
  /// Returns: Liste des produits avec isActive = true
  ///
  /// Throws: Exception en cas d'erreur serveur
  ///
  /// Note: Utilisé principalement dans la boutique pour n'afficher
  /// que les produits disponibles à l'achat.
  Future<List<dynamic>> getActiveProducts({bool forceRefresh = false}) async {
    try {
      // Tentative de filtrage depuis le cache
      if (!forceRefresh) {
        final cached = _storageService.read(AppConstants.keyProducts);
        if (cached != null) {
          // Filtrage des produits actifs uniquement
          return (cached as List<dynamic>)
              .where((p) => p.isActive == true)
              .toList();
        }
      }

      // Appel serveur avec filtre activeOnly
      final products = await _client.product.getAllProducts(
        includeDeleted: false,
        activeOnly: true,
      );

      // Cache du résultat pour économiser les appels futurs
      _storageService.write(AppConstants.keyProducts, products);

      return products;
    } catch (e) {
      print('Get active products error: $e');
      rethrow;
    }
  }

  /// Récupère un produit par son ID
  ///
  /// [productId] L'ID du produit à récupérer
  ///
  /// Returns: Le produit avec toutes ses données (stock, prix, portions, etc.)
  ///
  /// Throws: Exception si le produit n'existe pas ou erreur serveur
  Future<dynamic> getProductById(int productId) async {
    try {
      return await _client.product.getProductById(productId);
    } catch (e) {
      print('Get product by ID error: $e');
      rethrow;
    }
  }

  /// Crée un nouveau produit
  ///
  /// Paramètres de base:
  /// [name] Nom du produit
  /// [description] Description détaillée
  /// [price] Prix unitaire en euros (pour produits réguliers)
  /// [categoryId] ID de la catégorie parente
  /// [stockQuantity] Quantité en stock (unités ou contenants)
  /// [minStockAlert] Seuil d'alerte de stock faible
  /// [imageUrl] URL optionnelle de l'image du produit
  ///
  /// Paramètres pour produits en vrac (bière pression, etc.):
  /// [isBulkProduct] Si `true`, active la gestion en vrac
  /// [bulkUnit] Unité de mesure ("litres", "kg", etc.)
  /// [bulkTotalQuantity] Capacité totale d'une unité (ex: 6L par fût)
  /// [currentUnitRemaining] Quantité restante dans l'unité entamée
  ///
  /// Gestion du stock:
  /// [trackStock] Si `false`, désactive la gestion de stock
  ///
  /// Returns: Le produit créé avec son ID
  ///
  /// Throws: Exception si validation échoue ou erreur serveur
  ///
  /// Note: Pour les produits en vrac, le prix est défini par les portions.
  /// Opération réservée aux administrateurs uniquement.
  Future<dynamic> createProduct({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required int stockQuantity,
    required int minStockAlert,
    String? imageUrl,
    bool isBulkProduct = false,
    String? bulkUnit,
    double? bulkTotalQuantity,
    double? currentUnitRemaining,
    bool trackStock = true,
  }) async {
    try {
      // Appel au backend pour création du produit
      return await _client.product.createProduct(
        name,
        description,
        price,
        categoryId,
        stockQuantity,
        minStockAlert,
        imageUrl,
        isBulkProduct: isBulkProduct,
        bulkUnit: bulkUnit,
        bulkTotalQuantity: bulkTotalQuantity,
        currentUnitRemaining: currentUnitRemaining,
        trackStock: trackStock,
      );
    } catch (e) {
      print('Create product error: $e');
      rethrow;
    }
  }

  /// Met à jour un produit existant
  ///
  /// Tous les paramètres sont identiques à [createProduct].
  /// [productId] est requis pour identifier le produit à modifier.
  ///
  /// Returns: Le produit mis à jour
  ///
  /// Throws: Exception si le produit n'existe pas, validation échoue,
  /// ou erreur serveur
  ///
  /// Note: Invalide automatiquement le cache après modification.
  /// Opération réservée aux administrateurs uniquement.
  Future<dynamic> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    required int minStockAlert,
    String? imageUrl,
    bool? isBulkProduct,
    String? bulkUnit,
    double? bulkTotalQuantity,
    int? stockQuantity,
    double? currentUnitRemaining,
    bool? trackStock,
  }) async {
    try {
      return await _client.product.updateProduct(
        productId,
        name,
        description,
        price,
        categoryId,
        minStockAlert,
        imageUrl,
        isBulkProduct: isBulkProduct,
        bulkUnit: bulkUnit,
        bulkTotalQuantity: bulkTotalQuantity,
        stockQuantity: stockQuantity,
        currentUnitRemaining: currentUnitRemaining,
        trackStock: trackStock,
      );
    } catch (e) {
      print('Update product error: $e');
      rethrow;
    }
  }

  /// Supprime un produit (soft delete)
  ///
  /// [productId] L'ID du produit à supprimer
  ///
  /// ⚠️ IMPORTANT: Il s'agit d'un "soft delete" - le produit n'est PAS
  /// supprimé physiquement de la base de données mais marqué comme inactif.
  /// Cela préserve l'historique des transactions.
  ///
  /// Throws: Exception si le produit n'existe pas ou erreur serveur
  ///
  /// Note: Invalide le cache après suppression.
  /// Opération réservée aux administrateurs uniquement.
  Future<void> deleteProduct(int productId) async {
    try {
      await _client.product.deleteProduct(productId);

      // Invalidation du cache car la liste des produits a changé
      _storageService.remove(AppConstants.keyProducts);
    } catch (e) {
      print('Delete product error: $e');
      rethrow;
    }
  }

  /// Active ou désactive un produit
  ///
  /// [productId] L'ID du produit
  /// [isActive] `true` pour activer, `false` pour désactiver
  ///
  /// Returns: Le produit avec son nouveau statut
  ///
  /// Throws: Exception si le produit n'existe pas ou erreur serveur
  ///
  /// Note: Les produits inactifs n'apparaissent pas dans la boutique.
  /// Invalide le cache après modification.
  /// Opération réservée aux administrateurs uniquement.
  Future<dynamic> toggleActiveStatus(int productId, bool isActive) async {
    try {
      final result = await _client.product.toggleActiveStatus(
        productId,
        isActive,
      );

      // Invalidation du cache car le statut a changé
      _storageService.remove(AppConstants.keyProducts);

      return result;
    } catch (e) {
      print('Toggle active status error: $e');
      rethrow;
    }
  }

  /// Met à jour le stock d'un produit
  ///
  /// [productId] L'ID du produit
  /// [newStockQuantity] Nouvelle quantité en stock (unités ou contenants)
  ///
  /// Returns: Le produit avec la quantité mise à jour
  ///
  /// Throws: Exception si le produit n'existe pas, trackStock = false,
  /// ou erreur serveur
  ///
  /// Note: Cette méthode est principalement utilisée pour les corrections
  /// manuelles. Pour le réapprovisionnement, préférer [StockRepository.restockProduct]
  /// qui crée un mouvement de stock traçable.
  /// Invalide le cache après modification.
  /// Opération réservée aux administrateurs uniquement.
  Future<dynamic> updateStock(int productId, int newStockQuantity) async {
    try {
      final result = await _client.product.updateStock(
        productId,
        newStockQuantity,
      );

      // Invalidation forcée du cache car le stock a changé
      _storageService.remove(AppConstants.keyProducts);

      return result;
    } catch (e) {
      print('Update stock error: $e');
      rethrow;
    }
  }

  /// Vide le cache des produits
  ///
  /// Force le rechargement depuis le serveur au prochain appel.
  /// Utile après des modifications importantes ou pour résoudre
  /// des problèmes de synchronisation.
  Future<void> clearCache() async {
    _storageService.remove(AppConstants.keyProducts);
  }
}
