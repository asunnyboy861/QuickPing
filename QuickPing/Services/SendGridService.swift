import Foundation

class SendGridService: EmailServiceProtocol {
    static let shared = SendGridService()
    
    var isConfigured: Bool {
        apiKey != nil && fromEmail != nil
    }
    
    private var apiKey: String?
    private var fromEmail: String?
    private var fromName: String?
    
    private let baseURL = "https://api.sendgrid.com/v3/mail/send"
    
    private init() {
        loadConfiguration()
    }
    
    func configure(apiKey: String, fromEmail: String, fromName: String = "QuickPing") {
        self.apiKey = apiKey
        self.fromEmail = fromEmail
        self.fromName = fromName
        saveConfiguration()
    }
    
    func sendEmail(to email: String, subject: String, body: String) async throws -> EmailSendResult {
        guard isConfigured else {
            throw EmailError.notConfigured
        }
        
        guard isValidEmail(email) else {
            throw EmailError.invalidEmail
        }
        
        guard let url = URL(string: baseURL) else {
            throw EmailError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let emailRequest = SendGridRequest(
            personalizations: [
                SendGridPersonalization(to: [SendGridEmail(email: email)])
            ],
            from: SendGridEmail(email: fromEmail!, name: fromName),
            subject: subject,
            content: [SendGridContent(type: "text/plain", value: body)]
        )
        
        request.httpBody = try JSONEncoder().encode(emailRequest)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw EmailError.networkError
            }
            
            if httpResponse.statusCode == 202 {
                let messageID = httpResponse.value(forHTTPHeaderField: "X-Message-Id")
                return EmailSendResult(
                    success: true,
                    messageID: messageID,
                    error: nil
                )
            } else {
                throw EmailError.apiError("HTTP \(httpResponse.statusCode)")
            }
        } catch {
            if error is EmailError {
                throw error
            }
            throw EmailError.networkError
        }
    }
    
    private func loadConfiguration() {
        apiKey = UserDefaults.standard.string(forKey: "sendgrid_api_key")
        fromEmail = UserDefaults.standard.string(forKey: "sendgrid_from_email")
        fromName = UserDefaults.standard.string(forKey: "sendgrid_from_name")
    }
    
    private func saveConfiguration() {
        UserDefaults.standard.set(apiKey, forKey: "sendgrid_api_key")
        UserDefaults.standard.set(fromEmail, forKey: "sendgrid_from_email")
        UserDefaults.standard.set(fromName, forKey: "sendgrid_from_name")
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
}

private struct SendGridRequest: Codable {
    let personalizations: [SendGridPersonalization]
    let from: SendGridEmail
    let subject: String
    let content: [SendGridContent]
}

private struct SendGridPersonalization: Codable {
    let to: [SendGridEmail]
}

private struct SendGridEmail: Codable {
    let email: String
    var name: String?
    
    init(email: String, name: String? = nil) {
        self.email = email
        self.name = name
    }
}

private struct SendGridContent: Codable {
    let type: String
    let value: String
}
