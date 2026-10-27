# Addendum - À faire lors de la prochaine mise à jour du backend

**Contexte :** ces points sont volontairement reportés. Ils seront traités quand d'autres modifications du backend justifieront un redéploiement (pas de redéploiement dédié).

---

## 1. Contrôles de longueur côté serveur (mot de passe et PIN)

### Situation actuelle
Depuis octobre 2026, l'application Flutter contrôle les longueurs dans les dialogues de réinitialisation (`lib/app/modules/admin/users/controllers/users_controller.dart`) :
- mot de passe : 6 caractères minimum
- PIN : exactement 4 chiffres

Le **serveur n'effectue aucun contrôle** : un appel direct à l'API (hors application) peut encore définir un mot de passe ou un PIN invalide, et bloquer un membre (la connexion refuse un mot de passe de moins de 6 caractères, l'écran de paiement n'accepte que 4 chiffres).

### À faire
Fichier : `airbar_backend/airbar_backend_server/lib/src/endpoints/auth/user_endpoint.dart`

| Méthode | Contrôle à ajouter |
|---------|--------------------|
| `resetPassword` | refuser un mot de passe de moins de 6 caractères |
| `resetPin` | refuser un PIN qui n'est pas composé d'exactement 4 chiffres (`^[0-9]{4}$`) |
| `createUser` | mêmes règles : mot de passe ≥ 6 caractères et PIN de 4 chiffres |

Erreur à lever : `InvalidParametersException` avec un message en français, par exemple :
- « Le mot de passe doit contenir au moins 6 caractères »
- « Le code PIN doit contenir 4 chiffres »

### Notes techniques
- Seul le corps des endpoints change, pas les signatures : **pas de `serverpod generate`** nécessaire.
- Le serveur doit être **redéployé/redémarré** pour prendre en compte la modification.
- Côté Flutter, les messages affichés sont déjà alignés sur ceux ci-dessus.

### Après la mise à jour
- Mettre à jour `GUIDE_UTILISATEUR.md` (section « Réinitialiser un mot de passe ou un PIN ») pour mentionner que les règles sont aussi contrôlées par le serveur.
- Tester : réinitialisation avec mot de passe de 5 caractères (refus), PIN de 3 chiffres (refus), puis valeurs valides (succès) ; création d'un utilisateur avec valeurs invalides (refus).
