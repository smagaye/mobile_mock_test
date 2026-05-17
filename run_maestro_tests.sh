#!/bin/bash

# ───────────────────────────────────────────────────────────
# run_maestro_tests.sh
# Script pour lancer les tests Maestro facilement
# ───────────────────────────────────────────────────────────

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🎭 Account Manager - Maestro Tests${NC}"
echo ""

# Vérifier Maestro
if ! command -v maestro &> /dev/null; then
    echo -e "${RED}❌ Maestro CLI non trouvé${NC}"
    echo "Installation: curl -Ls 'https://get.maestro.mobile.dev' | bash"
    exit 1
fi

# Lister les devices
echo -e "${BLUE}📱 Devices disponibles:${NC}"
adb devices | tail -n +2

# Demander le device ID si non fourni
if [ -z "$1" ]; then
    echo ""
    echo -e "${BLUE}Entrez l'ID du device (Ex: R92WC0DELDA):${NC}"
    read DEVICE_ID
else
    DEVICE_ID="$1"
fi

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}❌ Aucun device fourni${NC}"
    exit 1
fi

# Test email/password
TEST_EMAIL="${TEST_EMAIL:-admin@test.com}"
TEST_PASSWORD="${TEST_PASSWORD:-Test1234!}"

echo ""
echo -e "${GREEN}✓ Device: $DEVICE_ID${NC}"
echo -e "${GREEN}✓ Email: $TEST_EMAIL${NC}"
echo -e "${GREEN}✓ Password: ****${NC}"
echo ""

# Menu des tests
echo -e "${BLUE}📋 Choisir les tests à lancer:${NC}"
echo "1) Test login success"
echo "2) Test login error"
echo "3) Test create account"
echo "4) Test toggle account"
echo "5) Test delete account"
echo "6) Full flow"
echo "7) Tous les tests"
echo ""
read -p "Choix (1-7): " CHOICE

case $CHOICE in
    1)
        maestro test maestro/flows/01_login_success.yaml \
            --device "$DEVICE_ID" \
            -e TEST_EMAIL="$TEST_EMAIL" \
            -e TEST_PASSWORD="$TEST_PASSWORD"
        ;;
    2)
        maestro test maestro/flows/02_login_error.yaml \
            --device "$DEVICE_ID"
        ;;
    3)
        maestro test maestro/flows/03_create_account.yaml \
            --device "$DEVICE_ID" \
            -e TEST_EMAIL="$TEST_EMAIL" \
            -e TEST_PASSWORD="$TEST_PASSWORD"
        ;;
    4)
        maestro test maestro/flows/04_toggle_account.yaml \
            --device "$DEVICE_ID" \
            -e TEST_EMAIL="$TEST_EMAIL" \
            -e TEST_PASSWORD="$TEST_PASSWORD"
        ;;
    5)
        maestro test maestro/flows/05_delete_account.yaml \
            --device "$DEVICE_ID" \
            -e TEST_EMAIL="$TEST_EMAIL" \
            -e TEST_PASSWORD="$TEST_PASSWORD"
        ;;
    6)
        maestro test maestro/flows/06_full_flow.yaml \
            --device "$DEVICE_ID" \
            -e TEST_EMAIL="$TEST_EMAIL" \
            -e TEST_PASSWORD="$TEST_PASSWORD"
        ;;
    7)
        maestro test maestro/flows/ \
            --device "$DEVICE_ID" \
            -e TEST_EMAIL="$TEST_EMAIL" \
            -e TEST_PASSWORD="$TEST_PASSWORD"
        ;;
    *)
        echo -e "${RED}❌ Choix invalide${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Tests terminés!${NC}"

