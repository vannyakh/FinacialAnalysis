import Foundation
import SwiftData

class BudgetRepository {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Budget.self)
            modelContext = ModelContainer.shared.mainContext
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    // MARK: - CRUD Operations
    
    func fetchBudgets() async throws -> [Budget] {
        let descriptor = FetchDescriptor<Budget>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func fetchBudget(for category: Category) async throws -> Budget? {
        let descriptor = FetchDescriptor<Budget>(
            predicate: #Predicate<Budget> { budget in
                budget.category == category
            }
        )
        
        let budgets = try modelContext.fetch(descriptor)
        return budgets.first
    }
    
    func save(_ budget: Budget) async throws {
        // Check if budget already exists for category
        if let existingBudget = try await fetchBudget(for: budget.category) {
            // Update existing budget
            existingBudget.amount = budget.amount
            existingBudget.period = budget.period
            existingBudget.startDate = budget.startDate
        } else {
            // Create new budget
            modelContext.insert(budget)
        }
        
        try modelContext.save()
    }
    
    func deleteBudget(for category: Category) async throws {
        guard let budget = try await fetchBudget(for: category) else {
            return
        }
        
        modelContext.delete(budget)
        try modelContext.save()
    }
    
    func deleteAllBudgets() async throws {
        let budgets = try await fetchBudgets()
        budgets.forEach { modelContext.delete($0) }
        try modelContext.save()
    }
    
    // MARK: - Budget Analysis
    
    func getBudgetUtilization(for period: TimePeriod = .month) async throws -> [BudgetUtilization] {
        let budgets = try await fetchBudgets()
        let transactions = try await TransactionRepository().fetchTransactions(for: period)
        
        return budgets.map { budget in
            let categoryTransactions = transactions.filter { $0.category == budget.category }
            let spent = categoryTransactions
                .filter { $0.type == .expense }
                .reduce(Decimal(0)) { $0 + $1.amount }
            
            return BudgetUtilization(
                category: budget.category,
                budgetAmount: budget.amount,
                spentAmount: spent,
                period: budget.period
            )
        }
    }
    
    func checkBudgetAlerts() async throws -> [BudgetAlert] {
        let utilizations = try await getBudgetUtilization()
        return utilizations.compactMap { utilization in
            let percentage = Double(utilization.spentAmount / utilization.budgetAmount)
            
            if percentage >= 0.9 {
                return BudgetAlert(
                    category: utilization.category,
                    percentage: percentage,
                    severity: percentage >= 1.0 ? .critical : .warning
                )
            }
            return nil
        }
    }
}

// MARK: - Supporting Types

struct BudgetUtilization {
    let category: Category
    let budgetAmount: Decimal
    let spentAmount: Decimal
    let period: BudgetPeriod
    
    var remainingAmount: Decimal {
        budgetAmount - spentAmount
    }
    
    var utilizationPercentage: Double {
        Double(spentAmount / budgetAmount)
    }
}

struct BudgetAlert {
    let category: Category
    let percentage: Double
    let severity: AlertSeverity
    
    enum AlertSeverity {
        case warning    // 90-99% of budget
        case critical   // 100%+ of budget
    }
}

// MARK: - Preview Helpers

extension BudgetRepository {
    static var preview: BudgetRepository {
        let repository = BudgetRepository()
        
        // Add sample budgets
        Task {
            try? await repository.save(Budget(
                category: .food,
                amount: 1000,
                period: .monthly
            ))
            try? await repository.save(Budget(
                category: .transportation,
                amount: 300,
                period: .monthly
            ))
            try? await repository.save(Budget(
                category: .entertainment,
                amount: 200,
                period: .monthly
            ))
        }
        
        return repository
    }
} 