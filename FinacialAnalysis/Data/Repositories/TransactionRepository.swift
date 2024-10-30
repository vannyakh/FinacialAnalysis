import Foundation
import SwiftData

class TransactionRepository {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Transaction.self)
            modelContext = ModelContainer.shared.mainContext
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    // MARK: - CRUD Operations
    
    func fetchTransactions(
        for period: TimePeriod = .month,
        category: Category? = nil
    ) async throws -> [Transaction] {
        var predicates: [Predicate<Transaction>] = []
        
        // Date predicate based on period
        let startDate = Calendar.current.date(byAdding: period.dateComponent, to: .now) ?? .now
        predicates.append(#Predicate<Transaction> { transaction in
            transaction.date >= startDate
        })
        
        // Category predicate if specified
        if let category {
            predicates.append(#Predicate<Transaction> { transaction in
                transaction.category == category
            })
        }
        
        let descriptor = FetchDescriptor<Transaction>(
            predicate: Predicate<Transaction>.init(format: predicates),
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func fetchRecentTransactions(limit: Int = 10) async throws -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)],
            fetchLimit: limit
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func save(_ transaction: Transaction) async throws {
        modelContext.insert(transaction)
        try modelContext.save()
    }
    
    func update(_ transaction: Transaction) async throws {
        try modelContext.save()
    }
    
    func delete(_ transaction: Transaction) async throws {
        modelContext.delete(transaction)
        try modelContext.save()
    }
    
    // MARK: - Analysis Methods
    
    func getTransactionSummary(for period: TimePeriod = .month) async throws -> TransactionSummary {
        let transactions = try await fetchTransactions(for: period)
        
        let income = transactions
            .filter { $0.type == .income }
            .reduce(Decimal(0)) { $0 + $1.amount }
        
        let expenses = transactions
            .filter { $0.type == .expense }
            .reduce(Decimal(0)) { $0 + $1.amount }
        
        return TransactionSummary(
            income: income,
            expenses: expenses,
            netAmount: income - expenses,
            period: period
        )
    }
    
    func getCategoryBreakdown(for period: TimePeriod = .month) async throws -> [CategorySummary] {
        let transactions = try await fetchTransactions(for: period)
        let expenseTransactions = transactions.filter { $0.type == .expense }
        
        let totalExpenses = expenseTransactions.reduce(Decimal(0)) { $0 + $1.amount }
        var categoryTotals: [Category: Decimal] = [:]
        
        // Calculate totals for each category
        for transaction in expenseTransactions {
            categoryTotals[transaction.category, default: 0] += transaction.amount
        }
        
        // Convert to CategorySummary objects
        return categoryTotals.map { category, amount in
            CategorySummary(
                category: category,
                amount: amount,
                percentage: Double(amount / totalExpenses)
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    func getDailyTransactions(for period: TimePeriod = .month) async throws -> [DailyTransactions] {
        let transactions = try await fetchTransactions(for: period)
        let groupedTransactions = Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        
        return groupedTransactions.map { date, transactions in
            DailyTransactions(
                date: date,
                transactions: transactions.sorted { $0.date > $1.date }
            )
        }.sorted { $0.date > $1.date }
    }
}

// MARK: - Supporting Types

struct TransactionSummary {
    let income: Decimal
    let expenses: Decimal
    let netAmount: Decimal
    let period: TimePeriod
    
    var isProfit: Bool {
        netAmount >= 0
    }
}

struct CategorySummary {
    let category: Category
    let amount: Decimal
    let percentage: Double
}

struct DailyTransactions: Identifiable {
    let id = UUID()
    let date: Date
    let transactions: [Transaction]
    
    var totalAmount: Decimal {
        transactions.reduce(Decimal(0)) { total, transaction in
            switch transaction.type {
            case .income: return total + transaction.amount
            case .expense: return total - transaction.amount
            }
        }
    }
}

// MARK: - Helper Extensions

extension TimePeriod {
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

// MARK: - Preview Helpers

extension TransactionRepository {
    static var preview: TransactionRepository {
        let repository = TransactionRepository()
        
        // Add sample transactions
        Task {
            try? await repository.save(Transaction(
                amount: 1000,
                category: .food,
                date: .now.addingTimeInterval(-86400),
                note: "Grocery shopping",
                type: .expense
            ))
            
            try? await repository.save(Transaction(
                amount: 5000,
                category: .other,
                date: .now,
                note: "Salary",
                type: .income
            ))
        }
        
        return repository
    }
} 