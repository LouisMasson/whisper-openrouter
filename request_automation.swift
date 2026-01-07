#!/usr/bin/env swift

import Foundation
import AppKit

print("🔐 Demande de permission Automation...")
print("")

// Créer un AppleScript simple qui force la demande de permission
let script = """
tell application "System Events"
    return "Permission granted"
end tell
"""

var error: NSDictionary?
if let appleScript = NSAppleScript(source: script) {
    let result = appleScript.executeAndReturnError(&error)

    if let error = error {
        print("❌ Permission refusée ou non accordée")
        print("   Erreur: \(error)")
        print("")
        print("👉 Allez dans Réglages Système > Confidentialité et sécurité > Automation")
        print("   Activez 'Whisper' → 'System Events' ✅")
    } else {
        print("✅ Permission Automation accordée!")
        print("   Résultat: \(result.stringValue ?? "OK")")
    }
} else {
    print("❌ Impossible de créer l'AppleScript")
}

print("")
