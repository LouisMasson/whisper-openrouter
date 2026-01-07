import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var lastError: String?
    @Published var hasAPIKey: Bool
    @Published var selectedModelID: String {
        didSet {
            UserDefaults.standard.set(selectedModelID, forKey: "selectedModelID")
        }
    }

    let audioRecorder = AudioRecorder()
    let keyboardService = KeyboardService()

    init() {
        hasAPIKey = KeychainHelper.shared.hasAPIKey
        selectedModelID = UserDefaults.standard.string(forKey: "selectedModelID") ?? Constants.defaultModelID

        // Push-to-talk: Fn pressé = enregistre, Fn relâché = transcrit
        keyboardService.onFnPressed = { [weak self] in
            Task { @MainActor in
                self?.startRecording()
            }
        }

        keyboardService.onFnReleased = { [weak self] in
            Task { @MainActor in
                self?.stopRecordingAndTranscribe()
            }
        }

        // Démarrer le monitoring du clavier
        keyboardService.startMonitoring()

        // Vérifier les permissions d'accessibilité
        if !TextInjector.hasAccessibilityPermission() {
            TextInjector.requestAccessibilityPermission()
        }
    }

    private func startRecording() {
        guard hasAPIKey else {
            lastError = "Configure ta clé API dans les préférences"
            SoundService.shared.playErrorSound()
            print("❌ Erreur: Clé API manquante")
            return
        }

        guard !isTranscribing else {
            print("⚠️ Transcription en cours, impossible d'enregistrer")
            return
        }
        guard !isRecording else {
            print("⚠️ Enregistrement déjà en cours")
            return
        }

        print("🎤 Tentative de démarrage de l'enregistrement...")

        // Démarrer l'enregistrement EN PREMIER pour capturer les premiers mots
        do {
            try audioRecorder.startRecording()
            isRecording = true
            lastError = nil
            SoundService.shared.playStartSound()
            print("✅ Enregistrement démarré avec succès")
        } catch {
            lastError = error.localizedDescription
            SoundService.shared.playErrorSound()
            print("❌ Erreur de démarrage: \(error.localizedDescription)")
            return
        }

        // Capturer l'app qui a le focus APRÈS (en parallèle de l'enregistrement)
        TextInjector.shared.captureTargetApp()
    }

    private func stopRecordingAndTranscribe() {
        guard isRecording else {
            print("⚠️ Aucun enregistrement en cours")
            return
        }

        print("🛑 Arrêt de l'enregistrement...")

        guard let audioURL = audioRecorder.stopRecording() else {
            lastError = "Aucun enregistrement trouvé"
            isRecording = false
            SoundService.shared.playErrorSound()
            print("❌ Erreur: Pas de fichier audio")
            return
        }

        isRecording = false
        isTranscribing = true
        SoundService.shared.playStopSound()

        // Vérifier la taille du fichier
        if let fileSize = try? FileManager.default.attributesOfItem(atPath: audioURL.path)[.size] as? Int {
            print("📁 Fichier audio: \(audioURL.lastPathComponent) (\(fileSize) bytes)")
        }

        print("🔄 Début de la transcription avec modèle: \(selectedModelID)")

        Task {
            do {
                let text = try await TranscriptionService.shared.transcribe(audioURL: audioURL, modelID: selectedModelID)
                await MainActor.run {
                    print("✅ Transcription réussie: \(text.prefix(50))...")
                    // Sauvegarder dans l'historique
                    HistoryService.shared.add(text)
                    // Coller le texte
                    TextInjector.shared.inject(text: text)
                    isTranscribing = false
                }
            } catch {
                await MainActor.run {
                    lastError = error.localizedDescription
                    isTranscribing = false
                    SoundService.shared.playErrorSound()
                    print("❌ Erreur de transcription: \(error.localizedDescription)")
                }
            }

            // Nettoyer le fichier audio temporaire
            audioRecorder.cleanup()
        }
    }

    func updateAPIKey(_ key: String) async -> Bool {
        let isValid = await TranscriptionService.shared.validateAPIKey(key)
        await MainActor.run {
            if isValid {
                _ = KeychainHelper.shared.save(apiKey: key)
                hasAPIKey = true
            }
        }
        return isValid
    }

    func clearAPIKey() {
        KeychainHelper.shared.delete()
        hasAPIKey = false
    }

    func setModel(_ modelID: String) {
        selectedModelID = modelID
    }
}
