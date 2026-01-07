#!/bin/bash
# Créer un vrai App Bundle macOS pour Whisper

set -e

echo "=== Création de l'App Bundle Whisper.app ==="
echo ""

# Compiler en mode Release pour de meilleures performances
echo "1. Compilation en mode Release..."
swift build -c release

# Créer la structure du bundle
APP_NAME="Whisper.app"
APP_PATH="build/$APP_NAME"
CONTENTS_PATH="$APP_PATH/Contents"
MACOS_PATH="$CONTENTS_PATH/MacOS"
RESOURCES_PATH="$CONTENTS_PATH/Resources"

echo "2. Création de la structure du bundle..."
rm -rf "$APP_PATH"
mkdir -p "$MACOS_PATH"
mkdir -p "$RESOURCES_PATH"

# Copier l'exécutable
echo "3. Copie de l'exécutable..."
cp .build/release/Whisper "$MACOS_PATH/Whisper"

# Copier l'icône
echo "4. Copie de l'icône..."
if [ -f "AppIcon.icns" ]; then
    cp AppIcon.icns "$RESOURCES_PATH/AppIcon.icns"
    echo "   ✅ Icône copiée"
else
    echo "   ⚠️  AppIcon.icns introuvable, icône par défaut utilisée"
fi

# Créer Info.plist
echo "5. Création de l'Info.plist..."
cat > "$CONTENTS_PATH/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Whisper</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.hyrak.whisper</string>
    <key>CFBundleName</key>
    <string>Whisper</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSMicrophoneUsageDescription</key>
    <string>Whisper a besoin d'accéder au microphone pour enregistrer votre voix et la transcrire en texte.</string>
    <key>NSAppleEventsUsageDescription</key>
    <string>Whisper a besoin de contrôler System Events pour insérer automatiquement le texte transcrit.</string>
</dict>
</plist>
EOF

# Rendre l'exécutable... exécutable
chmod +x "$MACOS_PATH/Whisper"

echo ""
echo "✅ App Bundle créé avec succès!"
echo ""
echo "📦 Emplacement: $APP_PATH"
echo ""
echo "Pour lancer l'application:"
echo "  open build/Whisper.app"
echo ""
echo "Pour installer dans Applications:"
echo "  cp -r build/Whisper.app /Applications/"
echo ""
