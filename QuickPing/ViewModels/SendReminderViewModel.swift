import Foundation

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

    var availableContacts: [Contact] {
        dataStore.contacts
    }

    var availableTemplates: [ReminderTemplate] {
        dataStore.templates
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
                    break
                case .email:
                    break
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
