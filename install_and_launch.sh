#!/bin/bash
# Script complet : build, install et launch de Whisper

set -e

echo "═══════════════════════════════════════════════════"
echo "  Installation de Whisper dans /Applications"
echo "═══════════════════════════════════════════════════"
echo ""

# 1. Fermer l'app si elle tourne
echo "1. Fermeture de Whisper si elle est ouverte..."
pkill -9 Whisper 2>/dev/null || true
sleep 1

# 2. Build
echo "2. Build de l'application..."
./create_app_bundle.sh

# 3. Copier dans /Applications
echo ""
echo "3. Installation dans /Applications..."
rm -rf /Applications/Whisper.app
cp -r build/Whisper.app /Applications/

# 4. Vérifier la signature
echo "4. Vérification de la signature..."
codesign -dv /Applications/Whisper.app 2>&1 | grep "Identifier"

echo ""
echo "✅ Installation terminée!"
echo ""
echo "🚀 Lancement de Whisper..."
echo ""
echo "⚠️  IMPORTANT : Des popups vont apparaître pour demander les permissions :"
echo "   - Microphone ✅"
echo "   - Accessibilité ✅"
echo "   - Automation (System Events) ✅"
echo ""
echo "   Acceptez TOUTES les permissions!"
echo ""

sleep 2

# 5. Lancer l'application
open /Applications/Whisper.app

echo ""
echo "✅ Whisper lancée depuis /Applications!"
echo ""
echo "Si les permissions ne sont pas demandées, allez dans :"
echo "  Réglages Système > Confidentialité et sécurité"
echo "  - Microphone → Whisper ✅"
echo "  - Accessibilité → Whisper ✅"
echo "  - Automation → Whisper → System Events ✅"
echo ""
