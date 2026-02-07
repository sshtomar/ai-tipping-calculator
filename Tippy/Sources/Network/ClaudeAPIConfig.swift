import Foundation

enum ClaudeAPIConfig {
    static let apiKey: String? = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"] ??
        Bundle.main.infoDictionary?["CLAUDE_API_KEY"] as? String
    static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    static let model = "claude-sonnet-4-5-20250929"
    static let anthropicVersion = "2023-06-01"
    static let timeoutSeconds: TimeInterval = 15
    static let jpegQuality: CGFloat = 0.4
}
