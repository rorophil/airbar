# 🛒 Modes d'Achat - AirBar

**Comprendre la différence entre achat personnel et mode caisse**

---

## 📊 Comparaison Rapide

| Critère | 🛒 Achat Personnel | 💵 Mode Caisse |
|---------|-------------------|----------------|
| **Pour qui ?** | Vous-même (membre) | Clients de passage / visiteurs |
| **Client a un compte ?** | ✅ Oui (obligatoire) | ❌ Non (anonyme) |
| **Mode de paiement** | Compte membre (débité) | Espèces ou CB (immédiat) |
| **PIN demandé** | Votre PIN (acheteur) | Votre PIN (vendeur) |
| **À quoi sert le PIN ?** | Confirmer que c'est vous qui achetez | Tracer qui a fait la vente |
| **Qui est débité ?** | ✅ Vous | ❌ Personne (paiement cash) |
| **Transaction créée** | `purchase` (type achat) | `cashSale` (type vente caisse) |
| **Traçabilité** | Qui a acheté | Qui a vendu |
| **Argent encaissé** | ❌ Non (compte virtuel) | ✅ Oui (espèces/CB réel) |
| **Accès** | Icône panier 🛒 | Icône caisse 💰 |

---

## 🛒 Achat Personnel - Détaillé

### Cas d'usage
Vous êtes un **membre du club** et vous voulez acheter des produits pour vous-même.

### Processus

```
1. Boutique
   ↓
2. Ajouter produits au panier
   ↓
3. Cliquer sur l'icône panier 🛒
   ↓
4. "Passer la commande"
   ↓
5. Entrer VOTRE PIN (4 chiffres)
   ↓
6. Valider
   ↓
7. ✅ Votre compte est débité
   📦 Stock déduit
   📝 Transaction enregistrée (type: purchase)
```

### Exemple concret

**Vous achetez :**
- 2 Coca-Cola à 2.50€ = 5.00€
- 1 Paquet de chips à 1.50€ = 1.50€
- **Total : 6.50€**

**Que se passe-t-il ?**
1. Vous entrez votre PIN : `1234` (votre code personnel)
2. Votre solde passe de `42.30€` à `35.80€` (-6.50€)
3. Le stock est déduit (2 Coca, 1 chips)
4. Une transaction est enregistrée :
   - Type : `purchase` (achat)
   - Utilisateur : Vous (ID, nom)
   - Montant : -6.50€
   - Date/heure : Horodatée

**Vous ne touchez PAS d'argent** - c'est virtuel sur votre compte.

---

## 💵 Mode Caisse - Détaillé

### Cas d'usage
Un **client de passage** (pilote externe, visiteur, ami) veut acheter quelque chose au bar.

### Processus

```
1. Mode caisse (icône 💰)
   ↓
2. Sélectionner produits
   ↓
3. "Valider la vente"
   ↓
4. Choisir mode de paiement :
   💵 Espèces OU 💳 Carte
   ↓
5. Entrer VOTRE PIN (vendeur)
   ↓
6. Valider
   ↓
7. ✅ Encaisser l'argent du client
   📦 Stock déduit
   📝 Transaction enregistrée (type: cashSale)
   👤 Vous êtes tracé comme vendeur
```

### Exemple concret

**Le client achète :**
- 1 Bière 50cl à 2.80€
- 1 Paquet de cacahuètes à 1.20€
- **Total : 4.00€**

**Que se passe-t-il ?**
1. Vous sélectionnez les produits dans le panier caisse
2. Vous choisissez : `💵 Espèces`
3. Vous entrez votre PIN : `5678` (votre code de vendeur)
4. **Le client vous donne 4.00€ en liquide**
5. Vous mettez l'argent dans la caisse
6. Le stock est déduit (1 bière, 1 sachet)
7. Une transaction est enregistrée :
   - Type : `cashSale` (vente caisse)
   - Vendeur : Vous (ID, nom)
   - Client : Anonyme (pas de compte)
   - Montant : 4.00€ (espèces)
   - Mode paiement : Cash
   - Date/heure : Horodatée

**Votre compte N'EST PAS débité** - vous avez l'argent réel en caisse.

---

## 🔍 Questions Fréquentes

### Q : Pourquoi deux modes différents ?

**R :** Pour deux situations différentes :
- **Achat personnel** : Gestion des comptes membres (système de crédit interne)
- **Mode caisse** : Ventes au comptant pour générer du cash (visiteurs, urgence)

### Q : Puis-je acheter pour moi en mode caisse ?

**R :** Non, le mode caisse est strictement pour les ventes au comptant. Si vous avez un compte membre, utilisez la boutique normale. Sinon :
- Votre compte ne sera pas débité (vous perdrez le tracking)
- Vous devrez payer en espèces (alors que vous avez du crédit)

### Q : Pourquoi mon PIN est demandé en mode caisse si je ne suis pas débité ?

**R :** Pour la **traçabilité et la responsabilité** :
- L'application sait **qui a vendu quoi et quand**
- Permet de détecter les erreurs ou problèmes
- Utile pour l'audit et la comptabilité
- Évite les ventes non tracées

### Q : Un membre peut-il payer en espèces au lieu d'utiliser son compte ?

**R :** Techniquement oui via le mode caisse, mais ce n'est **pas recommandé** :
- ❌ Perte de la traçabilité sur le compte du membre
- ❌ Complique la comptabilité (mélange compte/cash)
- ❌ Le membre ne profite pas de son crédit

**Recommandation :** Les membres doivent toujours acheter via leur compte (boutique normale).

### Q : Que faire si un client veut un reçu ?

**R :** Après une vente en mode caisse, un reçu s'affiche automatiquement :
- Détails des articles
- Total payé
- Mode de paiement
- Date et heure
- Nom du vendeur

Le client peut demander une impression (si imprimante disponible).

### Q : Comment savoir combien d'argent j'ai en caisse ?

**R :** Les administrateurs peuvent :
1. Consulter l'historique des ventes caisse
2. Filtrer par vendeur et par date
3. Voir le total des espèces vs CB
4. Comparer avec l'argent physique en caisse

---

## 🎯 Aide-Mémoire Rapide

### Vous êtes MEMBRE et voulez acheter pour vous
➡️ **Boutique (icône panier 🛒)**
- Votre compte sera débité
- Entrez votre PIN d'acheteur

### Un CLIENT de passage veut acheter
➡️ **Mode Caisse (icône caisse 💰)**
- Choisir espèces ou CB
- Entrez votre PIN de vendeur
- Encaissez l'argent réel

### Vous voulez voir vos propres achats
➡️ **Menu ≡ → "Mes transactions"**
- Type : `purchase`

### Vous voulez voir vos ventes (si vous faites des permanences)
➡️ **Historique vendeur** (admin peut consulter)
- Type : `cashSale`
- Vous apparaissez comme vendeur

---

## 📌 Points Clés à Retenir

### Pour l'achat personnel
1. 🔐 **Connexion** obligatoire (email + mot de passe)
2. 🛒 **Panier** personnel
3. 🔢 **PIN** = confirme que c'est vous
4. 💳 **Compte débité** automatiquement
5. 📊 **Traçabilité** de qui a acheté quoi

### Pour le mode caisse
1. 💰 **Vente au comptant** (espèces ou CB)
2. 👤 **Client anonyme** (pas de compte nécessaire)
3. 🔢 **PIN vendeur** = trace qui a vendu
4. 💵 **Argent réel** encaissé immédiatement
5. 📊 **Traçabilité** de qui a vendu quoi

---

**💡 En cas de doute, rappelez-vous :**

> **Achat personnel** = Votre compte → Virtuel  
> **Mode caisse** = Argent liquide → Réel

---

✈️ **Bon vol et bonne gestion avec AirBar !**
