import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $viewModel.currentPage) {
                    WelcomePageView()
                        .tag(0)
                    
                    PermissionPageView(viewModel: viewModel)
                        .tag(1)
                    
                    ImportContactsPageView(viewModel: viewModel)
                        .tag(2)
                    
                    TemplateSelectionPageView(viewModel: viewModel)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                
                bottomNavigation
            }
        }
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                dismiss()
            }
        }
    }
    
    private var bottomNavigation: some View {
        HStack(spacing: DesignTokens.spacing) {
            if viewModel.currentPage > 0 {
                SecondaryButton(title: "Back") {
                    viewModel.previousPage()
                }
                .frame(width: 100)
            }
            
            Spacer()
            
            if viewModel.currentPage < viewModel.totalPages - 1 {
                PrimaryButton(title: "Next") {
                    viewModel.nextPage()
                }
                .frame(width: 120)
            } else {
                PrimaryButton(title: "Get Started") {
                    viewModel.completeOnboarding()
                }
                .frame(width: 140)
            }
        }
        .padding(.horizontal, DesignTokens.spacing)
        .padding(.vertical, DesignTokens.spacing)
        .background(Color(UIColor.secondarySystemGroupedBackground))
    }
}

struct WelcomePageView: View {
    var body: some View {
        VStack(spacing: DesignTokens.spacing * 2) {
            Spacer()
            
            Image(systemName: "paperplane.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.appPrimary)
            
            VStack(spacing: DesignTokens.smallSpacing) {
                Text("Welcome to QuickPing")
                    .font(.largeTitle.bold())
                
                Text("One-Tap Reminder Assistant")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: DesignTokens.spacing) {
                FeatureRow(
                    icon: "bolt.fill",
                    title: "Quick Send",
                    description: "Send reminders in 3 taps"
                )
                
                FeatureRow(
                    icon: "person.2.fill",
                    title: "Contact Management",
                    description: "Organize your clients easily"
                )
                
                FeatureRow(
                    icon: "doc.text.fill",
                    title: "Smart Templates",
                    description: "Pre-built templates for your business"
                )
            }
            .padding(.horizontal, DesignTokens.spacing * 2)
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: DesignTokens.spacing) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct PermissionPageView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: DesignTokens.spacing * 2) {
            Spacer()
            
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.appPrimary)
            
            VStack(spacing: DesignTokens.smallSpacing) {
                Text("Enable Notifications")
                    .font(.largeTitle.bold())
                
                Text("Get notified when your reminders are sent")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.spacing * 2)
            }
            
            VStack(spacing: DesignTokens.spacing) {
                PermissionRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "Receive alerts for your reminders",
                    isGranted: viewModel.isNotificationAuthorized
                ) {
                    Task {
                        await viewModel.requestNotificationPermission()
                    }
                }
                
                PermissionRow(
                    icon: "person.2.fill",
                    title: "Contacts",
                    description: "Import contacts from your address book",
                    isGranted: viewModel.isContactsAuthorized
                ) {
                    Task {
                        await viewModel.requestContactsPermission()
                    }
                }
            }
            .padding(.horizontal, DesignTokens.spacing * 2)
            
            Spacer()
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.spacing) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isGranted ? Color.green : Color.appPrimary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isGranted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(DesignTokens.spacing)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        }
    }
}

struct ImportContactsPageView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @StateObject private var dataStore = DataStore.shared
    
    var body: some View {
        VStack(spacing: DesignTokens.spacing * 2) {
            Spacer()
            
            Image(systemName: "person.badge.plus")
                .font(.system(size: 80))
                .foregroundStyle(Color.appPrimary)
            
            VStack(spacing: DesignTokens.smallSpacing) {
                Text("Add Your Contacts")
                    .font(.largeTitle.bold())
                
                Text("Import or manually add contacts to start sending reminders")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.spacing * 2)
            }
            
            VStack(spacing: DesignTokens.spacing) {
                ImportOptionRow(
                    icon: "arrow.down.circle.fill",
                    title: "Import from Contacts",
                    description: "Select contacts from your address book",
                    action: {}
                )
                
                ImportOptionRow(
                    icon: "plus.circle.fill",
                    title: "Add Manually",
                    description: "Enter contact information manually",
                    action: {}
                )
                
                ImportOptionRow(
                    icon: "square.and.arrow.up",
                    title: "Import from CSV",
                    description: "Upload a CSV file with contacts",
                    action: {}
                )
            }
            .padding(.horizontal, DesignTokens.spacing * 2)
            
            Spacer()
        }
    }
}

struct ImportOptionRow: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.spacing) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(DesignTokens.spacing)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        }
    }
}

struct TemplateSelectionPageView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: DesignTokens.spacing) {
            Spacer()
            
            Image(systemName: "doc.text.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.appPrimary)
            
            VStack(spacing: DesignTokens.smallSpacing) {
                Text("Choose Your Industry")
                    .font(.largeTitle.bold())
                
                Text("We'll set up templates tailored to your business")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.spacing * 2)
            }
            
            ScrollView {
                VStack(spacing: DesignTokens.smallSpacing) {
                    ForEach(OnboardingViewModel.IndustryType.allCases) { industry in
                        IndustrySelectionRow(
                            industry: industry,
                            isSelected: viewModel.selectedIndustry?.id == industry.id
                        ) {
                            viewModel.selectIndustry(industry)
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.spacing * 2)
            }
            
            Spacer()
        }
    }
}

struct IndustrySelectionRow: View {
    let industry: OnboardingViewModel.IndustryType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.spacing) {
                Image(systemName: industry.iconName)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : Color.appPrimary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(industry.rawValue)
                        .font(.headline)
                        .foregroundStyle(isSelected ? .white : .primary)
                    Text(industry.description)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                }
            }
            .padding(DesignTokens.spacing)
            .background(isSelected ? Color.appPrimary : Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                    .stroke(isSelected ? Color.appPrimary : Color.clear, lineWidth: 2)
            )
        }
    }
}
