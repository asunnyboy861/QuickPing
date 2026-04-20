import Foundation

struct ReminderTemplate: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var content: String
    var category: TemplateCategory
    var isDefault: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        content: String,
        category: TemplateCategory = .general,
        isDefault: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.content = content
        self.category = category
        self.isDefault = isDefault
        self.createdAt = createdAt
    }

    var iconName: String {
        switch category {
        case .appointment: return "calendar"
        case .payment: return "dollarsign.circle"
        case .followUp: return "arrow.uturn.right"
        case .general: return "bell"
        }
    }
}

enum TemplateCategory: String, Codable, CaseIterable, Identifiable {
    case appointment = "Appointment"
    case payment = "Payment"
    case followUp = "Follow-Up"
    case general = "General"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .appointment: return "calendar"
        case .payment: return "dollarsign.circle"
        case .followUp: return "arrow.uturn.right"
        case .general: return "bell"
        }
    }
}
