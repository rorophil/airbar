import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../services/auth_service.dart';

/// Controller du module de gestion des transactions (Admin)
///
/// Permet aux administrateurs de consulter l'historique complet des transactions
/// et d'effectuer des remboursements si nécessaire.
///
/// Fonctionnalités principales:
/// - Liste complète de toutes les transactions (tous utilisateurs)
/// - Filtrage par type: purchase (achat), credit (crédit), refund (remboursement)
/// - Recherche par nom d'utilisateur ou notes de transaction
/// - Remboursement de transactions d'achat (recrédite le compte)
/// - Affichage détaillé: date, utilisateur, montant, type, solde après
///
/// Types de transactions:
/// - purchase (rouge): achat en boutique, montant négatif
/// - credit (vert): crédit de compte par admin, montant positif
/// - refund (orange): remboursement d'achat, montant positif
///
/// Workflow remboursement:
/// 1. Sélection d'une transaction d'achat (purchase)
/// 2. Confirmation via dialog
/// 3. Appel repository.refundTransaction()
/// 4. Backend crée nouvelle transaction (type: refund)
/// 5. Backend recrédite le compte utilisateur
/// 6. Rechargement automatique de la liste
///
/// Notes:
/// - Les remboursements sont traçables (nouvelle transaction créée)
/// - Le solde utilisateur est automatiquement ajusté
/// - L'historique complet est préservé (audit trail)
class TransactionsController extends GetxController {
  final TransactionRepository _transactionRepository = Get.find();
  final UserRepository _userRepository = Get.find();
  final AuthService _authService = Get.find();

  // Observables
  final isLoading = false.obs;
  final transactions = <Transaction>[].obs;
  final filteredTransactions = <Transaction>[].obs;
  final users = <User>[].obs;
  final searchQuery = ''.obs;
  final selectedType = Rxn<TransactionType>();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Load transactions and users
  Future<void> loadData({bool forceRefresh = false}) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      // Load transactions and users in parallel
      final results = await Future.wait([
        _transactionRepository.getAllTransactions(),
        _userRepository.getAllUsers(),
      ]);

      transactions.value = List<Transaction>.from(results[0]);
      users.value = List<User>.from(results[1]);
      filterTransactions();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les transactions: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter transactions
  void filterTransactions() {
    var filtered = transactions.toList();

    // Filter by type
    if (selectedType.value != null) {
      filtered = filtered.where((t) => t.type == selectedType.value).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((t) {
        final userName = getUserName(t.userId).toLowerCase();
        return userName.contains(query) ||
            (t.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    filteredTransactions.value = filtered;
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterTransactions();
  }

  /// Select transaction type filter
  void selectType(TransactionType? type) {
    selectedType.value = type;
    filterTransactions();
  }

  /// Refund transaction
  Future<void> refundTransaction(Transaction transaction) async {
    // Confirm refund
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmer le remboursement'),
        content: Text(
          'Voulez-vous rembourser cette transaction de ${transaction.totalAmount.toStringAsFixed(2)}€ ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
            ),
            child: const Text('Rembourser'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final adminUser = _authService.currentUser.value;
      if (adminUser == null) {
        Get.snackbar(
          'Erreur',
          'Utilisateur non connecté',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _transactionRepository.refundTransaction(
        transactionId: transaction.id!,
        notes: '',
      );

      Get.snackbar(
        'Succès',
        'Transaction remboursée avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadData(forceRefresh: true);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de rembourser la transaction: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get transaction type label
  String getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return 'Achat';
      case TransactionType.credit:
        return 'Crédit';
      case TransactionType.refund:
        return 'Remboursement';
    }
  }

  /// Get transaction type color
  Color getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return const Color(0xFFF44336); // Red
      case TransactionType.credit:
        return const Color(0xFF4CAF50); // Green
      case TransactionType.refund:
        return const Color(0xFFFF9800); // Orange
    }
  }

  /// Get user name by ID
  String getUserName(int userId) {
    final user = users.firstWhereOrNull((u) => u.id == userId);
    if (user != null) {
      return '${user.firstName} ${user.lastName}';
    }
    return 'Utilisateur #$userId';
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadData(forceRefresh: true);
  }
}
