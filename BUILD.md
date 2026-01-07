# Guide de Compilation et d'Utilisation - Whisper

## Compilation avec Swift Package Manager

Ce projet peut être compilé sans Xcode en utilisant Swift Package Manager (SPM).

### Prérequis

- macOS 14.0 (Sonoma) ou supérieur
- Command Line Tools for Xcode installés

Pour installer les Command Line Tools :
```bash
xcode-select --install
```

### Compilation

Pour compiler le projet :

```bash
swift build
```

Pour compiler en mode Release (optimisé) :

```bash
swift build -c release
```

L'exécutable sera créé dans :
- Debug : `.build/debug/Whisper`
- Release : `.build/release/Whisper`

### Lancement de l'application

**Méthode 1 : Script automatique** (recommandé)
```bash
./run.sh
```

**Méthode 2 : Lancement direct**
```bash
.build/debug/Whisper
```

ou en mode Release :
```bash
.build/release/Whisper
```

## Configuration

### 1. Obtenir une clé API OpenRouter

1. Rendez-vous sur https://openrouter.ai/keys
2. Créez un compte ou connectez-vous
3. Générez une nouvelle clé API
4. Copiez la clé (format : `sk-or-v1-...`)

### 2. Configurer l'application

1. Lancez l'application (elle apparaît dans la barre de menu)
2. Cliquez sur l'icône dans la barre de menu
3. Sélectionnez "Préférences..."
4. Collez votre clé API OpenRouter
5. Cliquez sur "Valider"
6. Choisissez votre modèle préféré parmi :
   - **GPT-4o Audio** : Haute précision OpenAI
   - **Gemini 2.5 Flash** : Rapide et économique (par défaut)
   - **Gemini 2.0 Flash** : Ultra rapide

### 3. Permissions requises

Au premier lancement, l'application demandera les permissions suivantes :

**Microphone** : Pour enregistrer votre voix
- Allez dans Préférences Système > Confidentialité et sécurité > Microphone
- Activez Whisper

**Accessibilité** : Pour injecter le texte transcrit
- Allez dans Préférences Système > Confidentialité et sécurité > Accessibilité
- Activez Whisper

## Utilisation

1. **Enregistrer** : Maintenez la touche `Fn` enfoncée et parlez
2. **Transcrire** : Relâchez la touche `Fn`
3. Le texte transcrit sera automatiquement inséré à l'emplacement de votre curseur

### Sons

- **Son de démarrage (Morse)** : Enregistrement démarré
- **Son d'arrêt (Pop)** : Enregistrement arrêté, transcription en cours
- **Son d'erreur (Basso)** : Une erreur s'est produite

### Historique

- Cliquez sur "Historique" dans le menu pour voir vos transcriptions récentes
- L'historique est conservé pendant 24 heures
- Vous pouvez copier ou supprimer des entrées individuelles

## Modèles disponibles

### GPT-4o Audio Preview
- **Fournisseur** : OpenAI via OpenRouter
- **Prix** : $0.0025/input, $0.01/output
- **Avantages** : Excellente précision, bonne gestion du français technique
- **Utilisation** : Idéal pour la transcription professionnelle

### Gemini 2.5 Flash
- **Fournisseur** : Google via OpenRouter
- **Prix** : $0.30/M input, $1/M audio
- **Avantages** : Bon équilibre qualité/prix, rapide
- **Utilisation** : Recommandé pour usage quotidien (par défaut)

### Gemini 2.0 Flash Exp
- **Fournisseur** : Google via OpenRouter
- **Prix** : Économique
- **Avantages** : Très rapide, bon marché
- **Utilisation** : Idéal pour des notes rapides

## Développement

### Structure du projet

```
whisper/
├── Package.swift              # Configuration SPM
├── Whisper/                   # Code source
│   ├── WhisperApp.swift      # Point d'entrée
│   ├── AppState.swift        # État de l'application
│   ├── Helpers/              # Helpers (Keychain, Constants)
│   ├── Services/             # Services (Audio, Transcription, etc.)
│   └── Views/                # Vues SwiftUI
├── run.sh                    # Script de lancement
└── BUILD.md                  # Ce fichier
```

### Recompiler après modifications

```bash
swift build
```

### Nettoyer le build

```bash
swift package clean
```

### Créer une version Release optimisée

```bash
swift build -c release
```

## Dépannage

### L'application ne démarre pas
- Vérifiez que vous avez macOS 14.0+
- Vérifiez que les Command Line Tools sont installés
- Recompilez : `swift build --clean-build`

### La transcription ne fonctionne pas
- Vérifiez que votre clé API OpenRouter est valide
- Vérifiez votre connexion Internet
- Vérifiez que vous avez des crédits OpenRouter

### Le texte ne s'insère pas automatiquement
- Vérifiez les permissions d'Accessibilité
- Assurez-vous qu'une application avec champ de texte a le focus

### Erreur de compilation
- Mettez à jour les Command Line Tools : `xcode-select --install`
- Nettoyez et recompilez : `swift package clean && swift build`

## Différences avec la version Xcode

Cette version compilée avec SPM :
- ✅ Fonctionne sans installer Xcode complet
- ✅ Plus rapide à compiler
- ✅ Utilise OpenRouter au lieu d'OpenAI direct
- ✅ Choix entre 3 modèles de transcription
- ⚠️ Les previews SwiftUI sont désactivés (commentés)
- ⚠️ Pas de signature de code (pour distribution App Store)

## Migration depuis OpenAI

Si vous aviez l'ancienne version avec OpenAI :
1. Votre ancienne clé API ne fonctionnera plus
2. Obtenez une clé OpenRouter sur https://openrouter.ai/keys
3. Configurez la nouvelle clé dans les Préférences
4. Choisissez votre modèle préféré

Les modèles OpenRouter peuvent être moins chers qu'OpenAI direct, et vous avez accès à plusieurs fournisseurs.

## Licence

MIT License - Voir le fichier LICENSE

## Support

Pour toute question ou problème :
- Créez une issue sur GitHub
- Consultez la documentation OpenRouter : https://openrouter.ai/docs
