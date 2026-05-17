# Account Manager — Mock Flutter App

Application Flutter mockée pour démontrer les tests E2E avec Maestro.

## Credentials mock

| Email | Mot de passe |
|---|---|
| admin@test.com | Test1234! |

## Lancer l'app

```bash
flutter run --dart-define=BASE_URL=https://staging.monapp.com
```

---

## Maestro — Lancer les tests

```bash
# Un seul test
maestro test maestro/flows/01_login_success.yaml \
  -e TEST_EMAIL=admin@test.com \
  -e TEST_PASSWORD=Test1234!

# Tous les tests
maestro test maestro/flows/ \
  -e TEST_EMAIL=admin@test.com \
  -e TEST_PASSWORD=Test1234!

# Avec vidéo
maestro record maestro/flows/06_full_flow.yaml \
  -e TEST_EMAIL=admin@test.com \
  -e TEST_PASSWORD=Test1234!
```

---

## Carte des Semantics.identifier

### SplashScreen
| Identifier | Widget |
|---|---|
| `splash_screen` | Wrapper principal |
| `splash_logo` | Logo container |
| `splash_title` | Titre "Account Manager" |

### LoginScreen
| Identifier | Widget |
|---|---|
| `email_field` | TextField email |
| `password_field` | TextField mot de passe |
| `login_button` | Bouton "Se connecter" |
| `login_error` | Message d'erreur |

### AccountsScreen
| Identifier | Widget |
|---|---|
| `accounts_list` | ListView principale |
| `add_account_button` | FAB "Nouveau compte" |
| `logout_button` | Bouton déconnexion |
| `empty_state` | Écran vide |
| `account_item_{id}` | Carte d'un compte (ex: account_item_acc_1) |
| `account_name_{id}` | Nom du compte |
| `account_status_{id}` | Badge Actif/Inactif |
| `toggle_button_{id}` | Bouton activer/désactiver |
| `delete_button_{id}` | Bouton supprimer |
| `delete_confirm_button` | Bouton confirmer suppression (dialog) |
| `delete_cancel_button` | Bouton annuler suppression (dialog) |

### CreateAccountScreen
| Identifier | Widget |
|---|---|
| `name_field` | TextField nom |
| `create_email_field` | TextField email |
| `role_field` | Dropdown rôle |
| `create_button` | Bouton "Créer le compte" |
| `cancel_button` | Bouton fermeture (X) |
| `create_error` | Message d'erreur |

---

## Comptes mock par défaut

| ID | Nom | Email | Rôle | Statut |
|---|---|---|---|---|
| acc_1 | Alice Martin | alice@example.com | Admin | Actif |
| acc_2 | Bob Dupont | bob@example.com | Manager | Actif |
| acc_3 | Claire Bernard | claire@example.com | Utilisateur | Inactif |

---

## Tests disponibles

| Fichier | Scénario |
|---|---|
| 01_login_success.yaml | Connexion avec bons credentials |
| 02_login_error.yaml | Connexion avec mauvais credentials |
| 03_create_account.yaml | Créer un compte + erreur champs vides |
| 04_toggle_account.yaml | Activer/désactiver un compte |
| 05_delete_account.yaml | Supprimer + annuler une suppression |
| 06_full_flow.yaml | Flow complet de bout en bout |
