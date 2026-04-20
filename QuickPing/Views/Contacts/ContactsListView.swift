import SwiftUI

struct ContactsListView: View {
    @StateObject private var viewModel = ContactsViewModel()
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.contacts.isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: "No Contacts",
                        subtitle: "Add your first contact to start sending reminders."
                    )
                } else {
                    List {
                        ForEach(viewModel.filteredContacts) { contact in
                            NavigationLink(destination: ContactDetailView(contact: contact)) {
                                ContactRowView(contact: contact)
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .padding(.vertical, 4)
                            }
                        }
                        .onDelete { offsets in
                            viewModel.deleteContact(at: offsets, from: viewModel.filteredContacts)
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $viewModel.searchText, prompt: "Search contacts...")
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                ContactFormView(mode: .add) { contact in
                    viewModel.addContact(contact)
                }
            }
            .onAppear {
                viewModel.loadContacts()
            }
        }
    }
}

struct ContactDetailView: View {
    let contact: Contact
    @StateObject private var dataStore = DataStore.shared
    @State private var showEditSheet = false

    var body: some View {
        List {
            Section {
                HStack(spacing: DesignTokens.spacing) {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.15))
                        .frame(width: 64, height: 64)
                        .overlay {
                            Text(contact.initials)
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(Color.appPrimary)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(contact.name)
                            .font(.title2.weight(.bold))
                        if !contact.company.isEmpty {
                            Text(contact.company)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            if !contact.phone.isEmpty {
                Section {
                    HStack {
                        Label(contact.phone, systemImage: "phone.fill")
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "message.fill")
                                .foregroundStyle(Color.appPrimary)
                        }
                    }
                } header: {
                    Text("Phone")
                }
            }

            if !contact.email.isEmpty {
                Section {
                    Label(contact.email, systemImage: "envelope.fill")
                } header: {
                    Text("Email")
                }
            }

            if !contact.group.isEmpty {
                Section {
                    Label(contact.group, systemImage: "folder.fill")
                } header: {
                    Text("Group")
                }
            }

            if !contact.notes.isEmpty {
                Section {
                    Text(contact.notes)
                } header: {
                    Text("Notes")
                }
            }
        }
        .navigationTitle("Contact Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showEditSheet = true }) {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            ContactFormView(mode: .edit(contact)) { updatedContact in
                dataStore.updateContact(updatedContact)
            }
        }
    }
}

enum ContactFormMode {
    case add
    case edit(Contact)
}

struct ContactFormView: View {
    let mode: ContactFormMode
    let onSave: (Contact) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var company = ""
    @State private var notes = ""
    @State private var group = ""

    init(mode: ContactFormMode, onSave: @escaping (Contact) -> Void) {
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .add:
            _name = State(initialValue: "")
            _phone = State(initialValue: "")
            _email = State(initialValue: "")
            _company = State(initialValue: "")
            _notes = State(initialValue: "")
            _group = State(initialValue: "")
        case .edit(let contact):
            _name = State(initialValue: contact.name)
            _phone = State(initialValue: contact.phone)
            _email = State(initialValue: contact.email)
            _company = State(initialValue: contact.company)
            _notes = State(initialValue: contact.notes)
            _group = State(initialValue: contact.group)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Full Name", text: $name)
                }

                Section("Contact Info") {
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                }

                Section("Business") {
                    TextField("Company", text: $company)
                    TextField("Group", text: $group)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(isEditing ? "Edit Contact" : "New Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveContact()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func saveContact() {
        switch mode {
        case .add:
            let contact = Contact(
                name: name.trimmingCharacters(in: .whitespaces),
                phone: phone.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                company: company.trimmingCharacters(in: .whitespaces),
                notes: notes,
                group: group.trimmingCharacters(in: .whitespaces)
            )
            onSave(contact)
        case .edit(let original):
            var updated = original
            updated.name = name.trimmingCharacters(in: .whitespaces)
            updated.phone = phone.trimmingCharacters(in: .whitespaces)
            updated.email = email.trimmingCharacters(in: .whitespaces)
            updated.company = company.trimmingCharacters(in: .whitespaces)
            updated.notes = notes
            updated.group = group.trimmingCharacters(in: .whitespaces)
            updated.updatedAt = Date()
            onSave(updated)
        }
        dismiss()
    }
}
