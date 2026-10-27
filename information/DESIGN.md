---
name: AirBar
description: Application de gestion de bar pour aéro-clubs associatifs
colors:
  primary-blue: "#2196F3"
  primary-blue-dark: "#1976D2"
  primary-blue-light: "#64B5F6"
  accent-orange: "#FF9800"
  accent-orange-dark: "#F57C00"
  accent-orange-light: "#FFB74D"
  success-green: "#4CAF50"
  error-red: "#F44336"
  warning-orange: "#FF9800"
  info-blue: "#2196F3"
  neutral-bg: "#F5F5F5"
  neutral-surface: "#FFFFFF"
  neutral-surface-dark: "#424242"
  text-primary: "#212121"
  text-secondary: "#757575"
  text-hint: "#BDBDBD"
  text-white: "#FFFFFF"
  stock-ok: "#4CAF50"
  stock-low: "#FF9800"
  stock-out: "#F44336"
typography:
  display:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "32sp"
    fontWeight: 700
    lineHeight: 1.2
  headline:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "24sp"
    fontWeight: 600
    lineHeight: 1.3
  title:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "18sp"
    fontWeight: 600
    lineHeight: 1.4
  body:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "16sp"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Roboto, system-ui, sans-serif"
    fontSize: "14sp"
    fontWeight: 500
    lineHeight: 1.4
rounded:
  sm: "8px"
  md: "12px"
spacing:
  xs: "8px"
  sm: "12px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  xxl: "60px"
components:
  button-elevated:
    backgroundColor: "{colors.primary-blue}"
    textColor: "{colors.text-white}"
    rounded: "{rounded.sm}"
    padding: "16px 24px"
  button-elevated-hover:
    backgroundColor: "{colors.primary-blue-dark}"
  card:
    backgroundColor: "{colors.neutral-surface}"
    rounded: "{rounded.md}"
    padding: "16px"
  input:
    backgroundColor: "{colors.neutral-surface}"
    textColor: "{colors.text-primary}"
    rounded: "{rounded.md}"
    padding: "16px"
  appbar:
    backgroundColor: "{colors.primary-blue}"
    textColor: "{colors.text-white}"
    height: "56px"
---

# Design System: AirBar

## Overview

**Creative North Star: "Le Tableau de Bord d'Aéroport"**

AirBar s'inspire de l'interface fonctionnelle d'un tableau de bord d'aéroport : lisible à distance, immédiatement compréhensible, fiable sous pression. Chaque interaction est directe et prévisible. Les couleurs portent du sens opérationnel (bleu horizon pour la structure, orange balise pour l'action), jamais de la décoration. La densité reste aérée même sur tablette partagée en permanence de bar, avec des cibles tactiles généreuses adaptées à tous les âges.

Le système refuse le bruit visuel et les effets gratuits. Les états (stock, succès, erreur) s'expriment par la couleur, pas par des icônes redondantes. La hiérarchie visuelle repose sur le poids typographique et l'espacement, rarement sur la couleur seule. Les animations sont strictement fonctionnelles (feedback d'action, transitions de navigation).

Cette sobriété délibérée honore le contexte associatif : pas de dark patterns, pas de gamification forcée, pas de pression commerciale. L'interface sert l'utilisateur et s'efface dès la tâche accomplie.

**Key Characteristics:**
- Fonctionnel et sobre, jamais décoratif
- Lisibilité maximale en toutes conditions (hangar, lumière variable)
- Hiérarchie claire par le poids typographique et l'espacement
- Couleurs sémantiques portant du sens opérationnel
- Cibles tactiles généreuses (accessibilité intergénérationnelle)
- Cohérence Material Design 3 avec personnalité légère

## Colors

Le système repose sur deux accents principaux dérivés de Material Design, choisis pour leur clarté sémantique immédiate et leur accessibilité. Les couleurs de statut (stock, succès, erreur) sont fonctionnelles avant d'être décoratives.

### Primary
- **Bleu Horizon d'Aéroport** (#2196F3): Couleur structurelle principale. Utilisée pour les AppBars, navigation, boutons primaires, et tous les éléments de confiance et de continuité. Son évocation aéronautique renforce l'identité aéro-club sans lourdeur thématique.
- **Bleu Horizon Sombre** (#1976D2): Variante pour survols, états actifs, et thème sombre. Renforce le contraste sans casser l'unité chromatique.
- **Bleu Horizon Clair** (#64B5F6): Fond pour badges, états légers, et focus sans bloquer la lecture.

### Secondary
- **Orange Balise** (#FF9800): Couleur d'action et d'alerte visuelle. Réservée aux boutons secondaires, badges de statut "stock faible", et moments nécessitant l'attention (pas l'alarme). Son rôle est fonctionnel : guider l'œil vers les points de décision.
- **Orange Balise Sombre** (#F57C00): Survol et états actifs des composants secondaires.
- **Orange Balise Clair** (#FFB74D): Fonds légers pour indicateurs non critiques.

### Status Colors
- **Vert Succès** (#4CAF50): Stock OK, transactions validées, états positifs. Standard Material pour cohérence cross-platform.
- **Rouge Erreur** (#F44336): Rupture de stock, échecs de transaction, validations bloquantes. Utilisé avec parcimonie pour préserver son poids sémantique.
- **Orange Avertissement** (#FF9800): Stock faible, actions réversibles nécessitant attention. Partage la teinte de l'accent secondaire pour unité visuelle.
- **Bleu Info** (#2196F3): Messages informatifs non bloquants. Réutilise le primaire pour éviter la prolifération chromatique.

### Neutral
- **Gris Fond Clair** (#F5F5F5): Fond principal de l'application. Contraste doux avec les surfaces blanches sans fatigue visuelle.
- **Blanc Surface** (#FFFFFF): Cartes, modales, champs de saisie. Élévation visuelle par contraste avec le fond, pas par ombre lourde.
- **Gris Sombre Surface** (#424242): Fond pour thème sombre (prévu mais non prioritaire actuellement).
- **Noir Texte** (#212121): Texte principal. Presque noir pour contraste maximal sans dureté du noir pur.
- **Gris Texte Secondaire** (#757575): Labels, descriptions, métadonnées. Hiérarchie claire avec le texte primaire.
- **Gris Placeholder** (#BDBDBD): Indices de saisie, états désactivés. Suffisamment clair pour ne pas parasiter, suffisamment visible pour guider.
- **Blanc Texte** (#FFFFFF): Texte sur fonds foncés (AppBar, boutons primaires).

### Named Rules

**The Semantic First Rule.** Toute utilisation de couleur doit porter du sens fonctionnel ou structurel. Les couleurs de statut (vert/orange/rouge) sont strictement réservées à leurs rôles sémantiques (stock, succès, erreur). Ne jamais utiliser le rouge pour décorer, ni le vert pour attirer l'œil sans raison opérationnelle.

**The 10% Accent Rule.** L'orange balise apparaît sur ≤10% de tout écran donné. Sa rareté garantit son efficacité. Les boutons primaires restent bleus ; l'orange est réservé aux actions secondaires ou aux états nécessitant attention.

## Typography

**Display Font:** Roboto (système Android/Material), avec fallback system-ui, sans-serif
**Body Font:** Roboto (cohérence totale)
**Label/Mono Font:** Roboto (pas de police monospace distincte)

**Character:** Roboto apporte la neutralité fonctionnelle attendue d'une interface utilitaire. Son dessin clair et ses métriques généreuses garantissent la lisibilité sur tablettes partagées et en conditions de lumière variable (hangar, clubhouse). L'absence de police custom renforce la cohérence cross-platform (iOS utilise San Francisco via Material Design adaptation) et évite les problèmes de chargement ou de rendu.

### Hierarchy

- **Display** (700, 32sp, 1.2): Titre principal de l'application (écran login). Utilisé une fois par vue pour ancrer l'identité. Taille responsive via FlutterScreenUtil (.sp).
- **Headline** (600, 24sp, 1.3): Titres de sections principales (dashboard admin, en-têtes de modules). Hiérarchie forte sans agressivité.
- **Title** (600, 18sp, 1.4): Titres de cartes, dialogues, en-têtes de listes. Crée la structure interne des vues.
- **Body** (400, 16sp, 1.5): Texte courant, descriptions, contenu de formulaires. Taille de référence optimisée pour lisibilité à bras tendu (tablette sur comptoir). Line-height aérée pour confort de lecture prolongée.
- **Label** (500, 14sp, 1.4): Labels de formulaires, badges, métadonnées, timestamps. Poids medium (500) pour visibilité sans compétition avec le body.

### Named Rules

**The Single Weight Per Role Rule.** Chaque niveau typographique a un poids unique et immuable. La hiérarchie se construit par la taille et l'espacement, jamais par variation du poids au sein d'un rôle. Exception : emphase inline dans le body (italic, pas bold).

**The Responsive Unit Rule.** Toutes les tailles utilisent `.sp` (FlutterScreenUtil) pour adaptation proportionnelle aux écrans. Les valeurs en pixels fixes sont interdites sauf pour les icônes système ou les composants Material natifs.

## Layout

AirBar utilise FlutterScreenUtil (référence iPhone X : 375×812 dp) pour adaptation responsive proportionnelle. Tous les espacements, tailles et rayons utilisent les unités `.w` (largeur), `.h` (hauteur), `.sp` (police), `.r` (rayon).

**Spacing rhythm:** Échelle basée sur 8px (8, 12, 16, 24, 32, 60). Les valeurs intermédiaires (10, 14, 20) sont évitées pour cohérence du rythme vertical. Le padding interne des cartes et composants suit 16px standard ; les marges inter-éléments utilisent 8, 12, ou 16 selon la densité de la zone.

**Container behavior:** Pas de largeur maximale stricte (l'app cible tablettes et mobiles). Les vues utilisent `SafeArea` pour éviter les notches et barres système. Les listes denses (transactions, stock) utilisent padding horizontal 16.w ; les formulaires et détails utilisent 24.w pour confort de lecture.

**Responsive breakpoints:** Pas de breakpoints explicites ; FlutterScreenUtil adapte proportionnellement. Les layouts restent single-column sur mobile/tablette (pas de grilles complexes). La densité s'ajuste via les unités `.w/.h`, pas par restructuration conditionnelle.

**Grid:** Pas de grille 12-colonnes formelle. Les layouts reposent sur `Column`, `Row`, `Expanded`, et `Flexible` avec spacing constant (8, 16, 24). Les listes utilisent `ListView.builder` avec separators ou margins fixes.

**Density:** Aérée par défaut pour accessibilité tactile (cibles 48dp minimum en équivalent Flutter). Les listes denses (admin) réduisent légèrement le padding vertical (12.h au lieu de 16.h) sans compromettre les cibles de tap.

## Elevation & Depth

AirBar adopte une approche **presque plate** avec élévation subtile. La profondeur se construit par **contraste de surface** (fond gris #F5F5F5 vs cartes blanches #FFFFFF) plutôt que par ombres prononcées. Les ombres existent mais restent discrètes, réservées aux moments où l'élément doit flotter visuellement au-dessus du plan (modales, menus contextuels).

**Philosophy:** L'élévation sert la hiérarchie fonctionnelle, pas l'effet visuel. Une carte de produit n'a pas besoin de "sortir de l'écran" ; le contraste de couleur et le rayon suffisent. Les ombres marquent les **états transitoires** (hover sur bouton, ouverture de menu) ou les **surfaces modales** (dialogues, bottom sheets).

### Shadow Vocabulary

- **Card Resting** (`elevation: 2` — Material standard, ~4dp blur, #000000 12% opacity): Ombre standard des cartes au repos. Subtile, à peine perceptible sur fond gris clair, suffisante pour détacher visuellement.
- **AppBar** (`elevation: 0`): Pas d'ombre. La couleur pleine (#2196F3) crée la séparation visuelle avec le contenu scrollable en dessous.
- **Dialog / BottomSheet** (`elevation: 8` — Material standard, ~16dp blur): Élévation marquée pour signaler la modalité et l'interruption du flux. L'ombre renforce la séparation du contexte sous-jacent (souvent obscurci par overlay).
- **Button Hover** (pas d'élévation Material ; changement de couleur uniquement): Les boutons ElevatedButton ne flottent pas au hover. Le feedback est chromatique (primary → primaryDark), pas spatial.

### Named Rules

**The Flat-By-Default Rule.** Les surfaces sont plates au repos. Les ombres apparaissent uniquement pour signaler une **interruption du plan** (modale) ou un **état interactif** (menu déroulant ouvert). Jamais pour décorer une carte de liste au repos.

**The Color-Over-Shadow Rule.** Quand le contraste de couleur suffit à créer la séparation visuelle, l'ombre est omise. Exemple : AppBar bleue sur fond blanc/gris ne nécessite aucune shadow ; la couleur fait le travail.

## Shapes

Le langage formel d'AirBar repose sur des **rayons arrondis modérés** (8–12px) et des **bords nets sans ornement**. Pas de formes organiques, pas de découpes complexes, pas de bordures décoratives. La forme suit la fonction : les rayons adoucissent juste assez pour éviter l'agressivité industrielle, mais restent cohérents avec la sobriété fonctionnelle du système.

**Corner Philosophy:** Tous les composants interactifs (boutons, cartes, champs) ont des coins arrondis. Les valeurs fixes (8px, 12px) créent une hiérarchie subtile : les petits composants (boutons, badges) utilisent 8px ; les surfaces plus larges (cartes) utilisent 12px. Pas de rayons asymétriques, pas de formes pill (radius 999px).

**Border Treatment:** Les bordures sont fonctionnelles, jamais décoratives. Les champs de saisie utilisent `OutlineInputBorder` avec stroke 1px (couleur adaptative selon focus/error). Les cartes n'ont **pas de bordure** ; l'élévation et le contraste de surface suffisent. Les bordures colorées (rouge pour erreur, bleu pour focus) signalent des états, pas du style.

**Clipping:** Pas de clip-path complexes ou de masques SVG. Les images et contenus débordants utilisent `ClipRRect` avec les rayons standard (8 ou 12px) pour cohérence avec les containers.

**Recurring Forms:**
- **Cartes de liste** : Rectangle arrondi 12px, fond blanc, pas de bordure, élévation 2.
- **Boutons** : Rectangle arrondi 8px, padding horizontal généreux (24px), hauteur standard Material (48dp).
- **Champs de saisie** : Rectangle arrondi 8–12px, filled background blanc, outline au focus.
- **Dialogues** : Rectangle arrondi 12px, élévation 8, padding interne 24px.

## Components

Tous les composants suivent Material Design 3 avec légère personnalisation via AppTheme. Le système privilégie les composants natifs Flutter (ElevatedButton, Card, TextFormField) sur les recréations custom, garantissant cohérence cross-platform et accessibilité.

### Buttons

**Character:** Clairs, tactiles, confiants. Pas de subtilité excessive ; un bouton doit être immédiatement identifiable comme tel.

- **Shape:** Rectangle arrondi 8px (rounded.sm). Surface pleine, pas d'outline ou de bouton ghost sauf cas spécifiques (boutons tertiaires en attente de design).
- **Primary (ElevatedButton):** Fond bleu primaire (#2196F3), texte blanc (#FFFFFF), padding 16×24 (vertical × horizontal). Élévation Material standard (~2dp au repos). Utilisé pour actions principales (Connexion, Valider, Confirmer).
- **Hover / Focus:** Fond passe à bleu foncé (#1976D2). Pas de changement d'élévation. Transition couleur 200ms ease. Focus ring Material standard (glow bleu).
- **Secondary / Accent:** Fond orange balise (#FF9800), texte blanc. Même shape et padding. Réservé aux actions secondaires nécessitant attention (Ajouter produit, Créditer compte). Hover → orange foncé (#F57C00).
- **Disabled:** Opacité 50%, texte gris hint (#BDBDBD). Pas d'interaction, pas de hover.

### Cards

**Character:** Conteneurs sobres et effacés, jamais compétitifs avec leur contenu.

- **Corner Style:** 12px (rounded.md). Assez arrondi pour douceur tactile, pas assez pour effet "bubble".
- **Background:** Blanc (#FFFFFF) sur fond gris application (#F5F5F5). Contraste suffisant sans border nécessaire.
- **Shadow Strategy:** Élévation 2 (Material standard card resting). Ombre discrète, juste assez pour détacher du fond. Pas d'augmentation au hover (cartes ne sont pas toujours interactives).
- **Border:** Aucune. Le contraste fond + élévation fait le travail. Exception : état sélectionné dans listes (border 2px bleue).
- **Internal Padding:** 16px (spacing.md) standard. Augmenté à 20–24px pour cartes de formulaire ou détails nécessitant respiration.
- **Content Hierarchy:** Titre (title 18sp bold) en haut, métadonnées (label 14sp) en dessous ou en badges, actions en bas alignées à droite.

### Inputs / Fields

**Character:** Clairs, guidants, jamais ambigus.

- **Style:** `OutlineInputBorder` avec filled background blanc (#FFFFFF). Radius 8–12px selon contexte (formulaires denses 8px, modales 12px). Border grise neutre (#BDBDBD) au repos.
- **Focus:** Border passe à bleu primaire (#2196F3), width 2px. Léger glow bleu (Material standard). Transition 150ms.
- **Error:** Border rouge (#F44336), texte d'aide rouge en dessous. Icône error optionnelle dans suffix.
- **Disabled:** Background gris très clair, texte gris hint (#BDBDBD), border grise pale. Pas d'interaction.
- **Label:** Floating label Material standard. Police label 14sp, couleur texte secondaire (#757575), monte et réduit au focus.
- **Prefix/Suffix Icons:** Icons Material standard (Icons.email_outlined, Icons.lock_outline). Taille 20–24dp, couleur texte secondaire. Deviennent bleu primaire au focus.

### Icons

**Source:** Material Icons (Flutter default). Cohérence totale avec Material Design, compatibilité cross-platform garantie.

- **Taille standard:** 20–24dp pour icônes inline (prefix/suffix de champs), 40–48dp pour icônes standalone (logo app), 16–18dp pour badges ou labels.
- **Couleur:** Texte secondaire (#757575) par défaut. Bleu primaire (#2196F3) pour états actifs/focus. Couleurs sémantiques (vert/orange/rouge) pour statuts.
- **Style:** `outlined` pour icônes de navigation et formulaires (Icons.email_outlined). `filled` pour actions primaires (Icons.add, Icons.delete). Jamais de mix outlined/filled dans le même contexte.

### Navigation

**AppBar (Top):**
- **Style:** Fond bleu primaire (#2196F3), texte blanc (#FFFFFF). Hauteur standard Material 56dp.
- **Typography:** Title 18sp medium, centré (centerTitle: true).
- **Elevation:** 0 (flat). La couleur crée la séparation visuelle.
- **Icons:** Blanc, taille 24dp. Leading (back, menu), trailing (actions contextuelles max 2–3).

**Bottom Navigation / Tab Bar:**
- Pas encore implémenté dans l'existant. Future extension probable pour navigation utilisateur rapide (Boutique / Panier / Historique).

**Drawer (si applicable):**
- Pas présent actuellement. Navigation se fait via GetX routing programmatique.

### Dialogs / Modals

- **Shape:** Rectangle arrondi 12px, padding interne 24px.
- **Elevation:** 8 (élévation marquée pour modalité).
- **Background:** Blanc, overlay sombre 60% opacity sur contenu sous-jacent.
- **Actions:** Boutons alignés à droite (Material standard), spacing 8px entre eux. Bouton primaire à droite (Confirmer), secondaire/cancel à gauche.

## Do's and Don'ts

Règles dérivées de l'implémentation existante et des principes PRODUCT.md. Ces guardrails sont concrets, mesurables, et ancrés dans les choix déjà établis.

### Do:

- **Do** utiliser les couleurs sémantiques (vert/orange/rouge) **uniquement** pour leurs rôles fonctionnels (stock, succès, erreur). Pas de vert décoratif, pas de rouge pour attirer l'œil sans raison.
- **Do** respecter la hiérarchie typographique établie (Display 32sp, Headline 24sp, Title 18sp, Body 16sp, Label 14sp). Pas de tailles intermédiaires, pas de surcharge de poids.
- **Do** utiliser FlutterScreenUtil (.w, .h, .sp, .r) pour **toutes** les dimensions responsive. Les valeurs fixes en pixels cassent l'adaptation cross-device.
- **Do** maintenir les cibles tactiles ≥48dp (équivalent Flutter). Spacing minimum 8dp entre éléments interactifs adjacents.
- **Do** utiliser Material Icons exclusivement. Pas de mix avec des icon sets externes (FontAwesome, custom SVG) sauf assets métier spécifiques (logos partenaires).
- **Do** préserver l'élévation discrète (cards elevation 2, dialogs 8). Pas d'ombres lourdes ou de drop shadows custom.
- **Do** garder les rayons constants (8px pour boutons/petits composants, 12px pour cartes/surfaces). Pas de rayons asymétriques ou pill shapes.

### Don't:

- **Don't** utiliser l'orange balise (#FF9800) sur >10% de tout écran. Sa rareté est sa force.
- **Don't** ajouter de polices custom sans raison produit forte. Roboto/système garantit la cohérence cross-platform et la lisibilité.
- **Don't** créer de composants custom quand Material Design fournit l'équivalent (boutons, champs, cartes). Privilégier la personnalisation via ThemeData sur la recréation.
- **Don't** superposer bordures + ombres + couleurs de fond sur un même composant. Une séparation visuelle suffit (contraste de couleur OU élévation, rarement les deux).
- **Don't** utiliser des transitions/animations de >300ms. Les feedbacks sont instantanés (150–200ms) ou inexistants. Pas d'effet "wow" gratuit.
- **Don't** inventer des couleurs hors de la palette AppColors. Toute nouvelle teinte doit rejoindre la palette centralisée et documentée ici.
- **Don't** casser la cohérence Material pour "se démarquer". L'identité vient de la palette et de la sobriété, pas de l'invention de patterns custom.
