import SwiftData
import Foundation

@Model
final class Transaction {
    var id: UUID
    var amount: Decimal
    var category: Category
    var date: Date
    var note: String?
    var type: TransactionType
    
    init(amount: Decimal, category: Category, date: Date = .now, note: String? = nil, type: TransactionType) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.type = type
    }
}

enum TransactionType: String, Codable {
    case income
    case expense
} 