import SwiftUI

@MainActor
final class AddBudgetViewModel: ObservableObject {
    @Published var selectedCategory: Category = .food
    @Published var amount: Decimal = 0
    @Published var selectedPeriod: BudgetPeriod = .monthly
    
    private let repository: BudgetRepository
    
    var isValid: Bool {
        amount > 0
    }
    
    init(repository: BudgetRepository = BudgetRepository()) {
        self.repository = repository
    }
    
    func saveBudget() async {
        do {
            let budget = Budget(
                category: selectedCategory,
                amount: amount,
                period: selectedPeriod
            )
            try await repository.save(budget)
        } catch {
            print("Error saving budget: \(error)")
        }
    }
}

// MARK: - Preview Helper
extension AddBudgetViewModel {
    static var preview: AddBudgetViewModel {
        let viewModel = AddBudgetViewModel()
        viewModel.selectedCategory = .food
        viewModel.amount = 1000
        viewModel.selectedPeriod = .monthly
        return viewModel
    }
}

#Preview {
    AddBudgetView(viewModel: .preview)
} 