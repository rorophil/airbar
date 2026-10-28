/// Helper de traçage pour le debug du cycle de vie des objets.
///
/// Branche de test (`feature/debugprint`) : permet de tracer dans la console
/// la création, la libération (quand un hook `dispose()`/`onClose()` existe)
/// et les appels de méthode de (quasi) toutes les classes du frontend.
///
/// Dart n'a pas de destructeur déterministe : [dispose] ne doit être appelé
/// que depuis un point de code explicite (ex: `onClose()` d'un
/// `GetxController`, ou une méthode `dispose()`/`close()` existante). Pour
/// les classes qui n'ont pas un tel point, il n'y a pas de trace de
/// libération fiable à produire.
class Trace {
  Trace._();

  /// Formate l'heure actuelle en `HH:mm:ss` pour préfixer chaque log.
  static String _timestamp() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }

  /// Trace la création d'un objet (1ère ligne d'un constructeur).
  static void create(String className, [String? info]) => print(
    '[${_timestamp()}] 🟢 [CREATE] $className${info != null ? ' ($info)' : ''}',
  );

  /// Trace la libération d'un objet (1ère ligne de `dispose()`/`onClose()`).
  static void dispose(String className, [String? info]) => print(
    '[${_timestamp()}] 🔴 [DISPOSE] $className${info != null ? ' ($info)' : ''}',
  );

  /// Trace l'appel d'une méthode (1ère ligne du corps de la méthode).
  static void call(String className, String method, [String? args]) => print(
    '[${_timestamp()}] ▶️ [CALL] $className.$method(${args ?? ''})',
  );
}
