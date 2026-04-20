import SwiftUI

struct HistoryView: View {
    @StateObject private var dataStore = DataStore.shared
    @State private var filterChannel: SendChannel?

    var body: some View {
        NavigationStack {
            Group {
                if dataStore.sentReminders.isEmpty {
                    EmptyStateView(
                        icon: "clock",
                        title: "No History",
                        subtitle: "Your sent reminders will appear here."
                    )
                } else {
                    List {
                        ForEach(filteredReminders) { reminder in
                            HistoryRowView(reminder: reminder)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("All Channels") { filterChannel = nil }
                        ForEach(SendChannel.allCases) { channel in
                            Button(channel.rawValue) { filterChannel = channel }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }

    private var filteredReminders: [SentReminder] {
        if let filter = filterChannel {
            return dataStore.sentReminders.filter { $0.channel == filter }
        }
        return dataStore.sentReminders
    }
}

struct HistoryRowView: View {
    let reminder: SentReminder

    var body: some View {
        HStack(spacing: DesignTokens.spacing) {
            Image(systemName: reminder.channel.iconName)
                .font(.title3)
                .foregroundStyle(channelColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.contactName)
                    .font(.body.weight(.medium))
                Text(reminder.templateName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(reminder.message)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(reminder.sentAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(reminder.sentAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                statusBadge
            }
        }
        .padding(DesignTokens.spacing)
        .cardStyle()
    }

    private var channelColor: Color {
        switch reminder.channel {
        case .notification: return .blue
        case .sms: return .green
        case .email: return .orange
        }
    }

    private var statusBadge: some View {
        Text(reminder.status.rawValue)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(reminder.status == .sent ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
            .foregroundStyle(reminder.status == .sent ? .green : .red)
            .clipShape(Capsule())
    }
}
