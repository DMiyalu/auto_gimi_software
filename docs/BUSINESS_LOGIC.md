# Logique métier — Application de gestion de garage automobile

## 1. Vision produit

Application mobile destinée au **personnel du garage** (accueil, mécaniciens, responsable) pour gérer et suivre l'ensemble des opérations d'un garage automobile : accueil client, parc véhicules, catalogue de prestations, exécution et facturation des interventions, fidélisation, alertes d'entretien et pilotage basique de l'activité.

Le **client final** n'utilise pas l'application. Il interagit uniquement via des **notifications WhatsApp** (message de bienvenue, rappels d'entretien).

L'application cible **un seul garage** pour le MVP.

---

## 2. Vocabulaire du domaine

| Terme | Définition | Ne pas confondre avec |
|-------|------------|------------------------|
| **Catégorie** | Regroupement de services du catalogue (ex. « Mécanique », « Carrosserie »). | Service |
| **Service** | Prestation *proposée* par le garage, rattachée à une catégorie (ex. « Changement des roues » dans « Mécanique »). Entrée de **catalogue**. | Prestation / Intervention |
| **Prestation** (ou **Intervention**) | *Exécution réelle* d'un ou plusieurs services sur un véhicule donné, à une date donnée. Génère **une seule facture**. | Service (catalogue) |
| **Ligne de prestation** | Ligne associant un service du catalogue à une prestation, avec quantité et montant. | — |
| **Jeton boisson** | Bon pour une boisson offerte, émis à l'accueil lors de l'ouverture d'une prestation. Possède son propre QR code. | Points de fidélité |
| **Point de fidélité** | Unité accumulée par client : **1 service consommé = 1 point**. | Jeton boisson |
| **Bonus de volume** | Mécanisme de fidélité basé sur l'accumulation de points (10 points = 1 service offert). | Jeton boisson |
| **Alerte d'entretien** | Rappel calculé par véhicule, basé sur l'intervalle en jours d'un service et la dernière intervention. | Notification WhatsApp |

---

## 3. Acteurs

| Acteur | Rôle |
|--------|------|
| Personnel du garage | Utilisateur principal, authentifié via Firebase (email + mot de passe) |
| Client final | Identifié par téléphone / QR ; reçoit WhatsApp uniquement |
| Système (serveur) | Cloud Function traitant la file de notifications WhatsApp |

---

## 4. Règles métier fondamentales

### 4.1 Identification du client

- Clé d'identité principale : **numéro de téléphone** au format international **E.164** (ex. `+33612345678`).
- Identification alternative : **QR code** contenant l'**UUID du client**, généré à l'enregistrement.
- Le téléphone est **unique** dans le système (un numéro = un client).

### 4.2 Client et véhicules

- Un **client** peut posséder **plusieurs véhicules**.
- Un **véhicule** appartient à **un seul client**.
- Chaque véhicule possède :
  - un **historique** des prestations passées ;
  - des **alertes** de prochaines échéances d'entretien.
- Le **kilométrage** du véhicule est **optionnel**.

### 4.3 Catalogue de services

- Les **catégories** regroupent les **services** (relation 1—N).
  - Exemple : catégorie « Mécanique » → services « Changement des roues », « Vidange », etc.
- Chaque **service** du catalogue définit :
  - un **prix fixe** en **USD** (non modifiable à la clôture) ;
  - un **intervalle d'entretien en jours** (utilisé pour les alertes).
- Pas d'intervalle en kilomètres dans le MVP.

### 4.4 Cycle de vie d'une prestation

Une prestation se déroule en **moments distincts**.

#### A. Ouverture (accueil)

1. Scan du **QR code client** (UUID client) → identification.
2. Sélection du **véhicule** concerné.
3. Ouverture d'une **prestation** rattachée au client et au véhicule.
4. Émission immédiate d'un **jeton boisson** avec affichage de son **QR code** (UUID du jeton).

**Règles impératives :**
- **Pas de scan QR client → pas de jeton.**
- **Un jeton par prestation ouverte.**
- **Une prestation ouverte maximum par véhicule** à la fois.
- Un client avec **plusieurs véhicules** peut avoir **plusieurs prestations ouvertes** simultanément (une par véhicule).
- **Plusieurs services** peuvent être ajoutés à **une seule prestation** → **une seule facture** à la clôture.

#### B. Exécution

- Ajout des **lignes de prestation** (services du catalogue, prix fixes).
- Le personnel peut **utiliser les points de fidélité** du client pour régler la prestation ou une partie de celle-ci (voir §4.5).

#### C. Clôture

1. Calcul du montant total (USD, **TVA 0 %**).
2. Application éventuelle des **points de fidélité** en déduction.
3. **Affichage** de la facture à l'écran (MVP : pas d'impression).
4. Attribution des **points** : **1 point par service** consommé dans la prestation.
5. Mise à jour de l'**historique du véhicule**.
6. Création ou mise à jour de l'**alerte de prochaine échéance d'entretien** (jours uniquement).
7. Passage de la prestation au statut **clôturée**.

**Invariant :** une prestation **clôturée est immuable** — aucune modification possible.

### 4.5 Fidélité et points

| Règle | Détail |
|-------|--------|
| Accumulation | **1 service consommé = 1 point**, cumulés par client |
| Exemple | Prestation clôurée avec 3 services → **+3 points** |
| Conversion | **10 points = 1 service offert** (valeur = prix du service le moins cher de la prestation, ou règle à appliquer au moment du règlement — voir implémentation) |
| Utilisation | Le client peut utiliser ses points pour **régler une prestation entière ou partiellement** à la clôture |
| Décompte | Les points utilisés sont **déduits** du solde client |

### 4.6 Jeton boisson

| Règle | Détail |
|-------|--------|
| Émission | À l'ouverture de la prestation (après scan QR client) |
| QR code | Contient l'**UUID du jeton**, relié à la prestation |
| Consommation | Le personnel **scanne le QR jeton** pour vérifier sa validité et le **consommer** |
| Expiration | Le jeton **expire dès qu'il est consommé** (statut `consommé`) |
| Validité | Un jeton déjà consommé ou non lié à une prestation ouverte est **invalide** |

### 4.7 Notifications WhatsApp

| Événement | Déclencheur | Fréquence |
|-----------|-------------|-----------|
| Message de bienvenue | Enregistrement d'un **nouveau client** | **Une seule fois** |
| Rappel d'entretien | Échéance d'alerte d'entretien | **2 jours avant** l'échéance **et le jour J** |

**Principe architectural :** l'application mobile **ne contacte jamais l'API WhatsApp**. Elle crée une **demande de notification** en local (file d'attente), synchronisée vers Firestore, traitée par une **Cloud Function** côté serveur.

### 4.8 Alertes d'entretien

- Calculées **par véhicule**, à partir de l'**intervalle en jours** du service et de la **date** de la dernière intervention incluant ce service.
- **Pas de calcul basé sur le kilométrage** dans le MVP.

---

## 5. Modules fonctionnels

### 5.1 Vision cible complète

| Module | Description |
|--------|-------------|
| Clients (CRM) | Gestion et identification des clients |
| Véhicules | Parc rattaché aux clients, historique |
| Catalogue | Catégories et services |
| Prestations / Interventions | Ouverture, exécution, clôture |
| Stocks | Consommation pièces/produits |
| Facturation | Génération et impression des factures |
| Fidélité & Gamification | Jetons, points, bonus |
| Alertes & Rappels | Échéances d'entretien |
| Reporting & Statistiques | Pilotage de l'activité |
| Notifications | WhatsApp + email (transversal) |
| Personnel & Droits | Rôles et permissions |

### 5.2 Périmètre MVP (inclus)

| Module | Fonctionnalités |
|--------|-----------------|
| **Authentification** | Firebase Auth — email + mot de passe |
| **Clients** | CRUD, identification téléphone + QR (UUID client), solde de points |
| **Véhicules** | CRUD rattachés à un client, consultation historique prestations |
| **Catalogue** | CRUD catégories et services, intervalle d'entretien en jours, prix fixe USD |
| **Prestations** | Ouverture (scan QR client → jeton), ajout lignes services, utilisation points, clôture (facture écran, historique, alertes) |
| **Jetons boisson** | Émission, affichage QR, scan pour validation et consommation |
| **Fidélité** | Compteur points par client, conversion 10 pts = 1 service, déduction à la clôture |
| **Reporting (basique)** | Stats du jour : nombre de prestations, chiffre d'affaires |
| **Notifications WhatsApp** | File d'attente locale : bienvenue + rappel entretien (J-2 et J) |
| **Paramètres** | Choix de langue : Français ou Anglais (défaut = langue du device) |
| **Sync** | Synchronisation bidirectionnelle Firestore |

### 5.3 Hors MVP (reporté)

| Élément | Raison |
|---------|--------|
| Impression factures et jetons | Pas de terminal d'impression ; affichage écran suffit |
| Email reporting hebdo / mensuel propriétaire (restaurant) | Cloud Functions planifiées + `users.email` (voir `docs/RAPPORTS.md`) |
| Gestion fine des stocks | Hors périmètre initial |
| Personnel et rôles avancés | Un seul profil admin suffit |
| Gamification avancée | Phase ultérieure |
| Intervalle d'entretien en km | Supprimé du modèle |
| TVA | 0 % pour l'instant ; évolution future possible |
| Multi-garage | Un seul garage pour le MVP |

---

## 6. Flux métier principaux (MVP)

### 6.1 Connexion

```
Saisie email + mot de passe
  → Firebase Auth
  → Accès à l'application
```

### 6.2 Enregistrement d'un nouveau client

```
Saisie infos client (téléphone E.164 obligatoire)
  → Création client (UUID)
  → Génération QR code client (UUID)
  → Initialisation solde points = 0
  → Création demande notification « bienvenue » (file locale)
  → Sync Firestore → Cloud Function → WhatsApp
```

### 6.3 Ouverture d'une prestation

```
Scan QR client (UUID)
  → Identification client
  → Sélection véhicule (vérifier : pas de prestation ouverte sur ce véhicule)
  → Ouverture prestation (statut : ouverte)
  → Émission jeton boisson + affichage QR jeton (UUID jeton)
```

### 6.4 Consommation d'un jeton boisson

```
Scan QR jeton (UUID)
  → Vérification validité (statut = émis, prestation associée ouverte)
  → Affichage confirmation
  → Marquage jeton consommé (statut = consommé, dateConsommation)
```

### 6.5 Clôture d'une prestation

```
Prestation ouverte + lignes services ajoutées
  → Proposition utilisation points fidélité (optionnel)
  → Calcul montant total USD (TVA 0 %, déduction points appliquée)
  → Affichage facture à l'écran
  → +N points client (N = nombre de services/lignes)
  → Déduction points utilisés du solde
  → Enregistrement dans historique véhicule
  → Création / MAJ alertes entretien (par service, en jours)
  → Clôture prestation (statut : clôturée, immuable)
```

### 6.6 Rappel d'entretien

```
Alerte entretien à échéance dans 2 jours
  → Création demande notification « rappel J-2 » (file locale)
  → Sync → Cloud Function → WhatsApp

Alerte entretien le jour J
  → Création demande notification « rappel J » (file locale)
  → Sync → Cloud Function → WhatsApp
```

---

## 7. Contraintes et invariants métier

1. Téléphone client unique (format E.164).
2. Pas de jeton sans scan QR client et sans prestation ouverte.
3. Un jeton maximum par prestation ouverte.
4. Un jeton consommé ne peut plus être réutilisé.
5. Message de bienvenue WhatsApp : une seule fois par client.
6. Véhicule rattaché à exactement un client.
7. Une prestation ouverte maximum par véhicule.
8. Prestation clôturée = immuable.
9. Prix des services fixes (catalogue), devise USD, TVA 0 %.
10. 1 service consommé = 1 point ; 10 points = 1 service offert.
11. Alertes d'entretien basées sur les jours uniquement.
12. Rappels WhatsApp : J-2 et jour J.
13. L'application fonctionne **offline-first** : opérations métier sans connexion ; sync et WhatsApp à la reconnexion.
