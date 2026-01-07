import Foundation

enum Constants {
    static let keychainService = "com.hyrak.whisper"
    static let keychainAPIKeyAccount = "openrouter-api-key"

    // OpenRouter configuration
    static let openRouterBaseURL = "https://openrouter.ai/api/v1"
    static let openRouterChatURL = "\(openRouterBaseURL)/chat/completions"

    // Available transcription models (avec support audio confirmé)
    static let availableModels: [(id: String, name: String, description: String)] = [
        ("openai/gpt-4o-audio-preview", "GPT-4o Audio", "Haute précision OpenAI"),
        ("google/gemini-3-flash-preview", "Gemini 3 Flash", "Rapide et économique"),
        ("google/gemini-3-pro-preview", "Gemini 3 Pro", "Précision maximale Google")
    ]

    static let defaultModelID = "google/gemini-3-flash-preview"
    static let doubleTapInterval: TimeInterval = 0.3 // 300ms pour double-tap
}
