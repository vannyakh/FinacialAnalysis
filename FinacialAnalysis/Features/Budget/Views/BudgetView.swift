import SwiftUI

struct BudgetView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @State private var showingAddBudget = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Theme.spacing) {
                    OverallBudgetCard(
                        spent: viewModel.totalSpent,
                        budget: viewModel.totalBudget
                    )
                    .padding(.horizontal)
                    
                    ForEach(viewModel.categoryBudgets) { budget in
                        BudgetCategoryRow(
                            category: budget.category,
                            spent: budget.spent,
                            limit: budget.limit,
                            onTap: { viewModel.selectCategory(budget.category) }
                        )
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddBudget = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView(viewModel: AddBudgetViewModel())
            }
        }
    }
} 