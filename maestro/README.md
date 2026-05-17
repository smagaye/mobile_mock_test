# 🎭 Tests Maestro - Account Manager

Ce dossier contient les tests automatisés Maestro pour l'application Account Manager.

## 📋 Prérequis

1. **Maestro CLI** installé:
   ```bash
   curl -Ls "https://get.maestro.mobile.dev" | bash
   ```

2. **Un device Android connecté** avec USB Debugging activé:
   ```bash
   flutter devices
   ```

3. **L'app compilée en debug** sur le device:
   ```bash
   flutter run
   ```

## 🚀 Lancer les tests

### Option 1: Test unique
```bash
# Tester le login success
maestro test flows/01_login_success.yaml --device <device_id>

# Tester le login error
maestro test flows/02_login_error.yaml --device <device_id>
```

### Option 2: Tous les tests
```bash
maestro test flows/ --device <device_id>
```

### Option 3: Avec variables d'environnement
```bash
maestro test flows/01_login_success.yaml \
  --device R92WC0DELDA \
  -e TEST_EMAIL="admin@test.com" \
  -e TEST_PASSWORD="Test1234!"
```

## 📝 Structure

- `01_login_success.yaml` - Test de connexion avec credentials valides
- `02_login_error.yaml` - Test de connexion avec credentials invalides
- `03_create_account.yaml` - Test de création de compte
- `04_toggle_account.yaml` - Test d'activation/désactivation de compte
- `05_delete_account.yaml` - Test de suppression de compte
- `06_full_flow.yaml` - Flux complet de l'application

## 🐛 Problèmes communs

### ❌ "email_field is visible" assertion failed
**Solution**: Le splash screen prend ~3.5 secondes pour se charger. Les tests utilisent maintenant `sleep: 3500` au lieu de `waitForAnimationToEnd`.

### ❌ App ne démarre pas
**Vérifier**:
1. Bundle ID: `com.example.account_manager`
2. Device connecté: `adb devices`
3. App compilée: `flutter run`

### ❌ Maestro CLI non trouvé
```bash
# Ajouter au PATH
export PATH="$PATH:$HOME/.maestro/bin"
```

## 📊 Notes de débogage

- Bundle ID utilisé: `com.example.account_manager`
- Credentials de test: `admin@test.com` / `Test1234!`
- Délai splash screen: 2500ms + 700ms animation = 3200ms (arrondi à 3500ms)

