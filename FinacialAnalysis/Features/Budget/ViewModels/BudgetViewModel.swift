import SwiftUI
import SwiftData
import Foundation

@MainActor
final class BudgetViewModel: ObservableObject {
    @Published private(set) var categoryBudgets: [CategoryBudget] = []
    @Published private(set) var totalSpent: Decimal = 0
    @Published private(set) var totalBudget: Decimal = 0
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let repository: BudgetRepository
    private let transactionRepository: TransactionRepository
    
    init(
        repository: BudgetRepository = BudgetRepository(),
        transactionRepository: TransactionRepository = TransactionRepository()
    ) {
        self.repository = repository
        self.transactionRepository = transactionRepository
        Task {
            await loadBudgets()
        }
    }
    
    func loadBudgets() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let budgets = try await repository.fetchBudgets()
            let transactions = try await transactionRepository.fetchTransactions(for: .month)
            
            await calculateBudgetMetrics(budgets: budgets, transactions: transactions)
            error = nil
        } catch {
            self.error = error
            print("Error loading budgets: \(error)")
        }
    }
    
    func selectCategory(_ category: Category) {
        // Handle category selection for detailed view
    }
    
    func addBudget(_ budget: Budget) async {
        do {
            try await repository.save(budget)
            await loadBudgets()
            error = nil
        } catch {
            self.error = error
            print("Error saving budget: \(error)")
        }
    }
    
    func deleteBudget(for category: Category) async {
        do {
            try await repository.deleteBudget(for: category)
            await loadBudgets()
            error = nil
        } catch {
            self.error = error
            print("Error deleting budget: \(error)")
        }
    }
    
    private func calculateBudgetMetrics(budgets: [Budget], transactions: [Transaction]) async {
        var categoryBudgets: [CategoryBudget] = []
        var totalBudgetAmount: Decimal = 0
        var totalSpentAmount: Decimal = 0
        
        // Group transactions by category
        let transactionsByCategory = Dictionary(grouping: transactions) { $0.category }
        
        // Calculate spending for each budget category
        for budget in budgets {
            let categoryTransactions = transactionsByCategory[budget.category] ?? []
            let spent = categoryTransactions
                .filter { $0.type == .expense }
                .reduce(Decimal(0)) { $0 + $1.amount }
            
            // Safe calculation of progress
            let progress: Double
            if budget.amount > 0 {
                progress = Double(truncating: NSDecimalNumber(decimal: spent).dividing(by: NSDecimalNumber(decimal: budget.amount)))
            } else {
                progress = spent > 0 ? 1.0 : 0.0
            }
            
            categoryBudgets.append(CategoryBudget(
                category: budget.category,
                spent: spent,
                limit: budget.amount,
                progress: progress
            ))
            
            totalBudgetAmount += budget.amount
            totalSpentAmount += spent
        }
        
        // Sort by progress percentage (highest to lowest)
        categoryBudgets.sort { $0.progress > $1.progress }
        
        await MainActor.run {
            self.categoryBudgets = categoryBudgets
            self.totalBudget = totalBudgetAmount
            self.totalSpent = totalSpentAmount
        }
    }
}

// MARK: - Supporting Types
struct CategoryBudget: Identifiable {
    let id = UUID()
    let category: Category
    let spent: Decimal
    let limit: Decimal
    let progress: Double
    
    var remainingAmount: Decimal {
        limit - spent
    }
    
    var isOverBudget: Bool {
        spent > limit
    }
    
    var statusColor: Color {
        switch progress {
        case ..<0.5:
            return .green
        case 0.5..<0.8:
            return .yellow
        case 0.8..<1.0:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - Preview Helpers
extension CategoryBudget {
    static var preview: CategoryBudget {
        CategoryBudget(
            category: .food,
            spent: 750,
            limit: 1000,
            progress: 0.75
        )
    }
}

extension BudgetViewModel {
    static var preview: BudgetViewModel {
        let viewModel = BudgetViewModel()
        viewModel.categoryBudgets = [
            .preview,
            CategoryBudget(
                category: .transportation,
                spent: 200,
                limit: 300,
                progress: 0.67
            ),
            CategoryBudget(
                category: .entertainment,
                spent: 150,
                limit: 200,
                progress: 0.75
            )
        ]
        viewModel.totalBudget = 1500
        viewModel.totalSpent = 1100
        return viewModel
    }
}
