import SwiftUI

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
        // Implementation for fetching previous period transactions
        return []
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
        let changePercentage = previousSpent > 0 
            ? Double((currentSpent - previousSpent) / previousSpent * 100)
            : 0
        
        // Calculate category breakdown
        let categoryTotals = Dictionary(grouping: currentTransactions) { $0.category }
            .mapValues { transactions in
                transactions
                    .filter { $0.type == .expense }
                    .reduce(Decimal(0)) { $0 + $1.amount }
            }
        
        let breakdown = categoryTotals.map { category, amount in
            CategorySpending(
                name: category.rawValue,
                amount: amount,
                percentage: Double(amount / currentSpent),
                color: category.color // Add this property to Category enum
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
} 