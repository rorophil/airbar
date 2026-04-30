import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

/// Save file on IO platforms (desktop/mobile)
/// Returns the file path if saved successfully, null if user cancelled
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
