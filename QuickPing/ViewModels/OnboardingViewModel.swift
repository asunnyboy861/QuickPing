import Foundation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var isNotificationAuthorized = false
    @Published var isContactsAuthorized = false
    @Published var selectedIndustry: IndustryType?
    @Published var isCompleted = false
    
    private let notificationService = NotificationService.shared
    private let dataStore = DataStore.shared
    
    let totalPages = 4
    
    enum IndustryType: String, CaseIterable, Identifiable {
        case dental = "Dental Clinic"
        case law = "Law Firm"
        case beauty = "Beauty Salon"
        case contractor = "Contractor"
        case consultant = "Consultant"
        case other = "Other"
        
        var id: String { rawValue }
        
        var iconName: String {
            switch self {
            case .dental: return "tooth"
            case .law: return "scale.3d"
            case .beauty: return "scissors"
            case .contractor: return "hammer"
            case .consultant: return "briefcase"
            case .other: return "building.2"
            }
        }
        
        var description: String {
            switch self {
            case .dental: return "Appointment confirmations and follow-ups"
            case .law: return "Document reminders and client follow-ups"
            case .beauty: return "Booking confirmations and reminders"
            case .contractor: return "Project updates and payment reminders"
            case .consultant: return "Meeting reminders and follow-ups"
            case .other: return "Custom reminder templates"
            }
        }
    }
    
    func requestNotificationPermission() async {
        isNotificationAuthorized = await notificationService.requestAuthorization()
    }
    
    func requestContactsPermission() async {
        isContactsAuthorized = true
    }
    
    func selectIndustry(_ industry: IndustryType) {
        selectedIndustry = industry
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isCompleted = true
    }
    
    func nextPage() {
        if currentPage < totalPages - 1 {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
}
