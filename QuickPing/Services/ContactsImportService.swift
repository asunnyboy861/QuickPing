import Foundation
import Contacts
import ContactsUI

class ContactsImportService: ObservableObject {
    static let shared = ContactsImportService()
    
    @Published var isAuthorized = false
    @Published var systemContacts: [CNContact] = []
    
    private let store = CNContactStore()
    
    private init() {}
    
    func checkAuthorizationStatus() -> CNAuthorizationStatus {
        store.status(forEntityType: .contacts)
    }
    
    func requestAuthorization() async -> Bool {
        let status = checkAuthorizationStatus()
        
        if status == .notDetermined {
            do {
                let granted = try await store.requestAccess(for: .contacts)
                await MainActor.run {
                    isAuthorized = granted
                }
                return granted
            } catch {
                return false
            }
        } else if status == .authorized {
            await MainActor.run {
                isAuthorized = true
            }
            return true
        } else {
            return false
        }
    }
    
    func fetchContacts() async throws -> [CNContact] {
        let keys: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor
        ]
        
        let request = CNContactFetchRequest(keysToFetch: keys)
        var fetchedContacts: [CNContact] = []
        
        try store.enumerateContacts(with: request) { contact, _ in
            fetchedContacts.append(contact)
        }
        
        await MainActor.run {
            self.systemContacts = fetchedContacts
        }
        
        return fetchedContacts
    }
    
    func convertToContact(_ cnContact: CNContact) -> Contact? {
        let name = "\(cnContact.givenName) \(cnContact.familyName)".trimmingCharacters(in: .whitespaces)
        
        guard !name.isEmpty else { return nil }
        
        let phone = cnContact.phoneNumbers.first?.value.stringValue ?? ""
        let email = cnContact.emailAddresses.first?.value ?? ""
        let company = cnContact.organizationName
        
        return Contact(
            name: name,
            phone: phone,
            email: email as String,
            company: company
        )
    }
    
    func importContacts(_ cnContacts: [CNContact]) -> [Contact] {
        return cnContacts.compactMap { convertToContact($0) }
    }
}