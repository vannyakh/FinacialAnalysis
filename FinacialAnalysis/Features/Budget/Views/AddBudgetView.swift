import SwiftUI

struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: AddBudgetViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
                
                Section("Amount") {
                    TextField("Amount", value: $viewModel.amount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                }
                
                Section("Period") {
                    Picker("Period", selection: $viewModel.selectedPeriod) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue.capitalized)
                                .tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.saveBudget()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
} 