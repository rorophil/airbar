import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:airbar_backend_client/airbar_backend_client.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

/// Service de génération de reçus PDF pour les ventes caisse
class PdfReceiptService {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final NumberFormat _numberFormat = NumberFormat('#,##0.00', 'fr_FR');

  /// Formate un montant avec le symbole € après
  String _formatCurrency(double amount) {
    return '${_numberFormat.format(amount)}€';
  }

  /// Génère un reçu PDF pour une transaction de vente caisse
  Future<Uint8List> generateReceipt({
    required Transaction transaction,
    required User seller,
    List? items,
  }) async {
    final pdf = pw.Document();

    // Charger les polices avec support Unicode
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Récupérer les items de la transaction
    // Note: Dans une implémentation complète, il faudrait ajouter
    // un endpoint pour récupérer les TransactionItems
    // Pour l'instant, on utilise les données de base de la transaction

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(),
              pw.SizedBox(height: 30),

              // Informations de vente
              _buildSaleInfo(transaction, seller),
              pw.SizedBox(height: 20),

              // Séparateur
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),

              // Tableau des articles
              _buildItemsTable(items),
              pw.SizedBox(height: 20),

              // Séparateur
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),

              // Total
              _buildTotal(transaction),
              pw.SizedBox(height: 30),

              // Footer
              pw.Spacer(),
              _buildFooter(transaction),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Construit l'en-tête du reçu
  pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'AirBar',
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Bar d\'Aéro-club',
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'REÇU DE VENTE',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Construit les informations de vente
  pw.Widget _buildSaleInfo(Transaction transaction, User seller) {
    final paymentMethodLabel = transaction.paymentMethod == PaymentMethod.cash
        ? 'Espèces'
        : 'Carte bancaire';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildInfoRow('N° Transaction:', '#${transaction.id}'),
        pw.SizedBox(height: 8),
        _buildInfoRow('Date:', _dateFormat.format(transaction.timestamp)),
        pw.SizedBox(height: 8),
        _buildInfoRow('Vendeur:', '${seller.firstName} ${seller.lastName}'),
        pw.SizedBox(height: 8),
        _buildInfoRow('Mode de paiement:', paymentMethodLabel),
      ],
    );
  }

  /// Construit le tableau des articles
  pw.Widget _buildItemsTable(List? items) {
    if (items == null || items.isEmpty) {
      return pw.Text(
        'Aucun article',
        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Articles achetés',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // En-tête du tableau
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              children: [
                _buildTableCell('Article', isHeader: true),
                _buildTableCell('Qté', isHeader: true, align: pw.TextAlign.center),
                _buildTableCell('Prix unit.', isHeader: true, align: pw.TextAlign.right),
                _buildTableCell('Sous-total', isHeader: true, align: pw.TextAlign.right),
              ],
            ),
            // Lignes des articles
            ...items.map((item) {
              final displayName = item.portion != null 
                  ? '${item.product.name} - ${item.portion.name}'
                  : item.product.name;
              final effectivePrice = item.portion?.price ?? item.product.price;
              final subtotal = effectivePrice * item.quantity;

              return pw.TableRow(
                children: [
                  _buildTableCell(displayName),
                  _buildTableCell('${item.quantity}', align: pw.TextAlign.center),
                  _buildTableCell(_formatCurrency(effectivePrice), align: pw.TextAlign.right),
                  _buildTableCell(_formatCurrency(subtotal), align: pw.TextAlign.right),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  /// Construit une cellule de tableau
  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  /// Construit une ligne d'information
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 150,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  /// Construit la section total
  pw.Widget _buildTotal(Transaction transaction) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'TOTAL',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            _formatCurrency(transaction.totalAmount),
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le pied de page
  pw.Widget _buildFooter(Transaction transaction) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 10),
        pw.Text(
          'Merci de votre visite',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Document généré le ${_dateFormat.format(DateTime.now())}',
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }
}
