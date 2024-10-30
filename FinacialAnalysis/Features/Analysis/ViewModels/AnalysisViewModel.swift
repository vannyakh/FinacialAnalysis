import SwiftUI
import Foundation

@MainActor
final class AnalysisViewModel: ObservableObject {
    @Published private(set) var totalSpent: Decimal = 0
    @Published private(set) var monthlyChangePercentage: Double = 0
    @Published private(set) var categoryBreakdown: [CategorySpending] = []
    @Published private(set) var monthlyTrend: [MonthlySpending] = []
    @Published private(set) var topSpendingCategories: [CategorySpending] = []
    @Published var selectedTimePeriod: TimePeriod = .month
    
    private let repository: TransactionRepository
    
    init(repository: TransactionRepository = TransactionRepository()) {
        self.repository = repository
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        do {
            let currentPeriodTransactions = try await repository.fetchTransactions(for: selectedTimePeriod)
            let previousPeriodTransactions = try await fetchPreviousPeriodTransactions()
            
            await calculateMetrics(
                currentTransactions: currentPeriodTransactions,
                previousTransactions: previousPeriodTransactions
            )
        } catch {
            print("Error loading analysis data: \(error)")
        }
    }
    
    private func fetchPreviousPeriodTransactions() async throws -> [Transaction] {
        // Calculate the start date for the previous period
        let calendar = Calendar.current
        let currentStartDate = calendar.date(byAdding: selectedTimePeriod.dateComponent, to: .now) ?? .now
        let previousStartDate = calendar.date(byAdding: selectedTimePeriod.dateComponent, to: currentStartDate) ?? currentStartDate
        
        return try await repository.fetchTransactions(from: previousStartDate, to: currentStartDate)
    }
    
    private func calculateMetrics(
        currentTransactions: [Transaction],
        previousTransactions: [Transaction]
    ) async {
        // Calculate total spent
        let currentSpent = currentTransactions
            .filter { $0.type == .expense }
            .reduce(Decimal(0)) { $0 + $1.amount }
        
        let previousSpent = previousTransactions
            .filter { $0.type == .expense }
            .reduce(Decimal(0)) { $0 + $1.amount }
        
        // Calculate monthly change percentage
        let changePercentage: Double
        if previousSpent > 0 {
            let change = NSDecimalNumber(decimal: currentSpent)
                .subtracting(NSDecimalNumber(decimal: previousSpent))
                .dividing(by: NSDecimalNumber(decimal: previousSpent))
                .multiplying(by: NSDecimalNumber(value: 100))
            changePercentage = change.doubleValue
        } else {
            changePercentage = currentSpent > 0 ? 100 : 0
        }
        
        // Calculate category breakdown
        let categoryTotals = Dictionary(grouping: currentTransactions) { $0.category }
            .mapValues { transactions in
                transactions
                    .filter { $0.type == .expense }
                    .reduce(Decimal(0)) { $0 + $1.amount }
            }
        
        let breakdown = categoryTotals.map { category, amount in
            // Safe calculation of percentage
            let percentage: Double
            if currentSpent > 0 {
                percentage = NSDecimalNumber(decimal: amount)
                    .dividing(by: NSDecimalNumber(decimal: currentSpent))
                    .doubleValue
            } else {
                percentage = 0
            }
            
            return CategorySpending(
                name: category.rawValue,
                amount: amount,
                percentage: percentage,
                color: category.color
            )
        }.sorted { $0.amount > $1.amount }
        
        // Update published properties
        await MainActor.run {
            self.totalSpent = currentSpent
            self.monthlyChangePercentage = changePercentage
            self.categoryBreakdown = breakdown
            self.topSpendingCategories = breakdown
            // TODO: Implement monthly trend data
        }
    }
}

struct CategorySpending: Identifiable {
    let id = UUID()
    let name: String
    let amount: Decimal
    let percentage: Double
    let color: Color
}

struct MonthlySpending: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Decimal
}

enum TimePeriod: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
    
    var dateComponent: DateComponents {
        switch self {
        case .week:
            return DateComponents(day: -7)
        case .month:
            return DateComponents(month: -1)
        case .quarter:
            return DateComponents(month: -3)
        case .year:
            return DateComponents(year: -1)
        }
    }
} 