import SwiftUI

struct HomeView: View {
    @StateObject private var dataStore = DataStore.shared
    @State private var showQuickSend = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.spacing) {
                    todayStatsCard

                    quickSendButton

                    recentContactsSection

                    recentActivitySection
                }
                .padding(.horizontal, DesignTokens.spacing)
                .padding(.vertical, DesignTokens.smallSpacing)
            }
            .background(Color.appBackground)
            .navigationTitle("QuickPing")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showQuickSend) {
                QuickSendView()
            }
        }
    }

    private var todayStatsCard: some View {
        HStack(spacing: DesignTokens.spacing) {
            VStack(spacing: 4) {
                Text("\(dataStore.todaySentCount)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.appPrimary)
                Text("Sent Today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 40)

            VStack(spacing: 4) {
                Text("\(dataStore.contacts.count)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.orange)
                Text("Contacts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(DesignTokens.spacing)
        .cardStyle()
    }

    private var quickSendButton: some View {
        Button(action: { showQuickSend = true }) {
            HStack(spacing: DesignTokens.smallSpacing) {
                Image(systemName: "paperplane.fill")
                Text("Quick Send")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.buttonHeight + 6)
            .background(Color.appPrimary)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius + 4))
        }
    }

    private var recentContactsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.smallSpacing) {
            HStack {
                Text("Recent Contacts")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: ContactsListView()) {
                    Text("See All")
                        .font(.subheadline)
                }
            }

            if dataStore.recentContacts.isEmpty {
                EmptyStateView(
                    icon: "person.2",
                    title: "No Contacts Yet",
                    subtitle: "Add contacts to start sending reminders."
                )
            } else {
                ForEach(dataStore.recentContacts) { contact in
                    ContactRowView(contact: contact)
                }
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.smallSpacing) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: HistoryView()) {
                    Text("See All")
                        .font(.subheadline)
                }
            }

            if dataStore.sentReminders.isEmpty {
                EmptyStateView(
                    icon: "clock",
                    title: "No Activity Yet",
                    subtitle: "Send your first reminder to see activity here."
                )
            } else {
                ForEach(dataStore.sentReminders.prefix(5)) { reminder in
                    ActivityRowView(reminder: reminder)
                }
            }
        }
    }
}

struct ContactRowView: View {
    let contact: Contact

    var body: some View {
        HStack(spacing: DesignTokens.spacing) {
            Circle()
                .fill(Color.appPrimary.opacity(0.15))
                .frame(width: DesignTokens.avatarSize, height: DesignTokens.avatarSize)
                .overlay {
                    Text(contact.initials)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.appPrimary)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.body.weight(.medium))
                if !contact.company.isEmpty {
                    Text(contact.company)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            HStack(spacing: DesignTokens.spacing) {
                if !contact.phone.isEmpty {
                    Image(systemName: "message.fill")
                        .foregroundStyle(Color.appPrimary)
                }
                if !contact.email.isEmpty {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(Color.appPrimary.opacity(0.6))
                }
            }
            .font(.subheadline)
        }
        .padding(DesignTokens.spacing)
        .cardStyle()
    }
}

struct ActivityRowView: View {
    let reminder: SentReminder

    var body: some View {
        HStack(spacing: DesignTokens.spacing) {
            Image(systemName: reminder.channel.iconName)
                .font(.title3)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.contactName)
                    .font(.body.weight(.medium))
                Text(reminder.templateName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(reminder.channel.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.appPrimary)
                Text(reminder.sentAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(DesignTokens.spacing)
        .cardStyle()
    }
}
