import 'dart:typed_data';
import 'dart:html' as html;
import 'package:get/get.dart';

Future<void> downloadPdf(Uint8List bytes, String filename) async {
  try {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);

    Get.snackbar(
      'Succès',
      'Le reçu PDF a été téléchargé',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    Get.snackbar(
      'Erreur',
      'Impossible de télécharger le PDF: $e',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
