// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Whisper",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "Whisper",
            targets: ["WhisperApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "WhisperApp",
            path: "Whisper",
            exclude: [
                "Info.plist",
                "Whisper.entitlements"
            ],
            sources: [
                "WhisperApp.swift",
                "AppState.swift",
                "Helpers/Constants.swift",
                "Helpers/KeychainHelper.swift",
                "Services/AudioRecorder.swift",
                "Services/TranscriptionService.swift",
                "Services/KeyboardService.swift",
                "Services/TextInjector.swift",
                "Services/SoundService.swift",
                "Services/HistoryService.swift",
                "Views/MenuBarView.swift",
                "Views/SettingsView.swift",
                "Views/HistoryView.swift"
            ]
        )
    ]
)
