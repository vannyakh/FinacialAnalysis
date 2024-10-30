import SwiftUI

@MainActor
final class AddTransactionViewModel: ObservableObject {
    @Published var amount: Decimal = 0
    @Published var selectedCategory: Category = .food
    @Published var selectedType: TransactionType = .expense
    @Published var note: String = ""
    @Published var date: Date = .now
    
    private let repository: TransactionRepository
    private let transaction: Transaction?
    
    var isEditing: Bool { transaction != nil }
    
    var isValid: Bool {
        amount > 0
    }
    
    init(
        transaction: Transaction? = nil,
        repository: TransactionRepository = TransactionRepository()
    ) {
        self.repository = repository
        self.transaction = transaction
        
        if let transaction = transaction {
            self.amount = transaction.amount
            self.selectedCategory = transaction.category
            self.selectedType = transaction.type
            self.note = transaction.note ?? ""
            self.date = transaction.date
        }
    }
    
    func saveTransaction() async throws {
        let transaction = Transaction(
            amount: amount,
            category: selectedCategory,
            date: date,
            note: note.isEmpty ? nil : note,
            type: selectedType
        )
        
        try await repository.save(transaction)
    }
    
    func updateTransaction() async throws {
        guard let existingTransaction = transaction else { return }
        
        existingTransaction.amount = amount
        existingTransaction.category = selectedCategory
        existingTransaction.date = date
        existingTransaction.note = note.isEmpty ? nil : note
        existingTransaction.type = selectedType
        
        try await repository.update(existingTransaction)
    }
}

// MARK: - Preview Helper
extension AddTransactionViewModel {
    static var preview: AddTransactionViewModel {
        let viewModel = AddTransactionViewModel()
        viewModel.amount = 50
        viewModel.selectedCategory = .food
        viewModel.selectedType = .expense
        viewModel.note = "Lunch"
        return viewModel
    }
} 