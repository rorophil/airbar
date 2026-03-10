import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/transaction_repository.dart';

class ExportController extends GetxController {
  final TransactionRepository _transactionRepository = Get.find();

  // Observables
  final isExporting = false.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final selectedType = Rxn<TransactionType>();

  /// Select start date
  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          startDate.value ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      startDate.value = picked;
    }
  }

  /// Select end date
  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? DateTime.now(),
      firstDate: startDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      endDate.value = picked;
    }
  }

  /// Select transaction type filter
  void selectType(TransactionType? type) {
    selectedType.value = type;
  }

  /// Export transactions
  Future<void> exportTransactions() async {
    if (startDate.value == null || endDate.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner une période',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isExporting.value = true;

      // Get transactions
      final transactions = await _transactionRepository.getAllTransactions();

      // Filter by date range
      final filteredByDate = transactions.where((t) {
        return t.createdAt.isAfter(startDate.value!) &&
            t.createdAt.isBefore(endDate.value!.add(const Duration(days: 1)));
      }).toList();

      // Filter by type if selected
      final filtered = selectedType.value != null
          ? filteredByDate
                .where((t) => t.transactionType == selectedType.value)
                .toList()
          : filteredByDate;

      // Generate CSV content
      final csvContent = _generateCSV(filtered);

      // In a real app, you would save this to a file or share it
      // For now, we'll just show a success message
      Get.snackbar(
        'Succès',
        'Export terminé: ${filtered.length} transaction(s) exportée(s)',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Log the CSV content (in production, you would save it)
      print('CSV Export:\n$csvContent');
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter les transactions: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExporting.value = false;
    }
  }

  /// Generate CSV content
  String _generateCSV(List<dynamic> transactions) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('ID,Type,Montant,Utilisateur,Date,Balance Après,Notes');

    // Rows
    for (final transaction in transactions) {
      buffer.writeln(
        [
          transaction.id,
          transaction.transactionType.name,
          transaction.amount,
          transaction.userId,
          transaction.createdAt.toIso8601String(),
          transaction.balanceAfter,
          transaction.notes?.replaceAll(',', ';') ?? '',
        ].join(','),
      );
    }

    return buffer.toString();
  }

  /// Get transaction type label
  String getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return 'Achats';
      case TransactionType.credit:
        return 'Crédits';
      case TransactionType.refund:
        return 'Remboursements';
    }
  }
}
