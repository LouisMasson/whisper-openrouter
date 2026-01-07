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
        print("📋 TextInjector: Utilisation de CGEvent pour Cmd+V")

        // Créer événement Cmd+V via CGEvent (nécessite seulement Accessibility, pas Automation)
        let vKeyCode: CGKeyCode = 9  // Touche V

        // Événement: Appui sur Cmd
        guard let cmdDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_Command), keyDown: true) else {
            print("❌ TextInjector: Impossible de créer événement Cmd down")
            return
        }

        // Événement: Appui sur V avec Cmd
        guard let vDown = CGEvent(keyboardEventSource: nil, virtualKey: vKeyCode, keyDown: true) else {
            print("❌ TextInjector: Impossible de créer événement V down")
            return
        }
        vDown.flags = .maskCommand

        // Événement: Relâchement de V
        guard let vUp = CGEvent(keyboardEventSource: nil, virtualKey: vKeyCode, keyDown: false) else {
            print("❌ TextInjector: Impossible de créer événement V up")
            return
        }
        vUp.flags = .maskCommand

        // Événement: Relâchement de Cmd
        guard let cmdUp = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_Command), keyDown: false) else {
            print("❌ TextInjector: Impossible de créer événement Cmd up")
            return
        }

        // Poster les événements
        let loc = CGEventTapLocation.cghidEventTap
        vDown.post(tap: loc)
        vUp.post(tap: loc)

        print("✅ TextInjector: Cmd+V envoyé via CGEvent")
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
