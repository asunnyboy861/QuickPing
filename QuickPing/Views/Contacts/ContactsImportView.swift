import SwiftUI
import Contacts

struct ContactsImportView: View {
    @StateObject private var importService = ContactsImportService.shared
    @StateObject private var dataStore = DataStore.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedContacts: Set<String> = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading contacts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !importService.isAuthorized {
                    authorizationRequiredView
                } else if importService.systemContacts.isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: "No Contacts",
                        subtitle: "Your address book is empty."
                    )
                } else {
                    contactsList
                }
            }
            .navigationTitle("Import Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Import") {
                        importSelectedContacts()
                    }
                    .disabled(selectedContacts.isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .task {
            await loadContacts()
        }
    }
    
    private var authorizationRequiredView: some View {
        VStack(spacing: DesignTokens.spacing * 2) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            VStack(spacing: DesignTokens.smallSpacing) {
                Text("Contacts Access Required")
                    .font(.title2.bold())
                
                Text("Please grant access to your contacts to import them into QuickPing.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.spacing * 2)
            }
            
            PrimaryButton(title: "Grant Access") {
                Task {
                    let granted = await importService.requestAuthorization()
                    if granted {
                        await loadContacts()
                    }
                }
            }
            .frame(width: 200)
            
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.subheadline)
        }
    }
    
    private var contactsList: some View {
        List(importService.systemContacts, id: \.identifier) { contact in
            Button(action: { toggleContact(contact) }) {
                HStack(spacing: DesignTokens.spacing) {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text(getInitials(from: contact))
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(Color.appPrimary)
                        }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(getFullName(from: contact))
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)
                        
                        if !contact.organizationName.isEmpty {
                            Text(contact.organizationName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let phone = contact.phoneNumbers.first?.value.stringValue {
                            Text(phone)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    
                    Spacer()
                    
                    if selectedContacts.contains(contact.identifier) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.appPrimary)
                    } else {
                        Image(systemName: "circle")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    private func loadContacts() async {
        isLoading = true
        
        let authorized = await importService.requestAuthorization()
        
        if authorized {
            do {
                _ = try await importService.fetchContacts()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        
        isLoading = false
    }
    
    private func toggleContact(_ contact: CNContact) {
        if selectedContacts.contains(contact.identifier) {
            selectedContacts.remove(contact.identifier)
        } else {
            selectedContacts.insert(contact.identifier)
        }
    }
    
    private func importSelectedContacts() {
        let contactsToImport = importService.systemContacts.filter {
            selectedContacts.contains($0.identifier)
        }
        
        let newContacts = importService.importContacts(contactsToImport)
        
        for contact in newContacts {
            dataStore.addContact(contact)
        }
        
        dismiss()
    }
    
    private func getInitials(from contact: CNContact) -> String {
        let givenName = contact.givenName
        let familyName = contact.familyName
        
        let initials = "\(givenName.first ?? "?")\(familyName.first ?? "")"
        return initials.uppercased()
    }
    
    private func getFullName(from contact: CNContact) -> String {
        "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
    }
}
