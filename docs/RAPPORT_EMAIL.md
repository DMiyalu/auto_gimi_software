# Rapport email hebdo / mensuel (restaurant)

Envoi automatique et manuel d’un résumé d’activité **par e-mail** au
propriétaire d’un établissement **restaurant**. Complète
[`RAPPORTS.md`](RAPPORTS.md) (agrégations UI) sans le dupliquer.

---

## 1. Décisions (V1)

| Sujet | Choix |
|-------|--------|
| Canal | **E-mail uniquement** (pas WhatsApp, pas SMS) |
| Périmètre | Établissements `category == restaurant` |
| Destinataire | Propriétaire (`establishments.ownerId`) si `users.email` valide |
| Contenu | 4 KPIs (+ % vs période précédente) + top 5 produits, montants CDF |
| Fréquences auto | Hebdo (lundi 07:00) + mensuel (1er du mois 07:00), TZ `Africa/Kinshasa` |
| Envoi manuel | Bouton **Envoyer** sur l’écran Rapports |

---

## 2. Architecture

```text
Profil (users.email)
        │
        ▼
┌───────────────────┐     onSchedule / bouton Envoyer
│ Cloud Functions   │────────────────────────────────┐
│ europe-west1      │                                │
└───────────────────┘                                ▼
        │                              SMTP / Resend / console
        │  lit establishments/*/commandes
        │  + ligne_commandes
        ▼
  KPIs + top produits → e-mail HTML/texte
        │
        ▼
  reportDeliveries/{periodKey}  (idempotence)
```

---

## 3. Cloud Functions

| Function | Trigger | Rôle |
|----------|---------|------|
| `sendWeeklyRestaurantReports` | Cron `0 7 * * 1` (`Africa/Kinshasa`) | Semaine lun→lun précédente |
| `sendMonthlyRestaurantReports` | Cron `0 7 1 * *` | Mois calendaire précédent |
| `sendTestRestaurantReport` | Callable (auth owner) | Envoi forcé (QA + bouton app) |

Code : `functions/src/reporting/`  
Export : `functions/src/index.ts`

### Règles d’agrégation

Identiques à l’écran Rapports (`RestaurantReportAggregator`) :

- **CA / panier** : commandes `cloturee`
- **Commandes / clients** : statut ≠ `annulees`
- Filtre sur `createdAt` dans `[start, end)`
- Top produits : sommes de `quantite` sur lignes des commandes clôturées

### Idempotence

Document `establishments/{id}/reportDeliveries/{periodKey}`  
(ex. `weekly_2026-08-03`, `monthly_2026-07`).  
L’envoi manuel (`force: true`) peut renvoyer même si déjà livré.

---

## 4. App mobile

| Élément | Emplacement |
|---------|-------------|
| Champ `users.email` | Profil (sheet initiale header) |
| Flag de rappel | Visible tant que l’e-mail manque / est invalide |
| Texte d’aide | « Utilisé pour le reporting hebdomadaire et mensuel… » |
| Bouton **Envoyer** | Header de l’écran Rapports → choix hebdo / mensuel |
| Appel CF | `FirebaseRestaurantReportMailRepository` → `sendTestRestaurantReport` |

Fichiers clés :

- `lib/features/establishment/domain/models/user_profile.dart`
- `lib/features/primary_module/widgets/business_header.dart`
- `lib/features/reporting/presentation/screens/restaurant_reports_screen.dart`
- `lib/features/reporting/presentation/providers/restaurant_report_providers.dart`

---

## 5. Configuration mail

Fichier : `functions/.env.gimiauto-af32b` (ne pas committer).  
Modèle : `functions/.env.example`.

```bash
MAIL_PROVIDER=smtp          # console | smtp | resend
REPORT_FROM_EMAIL=ZOLANA Rapports <noreply@example.com>

# Si MAIL_PROVIDER=smtp
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=...
SMTP_PASS=...               # mot de passe d’application Gmail

# Si MAIL_PROVIDER=resend
# RESEND_API_KEY=re_...
```

`MAIL_PROVIDER=console` : log uniquement (pas d’e-mail réel).

---

## 6. Déploiement

```bash
cd functions && npm run build && cd ..
firebase deploy --only functions,firestore:rules
```

Vérifier :

```bash
firebase functions:list
```

Doivent apparaître : `sendWeeklyRestaurantReports`,
`sendMonthlyRestaurantReports`, `sendTestRestaurantReport`.

Logs d’un envoi manuel :

```bash
firebase functions:log --only sendTestRestaurantReport
```

---

## 7. Checklist mise en service

| Étape | Statut attendu |
|-------|----------------|
| Provider mail (`smtp` / `resend`) dans `.env` | Configuré |
| Deploy functions + rules | Déployé |
| E-mail renseigné dans le profil owner (app) | Obligatoire |
| Hot-restart app + **Rapports → Envoyer** | Test manuel |
| Réception boîte mail (+ spams) | OK |

---

## 8. Tests

```bash
# Functions (agrégateur, périodes, validation e-mail)
cd functions && npm test

# App
flutter test test/establishment/user_profile_email_test.dart
flutter test test/reporting/send_restaurant_report_test.dart
flutter test test/reporting/restaurant_reports_e2e_test.dart
```

---

## 9. Hors scope V1

- WhatsApp Business, SMS digest  
- Garage / autres métiers  
- PDF joint  
- Opt-out granulaire (retirer l’e-mail du profil suffit)
