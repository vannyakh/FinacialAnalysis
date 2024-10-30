import Foundation
import SwiftUI

enum Category: String, Codable, CaseIterable {
    case food = "Food"
    case transportation = "Transportation"
    case housing = "Housing"
    case utilities = "Utilities"
    case entertainment = "Entertainment"
    case healthcare = "Healthcare"
    case shopping = "Shopping"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .entertainment: return "tv.fill"
        case .healthcare: return "heart.fill"
        case .shopping: return "cart.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .blue
        case .transportation: return .green
        case .housing: return .orange
        case .utilities: return .yellow
        case .entertainment: return .purple
        case .healthcare: return .red
        case .shopping: return .pink
        case .other: return .gray
        }
    }
} 