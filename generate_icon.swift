#!/usr/bin/env swift

import AppKit

// Générer une icône PNG depuis un SF Symbol
func generateIcon(symbolName: String, size: CGFloat, outputPath: String) {
    let config = NSImage.SymbolConfiguration(pointSize: size, weight: .regular)
    guard let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?.withSymbolConfiguration(config) else {
        print("❌ Impossible de créer l'image pour le symbole: \(symbolName)")
        exit(1)
    }

    // Créer une image avec fond transparent
    let targetSize = NSSize(width: size, height: size)
    let finalImage = NSImage(size: targetSize)

    finalImage.lockFocus()

    // Dessiner le symbole en noir (ou couleur de votre choix)
    NSColor.black.set()

    let rect = NSRect(origin: .zero, size: targetSize)
    image.draw(in: rect)

    finalImage.unlockFocus()

    // Sauvegarder en PNG
    guard let tiffData = finalImage.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
        print("❌ Impossible de convertir en PNG")
        exit(1)
    }

    let url = URL(fileURLWithPath: outputPath)
    do {
        try pngData.write(to: url)
        print("✅ Icône générée: \(outputPath)")
    } catch {
        print("❌ Erreur d'écriture: \(error)")
        exit(1)
    }
}

// Générer plusieurs tailles pour l'iconset
let sizes: [CGFloat] = [16, 32, 64, 128, 256, 512, 1024]
let iconsetPath = "AppIcon.iconset"

// Créer le dossier iconset
try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

for size in sizes {
    // Taille normale
    let filename = "icon_\(Int(size))x\(Int(size)).png"
    generateIcon(symbolName: "mic.circle.fill", size: size, outputPath: "\(iconsetPath)/\(filename)")

    // Taille @2x (sauf pour 1024)
    if size < 1024 {
        let filename2x = "icon_\(Int(size))x\(Int(size))@2x.png"
        generateIcon(symbolName: "mic.circle.fill", size: size * 2, outputPath: "\(iconsetPath)/\(filename2x)")
    }
}

print("✅ Iconset créé dans \(iconsetPath)")
print("Exécutez maintenant: iconutil -c icns \(iconsetPath) -o AppIcon.icns")
