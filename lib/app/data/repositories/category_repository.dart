import 'package:get/get.dart';
import '../../services/storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository de gestion des catégories de produits
///
/// Implémente le pattern Repository pour abstraire l'accès aux données des catégories.
/// Gère le cache local via [StorageService] pour améliorer les performances.
///
/// Ce repository gère:
/// - CRUD des catégories
/// - Catégorie spéciale "Sans catégorie" (non supprimable)
/// - Ordre d'affichage (displayOrder)
/// - Cache local avec invalidation automatique
///
/// ⚠️ IMPORTANT: La catégorie "Sans catégorie" est protégée:
/// - Créée automatiquement si absente
/// - Ne peut pas être supprimée
/// - displayOrder = 999 (toujours en dernier)
/// - Les produits orphelins y sont automatiquement assignés
class CategoryRepository {
  /// Client Serverpod pour les appels API
  Client get _client => ServerpodClientProvider.client;

  /// Service de stockage local pour le cache
  final _storageService = Get.find<StorageService>();

  /// Récupère toutes les catégories
  ///
  /// [forceRefresh] Si `true`, force le rechargement depuis le serveur
  /// en ignorant le cache
  ///
  /// Returns: Liste des catégories triées par displayOrder
  ///
  /// Throws: Exception en cas d'erreur serveur
  ///
  /// Pattern de cache:
  /// 1. Si forceRefresh = false, tentative de lecture du cache
  /// 2. Si cache trouvé, retour immédiat
  /// 3. Sinon, appel serveur et mise en cache du résultat
  Future<List<dynamic>> getAllCategories({bool forceRefresh = false}) async {
    try {
      // Vérification du cache d'abord
      if (!forceRefresh) {
        final cached = _storageService.read(AppConstants.keyCategories);
        if (cached != null) {
          return cached as List<dynamic>;
        }
      }

      // Récupération depuis le serveur si pas de cache ou forceRefresh
      final categories = await _client.category.getCategories();

      // Mise en cache pour les prochains appels
      _storageService.write(AppConstants.keyCategories, categories);

      return categories;
    } catch (e) {
      print('Get all categories error: $e');
      rethrow;
    }
  }

  /// Récupère une catégorie par son ID
  ///
  /// [categoryId] L'ID de la catégorie
  ///
  /// Returns: La catégorie si elle existe, `null` sinon
  ///
  /// Throws: Exception en cas d'erreur serveur
  ///
  /// Note: Utilise le cache via [getAllCategories] pour éviter
  /// un appel serveur supplémentaire
  Future<dynamic> getCategoryById(int categoryId) async {
    try {
      // Récupération de toutes les catégories (avec cache)
      final categories = await getAllCategories();

      // Filtrage pour trouver la catégorie recherchée
      return categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => null,
      );
    } catch (e) {
      print('Get category by ID error: $e');
      rethrow;
    }
  }

  /// Crée une nouvelle catégorie
  ///
  /// [name] Nom de la catégorie
  /// [description] Description détaillée
  /// [iconName] Nom optionnel de l'icône (FontAwesome, Material Icons, etc.)
  /// [displayOrder] Ordre d'affichage (défaut: 0)
  ///
  /// Returns: La catégorie créée avec son ID
  ///
  /// Throws: Exception si le nom existe déjà ou erreur serveur
  ///
  /// Note: Invalide automatiquement le cache après création.
  /// Opération réservée aux administrateurs uniquement.
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

      // Invalidation du cache car la liste a changé
      _storageService.remove(AppConstants.keyCategories);

      return category;
    } catch (e) {
      print('Create category error: $e');
      rethrow;
    }
  }

  /// Met à jour une catégorie existante
  ///
  /// Tous les paramètres sont identiques à [createCategory].
  /// [categoryId] est requis pour identifier la catégorie à modifier.
  ///
  /// Returns: La catégorie mise à jour
  ///
  /// Throws: Exception si la catégorie n'existe pas, le nom existe déjà,
  /// ou erreur serveur
  ///
  /// Note: Invalide automatiquement le cache après modification.
  /// Opération réservée aux administrateurs uniquement.
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

      // Invalidation du cache car la catégorie a été modifiée
      _storageService.remove(AppConstants.keyCategories);

      return category;
    } catch (e) {
      print('Update category error: $e');
      rethrow;
    }
  }

  /// Supprime une catégorie
  ///
  /// [categoryId] L'ID de la catégorie à supprimer
  ///
  /// ⚠️ IMPORTANT:
  /// - La catégorie "Sans catégorie" ne peut PAS être supprimée
  /// - Avant suppression, tous les produits de cette catégorie sont
  ///   automatiquement déplacés vers "Sans catégorie"
  ///
  /// Throws: Exception si:
  /// - Tentative de suppression de "Sans catégorie"
  /// - Catégorie introuvable
  /// - Erreur serveur
  ///
  /// Note: Invalide le cache après suppression.
  /// Opération réservée aux administrateurs uniquement.
  Future<void> deleteCategory(int categoryId) async {
    try {
      await _client.category.deleteCategory(categoryId);

      // Invalidation du cache car la liste a changé
      _storageService.remove(AppConstants.keyCategories);
    } catch (e) {
      print('Delete category error: $e');
      rethrow;
    }
  }

  /// Vide le cache des catégories
  ///
  /// Force le rechargement depuis le serveur au prochain appel.
  Future<void> clearCache() async {
    _storageService.remove(AppConstants.keyCategories);
  }
}
