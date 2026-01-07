#!/bin/bash
# Force la demande de permission Automation pour Whisper

echo "🔐 Forçage de la demande de permission Automation"
echo ""
echo "1. Fermez Whisper si elle est ouverte"
pkill -9 Whisper
sleep 1

echo "2. Réinitialisation des permissions Automation..."
tccutil reset AppleEvents com.hyrak.whisper

echo "3. Lancement de Whisper depuis /Applications..."
echo ""
echo "⚠️  UNE POPUP VA APPARAÎTRE vous demandant la permission Automation"
echo "    👉 Cliquez sur 'OK' ou 'Autoriser'"
echo ""
sleep 2

# Lancer l'application
open /Applications/Whisper.app

echo ""
echo "✅ Whisper lancée!"
echo ""
echo "Si aucune popup n'apparaît, allez manuellement dans:"
echo "   Réglages Système > Confidentialité et sécurité > Automation"
echo "   Activez 'Whisper' → 'System Events' ✅"
echo ""
