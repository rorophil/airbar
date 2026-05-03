// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

/// Sauvegarde de fichiers pour plateforme Web
///
/// Implémentation de la sauvegarde de fichiers pour navigateurs web.
///
/// Fonctionnement:
/// 1. Convertit le contenu en bytes UTF-8
/// 2. Crée un Blob (Binary Large Object) contenant les données
/// 3. Génère une URL temporaire pointant vers le blob
/// 4. Crée un élément <a> invisible avec attribut download
/// 5. Simule un clic pour déclencher le téléchargement
/// 6. Nettoie (supprime élément et révoque URL)
///
/// Comportement navigateur:
/// - Chrome/Edge: téléchargement direct dans dossier par défaut
/// - Firefox: peut afficher dialog "Enregistrer sous"
/// - Safari: téléchargement dans dossier Téléchargements
///
/// Limitations Web:
/// - Pas de sélection manuelle du dossier de destination
/// - Nom de fichier peut être modifié par le navigateur selon paramètres
/// - Téléchargements multiples peuvent déclencher popup de confirmation
///
/// [content] Contenu du fichier (ex: CSV)
/// [fileName] Nom du fichier suggéré au navigateur
///
/// Returns: Nom du fichier (toujours non-null sur Web, sauf exception)
Future<String?> saveFile(String content, String fileName) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = fileName;
  html.document.body?.children.add(anchor);

  anchor.click();

  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
  return fileName;
}
