import Foundation

class TwilioService: SMSServiceProtocol {
    static let shared = TwilioService()
    
    var isConfigured: Bool {
        accountSID != nil && authToken != nil && fromNumber != nil
    }
    
    private var accountSID: String?
    private var authToken: String?
    private var fromNumber: String?
    
    private let baseURL = "https://api.twilio.com/2010-04-01/Accounts"
    
    private init() {
        loadConfiguration()
    }
    
    func configure(accountSID: String, authToken: String, fromNumber: String) {
        self.accountSID = accountSID
        self.authToken = authToken
        self.fromNumber = fromNumber
        saveConfiguration()
    }
    
    func sendSMS(to phone: String, message: String) async throws -> SMSSendResult {
        guard isConfigured else {
            throw SMSError.notConfigured
        }
        
        guard isValidPhoneNumber(phone) else {
            throw SMSError.invalidPhoneNumber
        }
        
        guard message.count <= 1600 else {
            throw SMSError.messageTooLong
        }
        
        let formattedPhone = formatPhoneNumber(phone)
        
        guard let url = URL(string: "\(baseURL)/\(accountSID!)/Messages.json") else {
            throw SMSError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let credentials = "\(accountSID!):\(authToken!)"
        let credentialsData = credentials.data(using: .utf8)!
        let base64Credentials = credentialsData.base64EncodedString()
        
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "From=\(fromNumber!)&To=\(formattedPhone)&Body=\(message.urlEncoded)"
        request.httpBody = body.data(using: .utf8)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SMSError.networkError
            }
            
            if httpResponse.statusCode == 201 {
                let twilioResponse = try JSONDecoder().decode(TwilioResponse.self, from: data)
                return SMSSendResult(
                    success: true,
                    messageID: twilioResponse.sid,
                    error: nil,
                    cost: Double(twilioResponse.price ?? "0")
                )
            } else {
                let errorResponse = try? JSONDecoder().decode(TwilioErrorResponse.self, from: data)
                throw SMSError.apiError(errorResponse?.message ?? "Unknown error")
            }
        } catch {
            if error is SMSError {
                throw error
            }
            throw SMSError.networkError
        }
    }
    
    private func loadConfiguration() {
        accountSID = UserDefaults.standard.string(forKey: "twilio_account_sid")
        authToken = UserDefaults.standard.string(forKey: "twilio_auth_token")
        fromNumber = UserDefaults.standard.string(forKey: "twilio_from_number")
    }
    
    private func saveConfiguration() {
        UserDefaults.standard.set(accountSID, forKey: "twilio_account_sid")
        UserDefaults.standard.set(authToken, forKey: "twilio_auth_token")
        UserDefaults.standard.set(fromNumber, forKey: "twilio_from_number")
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^\\+?[1-9]\\d{1,14}$"
        return phone.range(of: phoneRegex, options: .regularExpression) != nil
    }
    
    private func formatPhoneNumber(_ phone: String) -> String {
        var formatted = phone.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        if !formatted.hasPrefix("+") {
            formatted = "+1" + formatted
        }
        return formatted
    }
}

private struct TwilioResponse: Codable {
    let sid: String
    let status: String
    let price: String?
}

private struct TwilioErrorResponse: Codable {
    let message: String
    let code: Int
}

private extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
