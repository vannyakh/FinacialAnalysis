import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
    var preferences: UserPreferences
    
    init(id: UUID = UUID(), name: String, email: String, preferences: UserPreferences = .default) {
        self.id = id
        self.name = name
        self.email = email
        self.preferences = preferences
    }
}

struct UserPreferences: Codable {
    var defaultCurrency: String
    var notificationsEnabled: Bool
    var budgetAlertThreshold: Double
    var theme: AppTheme
    
    static let `default` = UserPreferences(
        defaultCurrency: "USD",
        notificationsEnabled: true,
        budgetAlertThreshold: 0.8,
        theme: .system
    )
}

enum AppTheme: String, Codable {
    case light
    case dark
    case system
} 