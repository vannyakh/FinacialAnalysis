import Foundation

enum BudgetPeriod: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
    
    var displayName: String { rawValue }
    
    var days: Int {
        switch self {
        case .weekly:
            return 7
        case .monthly:
            return 30
        case .quarterly:
            return 90
        case .yearly:
            return 365
        }
    }
    
    var dateComponent: DateComponents {
        switch self {
        case .weekly:
            return DateComponents(day: 7)
        case .monthly:
            return DateComponents(month: 1)
        case .quarterly:
            return DateComponents(month: 3)
        case .yearly:
            return DateComponents(year: 1)
        }
    }
} 