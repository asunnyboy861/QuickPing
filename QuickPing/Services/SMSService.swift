import Foundation

protocol SMSServiceProtocol {
    var isConfigured: Bool { get }
    
    func sendSMS(to phone: String, message: String) async throws -> SMSSendResult
    func configure(accountSID: String, authToken: String, fromNumber: String)
}

struct SMSSendResult: Codable {
    let success: Bool
    let messageID: String?
    let error: String?
    let cost: Double?
}

enum SMSError: LocalizedError {
    case notConfigured
    case invalidPhoneNumber
    case messageTooLong
    case networkError
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "SMS service is not configured. Please add your Twilio credentials in Settings."
        case .invalidPhoneNumber:
            return "Invalid phone number format."
        case .messageTooLong:
            return "Message is too long. Maximum 1600 characters allowed."
        case .networkError:
            return "Network error. Please check your connection."
        case .apiError(let message):
            return "SMS service error: \(message)"
        }
    }
}