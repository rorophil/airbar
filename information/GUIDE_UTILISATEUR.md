# 📱 AirBar - Guide Utilisateur

**Guide complet pour utiliser l'application de gestion du bar de l'aéro-club**

Version 1.1 - Octobre 2026

---

## 🔐 Système de Sécurité à Deux Niveaux

AirBar utilise **deux identifiants distincts** pour une sécurité renforcée :

1. **Email + Mot de passe** 📧
   - Pour **se connecter** à l'application
   - Donne accès à votre compte
   - Mot de passe minimum 6 caractères

2. **Code PIN** (4 chiffres) 🔢
   - Pour **valider vos achats** (et vos ventes en mode caisse)
   - Confirmation de sécurité lors du paiement
   - Exactement 4 chiffres

> 💡 **Pourquoi deux identifiants ?** C'est une double protection : même si quelqu'un connaît votre mot de passe, il ne pourra pas effectuer d'achats sans votre PIN.

---

## 📋 Table des matières

1. [Système de sécurité](#système-de-sécurité-à-deux-niveaux)
2. [Premiers pas](#premiers-pas)
3. [Connexion à l'application](#connexion)
4. [Interface utilisateur - Boutique](#boutique)
5. [Panier et achat](#panier-et-achat)
6. [Mode Caisse](#mode-caisse)
7. [Espace Administrateur](#espace-administrateur)
8. [Questions fréquentes](#faq)

---

## 🚀 Premiers pas {#premiers-pas}

### Qu'est-ce qu'AirBar ?

AirBar est l'application de gestion du bar de votre aéro-club. Elle vous permet de :
- 🛒 Acheter des produits (boissons, snacks, etc.)
- 💳 Payer avec votre compte de membre
- 👤 Consulter votre solde (affiché en haut de la boutique et du panier)
- 💰 Recharger votre compte (via l'administrateur)
- 💵 **Mode caisse** : Vendre au comptant à des clients de passage

**Comment ça marche ?**
1. Connectez-vous avec votre **email et mot de passe**
2. Ajoutez des produits à votre panier
3. Validez votre panier avec **"Valider la commande"**, puis confirmez avec votre **code PIN** (4 chiffres)
4. Votre compte est débité automatiquement

**Mode caisse (vente au comptant) :**
1. Cliquez sur l'icône **Mode Caisse** dans la barre du haut de la boutique
2. Sélectionnez les produits pour le client
3. Cliquez sur **"Valider"** puis choisissez le mode de paiement (espèces ou carte bancaire)
4. Entrez **votre** PIN (traçabilité du vendeur) et confirmez la vente
5. Encaissez le paiement du client

### Installation

L'application peut être installée sur :
- 💻 **macOS** et 🪟 **Windows** : application de bureau
- 🌐 **Web** : dans un navigateur
- 📱 **Android** et **iOS** : application mobile

> 📝 **Note :** Les versions réellement disponibles dépendent de ce que votre club a déployé. Renseignez-vous auprès de votre administrateur.

> ⚠️ **Connexion internet obligatoire :** AirBar fonctionne avec un serveur. Sans connexion, la connexion à l'application est impossible (message « Pas de connexion internet. ») et un bandeau ou un message « Connexion perdue » vous avertit si le réseau disparaît en cours d'utilisation.

**Première utilisation :**
1. Lancez l'application
2. Configurez l'adresse du serveur (fournie par votre club) - voir [Configuration du serveur](#configuration-du-serveur-première-utilisation)
3. Demandez à un administrateur de créer votre compte (il n'y a pas d'inscription depuis l'application)
4. Connectez-vous avec votre email et mot de passe

---

## 🔐 Connexion à l'application {#connexion}

### Écran de connexion

<img src="docs/screenshots/login.png" alt="Écran de connexion" width="400"/>

L'écran affiche le logo AirBar, les champs **Email** et **Mot de passe**, le bouton **"Connexion"** et, en bas, le bouton **"Configuration serveur"**.

1. **Ouvrez l'application** AirBar (un écran de démarrage s'affiche 2 secondes)
2. **Entrez votre email** (celui fourni lors de votre inscription)
3. **Entrez votre mot de passe**
   - 👁️ Cliquez sur l'icône œil pour afficher/masquer votre mot de passe
4. **Appuyez sur "Connexion"** (ou sur la touche `Entrée` depuis le champ mot de passe)

**Après la connexion :**
- Un **membre** arrive sur la **Boutique**
- Un **administrateur** arrive sur le **tableau de bord « Administration »**
- Un message « Bienvenue Prénom Nom » s'affiche brièvement

**Messages d'erreur possibles :**
- « Email invalide » / « Veuillez entrer votre email » : l'adresse est mal saisie ou vide
- « Le mot de passe doit contenir au moins 6 caractères »
- « Email ou mot de passe incorrect, ou compte désactivé »
- « Le serveur ne répond pas (délai dépassé). Vérifiez la configuration serveur. »
- « Pas de connexion internet. »

> 💡 **Astuce :** Si vous avez oublié vos identifiants, contactez un administrateur du club (l'écran de connexion le rappelle : « Contactez l'administrateur pour obtenir vos identifiants »).

### Configuration du serveur (première utilisation)

Si c'est votre première connexion, ou si l'adresse du serveur a changé :

1. En bas de l'écran de connexion, cliquez sur **"Configuration serveur"**
2. Renseignez les champs, avec les informations fournies par votre club :
   - **Adresse du serveur** : nom de domaine ou adresse IP **sans** `http://` (exemples : `192.168.1.100`, `localhost`)
   - **Port** : par défaut `8080` (le port passe automatiquement à `443` quand vous activez la connexion sécurisée)
   - **Délai d'inactivité (minutes)** : durée sans utilisation avant la déconnexion automatique (voir [Sécurité](#sécurité)). Valeur de 0 à 120, `0` désactive la déconnexion automatique. Par défaut : 5 minutes.
   - **Connexion sécurisée (HTTPS)** : à activer pour les serveurs de test et de production ; à désactiver uniquement pour un serveur local de développement
3. Cliquez sur **"Tester la connexion"** : un message vert « Connexion au serveur réussie » s'affiche si le serveur répond
4. Cliquez sur **"Sauvegarder"** : vous revenez à l'écran de connexion

Le bouton **"Réinitialiser par défaut"** remet `localhost`, `8080`, HTTP et 5 minutes dans les champs ; il faut ensuite cliquer sur **"Sauvegarder"** pour les enregistrer. L'encadré **"Configuration actuelle"** en bas de l'écran affiche l'adresse (URL) utilisée.

### Sécurité

- ⚠️ L'application **ne sauvegarde jamais votre session** : vous devez vous reconnecter à chaque lancement
- ⏱️ **Déconnexion automatique après inactivité** : au bout de 5 minutes sans toucher l'écran (réglable de 0 à 120 minutes dans « Configuration serveur »), vous êtes ramené à l'écran de connexion avec le message « Session expirée »
- 🔒 Votre mot de passe et votre PIN ne sont jamais stockés en clair : ils sont chiffrés (SHA-256) sur le serveur
- 🚪 Pour vous déconnecter, utilisez l'icône **Déconnexion** en haut à droite (une confirmation est demandée), puis fermez l'application après utilisation

> 📝 **Note :** Vous avez deux identifiants distincts :
> - **Email + Mot de passe** : Pour vous connecter à l'application
> - **Code PIN** (4 chiffres) : Pour valider vos achats

---

## 🛒 Interface utilisateur - Boutique {#boutique}

### Vue d'ensemble

<img src="docs/screenshots/shop.png" alt="Boutique" width="600"/>

L'écran de la boutique se divise en plusieurs zones :

#### 1. Barre supérieure (bandeau bleu)
- 🏷️ **Titre « Boutique »**, puis **vos prénom et nom**
- 💰 **« Votre solde est de XX.XX € »** (texte simple, sans code couleur)
- À droite, quatre icônes :
  - 🛒 **Panier** : un badge rouge indique le nombre de lignes dans votre panier
  - 🧾 **Mode Caisse** (icône « caisse enregistreuse ») : accès à la vente au comptant
  - 🛡️ **Dashboard Admin** : visible **uniquement pour les administrateurs**
  - 🚪 **Déconnexion** : demande une confirmation

#### 2. Barre de recherche
- Toujours visible sous la barre du haut
- Tapez une partie du **nom ou de la description** d'un produit : la liste se filtre en temps réel
- Cliquez sur la croix pour effacer la recherche

#### 3. Filtres par catégories
- Une rangée de pastilles défilantes : **« Tous »** puis **toutes les catégories créées par les administrateurs** (par exemple Boissons, Snacks, etc. : la liste dépend de votre club)
- Cliquez sur une catégorie pour ne voir que ses produits

#### 4. Liste des produits

> 💡 Tirez la liste vers le bas (geste « pull to refresh ») pour recharger les produits et votre solde.

Deux types de produits sont affichés :

##### 🧃 Produits normaux (unités)
```
┌──────────────────────────────┐
│ [icône] Coca-Cola       🛒   │
│         Bouteille 33cl       │
│         2.50 €      📦 12    │
└──────────────────────────────┘
```
Chaque carte affiche l'icône de la catégorie, le nom, la description, le prix et le **nombre d'unités en stock** (coloré).

##### 🍺 Produits en vrac (portions)
```
┌──────────────────────────────┐
│ [icône] Bière pression  📦 5 │
│         [Produit en vrac]    │
│ Contenance: 6.0 litres       │
│ ──────────────────────────── │
│ 25cl  0.25 litres  1.80 € 🛒 │
│ 33cl  0.33 litres  2.20 € 🛒 │
│ 50cl  0.5 litres   2.80 € 🛒 │
└──────────────────────────────┘
```
Pour un produit en vrac, le nombre affiché en haut à droite est le **nombre d'unités complètes en réserve** (ici 5 fûts fermés), pas un volume en litres. Le fût déjà entamé n'est pas compté dans ce chiffre.

### Indicateurs de stock

Le nombre affiché sur chaque carte prend la couleur suivante :

| Couleur | Signification |
|---------|---------------|
| 🟢 **Vert** | Stock suffisant |
| 🟠 **Orange** | Stock faible (inférieur ou égal au seuil d'alerte fixé par l'administrateur) |
| 🔴 **Rouge** | Rupture de stock (0) : l'ajout au panier est impossible |

> 📝 **Note :** Pour les produits dont le **stock n'est pas géré** (café, eau en libre-service), la boutique n'affiche aucun nombre de stock et l'ajout au panier est toujours possible, comme en mode caisse. La mention **« N/A »** n'apparaît que dans l'espace administrateur.

### Acheter un produit

#### Produit normal (unités)

1. **Cliquez sur la carte du produit**
2. Une fiche s'ouvre par le bas : nom, description, prix, « Stock disponible »
3. **Saisissez la quantité** dans le champ « Quantité » (chiffres uniquement, `1` par défaut)
4. **Cliquez sur "Ajouter au panier" 🛒** (le bouton est grisé si le stock est à 0)
5. Un message « *Nom du produit* ajouté au panier » s'affiche en bas de l'écran

> 💡 **Exemple :** Coca-Cola à 2.50€ × 3 = 7.50€ (le total est visible dans le panier)

#### Produit en vrac (portions)

1. **Cliquez sur une portion** (25cl, 50cl, etc.) dans la carte du produit
2. Une boîte de dialogue s'ouvre avec :
   - Le nom de la portion et du produit
   - Le prix de la portion
   - La quantité de produit consommée (ex : 0.5 litres)
   - Un champ **« Quantité »** : le nombre de portions voulues
3. **Saisissez le nombre de portions** (1 par défaut)
4. **Cliquez sur "Ajouter au panier"** (ou sur **"Annuler"**)

> 💡 **Exemple :**
> - Portion : 50cl de bière à 2.80€
> - Quantité : 3 portions
> - Total : 8.40€
> - Consommation : 1.5L de bière

L'application vérifie que le volume restant (fûts fermés + fût entamé) suffit pour la quantité demandée. Sinon, un message « Stock insuffisant » indique ce qu'il reste.

> ⚠️ Si le stock de fûts fermés tombe à 0, les portions sont grisées dans la boutique, même s'il reste un peu de produit dans le fût entamé. Prévenez un administrateur pour réapprovisionner.

### Recherche d'un produit

Pour trouver rapidement un produit :

1. **Cliquez dans la barre de recherche** (en haut de la liste)
2. **Tapez le nom** du produit (ex: "coca")
3. Les produits correspondants s'affichent immédiatement
4. **Effacez la recherche** (croix) pour voir tous les produits

La recherche se combine avec le filtre de catégorie.

---

## 🛒 Panier et achat {#panier-et-achat}

### Accéder au panier

Cliquez sur **l'icône panier 🛒** (en haut à droite de la boutique). Il n'y a pas d'autre raccourci : le message qui s'affiche après un ajout est purement informatif.

### Gérer le panier

<img src="docs/screenshots/cart.png" alt="Panier" width="400"/>

#### Vue du panier

Le bandeau du haut affiche **« Panier »** et **« Votre solde est de XX.XX € »**. Chaque article affiche :
- 🏷️ **Nom du produit** (+ nom de la portion si applicable)
- 💰 **Prix unitaire** (« 2.50 € / unité »)
- 🔢 **Quantité** avec boutons `−` et `+`
- 💶 **Sous-total** de la ligne
- 🗑️ **Icône de suppression** (rouge)

Ajouter plusieurs fois le même produit (ou la même portion) **additionne** les quantités sur une seule ligne.

#### Modifier les quantités

- **Augmenter** : Appuyez sur `+`
- **Diminuer** : Appuyez sur `−`. À 1, un nouvel appui sur `−` retire directement la ligne
- **Supprimer** : icône 🗑️, puis confirmation « Retirer … du panier ? »
- **Vider tout le panier** : icône « balai » dans le bandeau du haut, puis confirmation
- **Actualiser** : tirez la liste vers le bas

> ⚠️ **Attention :** Si le stock est insuffisant pour augmenter la quantité, un message « Stock insuffisant » apparaît.

#### Bas de panier

```
┌─────────────────────────────┐
│ Total               15.80 € │
│ [ 💳 Valider la commande ]  │
└─────────────────────────────┘
```

Si le panier est vide, l'écran affiche « Votre panier est vide » et un bouton **"Continuer mes achats"**.

### Finaliser l'achat (Checkout)

1. **Vérifiez votre panier**
2. **Cliquez sur "Valider la commande" 💳**
3. Si votre **solde est inférieur au total**, l'application affiche un message rouge « Solde insuffisant » (avec votre solde et le total) et **n'ouvre pas** l'écran de paiement : rechargez d'abord votre compte auprès d'un administrateur
4. Sinon, l'écran de validation s'ouvre :

#### Écran de confirmation

<img src="docs/screenshots/checkout.png" alt="Checkout" width="400"/>

**Affichage :**
- 💰 **Votre solde** actuel
- 💶 **Montant à payer**
- 📉 **Nouveau solde** (solde après achat)

> 📝 L'écran de paiement ne détaille pas les articles : vérifiez-les dans le panier avant de valider.

**Validation :**
1. **Entrez votre code PIN** (4 chiffres, clavier numérique : différent de votre mot de passe)
2. 👁️ Cliquez sur l'icône œil pour voir/masquer le PIN
3. **Cliquez sur "Confirmer" ✅** (le bouton ne s'active qu'une fois 4 chiffres saisis ; la touche `Entrée` fonctionne aussi)
4. Le bouton **"Annuler"** vous ramène au panier

> 🔒 **Sécurité :** Le code PIN (4 chiffres) est une protection supplémentaire qui confirme que c'est bien vous qui effectuez l'achat. Il est différent de votre mot de passe de connexion. Le champ PIN est vidé après chaque tentative, réussie ou non.

### Après l'achat

**Si l'achat réussit ✅ :**
- Message « Achat effectué avec succès ! »
- Votre solde est mis à jour
- Le panier est vidé automatiquement
- Retour à la boutique

**Si l'achat échoue ❌ :**
- Message d'erreur explicite :
  - 💸 « Solde insuffisant » → Rechargez votre compte
  - 🔒 « Code PIN incorrect » → Vérifiez votre PIN (4 chiffres)
  - 📦 « Stock insuffisant pour… » → Produit en rupture ou quantité trop élevée
  - 🚫 « Le produit … n'est plus disponible » → Le produit a été désactivé depuis l'ajout au panier

> 📝 L'achat est **atomique** : en cas d'erreur, rien n'est débité et le stock reste inchangé.

### Historique des transactions

L'application ne propose **pas** d'écran « Mes transactions » côté membre. Votre historique d'achats et de crédits est consultable par les **administrateurs** (écran « Transactions », en cherchant votre nom). Demandez-leur un relevé si besoin.

---

## 💵 Mode Caisse {#mode-caisse}

### Qu'est-ce que le mode caisse ?

Le mode caisse permet de **vendre des produits au comptant** à des clients de passage (non-membres ou visiteurs).

> 👥 **Exemple :** Un pilote de passage ou un visiteur veut acheter une boisson. Vous utilisez le mode caisse pour enregistrer la vente et il paie immédiatement en espèces ou par carte.

**Caractéristiques :**
- 💰 **Paiement immédiat** : Espèces ou carte bancaire
- 👤 **Client anonyme** : Pas besoin de compte membre (la vente apparaît comme « Client anonyme » chez les administrateurs)
- 📝 **Traçabilité** : Votre PIN enregistre qui a fait la vente
- 💳 **Vous n'êtes PAS débité** : C'est une vente au comptant
- 📦 **Stock déduit** automatiquement (pour les produits dont le stock est géré)

> 📚 **Pour en savoir plus :** Consultez le guide complet [Modes d'Achat](MODES_ACHAT.md) qui compare en détail l'achat personnel et le mode caisse.

### Accéder au mode caisse

**Depuis la boutique :**
1. Cliquez sur l'icône **Mode Caisse** (caisse enregistreuse, en haut à droite)
2. L'interface de caisse s'ouvre

**Depuis le tableau de bord admin :** carte **« Caisse »** (« Vendre aux non-membres »).

Le mode caisse est accessible à **tous les membres connectés**, pas seulement aux administrateurs.

### Interface du mode caisse

<img src="docs/screenshots/cashier.png" alt="Mode caisse" width="800"/>

Le bandeau du haut affiche **« Mode Caisse »** et votre nom. L'écran est divisé en deux parties :

#### 📦 Gauche : Sélection des produits
- Barre de recherche (« Rechercher un produit... »)
- Filtres par catégories (« Tous » + catégories)
- Liste des produits actifs, au même format que la boutique (cartes produits et cartes « produit en vrac » avec leurs portions)
- Le nombre en stock n'est affiché que pour les produits dont le stock est géré

#### 🛒 Droite : Panier de la vente
- En-tête « Panier » et nombre d'articles
- Articles sélectionnés, avec boutons `−` / `+` et 🗑️
- **TOTAL** de la vente
- Boutons **"Vider"** et **"Valider"**

### Effectuer une vente au comptant

**Étapes :**

1. **Sélectionnez les produits** (partie gauche)
   - Produit normal : Cliquez sur la carte → saisissez la quantité → **"Ajouter au panier"**
   - Produit en vrac : Cliquez sur une portion → saisissez le nombre de portions → **"Ajouter au panier"**
   - Un message « Ajouté » confirme chaque ajout

2. **Vérifiez le panier** (partie droite)
   - Ajustez les quantités si nécessaire
   - Vérifiez le total

3. **Cliquez sur "Valider"** : l'écran **« Validation de la vente »** s'ouvre avec le récapitulatif (« 2x Bière - 50cl … ») et le **TOTAL**

4. **Choisissez le mode de paiement** (obligatoire)
   - 💵 **Espèces** : Le client paie en liquide
   - 💳 **Carte bancaire** : Le client paie par CB

5. **Authentifiez-vous**
   - Entrez **VOTRE code PIN** (4 chiffres)
   - ⚠️ **Important :** C'est VOTRE PIN de vendeur, pour tracer qui a fait la vente !
   - 👁️ Vous pouvez afficher le PIN pour vérifier la saisie

6. **Confirmez**
   - Cliquez sur **"Confirmer la vente" ✅** (actif uniquement quand un mode de paiement est choisi **et** que 4 chiffres sont saisis)
   - **"Annuler"** ramène au panier de la caisse

7. **Consultez le reçu**
   - L'écran **« Reçu de vente »** s'affiche automatiquement avec « Vente réussie ! » : n° de transaction, date, vendeur, mode de paiement, montant
   - **"Sauvegarder PDF"** (sur ordinateur et mobile) ou **"Télécharger PDF"** (sur le web) génère le reçu au format PDF
   - **"Nouvelle vente"** vous ramène à la caisse avec un panier vide

8. **Encaissez le paiement**
   - Le client vous donne l'argent ou paie par carte
   - Mettez l'argent en caisse

**Résultat :**
- La vente est enregistrée avec votre nom (traçabilité)
- Le stock est déduit automatiquement (produits à stock géré)
- Le panier caisse est vidé
- Vous pouvez effectuer une nouvelle vente

**En cas d'erreur** (PIN incorrect, stock insuffisant, produit devenu indisponible), un message s'affiche et le panier est conservé ; le PIN saisi est effacé.

> 💡 **Pourquoi mon PIN ?** Votre PIN garantit la traçabilité : l'application sait qui a effectué chaque vente. Vous n'êtes pas débité, c'est juste pour l'audit.

### Gérer le panier caisse

**Boutons disponibles :**
- `−` / `+` : Modifier la quantité (retire la ligne si elle tombe à 0 ; un message apparaît si le stock est insuffisant)
- 🗑️ : Supprimer un article (immédiat, sans confirmation)
- **"Vider"** : Vider tout le panier (avec confirmation « Oui / Non »)

Ajouter deux fois le même produit (ou la même portion) additionne les quantités. Le panier caisse n'existe que sur l'écran : il est perdu si vous quittez la caisse.

### Retour à la boutique

- Cliquez sur l'icône **« Retour au dashboard »** (tableau de bord) en haut à droite
  - un **administrateur** retourne au tableau de bord d'administration
  - un **membre** retourne à la boutique
- Si le panier contient des articles, une confirmation « Quitter le mode caisse » est demandée

### Différence avec un achat personnel

| Critère | Mode Caisse | Achat Personnel |
|---------|-------------|----------------|
| **Client** | Anonyme / de passage | Vous-même (membre) |
| **Paiement** | Espèces ou CB (immédiat) | Compte membre (débité) |
| **PIN demandé** | Votre PIN (vendeur) | Votre PIN (acheteur) |
| **Vous êtes débité ?** | ❌ Non | ✅ Oui |
| **Traçabilité** | Qui a vendu | Qui a acheté |
| **Reçu PDF** | ✅ Oui | ❌ Non |

> 💡 **Astuce :** Le mode caisse est accessible à tous les membres, pas seulement aux administrateurs.

---

## 🔐 Espace Administrateur {#espace-administrateur}

> ⚠️ **Réservé aux administrateurs du club.** Un membre qui tenterait d'ouvrir une page d'administration est redirigé vers la boutique avec le message « Cette section est réservée aux administrateurs ».

### Accéder au tableau de bord

**Si vous êtes administrateur :**
1. À la connexion, vous arrivez directement sur le **tableau de bord « Administration »**
2. Depuis la boutique : icône **🛡️ Dashboard Admin** (en haut à droite)

### Vue d'ensemble du tableau de bord

<img src="docs/screenshots/admin-dashboard.png" alt="Dashboard admin" width="800"/>

Le tableau de bord affiche **« Bienvenue, Prénom Nom »** puis une grille de huit cartes cliquables (pas de statistiques chiffrées) :

- 🛍️ **Boutique** : acheter des produits avec votre propre compte
- 💵 **Caisse** : vendre aux non-membres
- 👥 **Utilisateurs** : gestion des membres, soldes et paniers
- 📦 **Produits** : catalogue, prix, portions
- 🗂️ **Catégories** : organisation du catalogue
- 🏭 **Stock** : état des stocks et réapprovisionnement
- 🧾 **Transactions** : historique et remboursements
- 📥 **Exporter** : exports CSV

L'icône **Déconnexion** en haut à droite demande une confirmation.

---

### 👥 Gestion des Utilisateurs

#### Liste des utilisateurs

**Affichage :**
- Barre de recherche (prénom, nom ou email)
- Pour chaque utilisateur : initiales, nom complet, email, badge **Admin** ou **User**
- **Solde** du compte (vert si positif, rouge si nul ou négatif)
- Les comptes désactivés sont grisés avec le badge « Utilisateur désactivé »
- Tirez la liste vers le bas pour l'actualiser

**Boutons de chaque carte :**
- **Créditer** · **Modifier**
- 🛒 **Voir le panier** (orange quand le membre a des articles dans son panier)
- 🚫 **Désactiver** / ✅ **Réactiver**
- 🗑️ **Supprimer définitivement**
- **Réinitialiser mot de passe** · **Réinitialiser code PIN**

#### Créer un nouvel utilisateur

1. Cliquez sur **"Nouvel utilisateur"** (bouton flottant en bas)
2. Remplissez le formulaire :
   - **Email** (ex: jean.dupont@example.com) - doit être unique
   - **Mot de passe** (au moins 6 caractères)
   - **Prénom** (ex: Jean)
   - **Nom** (ex: Dupont)
   - **Code PIN (4 chiffres)** (ex: 1234)
   - **Rôle** : Utilisateur ou Administrateur
3. Cliquez sur **"Enregistrer"**

Le solde d'un nouvel utilisateur est de **0 €** : créditez-le ensuite avec **"Créditer"**.

> 🔒 **Sécurité :** 
> - L'**email** et le **mot de passe** permettent de se connecter à l'application
> - Le **code PIN** (4 chiffres) sert à valider les achats
> - Les deux sont automatiquement chiffrés (SHA-256)

#### Modifier un utilisateur

1. Cliquez sur **"Modifier"**
2. Modifiez les informations : **Email, Prénom, Nom, Rôle**
3. Cliquez sur **"Enregistrer"**

Le mot de passe et le PIN **ne se modifient pas ici** : utilisez les boutons de réinitialisation (ci-dessous).

> ⚠️ **Important :** Les changements n'affectent pas l'historique des transactions.

#### Réinitialiser un mot de passe ou un PIN

1. Cliquez sur **"Réinitialiser mot de passe"** ou **"Réinitialiser code PIN"**
2. Saisissez la nouvelle valeur **deux fois** (nouvelle valeur + confirmation ; l'œil permet de l'afficher)
3. Cliquez sur **"Réinitialiser"**

> ⚠️ **Règles contrôlées par l'application :** le mot de passe doit comporter **au moins 6 caractères** (message « Le mot de passe doit contenir au moins 6 caractères ») et le PIN **exactement 4 chiffres** (message « Le code PIN doit contenir 4 chiffres »). Les deux saisies doivent aussi être identiques. Sinon la réinitialisation est refusée.

#### Créditer / Débiter un compte

1. Cliquez sur le bouton **"Créditer"** de la carte de l'utilisateur (indisponible pour un compte désactivé)
2. L'écran **« Ajuster le solde »** affiche le membre et son solde actuel
3. Entrez le **montant** :
   - **Positif** pour un crédit (ex: 20)
   - **Négatif** pour un débit (ex: -5)
   - Des boutons rapides sont proposés : `+10€`, `+20€`, `+50€`, `-5€`, `-10€`, `-20€`
4. Ajoutez une note (**« Notes / Raison »**, optionnel)
5. Cliquez sur **"Valider l'ajustement"** (ou **"Annuler"**)

**Résultat :**
- Le solde est mis à jour immédiatement
- Une transaction de type **Crédit** est enregistrée dans l'historique
- Un message « Compte crédité de … € » ou « Compte débité de … € » s'affiche

> ⚠️ Le montant `0` est refusé. **Un débit peut rendre le solde négatif** : l'application ne l'empêche pas, vérifiez le solde avant de saisir un montant négatif.

> 💡 **Exemples d'usage :**
> - +50€ : Membre recharge son compte
> - -10€ : Correction d'une erreur

#### Voir et gérer le panier d'un membre

L'icône 🛒 de la carte ouvre **« Panier de Prénom Nom »** : lignes du panier, quantités, prix et total. Deux actions :

- **"Vider le panier"** : supprime les articles sans aucun débit (confirmation demandée)
- **"Forcer l'exécution"** : valide le panier **à la place du membre** et débite son compte, **même si le solde est insuffisant** (le solde peut devenir négatif). Une fenêtre récapitule le montant, le solde actuel et le solde après débit, et demande **votre** code PIN administrateur. Le stock reste vérifié. La transaction est annotée « Panier forcé par admin #… ».

#### Désactiver / Supprimer un utilisateur

- **Désactiver** (recommandé) : le compte ne peut plus se connecter (« compte désactivé ») mais l'historique est conservé ; **Réactiver** annule l'opération. Une confirmation est demandée.
- **Supprimer définitivement** : irréversible. **Impossible si le membre a déjà des transactions** (message « Impossible de supprimer cet utilisateur car il a des transactions associées ») : désactivez-le dans ce cas.

#### Historique d'un utilisateur

Il n'y a pas de fiche détaillée par utilisateur. Pour retrouver ses opérations :
1. Ouvrez **Transactions** depuis le tableau de bord
2. Tapez son nom dans la barre de recherche
3. Vous voyez ses achats 🛒, crédits/débits 💰 et remboursements 🔄 (voir [Historique des transactions](#-historique-des-transactions))

---

### 📦 Gestion des Produits

#### Liste des produits

**Affichage par défaut :**
- Tous les produits, **actifs et inactifs** (les produits « supprimés » n'apparaissent plus)
- Barre de recherche (nom ou description) et pastilles de catégories (« Tous » + catégories)
- Tirez la liste vers le bas pour l'actualiser

**Informations visibles sur chaque carte :**
- Nom, description, catégorie
- Prix
- Stock (nombre d'unités entières, coloré vert/orange/rouge ; **« N/A »** en gris si le stock n'est pas géré)
- Badge **Actif** / **Inactif**

**Boutons de chaque carte :** **Modifier**, **Désactiver** (ou **Réactiver**), **Gérer le stock** (grisé « Stock non géré » si le stock n'est pas suivi), **Supprimer**.

#### Créer un nouveau produit

1. Cliquez sur **"Nouveau produit"** (bouton flottant)
2. Remplissez le formulaire, dans cet ordre :

##### Informations générales
- **Nom du produit** (ex: Coca-Cola)
- **Description** (ex: Bouteille 33cl)
- **Catégorie** (sélectionner dans la liste, obligatoire)
- **Produit au détail / en vrac** : interrupteur (voir plus bas)
- **Prix (€)** (ex: 2.50) - obligatoire et supérieur à 0 pour un produit normal
- **Quantité en stock** (nombre entier)
- **Seuil d'alerte stock** (ex: 5) : en dessous ou à égalité, le produit est signalé en stock faible

##### Options
- **Produit actif** : interrupteur (un produit inactif n'apparaît ni dans la boutique ni dans la caisse)
- **Gérer le stock** : activé par défaut
  - Si désactivé : pas de suivi de stock (café, eau en libre-service). Les champs de stock sont grisés (inutile de les remplir), le stock est affiché « N/A » côté administrateur et masqué en boutique et en caisse, aucune alerte, aucune vérification ni déduction lors des ventes

##### Produit en vrac
Activez **« Produit au détail / en vrac »** (ex : bière en fût). Le prix de base devient optionnel (les prix sont définis par portion) et « Quantité en stock » devient « Nombre d'unités en stock » (fûts fermés). Champs supplémentaires :
- **Unité de mesure** (ex: litres, kg)
- **Quantité totale par unité** (ex: 6 pour un fût de 6L)
- **Quantité dans l'unité ouverte (optionnel)** (ex: 4.25 pour 4.25L restants dans le fût entamé)
- **Portions** (obligatoire, au moins une) : voir ci-dessous

> 💡 **Exemple : Fût de bière**
> - Nom : Bière pression
> - Prix de base : laissé vide (voir portions)
> - Produit en vrac : ✅
> - Unité : litres
> - Quantité par fût : 6
> - Unités en stock : 5 fûts
> - Unité ouverte : 4.25L
> - **Stock total disponible = (5 × 6) + 4.25 = 34.25L**

3. **Cliquez sur "Enregistrer"**

#### Ajouter des portions (produit en vrac)

Les portions se gèrent **directement dans le formulaire du produit** (création ou modification), dans le bloc **« Portions »** :

1. Cliquez sur l'icône **➕** du bloc « Portions »
2. Dans la fenêtre **« Ajouter une portion »**, remplissez :
   - **Nom** (ex: 25cl, 33cl, 50cl)
   - **Quantité en litres** (l'unité saisie plus haut ; ex: 0.25 pour 25cl)
   - **Prix (€)** (ex: 1.80)
3. Cliquez sur **"Confirmer"** (ou **"Annuler"**)
4. Cliquez sur **"Enregistrer"** le produit : les portions sont enregistrées à ce moment-là

> 📝 **Exemple complet : Bière pression**
> - Portion 1 : 25cl → 0.25L → 1.80€
> - Portion 2 : 33cl → 0.33L → 2.20€
> - Portion 3 : 50cl → 0.50L → 2.80€

**Gestion des portions :**
- ✏️ Modifier une portion (icône crayon)
- 🗑️ Supprimer une portion (icône poubelle)

Sans portion, un produit en vrac affiche « Aucune portion disponible » et ne peut pas être vendu.

#### Modifier un produit

1. Depuis la liste, cliquez sur **"Modifier"**
2. Modifiez les informations (le formulaire est identique à celui de création)
3. **Enregistrer**

> ⚠️ **Points d'attention :**
> - Les valeurs de stock saisies dans le formulaire **remplacent** les valeurs actuelles
> - Pour un produit en vrac, c'est ici que l'on corrige la **quantité dans l'unité ouverte**
> - L'interrupteur **« Produit actif »** est pris en compte à l'enregistrement (comme les boutons Désactiver / Réactiver de la liste)

#### Gérer le stock depuis la liste

Le bouton **"Gérer le stock"** ouvre une fenêtre avec le stock actuel et un champ **« Nouvelle quantité »** (boutons rapides `-10` et `+10`). Valider **remplace** la quantité d'unités entières par la valeur saisie (≥ 0).

> ⚠️ Ce raccourci ne laisse aucune ligne dans l'historique des mouvements de stock. Pour une livraison, préférez **Stock → Réapprovisionner**.

#### Désactiver un produit

**Pourquoi désactiver ?**
- Préserve l'historique des transactions
- Permet de réactiver plus tard

**Comment :**
1. Dans la liste, cliquez sur **"Désactiver"**
2. Confirmez

> 🚫 **Produit inactif :**
> - N'apparaît plus dans la boutique ni dans la caisse
> - Reste visible dans la liste admin (badge **Inactif**) et dans l'historique
> - Peut être réactivé avec **"Réactiver"**
> - Un panier qui le contient ne pourra plus être validé

#### Supprimer un produit

Le bouton **"Supprimer"** retire le produit **définitivement des listes** (il reste en base de données pour l'historique des transactions). Il n'est **plus possible de le réactiver depuis l'application** : en cas de doute, utilisez **Désactiver**.

---

### 📊 Gestion des Catégories

#### Liste des catégories

**Affichage :**
- Barre de recherche (nom ou description)
- Pour chaque catégorie : icône, nom, description, **« Ordre : n »**
- Boutons **Modifier** et **Supprimer**
- Bouton flottant **➕** pour créer

Les catégories sont triées par ordre d'affichage croissant.

#### Créer une catégorie

1. Cliquez sur le bouton **➕**
2. Remplissez :
   - **Nom de la catégorie** (ex: Boissons chaudes)
   - **Description** (optionnelle)
   - **Ordre d'affichage** (entier ≥ 0 : 1, 2, 3...)
     - Plus le numéro est petit, plus la catégorie apparaît en premier dans les filtres de la boutique
   - **Icône** : choisissez parmi 11 icônes (catégorie, bar, café, verre, fast-food, restaurant, vin, burger, pizza, glace, bouteille)
3. **Enregistrer**

#### Modifier l'ordre d'affichage

1. Cliquez sur **"Modifier"** sur la catégorie
2. Changez l'**ordre d'affichage**
3. **Enregistrer**

> 📝 Le glisser-déposer n'existe pas : l'ordre se règle uniquement avec ce numéro.

#### Supprimer une catégorie

1. Cliquez sur **"Supprimer"**
2. **Confirmation demandée**
3. Les produits de cette catégorie sont déplacés vers **"Sans catégorie"**

> ⚠️ **Catégorie spéciale : "Sans catégorie"**
> - Créée automatiquement
> - Ne peut pas être supprimée (message d'erreur)
> - Ordre d'affichage 999 : affichée toujours en dernier
> - Contient les produits orphelins

---

### 🔄 Gestion du Stock

#### Vue d'ensemble du stock

**Affichage :**
- Barre de recherche (nom ou description)
- Un bandeau orange **« N produit(s) en stock faible »** quand des produits à stock géré sont à leur seuil d'alerte ou en dessous (rupture comprise)
- Pour chaque produit : **Quantité actuelle** (nombre d'unités entières) avec un badge d'état, et **Seuil d'alerte**
- Bouton **"Réapprovisionner"**
- Tirez la liste vers le bas pour l'actualiser

**Badges d'état :**
- 🟢 **Stock OK**
- 🟠 **Stock faible** (≤ seuil d'alerte)
- 🔴 **Rupture** (0)
- ⚪ **Stock non géré** : le seuil affiche « N/A » et le bouton est remplacé par le message « Gestion de stock désactivée pour ce produit »

> 📝 Il n'y a pas de filtres « Stock faible / Rupture » : repérez les produits grâce aux couleurs ou à l'export « stock faible » (voir [Export](#-export-de-données)).

#### Réapprovisionner un produit normal

1. Cliquez sur **"Réapprovisionner"** pour le produit
2. Sur l'écran **« Réapprovisionnement »** (rappel du produit et de son stock actuel) :
   - **Quantité à ajouter** (entier supérieur à 0, ex: 10)
   - **Notes (facultatif)** (ex : fournisseur, numéro de commande)
3. Cliquez sur **"Réapprovisionner"**

**Résultat :**
- Stock mis à jour immédiatement
- Mouvement de stock enregistré avec votre nom (traçabilité)

> 💡 **Exemple :**
> - Stock actuel : 5 Coca-Cola
> - Réapprovisionnement : +12
> - Nouveau stock : 17

#### Réapprovisionner un produit en vrac

L'écran de réapprovisionnement ajoute des **unités complètes** (fûts, caisses…). La quantité de l'unité entamée n'est pas modifiée.

1. Cliquez sur **"Réapprovisionner"**
2. Entrez le nombre d'unités (ex: +2 fûts)
3. Notes (facultatif)
4. Cliquez sur **"Réapprovisionner"**

> 💡 **Exemple : Bière (fûts de 6L)**
> - Avant : 3 fûts + 4.25L entamé
> - Réappro : +2 fûts
> - Après : 5 fûts + 4.25L entamé
> - **Total : 34.25L**

**Changer de fût (corriger l'unité entamée) :**
1. **Produits** → **Modifier** le produit en vrac
2. Modifiez **« Quantité dans l'unité ouverte »** (ex: 6.0 pour un fût neuf)
3. **Enregistrer** (le nombre de fûts fermés ne change pas, sauf si vous le modifiez aussi)

> 💡 **Exemple : Changement de fût**
> - Avant : 3 fûts + 0.5L entamé (presque vide)
> - Action : mise à 6.0 de la quantité de l'unité ouverte
> - Après : 3 fûts + 6.0L entamé
> - **Total : 24L**

#### Ajustement manuel du stock (inventaire)

**Si besoin de corriger une erreur ou de faire un inventaire :**

1. **Produits** → bouton **"Gérer le stock"** du produit
2. Saisissez la **nouvelle quantité** (valeur absolue, pas relative) ou utilisez `-10` / `+10`
3. **Valider**

Pour un produit en vrac, ajustez en plus la quantité de l'unité ouverte via **Modifier**.

> ⚠️ **Attention :** Utilisez avec précaution. L'ajustement manuel écrase le stock et n'enregistre **pas** de raison ni de mouvement dans l'historique.

#### Mouvements de stock

Le serveur enregistre un mouvement pour chaque opération sur le stock avec votre nom ou celui du vendeur :
- ➖ **Vente** : Déduction automatique lors d'un achat ou d'une vente caisse
- ➕ **Réapprovisionnement** : Ajout de stock (écran « Réapprovisionnement »)
- 🔄 **Remboursement** : Remise en stock lors du remboursement d'un achat
- 🔧 **Ajustement** : Correction d'inventaire

> 📝 L'application n'affiche pas encore la liste de ces mouvements ; ils servent de traçabilité côté serveur.

---

### 📈 Historique des Transactions {#-historique-des-transactions}

#### Vue globale

**Accès :** Tableau de bord admin → **« Transactions »**

**Affichage :**
- Liste de toutes les transactions du club, de la plus récente à la plus ancienne
- Barre de recherche : nom du membre, nom du vendeur ou notes
- Pastilles de type : **Tous**, **Achats**, **Crédits**, **Remboursements**, **Ventes caisse**
- Boutons de période **« Date début »** / **« Date fin »** (une croix efface les dates)
- Sélecteur **« Nombre de transactions »** : 10, 25, 50 (par défaut), 100, 200 ou 500
- Tirez la liste vers le bas pour l'actualiser

> ⚠️ Seules les N dernières transactions (nombre choisi ci-dessus) sont chargées : augmentez le nombre pour remonter plus loin.

**Informations visibles sur chaque carte :**
- Badge du type : **Achat** (rouge), **Crédit** (vert), **Remboursement** (orange), **Vente caisse** (bleu)
- 💰 Montant
- 📅 Date et heure
- 👤 Membre (ou **« Client anonyme »** pour une vente caisse)
- 🧾 **Vendeur** (ventes caisse)
- 📝 Notes éventuelles (par ex. « Vente caisse - Paiement: espèces », « Panier forcé par admin #… », ou la note d'un crédit)

> 📝 Les crédits/débits manuels apparaissent comme des **Crédits** (avec montant négatif pour un débit). Il n'y a pas d'écran de détail par transaction : les informations sont sur la carte.

#### Remboursement d'une transaction

**Si une erreur a été commise sur un achat :**

1. Sur la carte d'une transaction de type **Achat**, cliquez sur **"Rembourser"** (ce bouton n'existe que pour les achats)
2. Confirmez la fenêtre « Voulez-vous rembourser cette transaction de … € ? »

**Résultat :**
- Le solde du membre est recrédité du montant de l'achat
- Une transaction de type **Remboursement** est créée
- **Les produits sont remis en stock** (pour les produits dont le stock est géré ; pour un produit en vrac, la quantité remise est ajoutée au fût entamé)
- L'opération est tracée dans l'historique

> ⚠️ **Important :**
> - Une transaction ne peut être remboursée **qu'une seule fois** (sinon : « Cette transaction a déjà été remboursée »)
> - Les **ventes caisse** et les crédits ne sont **pas remboursables** depuis l'application

---

### 📥 Export de données {#-export-de-données}

**Accès :** Tableau de bord admin → **« Exporter »** (écran « Export de données »). Les fichiers sont au format **CSV** (ouvrables avec Excel ou LibreOffice). Sur ordinateur et mobile, une fenêtre vous demande **le dossier** d'enregistrement ; sur le web, le fichier est téléchargé directement. Un message confirme le nombre d'éléments exportés.

Quatre exports sont proposés :

1. **Exporter produits stock faible** : produits **actifs** à stock géré dont le stock est sous le seuil d'alerte (ou en rupture).
   Fichier : `Produits stock faible JJ-MM-AAAA.csv`. Message « Aucun produit sous le seuil d'alerte » s'il n'y en a pas.
2. **Exporter les transactions** : choisissez une **Date de début** et une **Date de fin** (obligatoires : « Veuillez sélectionner une période »), puis éventuellement un filtre **Toutes / Achats / Crédits / Remboursements**.
   Fichier : `Transactions du JJ-MM-AAAA au JJ-MM-AAAA.csv`.
   > ⚠️ L'export part des **50 transactions les plus récentes** du club puis les filtre par période : pour une longue période, des transactions anciennes peuvent manquer.
3. **Exporter l'inventaire** : tous les produits (case **« Inclure les produits désactivés »**).
   Fichier : `Inventaire produits JJ-MM-AAAA.csv`.
4. **Exporter les soldes utilisateurs** : prénom, nom, email, rôle, solde, statut (case **« Inclure les utilisateurs désactivés »**).
   Fichier : `Soldes utilisateurs JJ-MM-AAAA.csv`.

---

### 🔙 Retour à la boutique (Admin)

- Depuis le tableau de bord : carte **« Boutique »** pour acheter avec votre compte, ou **« Caisse »** pour le mode caisse
- Depuis la boutique : icône 🛡️ **Dashboard Admin** pour revenir à l'administration
- Les écrans d'administration (Utilisateurs, Produits…) se quittent avec la **flèche de retour** en haut à gauche

> 💡 **Bascule rapide :** Les administrateurs peuvent passer du mode admin au mode boutique sans se déconnecter.

---

## ❓ Questions Fréquentes (FAQ) {#faq}

### Connexion et sécurité

**Q : Quelle est la différence entre mon mot de passe et mon PIN ?**
> R : Vous avez deux identifiants distincts :
> - **Email + Mot de passe** : Pour vous connecter à l'application (accès)
> - **Code PIN** (4 chiffres) : Pour valider vos achats (confirmation)
> C'est une double sécurité.

**Q : Pourquoi dois-je me reconnecter à chaque fois ?**
> R : Par mesure de sécurité, l'application ne sauvegarde jamais votre session. Cela garantit qu'aucune personne non autorisée ne peut utiliser l'application si vous oubliez de vous déconnecter.

**Q : Pourquoi l'application m'a-t-elle déconnecté toute seule ?**
> R : Après 5 minutes sans interaction (valeur par défaut), l'application vous déconnecte et affiche « Session expirée ». Le délai se règle de 0 à 120 minutes dans **Configuration serveur** (écran de connexion) ; `0` désactive cette déconnexion.

**Q : J'ai oublié mon mot de passe ou mon PIN, que faire ?**
> R : Contactez un administrateur du club. Il pourra réinitialiser vos identifiants (boutons « Réinitialiser mot de passe » / « Réinitialiser code PIN »).

**Q : Puis-je changer mon mot de passe ou mon PIN moi-même ?**
> R : Non, l'application ne propose pas ce changement aux membres : seul un administrateur peut modifier les identifiants.

**Q : Mes identifiants sont-ils sécurisés ?**
> R : Oui, le mot de passe et le code PIN sont tous deux chiffrés avec SHA-256 et ne sont jamais stockés en clair dans la base de données.

---

### Achats et panier

**Q : Puis-je acheter si mon solde est négatif ou insuffisant ?**
> R : Non. Quand vous cliquez sur « Valider la commande », l'application compare votre solde au total du panier et refuse si le solde est insuffisant. Seul un administrateur peut « forcer l'exécution » d'un panier, ce qui peut rendre un solde négatif. Rechargez votre compte auprès d'un administrateur.

**Q : Que signifie « Stock non géré » / « N/A » ?**
> R : Certains produits (café, eau libre-service) n'ont pas de suivi de stock : aucune alerte, aucune déduction, aucune limite à l'achat. « N/A » s'affiche dans l'espace administrateur ; en boutique et en mode caisse, leur stock est masqué et ils s'ajoutent toujours au panier.

**Q : Puis-je annuler un achat après validation ?**
> R : Non, une fois validé, l'achat est définitif. Contactez un administrateur : il peut rembourser l'achat (votre compte est recrédité et les produits remis en stock).

**Q : Pourquoi certains produits ont plusieurs prix ?**
> R : Ce sont des produits en vrac (bière pression, etc.). Le prix varie selon la portion choisie (25cl, 50cl, etc.).

**Q : Comment fonctionne le stock des produits en vrac ?**
> R : Le stock est géré en unités (fûts, caisses) et l'application suit automatiquement l'unité entamée. Exemple : 3 fûts + 4.5L dans le fût ouvert. Quand un fût entamé est vide, un nouveau fût est ouvert automatiquement.

**Q : Puis-je consulter mon historique d'achats ?**
> R : Pas dans l'application côté membre. Un administrateur peut le retrouver dans l'écran « Transactions ».

---

### Mode caisse

**Q : Qui peut utiliser le mode caisse ?**
> R : Tous les membres authentifiés peuvent accéder au mode caisse. Vous n'avez pas besoin d'être administrateur.

**Q : À quoi sert le mode caisse ?**
> R : Le mode caisse permet de **vendre au comptant** à des clients de passage (non-membres ou visiteurs). Le client paie immédiatement en espèces ou par carte bancaire. C'est différent d'un achat personnel où le compte membre est débité.

**Q : Quel PIN entrer lors d'une vente en mode caisse ?**
> R : Vous devez entrer **VOTRE PIN** (le vendeur), pas celui du client. Votre PIN sert à authentifier qui a effectué la vente (traçabilité). Vous n'êtes PAS débité - c'est une vente au comptant.

**Q : Le client a-t-il besoin d'un compte ou d'un PIN ?**
> R : Non ! Le mode caisse est fait pour les clients de passage ou visiteurs qui n'ont pas de compte membre. Ils paient directement en espèces ou par carte.

**Q : Quelle est la différence entre mode caisse et achat personnel ?**
> R : 
> - **Mode caisse** : Vente au comptant, client anonyme, paiement immédiat (espèces/CB), votre PIN trace qui a vendu
> - **Achat personnel** : Achat sur votre compte membre, votre compte est débité, votre PIN confirme que c'est vous qui achetez

**Q : Puis-je acheter pour moi-même en mode caisse ?**
> R : Ce n'est pas le but : le mode caisse enregistre une vente au comptant sans toucher à un compte membre. Pour payer avec votre solde, utilisez la boutique normale.

**Q : Comment obtenir le reçu ?**
> R : Après chaque vente, l'écran « Reçu de vente » s'affiche. Utilisez **« Sauvegarder PDF »** (ou **« Télécharger PDF »** sur le web) pour l'enregistrer. Une fois sorti de cet écran (« Nouvelle vente »), le reçu n'est plus proposé.

---

### Administration

**Q : Comment devenir administrateur ?**
> R : Seul un administrateur existant peut vous attribuer ce rôle (**Utilisateurs → Modifier → Rôle**). Contactez le bureau de votre aéro-club.

**Q : Puis-je supprimer un produit ?**
> R : Oui, mais la suppression est définitive côté application (le produit disparaît des listes, l'historique est conservé). Il est recommandé de **désactiver** les produits plutôt que de les supprimer.

**Q : Comment gérer un inventaire complet ?**
> R : Pour chaque produit, utilisez **Produits → Gérer le stock** et saisissez la quantité réelle (pour un produit en vrac, ajustez aussi la « Quantité dans l'unité ouverte » via **Modifier**). Ces ajustements n'ajoutent pas de raison ni de ligne dans l'historique des mouvements.

**Q : Puis-je supprimer une transaction ?**
> R : Non, les transactions ne peuvent pas être supprimées pour garantir la traçabilité. Vous pouvez en revanche rembourser un achat.

**Q : Pourquoi ne puis-je pas supprimer un utilisateur ?**
> R : Un utilisateur qui a déjà des transactions ne peut pas être supprimé. Désactivez-le à la place.

---

### Problèmes techniques

**Q : L'application ne se connecte pas au serveur**
> R : 
> 1. Vérifiez que le serveur est bien démarré et que vous avez internet
> 2. Vérifiez l'adresse, le port et l'option HTTPS dans **Configuration serveur** (adresse sans `http://`)
> 3. Testez la connexion avec le bouton **"Tester la connexion"**
> 4. Contactez l'administrateur technique si le problème persiste

**Q : "Code PIN incorrect" lors d'un achat alors que je suis sûr de mon code**
> R : 
> 1. Vérifiez que vous entrez bien votre **code PIN** (4 chiffres) et non votre mot de passe
> 2. Assurez-vous d'entrer exactement 4 chiffres
> 3. Utilisez l'icône œil pour vérifier votre saisie
> 4. Si le problème persiste, demandez une réinitialisation à un administrateur

**Q : "Email ou mot de passe incorrect, ou compte désactivé" lors de la connexion**
> R :
> 1. Vérifiez que vous utilisez le bon email (celui fourni par votre club)
> 2. Vérifiez votre mot de passe (6 caractères minimum)
> 3. Utilisez l'icône œil pour voir ce que vous tapez
> 4. Votre compte a peut-être été désactivé : contactez un administrateur

**Q : Mon solde ne se met pas à jour**
> R : 
> 1. Tirez la liste de la boutique vers le bas pour l'actualiser (le solde est aussi rechargé à l'ouverture du panier)
> 2. Sinon, déconnectez-vous puis reconnectez-vous
> 3. Si le problème persiste, contactez un administrateur

**Q : Un produit n'apparaît pas dans la boutique**
> R : Il est peut-être désactivé ou supprimé par un administrateur. Tirez la liste vers le bas pour actualiser, ou vérifiez que le filtre de catégorie et la recherche ne le masquent pas.

---

## 📞 Support et Contact

### Besoin d'aide ?

**Pour les questions sur l'utilisation :**
- Consultez ce guide utilisateur
- Demandez à un membre habitué
- Contactez un administrateur du club

**Pour les problèmes techniques :**
- Contactez l'administrateur technique de votre aéro-club
- Email : [contact@votre-aeroclub.fr]
- Téléphone : [XX XX XX XX XX]

### Signaler un bug

Si vous rencontrez un problème technique :
1. **Notez** les circonstances (que faisiez-vous ?)
2. **Capturez** une capture d'écran si possible
3. **Contactez** l'administrateur technique
4. **Décrivez** le problème en détail

### Suggestions d'amélioration

Votre aéro-club est ouvert à vos suggestions ! N'hésitez pas à proposer :
- Nouvelles fonctionnalités
- Améliorations de l'interface
- Idées pour faciliter l'utilisation

---

## 📚 Annexes

### Glossaire

- **Email** : Votre adresse email pour vous connecter à l'application
- **Mot de passe** : Code secret (minimum 6 caractères) pour vous connecter
- **PIN** : Code personnel à 4 chiffres pour valider vos achats (différent du mot de passe)
- **Solde** : Montant disponible sur votre compte membre
- **Checkout** : Finalisation et validation d'un achat (« Valider la commande »)
- **Produit en vrac** : Produit vendu en portions (bière pression, etc.)
- **Portion** : Quantité prédéfinie d'un produit en vrac (25cl, 50cl...)
- **Unité entamée / unité ouverte** : Fût ou contenant en cours de consommation
- **Stock** : Quantité disponible d'un produit
- **Stock non géré** : Produit sans suivi de stock (« N/A »)
- **Mouvement de stock** : Entrée ou sortie de stock (vente, réapprovisionnement, remboursement, ajustement)
- **Transaction** : Opération financière (achat, crédit/débit, remboursement, vente caisse)
- **Désactivation** : Masquage d'un produit ou blocage d'un compte sans le supprimer

### Raccourcis clavier (Ordinateur)

AirBar n'a pas de raccourcis personnalisés. Les touches suivantes fonctionnent :

| Raccourci | Action |
|-----------|--------|
| `Entrée` | Valider : connexion (depuis le champ mot de passe), PIN d'achat ou de vente (4 chiffres saisis) |
| `Échap` | Fermer une boîte de dialogue ou une fenêtre ouverte par le bas |

---

## 🎯 Bonnes Pratiques

### Pour les utilisateurs

✅ **À faire :**
- Vérifier votre solde régulièrement (en haut de la boutique)
- Vérifier votre panier avant de valider la commande
- Utiliser la recherche pour trouver rapidement un produit
- Signaler les produits en rupture à un administrateur
- Bien différencier votre mot de passe (connexion) et votre PIN (achats)
- Vous déconnecter avec l'icône Déconnexion avant de quitter

❌ **À éviter :**
- Partager vos identifiants (email, mot de passe, PIN)
- Laisser l'application ouverte et connectée sans surveillance
- Ajouter trop d'articles au panier sans vérifier le stock
- Confondre votre mot de passe avec votre code PIN

### Pour les membres en permanence (mode caisse)

✅ **À faire :**
- Vérifier le total avant validation
- Choisir le bon mode de paiement (espèces ou CB)
- Utiliser VOTRE PIN (vendeur) pour tracer la vente
- Encaisser l'argent ou le paiement CB immédiatement
- Enregistrer le reçu PDF si le client le demande avant de cliquer sur « Nouvelle vente »
- Signaler les stocks faibles

❌ **À éviter :**
- Oublier d'encaisser l'argent après avoir validé la vente
- Quitter la caisse en laissant un panier non validé (il est perdu)
- Confondre mode caisse (vente au comptant) et achat personnel (compte membre)

### Pour les administrateurs

✅ **À faire :**
- Réapprovisionner dès qu'un produit passe en orange
- Vérifier régulièrement l'historique des transactions
- Faire des inventaires périodiques
- Exporter régulièrement les transactions et les soldes (CSV) pour garder une trace
- Créer des portions cohérentes pour les produits en vrac
- Choisir des mots de passe faciles à communiquer au membre et lui conseiller de les garder confidentiels (6 caractères minimum, PIN de 4 chiffres)

❌ **À éviter :**
- Supprimer des produits (préférez les désactiver) ou des utilisateurs ayant un historique
- Modifier manuellement le stock sans raison valable
- Laisser des produits inactifs sans les gérer
- Oublier d'ajouter des notes lors des ajustements de solde et des réapprovisionnements
- Mettre un solde négatif par un débit sans vérifier le solde du membre

---

## 🚀 Mise à jour du guide

**Version actuelle :** 1.1 (Octobre 2026)

**Dernières modifications :**
- Refonte complète pour suivre fidèlement le comportement réel de l'application
- Ajout de la configuration du serveur (HTTPS, délai d'inactivité) et de la déconnexion automatique
- Ajout du panier d'un membre côté admin (vider / forcer l'exécution), des réinitialisations de mot de passe et de PIN, et des exports CSV
- Correction des écrans (boutique, panier, validation, caisse, reçu PDF, stock, transactions, remboursements)

**Prochaines versions :**
- Ajout de captures d'écran réelles
- Vidéos tutorielles (à venir)
- Guide avancé pour administrateurs

---

**🛫 Bon vol et bonne gestion avec AirBar ! ✈️**
