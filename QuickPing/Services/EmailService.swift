import Foundation

protocol EmailServiceProtocol {
    var isConfigured: Bool { get }
    
    func sendEmail(to email: String, subject: String, body: String) async throws -> EmailSendResult
    func configure(apiKey: String, fromEmail: String, fromName: String)
}

struct EmailSendResult: Codable {
    let success: Bool
    let messageID: String?
    let error: String?
}

enum EmailError: LocalizedError {
    case notConfigured
    case invalidEmail
    case networkError
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Email service is not configured. Please add your SendGrid API key in Settings."
        case .invalidEmail:
            return "Invalid email address format."
        case .networkError:
            return "Network error. Please check your connection."
        case .apiError(let message):
            return "Email service error: \(message)"
        }
    }
}