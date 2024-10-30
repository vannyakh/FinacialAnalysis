import Foundation

enum TransactionFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case income = "Income"
    case expense = "Expense"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
} 