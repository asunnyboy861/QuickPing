import Foundation

enum SendError: LocalizedError {
    case missingPhoneNumber(String)
    case missingEmail(String)
    case smsFailed(String)
    case emailFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .missingPhoneNumber(let name):
            return "\(name) doesn't have a phone number."
        case .missingEmail(let name):
            return "\(name) doesn't have an email address."
        case .smsFailed(let error):
            return "SMS failed: \(error)"
        case .emailFailed(let error):
            return "Email failed: \(error)"
        }
    }
}

@MainActor
class SendReminderViewModel: ObservableObject {
    @Published var selectedContacts: [Contact] = []
    @Published var selectedTemplate: ReminderTemplate?
    @Published var messageContent = ""
    @Published var selectedChannel: SendChannel = .notification
    @Published var isSending = false
    @Published var sendSuccess = false
    @Published var errorMessage: String?

    private let dataStore = DataStore.shared
    private let notificationService = NotificationService.shared
    private let smsService = TwilioService.shared
    private let emailService = SendGridService.shared

    var availableContacts: [Contact] {
        dataStore.contacts
    }

    var availableTemplates: [ReminderTemplate] {
        dataStore.templates
    }
    
    var isChannelConfigured: Bool {
        switch selectedChannel {
        case .notification:
            return true
        case .sms:
            return smsService.isConfigured
        case .email:
            return emailService.isConfigured
        }
    }

    func selectTemplate(_ template: ReminderTemplate) {
        selectedTemplate = template
        messageContent = template.content
    }

    func toggleContact(_ contact: Contact) {
        if selectedContacts.contains(where: { $0.id == contact.id }) {
            selectedContacts.removeAll { $0.id == contact.id }
        } else {
            selectedContacts.append(contact)
        }
    }

    func isContactSelected(_ contact: Contact) -> Bool {
        selectedContacts.contains(where: { $0.id == contact.id })
    }

    func personalizeMessage(_ template: String, for contact: Contact) -> String {
        var message = template
        message = message.replacingOccurrences(of: "{name}", with: contact.name)
        message = message.replacingOccurrences(of: "{company}", with: contact.company)
        return message
    }

    func sendReminders() async {
        guard !selectedContacts.isEmpty else {
            errorMessage = "Please select at least one contact."
            return
        }
        guard !messageContent.isEmpty else {
            errorMessage = "Please enter a message."
            return
        }
        
        if !isChannelConfigured {
            errorMessage = "\(selectedChannel.rawValue) service is not configured. Please configure it in Settings."
            return
        }

        isSending = true
        errorMessage = nil
        sendSuccess = false

        do {
            for contact in selectedContacts {
                let personalizedMessage = personalizeMessage(messageContent, for: contact)

                switch selectedChannel {
                case .notification:
                    try await notificationService.sendLocalReminder(
                        title: "Reminder from QuickPing",
                        body: personalizedMessage
                    )
                    
                case .sms:
                    guard !contact.phone.isEmpty else {
                        throw SendError.missingPhoneNumber(contact.name)
                    }
                    let result = try await smsService.sendSMS(
                        to: contact.phone,
                        message: personalizedMessage
                    )
                    if !result.success {
                        throw SendError.smsFailed(result.error ?? "Unknown error")
                    }
                    
                case .email:
                    guard !contact.email.isEmpty else {
                        throw SendError.missingEmail(contact.name)
                    }
                    let result = try await emailService.sendEmail(
                        to: contact.email,
                        subject: "Reminder from QuickPing",
                        body: personalizedMessage
                    )
                    if !result.success {
                        throw SendError.emailFailed(result.error ?? "Unknown error")
                    }
                }

                let record = SentReminder(
                    contactName: contact.name,
                    contactPhone: contact.phone,
                    contactEmail: contact.email,
                    templateName: selectedTemplate?.name ?? "Custom",
                    message: personalizedMessage,
                    channel: selectedChannel,
                    status: .sent
                )
                dataStore.addSentReminder(record)
            }

            sendSuccess = true
            selectedContacts = []
            selectedTemplate = nil
            messageContent = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isSending = false
    }
}
