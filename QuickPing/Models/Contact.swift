import Foundation

struct Contact: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var phone: String
    var email: String
    var company: String
    var notes: String
    var group: String
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        phone: String = "",
        email: String = "",
        company: String = "",
        notes: String = "",
        group: String = "",
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.company = company
        self.notes = notes
        self.group = group
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var initials: String {
        name.split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map { String($0) }
            .joined()
            .uppercased()
    }
}
