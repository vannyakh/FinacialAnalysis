import SwiftUI
import SwiftData

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published private(set) var groupedTransactions: [GroupedTransactions] = []
    @Published var searchText = ""
    @Published var selectedFilter: TransactionFilter = .all {
        didSet {
            Task {
                await loadTransactions()
            }
        }
    }
    
    private let repository: TransactionRepository
    private var allTransactions: [Transaction] = []
    
    init(repository: TransactionRepository = TransactionRepository()) {
        self.repository = repository
        Task {
            await loadTransactions()
        }
    }
    
    func loadTransactions() async {
        do {
            let transactions = try await repository.fetchTransactions(for: .month)
            
            // Filter transactions based on selected filter
            let filteredTransactions = filterTransactions(transactions)
            
            // Group transactions by date
            let grouped = Dictionary(grouping: filteredTransactions) { transaction in
                Calendar.current.startOfDay(for: transaction.date)
            }
            
            // Convert to array and sort by date
            let groupedArray = grouped.map { date, transactions in
                GroupedTransactions(
                    date: date,
                    transactions: transactions.sorted { $0.date > $1.date }
                )
            }.sorted { $0.date > $1.date }
            
            await MainActor.run {
                self.allTransactions = transactions
                self.groupedTransactions = groupedArray
            }
        } catch {
            print("Error loading transactions: \(error)")
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) async {
        do {
            try await repository.delete(transaction)
            await loadTransactions()
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
    
    private func filterTransactions(_ transactions: [Transaction]) -> [Transaction] {
        var filtered = transactions
        
        // Apply type filter
        switch selectedFilter {
        case .income:
            filtered = filtered.filter { $0.type == .income }
        case .expense:
            filtered = filtered.filter { $0.type == .expense }
        case .all:
            break
        }
        
        // Apply search filter if text is not empty
        if !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                let categoryMatch = transaction.category.rawValue
                    .localizedCaseInsensitiveContains(searchText)
                let noteMatch = transaction.note?
                    .localizedCaseInsensitiveContains(searchText) ?? false
                return categoryMatch || noteMatch
            }
        }
        
        return filtered
    }
    
    // MARK: - Transaction Summary
    var totalIncome: Decimal {
        allTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Decimal {
        allTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    var balance: Decimal {
        totalIncome - totalExpenses
    }
}

// MARK: - Supporting Types
struct GroupedTransactions: Identifiable {
    let id = UUID()
    let date: Date
    let transactions: [Transaction]
    
    var totalAmount: Decimal {
        transactions.reduce(0) { total, transaction in
            switch transaction.type {
            case .income:
                return total + transaction.amount
            case .expense:
                return total - transaction.amount
            }
        }
    }
}

// MARK: - Preview Helpers
extension TransactionsViewModel {
    static var preview: TransactionsViewModel {
        let viewModel = TransactionsViewModel()
        
        // Add sample grouped transactions
        viewModel.groupedTransactions = [
            GroupedTransactions(
                date: .now,
                transactions: [
                    Transaction(
                        amount: 50,
                        category: .food,
                        note: "Lunch",
                        type: .expense
                    ),
                    Transaction(
                        amount: 1000,
                        category: .other,
                        note: "Salary",
                        type: .income
                    )
                ]
            ),
            GroupedTransactions(
                date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
                transactions: [
                    Transaction(
                        amount: 30,
                        category: .transportation,
                        note: "Bus fare",
                        type: .expense
                    )
                ]
            )
        ]
        
        return viewModel
    }
}

#Preview {
    NavigationStack {
        List {
            ForEach(TransactionsViewModel.preview.groupedTransactions) { group in
                Section(header: Text(group.date.formatted(date: .abbreviated, time: .omitted))) {
                    ForEach(group.transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
            }
        }
        .navigationTitle("Transactions")
    }
} 