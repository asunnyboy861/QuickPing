import Foundation

@MainActor
class ContactsViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var searchText = ""
    @Published var isShowingAddSheet = false
    @Published var editingContact: Contact?

    private let dataStore = DataStore.shared

    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contacts
        }
        return contacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.company.localizedCaseInsensitiveContains(searchText) ||
            $0.email.localizedCaseInsensitiveContains(searchText)
        }
    }

    var groupedContacts: [(String, [Contact])] {
        let grouped = Dictionary(grouping: filteredContacts) { contact in
            contact.group.isEmpty ? "All Contacts" : contact.group
        }
        return grouped.sorted { $0.key < $1.key }
    }

    func loadContacts() {
        contacts = dataStore.contacts
    }

    func addContact(_ contact: Contact) {
        dataStore.addContact(contact)
        loadContacts()
    }

    func updateContact(_ contact: Contact) {
        dataStore.updateContact(contact)
        loadContacts()
    }

    func deleteContact(_ contact: Contact) {
        dataStore.deleteContact(contact)
        loadContacts()
    }

    func deleteContact(at offsets: IndexSet, from contacts: [Contact]) {
        for index in offsets {
            let contact = contacts[index]
            deleteContact(contact)
        }
    }
}
