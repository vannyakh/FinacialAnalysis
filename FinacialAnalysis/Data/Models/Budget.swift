import SwiftData
import Foundation

@Model
final class Budget {
    var id: UUID
    var category: Category
    var amount: Decimal
    var period: BudgetPeriod
    var startDate: Date
    
    init(category: Category, amount: Decimal, period: BudgetPeriod = .monthly, startDate: Date = .now) {
        self.id = UUID()
        self.category = category
        self.amount = amount
        self.period = period
        self.startDate = startDate
    }
    
    var endDate: Date {
        Calendar.current.date(byAdding: period.dateComponent, to: startDate) ?? startDate
    }
    
    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
} 