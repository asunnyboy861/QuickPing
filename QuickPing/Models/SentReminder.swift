import Foundation

struct SentReminder: Identifiable, Codable {
    var id: UUID
    var contactName: String
    var contactPhone: String
    var contactEmail: String
    var templateName: String
    var message: String
    var channel: SendChannel
    var status: SendStatus
    var sentAt: Date

    init(
        id: UUID = UUID(),
        contactName: String,
        contactPhone: String = "",
        contactEmail: String = "",
        templateName: String,
        message: String,
        channel: SendChannel,
        status: SendStatus = .sent,
        sentAt: Date = Date()
    ) {
        self.id = id
        self.contactName = contactName
        self.contactPhone = contactPhone
        self.contactEmail = contactEmail
        self.templateName = templateName
        self.message = message
        self.channel = channel
        self.status = status
        self.sentAt = sentAt
    }
}

enum SendChannel: String, Codable, CaseIterable, Identifiable {
    case notification = "Notification"
    case sms = "SMS"
    case email = "Email"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .notification: return "bell.fill"
        case .sms: return "message.fill"
        case .email: return "envelope.fill"
        }
    }

    var isFree: Bool {
        self == .notification
    }
}

enum SendStatus: String, Codable {
    case sent = "Sent"
    case failed = "Failed"
    case pending = "Pending"
}
