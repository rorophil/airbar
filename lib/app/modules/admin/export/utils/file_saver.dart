/// Abstraction de sauvegarde de fichiers multi-plateforme
///
/// Ce fichier sert de point d'entrée unique pour la sauvegarde de fichiers,
/// en redirigeant automatiquement vers l'implémentation appropriée selon la plateforme:
/// - file_saver_io.dart: pour Desktop (macOS, Windows, Linux) et Mobile (iOS, Android)
/// - file_saver_web.dart: pour Web (navigateur)
///
/// La directive export conditionnel permet au compilateur Dart de choisir
/// l'implémentation correcte au moment de la compilation.
///
/// Usage depuis ExportController:
/// ```dart
/// import '../utils/file_saver.dart' as file_saver;
///
/// final path = await file_saver.saveFile(csvContent, fileName);
/// ```
///
/// Cette approche évite d'avoir du code spécifique à la plateforme dans le controller,
/// rendant le code plus propre et maintenable.
export 'file_saver_io.dart' if (dart.library.html) 'file_saver_web.dart';
