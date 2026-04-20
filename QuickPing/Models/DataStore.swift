import Foundation

class DataStore: ObservableObject {
    static let shared = DataStore()

    @Published var contacts: [Contact] = []
    @Published var templates: [ReminderTemplate] = []
    @Published var sentReminders: [SentReminder] = []

    private let contactsKey = "quickping_contacts"
    private let templatesKey = "quickping_templates"
    private let sentRemindersKey = "quickping_sent_reminders"

    private init() {
        loadContacts()
        loadTemplates()
        loadSentReminders()
        if templates.isEmpty {
            templates = ReminderTemplate.defaultTemplates
            saveTemplates()
        }
    }

    private func loadContacts() {
        guard let data = UserDefaults.standard.data(forKey: contactsKey) else { return }
        contacts = (try? JSONDecoder().decode([Contact].self, from: data)) ?? []
    }

    private func saveContacts() {
        guard let data = try? JSONEncoder().encode(contacts) else { return }
        UserDefaults.standard.set(data, forKey: contactsKey)
    }

    private func loadTemplates() {
        guard let data = UserDefaults.standard.data(forKey: templatesKey) else { return }
        templates = (try? JSONDecoder().decode([ReminderTemplate].self, from: data)) ?? []
    }

    private func saveTemplates() {
        guard let data = try? JSONEncoder().encode(templates) else { return }
        UserDefaults.standard.set(data, forKey: templatesKey)
    }

    private func loadSentReminders() {
        guard let data = UserDefaults.standard.data(forKey: sentRemindersKey) else { return }
        sentReminders = (try? JSONDecoder().decode([SentReminder].self, from: data)) ?? []
    }

    private func saveSentReminders() {
        guard let data = try? JSONEncoder().encode(sentReminders) else { return }
        UserDefaults.standard.set(data, forKey: sentRemindersKey)
    }

    func addContact(_ contact: Contact) {
        contacts.append(contact)
        saveContacts()
    }

    func updateContact(_ contact: Contact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
            saveContacts()
        }
    }

    func deleteContact(_ contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
        saveContacts()
    }

    func addTemplate(_ template: ReminderTemplate) {
        templates.append(template)
        saveTemplates()
    }

    func updateTemplate(_ template: ReminderTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            saveTemplates()
        }
    }

    func deleteTemplate(_ template: ReminderTemplate) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }

    func addSentReminder(_ reminder: SentReminder) {
        sentReminders.insert(reminder, at: 0)
        saveSentReminders()
    }

    var todaySentCount: Int {
        let calendar = Calendar.current
        return sentReminders.filter { calendar.isDateInToday($0.sentAt) }.count
    }

    var recentContacts: [Contact] {
        Array(contacts.sorted { $0.updatedAt > $1.updatedAt }.prefix(5))
    }
}

extension ReminderTemplate {
    static var defaultTemplates: [ReminderTemplate] {
        [
            ReminderTemplate(
                name: "Appointment Confirmation",
                content: "Hi {name},\n\nThis is a friendly reminder about your upcoming appointment. Please reply to confirm or let us know if you need to reschedule.\n\nThank you!\n{company}",
                category: .appointment,
                isDefault: true
            ),
            ReminderTemplate(
                name: "Payment Reminder",
                content: "Hi {name},\n\nThis is a reminder that your payment is now due. Please submit your payment at your earliest convenience.\n\nThank you for your business!\n{company}",
                category: .payment,
                isDefault: true
            ),
            ReminderTemplate(
                name: "Follow-Up",
                content: "Hi {name},\n\nI wanted to follow up on our recent conversation. Please let me know if you have any questions or if there's anything else I can help with.\n\nBest regards,\n{company}",
                category: .followUp,
                isDefault: true
            ),
            ReminderTemplate(
                name: "General Reminder",
                content: "Hi {name},\n\nJust a quick reminder regarding {company}. Please let us know if you need any assistance.\n\nThank you!",
                category: .general,
                isDefault: true
            )
        ]
    }
}
