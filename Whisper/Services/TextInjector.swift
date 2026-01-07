import AppKit
import Carbon.HIToolbox

final class TextInjector {
    static let shared = TextInjector()
    private init() {}

    /// L'app qui avait le focus quand l'enregistrement a commencé
    private var targetApp: NSRunningApplication?

    /// Capture l'app frontale actuelle (à appeler au début de l'enregistrement)
    func captureTargetApp() {
        targetApp = NSWorkspace.shared.frontmostApplication
    }

    /// Injecte le texte à la position actuelle du curseur via CGEvent
    func inject(text: String) {
        print("📋 TextInjector: Début de l'injection de texte: \"\(text.prefix(50))...\"")

        // Vérifier les permissions d'accessibilité
        if !TextInjector.hasAccessibilityPermission() {
            print("❌ TextInjector: Pas de permission d'accessibilité!")
            TextInjector.requestAccessibilityPermission()
            return
        }

        // Sauvegarder le contenu actuel du presse-papiers
        let pasteboard = NSPasteboard.general
        let previousContents = pasteboard.string(forType: .string)

        // Mettre le texte transcrit dans le presse-papiers
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        print("📋 TextInjector: Texte copié dans le presse-papiers")

        // S'assurer que l'app cible a le focus
        if let app = targetApp {
            print("📋 TextInjector: Activation de l'app cible: \(app.localizedName ?? "?")")
            app.activate(options: [.activateIgnoringOtherApps])
        } else {
            print("⚠️ TextInjector: Aucune app cible capturée!")
        }

        // Délai pour s'assurer que l'app est vraiment active
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            print("📋 TextInjector: Tentative de collage...")
            self.pasteViaCGEvent()

            // Restaurer le presse-papiers après un délai
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let previous = previousContents {
                    pasteboard.clearContents()
                    pasteboard.setString(previous, forType: .string)
                    print("📋 TextInjector: Presse-papiers restauré")
                }
                self.targetApp = nil
            }
        }
    }

    private func pasteViaCGEvent() {
        // Utiliser AppleScript pour la fiabilité
        pasteViaAppleScript()
    }

    private func pasteViaAppleScript() {
        let script = """
        tell application "System Events"
            keystroke "v" using command down
        end tell
        """

        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }

        if let error = error {
            print("❌ TextInjector: Erreur AppleScript: \(error)")
        } else {
            print("✅ TextInjector: Cmd+V exécuté via AppleScript")
        }
    }


    /// Vérifie si l'app a les permissions d'accessibilité
    static func hasAccessibilityPermission() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    /// Demande les permissions d'accessibilité
    static func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}
