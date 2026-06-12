import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

Future<void> downloadPdf(Uint8List bytes, String filename) async {
  try {
    // Demander à l'utilisateur où sauvegarder le fichier
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Sauvegarder le reçu PDF',
      fileName: filename,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (outputPath != null) {
      // Sauvegarder le fichier
      final file = File(outputPath);
      await file.writeAsBytes(bytes);

      Get.snackbar(
        'Succès',
        'Le reçu PDF a été sauvegardé',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } catch (e) {
    Get.snackbar(
      'Erreur',
      'Impossible de sauvegarder le PDF: $e',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
