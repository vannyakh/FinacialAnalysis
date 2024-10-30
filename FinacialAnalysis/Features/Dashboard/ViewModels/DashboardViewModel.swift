import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var totalBalance: Decimal = 0
    @Published private(set) var monthlyIncome: Decimal = 0
    @Published private(set) var monthlyExpenses: Decimal = 0
    @Published private(set) var recentTransactions: [Transaction] = []
    @Published private(set) var monthlySpendingData: [SpendingData] = []
    
    private let transactionRepository: TransactionRepository
    
    init(transactionRepository: TransactionRepository = TransactionRepository()) {
        self.transactionRepository = transactionRepository
        Task {
            await refreshData()
        }
    }
    
    func refreshData() async {
        do {
            let transactions = try await transactionRepository.fetchTransactions(for: .month)
            let recentOnes = try await transactionRepository.fetchRecentTransactions(limit: 5)
            
            let income = transactions
                .filter { $0.type == .income }
                .reduce(Decimal(0)) { $0 + $1.amount }
            
            let expenses = transactions
                .filter { $0.type == .expense }
                .reduce(Decimal(0)) { $0 + $1.amount }
            
            // Calculate spending by category
            let categoryTotals = Dictionary(grouping: transactions.filter { $0.type == .expense }) { $0.category }
                .mapValues { transactions in
                    transactions.reduce(Decimal(0)) { $0 + $1.amount }
                }
            
            let spendingData = categoryTotals.map { category, amount in
                SpendingData(category: category, amount: amount)
            }.sorted { $0.amount > $1.amount }
            
            await MainActor.run {
                self.totalBalance = income - expenses
                self.monthlyIncome = income
                self.monthlyExpenses = expenses
                self.recentTransactions = recentOnes
                self.monthlySpendingData = spendingData
            }
        } catch {
            print("Error refreshing dashboard data: \(error)")
        }
    }
} 