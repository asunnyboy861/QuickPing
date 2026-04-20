import SwiftUI

struct SettingsView: View {
    @StateObject private var dataStore = DataStore.shared
    @AppStorage("userName") private var userName = ""
    @AppStorage("userCompany") private var userCompany = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Profile") {
                    TextField("Your Name", text: $userName)
                    TextField("Company Name", text: $userCompany)
                }

                Section("Data") {
                    LabeledContent("Contacts", value: "\(dataStore.contacts.count)")
                    LabeledContent("Templates", value: "\(dataStore.templates.count)")
                    LabeledContent("Reminders Sent", value: "\(dataStore.sentReminders.count)")
                }

                Section {
                    NavigationLink(destination: SupportView()) {
                        Label("Contact Support", systemImage: "questionmark.circle")
                    }

                    Link(destination: URL(string: "https://asunnyboy861.github.io/QuickPing-support/")!) {
                        Label("Technical Support", systemImage: "wrench.and.screwdriver")
                    }

                    Link(destination: URL(string: "https://asunnyboy861.github.io/QuickPing-pravicy/")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Link(destination: URL(string: "https://asunnyboy861.github.io/QuickPing-terms/")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    LabeledContent("Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SupportView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var selectedSubject = "Bug Report"
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    private let subjects = [
        "Bug Report",
        "Feature Request",
        "Question",
        "Performance Issue",
        "UI Feedback",
        "Other"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.spacing) {
                subjectSelectionSection

                nameSection

                emailSection

                messageSection

                PrimaryButton(
                    title: "Submit Feedback",
                    icon: "paperplane.fill",
                    isDisabled: !isFormValid,
                    isLoading: isSubmitting
                ) {
                    submitFeedback()
                }
                .padding(.top, DesignTokens.smallSpacing)
            }
            .padding(DesignTokens.spacing)
        }
        .background(Color.appBackground)
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Thank You!", isPresented: $showSuccess) {
            Button("OK") { }
        } message: {
            Text("Your feedback has been submitted successfully. We will get back to you soon.")
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var subjectSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.smallSpacing) {
            Text("Subject")
                .font(.headline)

            VStack(spacing: DesignTokens.smallSpacing) {
                ForEach(subjects, id: \.self) { subject in
                    Button(action: { selectedSubject = subject }) {
                        HStack(spacing: DesignTokens.spacing) {
                            Image(systemName: iconName(for: subject))
                                .font(.body)
                                .foregroundStyle(selectedSubject == subject ? .white : Color.appPrimary)
                                .frame(width: 24)

                            Text(subject)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(selectedSubject == subject ? .white : .primary)

                            Spacer()

                            if selectedSubject == subject {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, DesignTokens.spacing)
                        .padding(.vertical, 12)
                        .background(selectedSubject == subject ? Color.appPrimary : Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
                    }
                }
            }
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.smallSpacing) {
            Text("Name")
                .font(.headline)
            TextField("Your name", text: $name)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.smallSpacing) {
            Text("Email")
                .font(.headline)
            TextField("your@email.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
        }
    }

    private var messageSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.smallSpacing) {
            Text("Message")
                .font(.headline)
            TextEditor(text: $message)
                .frame(minHeight: 150)
                .padding(DesignTokens.smallSpacing)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                        .stroke(Color(UIColor.separator), lineWidth: 1)
                )
        }
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func iconName(for subject: String) -> String {
        switch subject {
        case "Bug Report": return "ladybug"
        case "Feature Request": return "lightbulb"
        case "Question": return "questionmark.circle"
        case "Performance Issue": return "gauge.with.dots.needle.67percent"
        case "UI Feedback": return "paintbrush"
        default: return "ellipsis.circle"
        }
    }

    private func submitFeedback() {
        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                let response = try await FeedbackService.shared.submitFeedback(
                    name: name.trimmingCharacters(in: .whitespaces),
                    email: email.trimmingCharacters(in: .whitespaces),
                    subject: selectedSubject,
                    message: message.trimmingCharacters(in: .whitespaces)
                )

                await MainActor.run {
                    isSubmitting = false
                    if response.success {
                        showSuccess = true
                        clearForm()
                    } else {
                        errorMessage = response.error ?? "Failed to submit feedback."
                    }
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func clearForm() {
        name = ""
        email = ""
        selectedSubject = "Bug Report"
        message = ""
    }
}
