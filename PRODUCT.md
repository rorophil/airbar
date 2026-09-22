# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Stack

Flutter (multiplateforme) + Serverpod (backend) + PostgreSQL + GetX (state management). Choix déjà établi par le projet existant.

## Users

**Permanenciers de bar** — Membres bénévoles tenant le bar durant les heures d'ouverture de l'aéro-club, servant à la fois les membres du club et des visiteurs extérieurs. Utilisent l'app sur une tablette ou un ordinateur partagé au bar.

**Administrateurs** — Gestionnaires administratifs (trésoriers, responsables) gérant le stock, les comptes membres, et supervisant les transactions. Accès distant depuis leur ordinateur.

**Membres pilotes** — Membres de l'aéro-club (pilotes, mécaniciens, passionnés) achetant au bar après un vol ou pendant les pauses. Utilisent leur compte prépayé pour des achats sans manipulation d'espèces.

## Product Purpose

AirBar digitalise la gestion du bar d'un aéro-club associatif, remplaçant cahiers papier et caisse manuelle par un système qui :
- Permet aux membres d'acheter instantanément avec leur solde de compte (pas de cash à chaque transaction)
- Offre une caisse fonctionnelle pour les visiteurs extérieurs payant directement
- Donne aux administrateurs un contrôle complet sur stock, prix, utilisateurs et transactions
- Simplifie la gestion collaborative par des bénévoles non-professionnels

Le succès se mesure à la fluidité des achats en permanence (pas de file d'attente) et à la transparence comptable pour l'association.

## Positioning

**Système de compte membre avec solde prépayé** — Les membres rechargent leur compte à l'avance et achètent sans manipulation d'argent lors de chaque transaction, ce qu'un système de caisse classique n'offre pas. Cette mécanique de "crédit club" est centrale à la gestion associative et élimine les manipulations répétées de paiement.

**Double mode de vente** — L'app combine une interface boutique pour membres connectés (solde de compte) ET une caisse point-of-sale pour extérieurs (paiement direct), là où les solutions existantes sont soit l'un, soit l'autre.

**Gestion stock adaptée aux produits en vrac** — Supporte nativement les fûts entamés, portions servies (25cl, 50cl), et déduction intelligente du stock sur produits consommables, une complexité que les systèmes génériques ne couvrent pas.

## Operating Context

- **Environnement physique** : Hangar ou clubhouse avec connexion Internet parfois instable. L'app doit tolérer des coupures temporaires et reprendre proprement.
- **Appareils partagés** : Tablette au bar et ordinateur du trésorier, utilisés par plusieurs personnes. Authentification rapide par code PIN (pas de mot de passe complexe).
- **Rythme d'usage** : Pics d'activité le week-end et après les vols en soirée. Calme en semaine.
- **Futures extensions** : Utilisation mobile probable pour les membres via leur smartphone.

## Capabilities and Constraints

**Fonctionnalités confirmées :**
- Gestion de comptes membres avec solde, crédit/débit, historique de transactions
- Boutique produits avec catégories, gestion de stock, alertes de stock faible
- Support produits réguliers ET produits en vrac (fûts, portions servies)
- Mode caisse pour ventes aux extérieurs (sans compte membre)
- Gestion administrative complète (utilisateurs, produits, transactions, stock)
- Authentification par code PIN à 6 chiffres (SHA256)
- Soft delete des produits (préservation de l'historique)

**Contraintes techniques :**
- Application Flutter cross-platform (iOS, Android, Web, macOS)
- Backend Serverpod avec base PostgreSQL
- Architecture Repository Pattern avec GetX pour state management
- Pas de persistance de session entre lancements (reconnexion obligatoire)

**Terminologie établie :**
- "Membre" = utilisateur avec compte prépayé
- "Produit en vrac" = fût, bouteille consignée, etc. avec unité entamée
- "Portion" = taille de service (25cl, 50cl) pour produits en vrac
- "Caisse" / "Mode caisse" = vente directe pour extérieurs

## Brand Commitments

Aucun logo, charte graphique ou identité visuelle établie. Le nom "AirBar" est confirmé.

Tonalité souhaitée : Fonctionnelle et sobre, adaptée à un contexte associatif. Pas de marketing agressif ou gamification. L'interface doit inspirer confiance pour la manipulation d'argent et être accessible à tous les âges.

## Evidence on Hand

- Documentation complète du projet dans `/information/documentation-complete.md`
- Guide d'installation dans `/DEMARRAGE_RAPIDE.md`
- Instructions GitHub Copilot détaillées dans `/.github/copilot-instructions.md`
- Code source complet du frontend Flutter (`/lib/app/`) et backend Serverpod
- Screenshots et maquettes : **Aucune référence visuelle existante**

**Absences importantes :**
- Aucun témoignage utilisateur ou retour terrain documenté
- Pas de données de performance ou KPIs d'usage réel
- Pas de benchmark concurrentiel formel

## Product Principles

1. **Transparence d'abord** — Chaque transaction, mouvement de stock et opération admin laisse une trace vérifiable. L'historique est immuable et consultable.

2. **Simplicité collaborative** — L'interface s'adapte au niveau technique de bénévoles non-professionnels. Les tâches fréquentes (vente, ajout stock) sont rapides ; les tâches sensibles (gestion comptes) sont explicites.

3. **Fiabilité offline-ready** — L'app tolère les coupures réseau temporaires typiques d'un hangar. Les données critiques (soldes, stock) sont cohérentes même après reconnexion.

4. **Adaptabilité opérationnelle** — Le système supporte aussi bien les produits simples (canettes) que les cas complexes (fûts en portions), sans imposer de rigidité administrative.

5. **Respect du contexte associatif** — Pas de pression commerciale, pas de dark patterns. L'outil sert l'association, pas l'inverse.

## Accessibility & Inclusion

Aucune exigence d'accessibilité formelle établie, mais les permanenciers et administrateurs couvrent potentiellement plusieurs générations et niveaux de familiarité technologique. L'interface doit éviter les conventions trop "tech-savvy" et privilégier la clarté immédiate.
