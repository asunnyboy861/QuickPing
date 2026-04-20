import SwiftUI

enum DesignTokens {
    static let primaryColor = Color.blue
    static let successColor = Color.green
    static let warningColor = Color.orange
    static let errorColor = Color.red

    static let cornerRadius: CGFloat = 12
    static let cardCornerRadius: CGFloat = 16
    static let buttonHeight: CGFloat = 50
    static let avatarSize: CGFloat = 48
    static let spacing: CGFloat = 16
    static let smallSpacing: CGFloat = 8

}

extension Color {
    static let appPrimary = Color.blue
    static let appBackground = Color(UIColor.systemGroupedBackground)
    static let appSurface = Color(UIColor.secondarySystemGroupedBackground)
    static let appTextPrimary = Color(UIColor.label)
    static let appTextSecondary = Color(UIColor.secondaryLabel)
    static let appDivider = Color(UIColor.separator)
}

extension View {
    func cardStyle() -> some View {
        self
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
