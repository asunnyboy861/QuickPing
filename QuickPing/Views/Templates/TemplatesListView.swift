import SwiftUI

struct TemplatesListView: View {
    @StateObject private var viewModel = TemplatesViewModel()
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.templates.isEmpty {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "No Templates",
                        subtitle: "Create your first reminder template."
                    )
                } else {
                    List {
                        ForEach(viewModel.groupedTemplates, id: \.0) { category, templates in
                            Section(category.rawValue) {
                                ForEach(templates) { template in
                                    NavigationLink(destination: TemplateDetailView(template: template)) {
                                        TemplateRowView(template: template)
                                    }
                                }
                                .onDelete { offsets in
                                    let itemsToDelete = offsets.map { templates[$0] }
                                    for item in itemsToDelete {
                                        viewModel.deleteTemplate(item)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: $viewModel.searchText, prompt: "Search templates...")
                }
            }
            .background(Color.appBackground)
            .navigationTitle("Templates")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                TemplateEditorView(mode: .add) { template in
                    viewModel.addTemplate(template)
                }
            }
            .onAppear {
                viewModel.loadTemplates()
            }
        }
    }
}

struct TemplateRowView: View {
    let template: ReminderTemplate

    var body: some View {
        HStack(spacing: DesignTokens.spacing) {
            Image(systemName: template.category.iconName)
                .font(.title3)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.body.weight(.medium))
                Text(template.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            if template.isDefault {
                Text("Default")
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.appPrimary.opacity(0.1))
                    .foregroundStyle(Color.appPrimary)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

struct TemplateDetailView: View {
    let template: ReminderTemplate
    @StateObject private var dataStore = DataStore.shared
    @State private var showEditSheet = false

    var body: some View {
        List {
            Section("Template Info") {
                LabeledContent("Name", value: template.name)
                LabeledContent("Category", value: template.category.rawValue)
            }

            Section("Message Content") {
                Text(template.content)
                    .font(.body)
            }

            Section {
                LabeledContent("Placeholders") {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("{name} - Contact name")
                        Text("{company} - Company name")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Template Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showEditSheet = true }) {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            TemplateEditorView(mode: .edit(template)) { updatedTemplate in
                dataStore.updateTemplate(updatedTemplate)
            }
        }
    }
}

enum TemplateEditorMode {
    case add
    case edit(ReminderTemplate)
}

struct TemplateEditorView: View {
    let mode: TemplateEditorMode
    let onSave: (ReminderTemplate) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var content = ""
    @State private var category: TemplateCategory = .general

    init(mode: TemplateEditorMode, onSave: @escaping (ReminderTemplate) -> Void) {
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .add:
            _name = State(initialValue: "")
            _content = State(initialValue: "")
            _category = State(initialValue: .general)
        case .edit(let template):
            _name = State(initialValue: template.name)
            _content = State(initialValue: template.content)
            _category = State(initialValue: template.category)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Template Name") {
                    TextField("e.g. Appointment Confirmation", text: $name)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(TemplateCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.iconName)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Message Content") {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }

                Section("Available Placeholders") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("{name}")
                                .font(.system(.caption, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.appPrimary.opacity(0.1))
                                .clipShape(Capsule())
                            Text("Contact's name")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("{company}")
                                .font(.system(.caption, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.appPrimary.opacity(0.1))
                                .clipShape(Capsule())
                            Text("Contact's company")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Template" : "New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || content.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func saveTemplate() {
        switch mode {
        case .add:
            let template = ReminderTemplate(
                name: name.trimmingCharacters(in: .whitespaces),
                content: content,
                category: category
            )
            onSave(template)
        case .edit(let original):
            var updated = original
            updated.name = name.trimmingCharacters(in: .whitespaces)
            updated.content = content
            updated.category = category
            onSave(updated)
        }
        dismiss()
    }
}
