# 📱 AirBar - Guide Utilisateur

**Guide complet pour utiliser l'application de gestion du bar de l'aéro-club**

Version 1.0 - Août 2026

---

## 🔐 Système de Sécurité à Deux Niveaux

AirBar utilise **deux identifiants distincts** pour une sécurité renforcée :

1. **Email + Mot de passe** 📧
   - Pour **se connecter** à l'application
   - Donne accès à votre compte
   - Mot de passe minimum 6 caractères

2. **Code PIN** (4 chiffres) 🔢
   - Pour **valider vos achats**
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
- 👤 Consulter votre solde et vos achats
- 💰 Recharger votre compte (via l'administrateur)
- 💵 **Mode caisse** : Vendre au comptant à des clients de passage

**Comment ça marche ?**
1. Connectez-vous avec votre **email et mot de passe**
2. Ajoutez des produits à votre panier
3. Validez vos achats avec votre **code PIN** (4 chiffres)
4. Votre compte est débité automatiquement

**Mode caisse (vente au comptant) :**
1. Activez le mode caisse depuis la boutique
2. Sélectionnez les produits pour le client
3. Choisissez le mode de paiement (espèces ou CB)
4. Validez avec votre PIN (traçabilité du vendeur)
5. Encaissez le paiement du client

### Installation

L'application est actuellement disponible sur :
- 💻 **macOS** : Application desktop
- 🪟 **Windows** : Application desktop

> 🚧 **En développement :** Les versions Web et Mobile (iOS/Android) seront disponibles prochainement.

**Première utilisation :**
1. Lancez l'application
2. Configurez l'adresse du serveur (fournie par votre club)
3. Créez votre compte avec un administrateur
4. Connectez-vous avec votre email et mot de passe

---

## 🔐 Connexion à l'application {#connexion}

### Écran de connexion

<img src="docs/screenshots/login.png" alt="Écran de connexion" width="400"/>

1. **Ouvrez l'application** AirBar
2. **Entrez votre email** (celui fourni lors de votre inscription)
3. **Entrez votre mot de passe**
   - 👁️ Cliquez sur l'icône œil pour afficher/masquer votre mot de passe
4. **Appuyez sur "Se connecter"**

> 💡 **Astuce :** Si vous avez oublié vos identifiants, contactez un administrateur du club.

### Configuration du serveur (première utilisation)

Si c'est votre première connexion :

1. En bas de l'écran, cliquez sur **"Configuration serveur"**
2. Entrez l'adresse fournie par votre club :
   - Format : `http://adresse-serveur:8080`
   - Exemple local : `http://localhost:8080`
3. Cliquez sur **"Tester la connexion"**
4. Si le test réussit ✅, cliquez sur **"Enregistrer"**

### Sécurité

- ⚠️ L'application **ne sauvegarde jamais votre session**
- 🔒 Vous devez vous reconnecter à chaque lancement
- 🛡️ Votre mot de passe et votre PIN sont chiffrés (SHA-256)
- 🚪 Pensez à fermer l'application après utilisation

> 📝 **Note :** Vous avez deux identifiants distincts :
> - **Email + Mot de passe** : Pour vous connecter à l'application
> - **Code PIN** (4 chiffres) : Pour valider vos achats

---

## 🛒 Interface utilisateur - Boutique {#boutique}

### Vue d'ensemble

<img src="docs/screenshots/shop.png" alt="Boutique" width="600"/>

L'écran de la boutique se divise en plusieurs zones :

#### 1. Barre supérieure
- 👤 **Votre prénom** (en haut à gauche)
- 💰 **Votre solde** (en couleur)
  - 🟢 Vert : solde positif
  - 🟠 Orange : solde faible
  - 🔴 Rouge : solde négatif
- 🛒 **Icône panier** : nombre d'articles
- 🔍 **Recherche** : rechercher un produit
- ⚙️ **Menu** : options (déconnexion, mode caisse, admin)

#### 2. Filtres par catégories
- Onglets pour filtrer les produits :
  - 🍺 Boissons
  - 🍔 Snacks
  - ☕ Café
  - 📦 Autres
- Cliquez sur une catégorie pour filtrer

#### 3. Liste des produits

Deux types de produits sont affichés :

##### 🧃 Produits normaux (unités)
```
┌─────────────────────────┐
│ 🥤 Coca-Cola            │
│ Bouteille 33cl          │
│                         │
│ Prix: 2.50€             │
│ Stock: ●●● (12)         │
│                         │
│        [AJOUTER] 🛒     │
└─────────────────────────┘
```

##### 🍺 Produits en vrac (portions)
```
┌─────────────────────────┐
│ 🍺 Bière pression       │
│ Badge: PRODUIT EN VRAC  │
│ Fût de 6 litres         │
│ Stock: 34.5L disponible │
│                         │
│ Portions disponibles:   │
│ [25cl - 1.80€]         │
│ [33cl - 2.20€]         │
│ [50cl - 2.80€]         │
└─────────────────────────┘
```

### Indicateurs de stock

| Couleur | Signification |
|---------|---------------|
| 🟢 **Vert** | Stock disponible |
| 🟠 **Orange** | Stock faible (bientôt en rupture) |
| 🔴 **Rouge** | Rupture de stock (achat impossible) |
| ⚪ **N/A** | Stock non géré (café, eau libre-service) |

### Acheter un produit

#### Produit normal (unités)

1. **Cliquez sur la carte du produit**
2. Une fiche détaillée s'ouvre par le bas
3. **Ajustez la quantité** avec les boutons `−` et `+`
4. **Vérifiez le prix total**
5. **Cliquez sur "Ajouter au panier" 🛒**

> 💡 **Exemple :** Coca-Cola à 2.50€ × 3 = 7.50€

#### Produit en vrac (portions)

1. **Cliquez sur une portion** (25cl, 50cl, etc.)
2. Un dialog s'ouvre avec :
   - Nom de la portion
   - Prix de la portion
   - Quantité en litres/kg
3. **Ajustez le nombre de portions** (1, 2, 3...)
4. **Cliquez sur "Ajouter au panier" 🛒**

> 💡 **Exemple :** 
> - Portion : 50cl de bière à 2.80€
> - Quantité : 3 portions
> - Total : 8.40€
> - Consommation : 1.5L de bière

### Barre de recherche

Pour trouver rapidement un produit :

1. **Cliquez sur l'icône de recherche** 🔍 (en haut)
2. **Tapez le nom** du produit (ex: "coca")
3. Les produits correspondants s'affichent
4. **Effacez la recherche** pour voir tous les produits

---

## 🛒 Panier et achat {#panier-et-achat}

### Accéder au panier

**Deux méthodes :**
1. Cliquez sur **l'icône panier 🛒** (en haut à droite)
2. Après un ajout, un message s'affiche → cliquez sur **"Voir le panier"**

### Gérer le panier

<img src="docs/screenshots/cart.png" alt="Panier" width="400"/>

#### Vue du panier

Chaque article affiche :
- 🖼️ **Nom du produit** (+ portion si applicable)
- 💰 **Prix unitaire**
- 🔢 **Quantité** avec boutons `−` et `+`
- 🗑️ **Icône de suppression**

#### Modifier les quantités

- **Augmenter** : Appuyez sur `+`
- **Diminuer** : Appuyez sur `−`
- **Supprimer** : Quantité à 0 ou cliquez sur l'icône 🗑️

> ⚠️ **Attention :** Si le stock est insuffisant, un message d'erreur apparaît.

#### Informations de bas de panier

```
┌─────────────────────────┐
│ Total: 15.80€           │
│ Votre solde: 42.30€     │
│ Après achat: 26.50€     │
└─────────────────────────┘
```

### Finaliser l'achat (Checkout)

1. **Vérifiez votre panier**
2. **Cliquez sur "Passer la commande" 💳**
3. L'écran de validation s'ouvre :

#### Écran de confirmation

<img src="docs/screenshots/checkout.png" alt="Checkout" width="400"/>

**Affichage du récapitulatif :**
- 📋 Liste des articles
- 💰 Montant total
- 👤 Votre solde actuel
- 📉 Solde après achat

**Validation :**
1. **Entrez votre code PIN** (4 chiffres - différent de votre mot de passe)
2. 👁️ Cliquez sur l'icône œil pour voir/masquer le PIN
3. **Cliquez sur "Valider l'achat" ✅**

> 🔒 **Sécurité :** Le code PIN (4 chiffres) est une protection supplémentaire qui confirme que c'est bien vous qui effectuez l'achat. Il est différent de votre mot de passe de connexion.

### Après l'achat

**Si l'achat réussit ✅ :**
- Message de confirmation
- Votre solde est mis à jour
- Le panier est vidé automatiquement
- Retour à la boutique

**Si l'achat échoue ❌ :**
- Message d'erreur explicite :
  - 💸 "Solde insuffisant" → Rechargez votre compte
  - 🔒 "Code PIN incorrect" → Vérifiez votre PIN (4 chiffres)
  - 📦 "Stock insuffisant pour..." → Produit en rupture

### Historique des transactions

**Accéder à l'historique :**
1. Menu ≡ → **"Mes transactions"**
2. Liste de tous vos achats :
   - 📅 Date et heure
   - 📋 Détails des articles
   - 💰 Montant débité
   - 💳 Solde après l'achat

---

## 💵 Mode Caisse {#mode-caisse}

### Qu'est-ce que le mode caisse ?

Le mode caisse permet de **vendre des produits au comptant** à des clients de passage (non-membres ou membres qui paient en espèces/carte).

> 👥 **Exemple :** Un pilote de passage ou un visiteur veut acheter une boisson. Vous utilisez le mode caisse pour enregistrer la vente et il paie immédiatement en espèces ou par carte.

**Caractéristiques :**
- 💰 **Paiement immédiat** : Espèces ou carte bancaire
- 👤 **Client anonyme** : Pas besoin de compte membre
- 📝 **Traçabilité** : Votre PIN enregistre qui a fait la vente
- 💳 **Vous n'êtes PAS débité** : C'est une vente au comptant

> 📚 **Pour en savoir plus :** Consultez le guide complet [Modes d'Achat](MODES_ACHAT.md) qui compare en détail l'achat personnel et le mode caisse.

### Accéder au mode caisse

**Depuis la boutique :**
1. Cliquez sur l'icône **💰 Caisse** (en haut à droite)
2. L'interface de caisse s'ouvre

### Interface du mode caisse

<img src="docs/screenshots/cashier.png" alt="Mode caisse" width="800"/>

**Écran divisé en deux parties :**

#### 📦 Gauche : Sélection des produits
- Barre de recherche
- Filtres par catégories
- Liste des produits disponibles
- Cliquez sur un produit pour l'ajouter

#### 🛒 Droite : Panier de la vente
- Articles sélectionnés
- Quantités
- Total de la vente
- Boutons d'action

### Effectuer une vente au comptant

**Étapes :**

1. **Sélectionnez les produits** (partie gauche)
   - Produit normal : Cliquez → Choisissez la quantité → Ajouter
   - Produit en vrac : Cliquez sur une portion → Quantité → Ajouter

2. **Vérifiez le panier** (partie droite)
   - Ajustez les quantités si nécessaire
   - Vérifiez le total

3. **Validez la vente**
   - Cliquez sur **"Valider la vente" 💳**

4. **Choisissez le mode de paiement**
   - 💵 **Espèces** : Le client paie en liquide
   - 💳 **Carte bancaire** : Le client paie par CB

5. **Authentifiez-vous**
   - Entrez **VOTRE code PIN** (4 chiffres)
   - ⚠️ **Important :** C'est VOTRE PIN de vendeur, pour tracer qui a fait la vente !
   - 👁️ Vous pouvez afficher le PIN pour vérifier la saisie

6. **Confirmez**
   - Cliquez sur **"Valider la vente" ✅**

7. **Encaissez le paiement**
   - Le client vous donne l'argent ou paie par carte
   - Mettez l'argent en caisse

**Résultat :**
- La vente est enregistrée avec votre nom (traçabilité)
- Le stock est déduit automatiquement
- Le panier caisse est vidé
- Un reçu s'affiche (optionnel)
- Vous pouvez effectuer une nouvelle vente

> 💡 **Pourquoi mon PIN ?** Votre PIN garantit la traçabilité : l'application sait qui a effectué chaque vente. Vous n'êtes pas débité, c'est juste pour l'audit.

### Gérer le panier caisse

**Boutons disponibles :**
- `−` / `+` : Modifier la quantité
- 🗑️ : Supprimer un article
- 🧹 **"Vider"** : Vider tout le panier (avec confirmation)

### Retour à la boutique

- Cliquez sur **« Retour »** en haut à gauche
- Si le panier contient des articles, une confirmation est demandée

### Différence avec un achat personnel

| Critère | Mode Caisse | Achat Personnel |
|---------|-------------|----------------|
| **Client** | Anonyme / de passage | Vous-même (membre) |
| **Paiement** | Espèces ou CB (immédiat) | Compte membre (débité) |
| **PIN demandé** | Votre PIN (vendeur) | Votre PIN (acheteur) |
| **Vous êtes débité ?** | ❌ Non | ✅ Oui |
| **Traçabilité** | Qui a vendu | Qui a acheté |

> 💡 **Astuce :** Le mode caisse est accessible à tous les membres, pas seulement aux administrateurs.

---

## 🔐 Espace Administrateur {#espace-administrateur}

> ⚠️ **Réservé aux administrateurs du club**

### Accéder au tableau de bord

**Si vous êtes administrateur :**
1. Depuis la boutique : Icône **⚙️ Admin** (en haut à droite)
2. Ou menu ≡ → **"Tableau de bord admin"**

### Vue d'ensemble du tableau de bord

<img src="docs/screenshots/admin-dashboard.png" alt="Dashboard admin" width="800"/>

**Statistiques en un coup d'œil :**
- 👥 Nombre total de membres
- 📦 Nombre de produits actifs
- ⚠️ Produits en rupture de stock
- 💰 Total des comptes membres

**Modules disponibles :**
- 👥 Gestion des utilisateurs
- 📦 Gestion des produits
- 📊 Gestion des catégories
- 🔄 Gestion du stock
- 📈 Historique des transactions

---

### 👥 Gestion des Utilisateurs

#### Liste des utilisateurs

**Affichage :**
- Nom complet
- Code PIN (masqué)
- Solde du compte
- Rôle (Utilisateur / Administrateur)
- Actions (modifier, voir historique)

#### Créer un nouvel utilisateur

1. Cliquez sur **"+ Ajouter un utilisateur"**
2. Remplissez le formulaire :
   - **Prénom** (ex: Jean)
   - **Nom** (ex: Dupont)
   - **Email** (ex: jean.dupont@example.com)
   - **Mot de passe** (au moins 6 caractères)
   - **Code PIN** (4 chiffres, ex: 1234)
   - **Rôle** : Utilisateur ou Administrateur
   - **Solde initial** (optionnel, 0€ par défaut)
3. Cliquez sur **"Enregistrer"**

> 🔒 **Sécurité :** 
> - L'**email** et le **mot de passe** permettent de se connecter à l'application
> - Le **code PIN** (4 chiffres) sert à valider les achats
> - Les deux sont automatiquement chiffrés (SHA-256)

#### Modifier un utilisateur

1. Cliquez sur l'icône ✏️ **Modifier**
2. Modifiez les informations :
   - Prénom, Nom, Email
   - Mot de passe (si changement nécessaire)
   - Code PIN (si changement nécessaire)
   - Rôle
3. Cliquez sur **"Enregistrer"**

> ⚠️ **Important :** Les changements d'identifiants n'affectent pas l'historique des transactions.

#### Créditer / Débiter un compte

**Deux méthodes :**

##### Méthode 1 : Depuis la liste
1. Cliquez sur l'icône 💰 **Créditer**
2. Entrez le montant :
   - **Positif** pour un crédit (ex: +20€)
   - **Négatif** pour un débit (ex: -5€)
3. Ajoutez une note (optionnel)
4. Validez

##### Méthode 2 : Depuis le détail utilisateur
1. Cliquez sur le nom de l'utilisateur
2. Section "Solde et crédits"
3. Bouton **"Ajuster le solde"**
4. Même processus

**Résultat :**
- Le solde est mis à jour immédiatement
- Une transaction est enregistrée dans l'historique

> 💡 **Exemples d'usage :**
> - +50€ : Membre recharge son compte
> - -10€ : Correction d'une erreur

#### Historique d'un utilisateur

1. Cliquez sur le nom de l'utilisateur
2. Section **"Historique des transactions"**
3. Affichage de toutes les opérations :
   - 🛒 Achats (boutique)
   - 💰 Crédits / Débits
   - 🔄 Remboursements
   - 📅 Date et heure
   - 💳 Solde après chaque opération

---

### 📦 Gestion des Produits

#### Liste des produits

**Affichage par défaut :**
- Tous les produits (actifs + inactifs)
- Filtre par catégorie
- Indicateur de stock (couleur)

**Informations visibles :**
- Nom et description
- Catégorie
- Prix
- Stock (quantité + couleur)
- Type (Normal / Vrac)
- Statut (Actif / Inactif)

#### Créer un nouveau produit

1. Cliquez sur **"+ Ajouter un produit"**
2. Remplissez le formulaire :

##### Informations générales
- **Nom** (ex: Coca-Cola)
- **Description** (ex: Bouteille 33cl)
- **Prix** (en euros, ex: 2.50)
- **Catégorie** (sélectionner dans la liste)
- **Stock initial** (quantité)
- **Alerte stock minimum** (ex: 5)

##### Options de stock
- **☑️ Gérer le stock** : Activé par défaut
  - Si décoché : Pas de suivi de stock (café, eau libre-service)
  - Stock affiché comme "N/A"

##### Produit en vrac
- **☑️ Est un produit en vrac** : Cochez si applicable

Si coché, champs supplémentaires :
- **Unité de vrac** (ex: litres, kg)
- **Quantité totale par unité** (ex: 6 pour un fût de 6L)
- **Quantité restante dans l'unité entamée** (ex: 4.5L)

> 💡 **Exemple : Fût de bière**
> - Nom : Bière pression
> - Prix : (ne s'applique pas, voir portions)
> - Produit en vrac : ✅
> - Unité : litres
> - Quantité par fût : 6
> - Stock : 5 fûts
> - Unité entamée : 4.25L
> - **Stock total disponible = (5 × 6) + 4.25 = 34.25L**

3. **Cliquez sur "Enregistrer"**

#### Ajouter des portions (produit en vrac)

**Après avoir créé un produit en vrac :**

1. Accédez à la fiche du produit
2. Section **"Portions disponibles"**
3. Cliquez sur **"+ Ajouter une portion"**
4. Remplissez :
   - **Nom** (ex: 25cl, 50cl, 1 pinte)
   - **Quantité** (ex: 0.25 pour 25cl)
   - **Prix** (ex: 1.80€)
5. **Enregistrer**

> 📝 **Exemple complet : Bière pression**
> - Portion 1 : 25cl → 0.25L → 1.80€
> - Portion 2 : 33cl → 0.33L → 2.20€
> - Portion 3 : 50cl → 0.50L → 2.80€

**Gestion des portions :**
- ✏️ Modifier une portion
- 🗑️ Supprimer une portion

#### Modifier un produit

1. Depuis la liste, cliquez sur ✏️ **Modifier**
2. Modifiez les informations
3. **Enregistrer**

> ⚠️ **Points d'attention :**
> - Changer le type (normal ↔ vrac) nécessite de vider le stock
> - Les portions existantes sont conservées

#### Désactiver un produit

**Pourquoi désactiver au lieu de supprimer ?**
- Préserve l'historique des transactions
- Permet de réactiver plus tard

**Comment :**
1. Modifier le produit
2. Décochez **"Produit actif"**
3. Enregistrer

> 🚫 **Produit inactif :**
> - N'apparaît plus dans la boutique
> - Reste visible dans l'historique
> - Peut être réactivé à tout moment

---

### 📊 Gestion des Catégories

#### Liste des catégories

**Affichage :**
- Nom de la catégorie
- Nombre de produits
- Ordre d'affichage
- Actions (modifier, supprimer)

#### Créer une catégorie

1. Cliquez sur **"+ Ajouter une catégorie"**
2. Remplissez :
   - **Nom** (ex: Boissons chaudes)
   - **Ordre d'affichage** (ex: 1, 2, 3...)
     - Plus le numéro est petit, plus la catégorie apparaît en premier
3. **Enregistrer**

#### Modifier l'ordre d'affichage

**Deux méthodes :**

##### Méthode 1 : Modifier la catégorie
1. Cliquez sur ✏️ **Modifier**
2. Changez l'ordre d'affichage
3. Enregistrer

##### Méthode 2 : Glisser-déposer (si disponible)
1. Maintenez et glissez une catégorie
2. Déposez à la nouvelle position
3. L'ordre est sauvegardé automatiquement

#### Supprimer une catégorie

1. Cliquez sur 🗑️ **Supprimer**
2. **Confirmation demandée**
3. Les produits de cette catégorie sont déplacés vers **"Sans catégorie"**

> ⚠️ **Catégorie spéciale : "Sans catégorie"**
> - Créée automatiquement
> - Ne peut pas être supprimée
> - Affichée toujours en dernier
> - Contient les produits orphelins

---

### 🔄 Gestion du Stock

#### Vue d'ensemble du stock

**Affichage :**
- Liste de tous les produits
- Stock actuel
- Stock minimum (seuil d'alerte)
- Indicateur de couleur (vert/orange/rouge)
- Bouton "Réapprovisionner"

**Filtres :**
- Tous les produits
- Stock faible (orange)
- Rupture de stock (rouge)

#### Réapprovisionner un produit normal

1. Cliquez sur **"Réapprovisionner"** pour le produit
2. Dialog de réapprovisionnement :
   - **Quantité à ajouter** (ex: +10)
   - **Note** (optionnel, ex: "Livraison fournisseur")
3. **Valider**

**Résultat :**
- Stock mis à jour immédiatement
- Mouvement de stock enregistré (traçabilité)

> 💡 **Exemple :**
> - Stock actuel : 5 Coca-Cola
> - Réapprovisionnement : +12
> - Nouveau stock : 17

#### Réapprovisionner un produit en vrac

**Deux options possibles :**

##### Option 1 : Ajout d'unités complètes
1. Cliquez sur **"Réapprovisionner"**
2. Choisissez : **"Ajouter des unités complètes"**
3. Entrez le nombre d'unités (ex: +2 fûts)
4. Note (optionnel)
5. Valider

**Résultat :**
- `stockQuantity` augmenté de 2
- `currentUnitRemaining` inchangé

> 💡 **Exemple : Bière (fûts de 6L)**
> - Avant : 3 fûts + 4.25L entamé
> - Réappro : +2 fûts
> - Après : 5 fûts + 4.25L entamé
> - **Total : 34.25L**

##### Option 2 : Remplacer l'unité entamée
1. Cliquez sur **"Réapprovisionner"**
2. Choisissez : **"Remplacer l'unité entamée"**
3. Entrez la quantité de la nouvelle unité (ex: 6.0)
4. Note (optionnel)
5. Valider

**Résultat :**
- `stockQuantity` inchangé
- `currentUnitRemaining` remplacé par 6.0L

> 💡 **Exemple : Changement de fût**
> - Avant : 3 fûts + 0.5L entamé (presque vide)
> - Réappro : Remplacer par fût neuf (6.0L)
> - Après : 3 fûts + 6.0L entamé
> - **Total : 24L**

#### Ajustement manuel du stock

**Si besoin de corriger une erreur :**

1. Depuis la fiche produit
2. Section "Stock"
3. **"Ajustement manuel"**
4. Entrez la nouvelle quantité (absolue, pas relative)
5. Raison de l'ajustement (ex: "Inventaire", "Casse")
6. Valider

> ⚠️ **Attention :** Utilisez avec précaution. L'ajustement manuel écrase le stock.

#### Historique des mouvements de stock

**Pour chaque produit :**
1. Accédez à la fiche produit
2. Section **"Mouvements de stock"**
3. Affichage de tous les mouvements :
   - 📅 Date et heure
   - 🔄 Type (vente, réapprovisionnement, ajustement)
   - 📊 Quantité (+ ou -)
   - 📝 Notes
   - 👤 Utilisateur responsable

**Types de mouvements :**
- ➖ **Vente** : Déduction automatique lors d'un achat
- ➕ **Réapprovisionnement** : Ajout de stock
- 🔧 **Ajustement** : Correction manuelle
- 📦 **Initialisation** : Stock initial à la création

---

### 📈 Historique des Transactions

#### Vue globale

**Accès :** Dashboard admin → **"Historique des transactions"**

**Affichage :**
- Liste de toutes les transactions du club
- Filtres :
  - Par utilisateur
  - Par date (aujourd'hui, cette semaine, ce mois)
  - Par type (achat, crédit, débit, remboursement)

**Informations visibles :**
- 📅 Date et heure
- 👤 Utilisateur
- 📋 Type d'opération
- 💰 Montant
- 💳 Solde après opération

#### Détail d'une transaction

Cliquez sur une transaction pour voir :
- **Récapitulatif général**
- **Articles achetés** (si achat)
- **Notes** (si crédit/débit)
- **Administrateur** (qui a effectué l'opération)

#### Remboursement d'une transaction

**Si une erreur a été commise :**

1. Depuis le détail de la transaction
2. Bouton **"Rembourser"**
3. Confirmation demandée
4. Validez

**Résultat :**
- Le solde du membre est recrédité
- Une transaction de remboursement est créée
- L'opération est tracée dans l'historique

> ⚠️ **Important :** Le remboursement ne remet PAS en stock les produits. C'est un simple ajustement de solde.

---

### 🔙 Retour à la boutique (Admin)

**Depuis n'importe quel écran admin :**
- Cliquez sur **"Boutique"** dans le menu
- Ou icône 🛒 en haut à droite

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

**Q : J'ai oublié mon mot de passe ou mon PIN, que faire ?**
> R : Contactez un administrateur du club. Il pourra réinitialiser vos identifiants.

**Q : Puis-je changer mon mot de passe ou mon PIN moi-même ?**
> R : Non, seul un administrateur peut modifier les identifiants pour des raisons de sécurité.

**Q : Mes identifiants sont-ils sécurisés ?**
> R : Oui, le mot de passe et le code PIN sont tous deux chiffrés avec SHA-256 et ne sont jamais stockés en clair dans la base de données.

---

### Achats et panier

**Q : Puis-je acheter si mon solde est négatif ?**
> R : Cela dépend de la politique de votre club. Certains clubs autorisent un découvert limité. Si votre achat est refusé, rechargez votre compte auprès d'un administrateur.

**Q : Que signifie "Stock non géré" ?**
> R : Certains produits (café, eau libre-service) n'ont pas de limite de stock. Vous pouvez toujours les acheter.

**Q : Puis-je annuler un achat après validation ?**
> R : Non, une fois validé, l'achat est définitif. Contactez un administrateur pour un éventuel remboursement.

**Q : Pourquoi certains produits ont plusieurs prix ?**
> R : Ce sont des produits en vrac (bière pression, etc.). Le prix varie selon la portion choisie (25cl, 50cl, etc.).

**Q : Comment fonctionne le stock des produits en vrac ?**
> R : Le stock est géré en unités (fûts, caisses) et l'application suit automatiquement l'unité entamée. Exemple : 3 fûts + 4.5L dans le fût ouvert.

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
> R : Non, le mode caisse est réservé aux ventes au comptant. Pour acheter en tant que membre, utilisez la boutique normale où votre compte sera débité.

---

### Administration

**Q : Comment devenir administrateur ?**
> R : Seul un administrateur existant peut vous attribuer ce rôle. Contactez le bureau de votre aéro-club.

**Q : Puis-je supprimer un produit ?**
> R : Il est recommandé de désactiver les produits plutôt que de les supprimer, pour préserver l'historique des transactions.

**Q : Comment gérer un inventaire complet ?**
> R : Utilisez les ajustements manuels de stock en précisant "Inventaire" comme raison. Cela permet de corriger tous les stocks en une fois.

**Q : Puis-je supprimer une transaction ?**
> R : Non, les transactions ne peuvent pas être supprimées pour garantir la traçabilité. Vous pouvez en revanche les rembourser.

---

### Problèmes techniques

**Q : L'application ne se connecte pas au serveur**
> R : 
> 1. Vérifiez que le serveur est bien démarré
> 2. Vérifiez l'adresse dans Configuration serveur
> 3. Testez la connexion avec le bouton "Tester"
> 4. Contactez l'administrateur technique si le problème persiste

**Q : "Code PIN incorrect" lors d'un achat alors que je suis sûr de mon code**
> R : 
> 1. Vérifiez que vous entrez bien votre **code PIN** (4 chiffres) et non votre mot de passe
> 2. Assurez-vous d'entrer exactement 4 chiffres
> 3. Utilisez l'icône œil pour vérifier votre saisie
> 4. Si le problème persiste, demandez une réinitialisation à un administrateur

**Q : "Email ou mot de passe incorrect" lors de la connexion**
> R :
> 1. Vérifiez que vous utilisez le bon email (celui fourni par votre club)
> 2. Vérifiez que votre mot de passe contient au moins 6 caractères
> 3. Utilisez l'icône œil pour voir ce que vous tapez
> 4. Si le problème persiste, contactez un administrateur

**Q : Mon solde ne se met pas à jour**
> R : 
> 1. Fermez et relancez l'application
> 2. Reconnectez-vous
> 3. Si le problème persiste, contactez un administrateur

**Q : Un produit apparaît en double dans mon panier**
> R : Utilisez les boutons `+` et `−` pour ajuster les quantités au lieu d'ajouter plusieurs fois le même produit.

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
- **Checkout** : Finalisation et validation d'un achat
- **Produit en vrac** : Produit vendu en portions (bière pression, etc.)
- **Portion** : Quantité prédéfinie d'un produit en vrac (25cl, 50cl...)
- **Stock** : Quantité disponible d'un produit
- **Mouvement de stock** : Entrée ou sortie de stock (achat, réapprovisionnement)
- **Transaction** : Opération financière (achat, crédit, débit)
- **Soft delete** : Désactivation d'un élément sans le supprimer physiquement

### Raccourcis clavier (Desktop)

| Raccourci | Action |
|-----------|--------|
| `Échap` | Retour / Fermer dialog |
| `Entrée` | Valider (dans formulaires) |
| `Ctrl/Cmd + F` | Rechercher un produit |
| `Ctrl/Cmd + P` | Voir le panier |
| `Ctrl/Cmd + L` | Se déconnecter |

---

## 🎯 Bonnes Pratiques

### Pour les utilisateurs

✅ **À faire :**
- Vérifier votre solde régulièrement
- Valider votre panier avant de quitter
- Utiliser la recherche pour trouver rapidement un produit
- Signaler les produits en rupture à un administrateur
- Bien différencier votre mot de passe (connexion) et votre PIN (achats)

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
- Vider le panier caisse entre chaque vente
- Signaler les stocks faibles
- Donner le reçu au client si demandé

❌ **À éviter :**
- Oublier d'encaisser l'argent après avoir validé la vente
- Laisser le panier caisse rempli entre deux ventes
- Confondre mode caisse (vente au comptant) et achat personnel (compte membre)

### Pour les administrateurs

✅ **À faire :**
- Réapprovisionner dès qu'un produit passe en orange
- Vérifier régulièrement l'historique des transactions
- Faire des inventaires périodiques
- Sauvegarder régulièrement les données (backend)
- Créer des portions cohérentes pour les produits en vrac

❌ **À éviter :**
- Supprimer physiquement des produits ou transactions
- Modifier manuellement le stock sans raison valable
- Laisser des produits inactifs sans les gérer
- Oublier d'ajouter des notes lors des ajustements de solde

---

## 🚀 Mise à jour du guide

**Version actuelle :** 1.0 (Août 2026)

**Dernières modifications :**
- Création du guide utilisateur complet
- Documentation du mode caisse
- Documentation des produits en vrac et portions
- FAQ complète

**Prochaines versions :**
- Ajout de captures d'écran réelles
- Vidéos tutorielles (à venir)
- Guide avancé pour administrateurs

---

**🛫 Bon vol et bonne gestion avec AirBar ! ✈️**
