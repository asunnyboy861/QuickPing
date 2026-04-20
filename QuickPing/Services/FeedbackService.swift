import Foundation

struct FeedbackRequest: Encodable {
    let name: String
    let email: String
    let subject: String
    let message: String
    let app_name: String
}

struct FeedbackResponse: Decodable {
    let success: Bool
    let id: Int?
    let error: String?
}

class FeedbackService {
    static let shared = FeedbackService()

    private let baseURL = "https://feedback-board.iocompile67692.workers.dev"
    private let appName = "QuickPing"

    private init() {}

    func submitFeedback(
        name: String,
        email: String,
        subject: String,
        message: String
    ) async throws -> FeedbackResponse {
        guard let url = URL(string: "\(baseURL)/api/feedback") else {
            throw FeedbackError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let feedback = FeedbackRequest(
            name: name,
            email: email,
            subject: subject,
            message: message,
            app_name: appName
        )

        request.httpBody = try JSONEncoder().encode(feedback)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw FeedbackError.serverError
        }

        return try JSONDecoder().decode(FeedbackResponse.self, from: data)
    }
}

enum FeedbackError: LocalizedError {
    case invalidURL
    case serverError
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid server URL."
        case .serverError: return "Server error. Please try again."
        case .networkError: return "Network error. Please check your connection."
        }
    }
}
