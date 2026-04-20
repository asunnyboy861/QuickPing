import Foundation

@MainActor
class TemplatesViewModel: ObservableObject {
    @Published var templates: [ReminderTemplate] = []
    @Published var searchText = ""
    @Published var isShowingAddSheet = false
    @Published var editingTemplate: ReminderTemplate?

    private let dataStore = DataStore.shared

    var filteredTemplates: [ReminderTemplate] {
        if searchText.isEmpty {
            return templates
        }
        return templates.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    var groupedTemplates: [(TemplateCategory, [ReminderTemplate])] {
        let grouped = Dictionary(grouping: filteredTemplates) { $0.category }
        return grouped.sorted { $0.key.rawValue < $1.key.rawValue }
    }

    func loadTemplates() {
        templates = dataStore.templates
    }

    func addTemplate(_ template: ReminderTemplate) {
        dataStore.addTemplate(template)
        loadTemplates()
    }

    func updateTemplate(_ template: ReminderTemplate) {
        dataStore.updateTemplate(template)
        loadTemplates()
    }

    func deleteTemplate(_ template: ReminderTemplate) {
        dataStore.deleteTemplate(template)
        loadTemplates()
    }
}
