import SwiftUI

struct QuickSendView: View {
    @StateObject private var viewModel = SendReminderViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.spacing * 1.5) {
                    contactSelectionSection

                    templateSelectionSection

                    messagePreviewSection

                    channelSelectionSection

                    PrimaryButton(
                        title: "Send Reminder",
                        icon: "paperplane.fill",
                        isDisabled: viewModel.selectedContacts.isEmpty || viewModel.messageContent.isEmpty,
                        isLoading: viewModel.isSending
                    ) {
                        Task { await viewModel.sendReminders() }
                    }
                }
                .padding(DesignTokens.spacing)
            }
            .background(Color.appBackground)
            .navigationTitle("Send Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Reminder Sent!", isPresented: $viewModel.sendSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your reminders have been sent successfully.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var contactSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.smallSpacing) {
            Text("Select Contacts")
                .font(.headline)

            if viewModel.selectedContacts.isEmpty {
                NavigationLink(destination: ContactPickerView(viewModel: viewModel)) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Contacts")
                    }
                    .foregroundStyle(Color.appPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.appPrimary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
                }
            } else {
                ForEach(viewModel.selectedContacts) { contact in
                    HStack {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.15))
                            .frame(width: 36, height: 36)
                            .overlay {
                                Text(contact.initials)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.appPrimary)
                            }
                        Text(contact.name)
                            .font(.body)
                        Spacer()
                        Button(action: { viewModel.toggleContact(contact) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, DesignTokens.spacing)
                    .padding(.vertical, 10)
                    .cardStyle()
                }

                NavigationLink(destination: ContactPickerView(viewModel: viewModel)) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add More")
                    }
                    .foregroundStyle(Color.appPrimary)
                    .font(.subheadline)
                }
            }
        }
    }

    private var templateSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.smallSpacing) {
            Text("Select Template")
                .font(.headline)

            ForEach(viewModel.availableTemplates) { template in
                TemplateSelectionRow(
                    template: template,
                    isSelected: viewModel.selectedTemplate?.id == template.id
                ) {
                    viewModel.selectTemplate(template)
                }
            }
        }
    }

    private var messagePreviewSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.smallSpacing) {
            Text("Message Preview")
                .font(.headline)

            TextEditor(text: $viewModel.messageContent)
                .frame(minHeight: 120)
                .padding(DesignTokens.smallSpacing)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                        .stroke(Color(UIColor.separator), lineWidth: 1)
                )
        }
    }

    private var channelSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.smallSpacing) {
            Text("Send Via")
                .font(.headline)

            HStack(spacing: DesignTokens.spacing) {
                ForEach(SendChannel.allCases) { channel in
                    ChannelButton(
                        channel: channel,
                        isSelected: viewModel.selectedChannel == channel,
                        isConfigured: viewModel.isChannelConfigured
                    ) {
                        viewModel.selectedChannel = channel
                    }
                }
            }
            
            if !viewModel.isChannelConfigured && viewModel.selectedChannel != .notification {
                HStack(spacing: DesignTokens.smallSpacing) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    
                    Text("\(viewModel.selectedChannel.rawValue) service is not configured. Go to Settings to configure.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, DesignTokens.smallSpacing)
            }
        }
    }
}

struct TemplateSelectionRow: View {
    let template: ReminderTemplate
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.spacing) {
                Image(systemName: template.category.iconName)
                    .font(.title3)
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(template.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(template.content)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appPrimary)
                }
            }
            .padding(DesignTokens.spacing)
            .background(isSelected ? Color.appPrimary.opacity(0.08) : Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                    .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct ChannelButton: View {
    let channel: SendChannel
    let isSelected: Bool
    let isConfigured: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: channel.iconName)
                    .font(.title3)
                Text(channel.rawValue)
                    .font(.caption.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(isSelected ? .white : Color.appPrimary)
            .background(isSelected ? Color.appPrimary : Color.appPrimary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
            .opacity(channel == .notification || isConfigured ? 1.0 : 0.5)
        }
    }
}

struct ContactPickerView: View {
    @ObservedObject var viewModel: SendReminderViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(viewModel.availableContacts) { contact in
                Button(action: {
                    viewModel.toggleContact(contact)
                }) {
                    HStack(spacing: DesignTokens.spacing) {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.15))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text(contact.initials)
                                    .font(.callout.weight(.semibold))
                                    .foregroundStyle(Color.appPrimary)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(contact.name)
                                .font(.body.weight(.medium))
                                .foregroundStyle(.primary)
                            if !contact.company.isEmpty {
                                Text(contact.company)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        if viewModel.isContactSelected(contact) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.appPrimary)
                        }
                    }
                }
            }
            .navigationTitle("Select Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
