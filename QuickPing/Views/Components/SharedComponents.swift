import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isDisabled: Bool
    let isLoading: Bool
    let action: () -> Void

    init(
        title: String,
        icon: String? = nil,
        isDisabled: Bool = false,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDisabled = isDisabled
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.smallSpacing) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    if let icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.buttonHeight)
            .foregroundStyle(.white)
            .background(isDisabled ? Color.gray : Color.appPrimary)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        }
        .disabled(isDisabled || isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.smallSpacing) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.buttonHeight)
            .foregroundStyle(Color.appPrimary)
            .background(Color.appPrimary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String

    init(text: Binding<String>, placeholder: String = "Search...") {
        self._text = text
        self.placeholder = placeholder
    }

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(DesignTokens.smallSpacing + 4)
        .background(Color(UIColor.tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: DesignTokens.spacing) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title3.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignTokens.spacing * 2)
    }
}
