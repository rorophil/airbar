import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

/// Sauvegarde de fichiers pour plateformes IO (Desktop/Mobile)
///
/// Implémentation de la sauvegarde de fichiers pour:
/// - macOS, Windows, Linux (Desktop)
/// - iOS, Android (Mobile)
///
/// Fonctionnement:
/// 1. Affiche un dialog de sélection de dossier (FilePicker.platform.getDirectoryPath)
/// 2. L'utilisateur choisit où sauvegarder le fichier
/// 3. Le fichier est écrit dans le dossier sélectionné avec le nom fourni
/// 4. Retourne le chemin complet du fichier sauvegardé
///
/// Gestion d'erreurs:
/// - Si l'utilisateur annule: retourne null
/// - Si erreur d'écriture: exception propagée au caller
///
/// Compatibilité paths:
/// - Utilise path.join() pour compatibilité Windows (\) et Unix (/)
/// - Encode le contenu en UTF-8 pour support caractères spéciaux
///
/// [content] Contenu du fichier (ex: CSV)
/// [fileName] Nom du fichier avec extension (ex: "Export.csv")
///
/// Returns: Chemin complet du fichier sauvegardé, ou null si annulation
Future<String?> saveFile(String content, String fileName) async {
  print('=== DEBUG: saveFile called with fileName: $fileName ===');

  // Ask user to select a directory (works on macOS, Windows, Linux)
  print('DEBUG: Opening directory picker...');
  String? directoryPath = await FilePicker.platform.getDirectoryPath(
    dialogTitle: 'Choisir un dossier pour enregistrer le fichier',
  );

  print('DEBUG: Directory path selected: $directoryPath');

  if (directoryPath == null) {
    // User canceled the picker
    print('DEBUG: User cancelled directory picker');
    return null;
  }

  // Write the file in the selected directory
  // Use path.join for cross-platform compatibility (Windows uses \ and macOS/Linux use /)
  final filePath = path.join(directoryPath, fileName);
  print('DEBUG: Writing file to: $filePath');

  final file = File(filePath);
  await file.writeAsString(content, encoding: utf8);

  print('DEBUG: File written successfully');
  return filePath;
}
