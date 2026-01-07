import Foundation

final class TranscriptionService {
    static let shared = TranscriptionService()
    private init() {}

    // MARK: - OpenRouter Request/Response Models

    struct OpenRouterRequest: Codable {
        let model: String
        let messages: [Message]
    }

    struct Message: Codable {
        let role: String
        let content: [Content]
    }

    struct Content: Codable {
        let type: String
        let text: String?
        let input_audio: InputAudio?

        enum CodingKeys: String, CodingKey {
            case type, text
            case input_audio
        }
    }

    struct InputAudio: Codable {
        let data: String  // base64
        let format: String  // audio format (m4a, mp3, etc.)
    }

    struct OpenRouterResponse: Codable {
        let choices: [Choice]
    }

    struct Choice: Codable {
        let message: MessageResponse
    }

    struct MessageResponse: Codable {
        let content: String
    }

    struct ErrorResponse: Codable {
        let error: ErrorDetail
    }

    struct ErrorDetail: Codable {
        let message: String
        let type: String?
        let code: String?
    }

    // MARK: - Transcription

    func transcribe(audioURL: URL, modelID: String? = nil) async throws -> String {
        guard let apiKey = KeychainHelper.shared.getAPIKey() else {
            throw TranscriptionError.noAPIKey
        }

        guard let url = URL(string: Constants.openRouterChatURL) else {
            throw TranscriptionError.invalidURL
        }

        // Utiliser le modèle fourni ou le modèle par défaut
        let selectedModel = modelID ?? Constants.defaultModelID

        // Lire et encoder l'audio en base64
        let audioData = try Data(contentsOf: audioURL)
        let base64Audio = audioData.base64EncodedString()

        // Créer la requête OpenRouter
        let openRouterRequest = OpenRouterRequest(
            model: selectedModel,
            messages: [
                Message(role: "user", content: [
                    Content(
                        type: "input_audio",
                        text: nil,
                        input_audio: InputAudio(data: base64Audio, format: "wav")
                    ),
                    Content(
                        type: "text",
                        text: "Transcris cet audio en texte. Donne uniquement la transcription exacte, rien d'autre.",
                        input_audio: nil
                    )
                ])
            ]
        )

        // Encoder en JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let requestBody = try encoder.encode(openRouterRequest)

        // Debug: Afficher la requête (sans le base64 complet pour éviter de polluer les logs)
        if let jsonString = String(data: requestBody, encoding: .utf8) {
            let truncated = jsonString.prefix(500)
            print("📤 Requête OpenRouter (tronquée): \(truncated)...")
        }

        // Créer la requête HTTP
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://whisper-macos.app", forHTTPHeaderField: "HTTP-Referer")
        request.setValue("Whisper for macOS", forHTTPHeaderField: "X-Title")
        request.httpBody = requestBody

        // Augmenter le timeout pour les gros fichiers audio
        request.timeoutInterval = 60

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranscriptionError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            // Debug: Afficher la réponse
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Réponse OpenRouter: \(responseString.prefix(500))...")
            }

            let openRouterResponse = try JSONDecoder().decode(OpenRouterResponse.self, from: data)

            guard let transcription = openRouterResponse.choices.first?.message.content else {
                throw TranscriptionError.invalidResponse
            }

            let cleanedTranscription = transcription.trimmingCharacters(in: .whitespacesAndNewlines)
            print("✅ Transcription nettoyée: \(cleanedTranscription)")
            return cleanedTranscription
        } else {
            // Tenter de décoder l'erreur OpenRouter
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                // Si erreur 401, donner un message plus détaillé
                if httpResponse.statusCode == 401 {
                    throw TranscriptionError.authenticationFailed(errorResponse.error.message)
                }
                throw TranscriptionError.apiError(errorResponse.error.message)
            }

            // Si on ne peut pas décoder l'erreur, afficher le contenu brut
            if httpResponse.statusCode == 401 {
                let errorText = String(data: data, encoding: .utf8) ?? "Erreur inconnue"
                throw TranscriptionError.authenticationFailed("Clé API invalide ou expirée. Détails: \(errorText)")
            }

            throw TranscriptionError.httpError(httpResponse.statusCode)
        }
    }

    // MARK: - API Key Validation

    func validateAPIKey(_ apiKey: String) async -> Bool {
        // Sauvegarder temporairement pour tester
        let originalKey = KeychainHelper.shared.getAPIKey()

        _ = KeychainHelper.shared.save(apiKey: apiKey)

        // Valider en faisant une requête simple vers l'endpoint OpenRouter
        guard let url = URL(string: "https://openrouter.ai/api/v1/models") else {
            if let original = originalKey {
                _ = KeychainHelper.shared.save(apiKey: original)
            }
            return false
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                let isValid = httpResponse.statusCode == 200
                if !isValid, let original = originalKey {
                    _ = KeychainHelper.shared.save(apiKey: original)
                }
                return isValid
            }
        } catch {
            if let original = originalKey {
                _ = KeychainHelper.shared.save(apiKey: original)
            }
        }

        return false
    }

    // MARK: - Error Types

    enum TranscriptionError: LocalizedError {
        case noAPIKey
        case invalidURL
        case invalidResponse
        case apiError(String)
        case httpError(Int)
        case authenticationFailed(String)

        var errorDescription: String? {
            switch self {
            case .noAPIKey:
                return "Clé API non configurée"
            case .invalidURL:
                return "URL invalide"
            case .invalidResponse:
                return "Réponse invalide du serveur"
            case .apiError(let message):
                return "Erreur API: \(message)"
            case .httpError(let code):
                return "Erreur HTTP: \(code)"
            case .authenticationFailed(let message):
                return "Authentification échouée: \(message)"
            }
        }
    }
}
