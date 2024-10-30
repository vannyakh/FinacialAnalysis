import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: AddTransactionViewModel
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                amountSection
                typeSection
                categorySection
                detailsSection
            }
            .navigationTitle(viewModel.isEditing ? "Edit Transaction" : "New Transaction")
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
                            await saveTransaction()
                        }
                    }
                    .bold()
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var amountSection: some View {
        Section {
            HStack {
                Text("$")
                TextField("Amount", value: $viewModel.amount, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
    private var typeSection: some View {
        Section {
            Picker("Type", selection: $viewModel.selectedType) {
                Text("Income")
                    .tag(TransactionType.income)
                Text("Expense")
                    .tag(TransactionType.expense)
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var categorySection: some View {
        Section {
            Picker("Category", selection: $viewModel.selectedCategory) {
                ForEach(Category.allCases, id: \.self) { category in
                    Label(category.rawValue, systemImage: category.icon)
                        .tag(category)
                }
            }
        }
    }
    
    private var detailsSection: some View {
        Section {
            DatePicker(
                "Date",
                selection: $viewModel.date,
                displayedComponents: [.date, .hourAndMinute]
            )
            
            TextField("Note", text: $viewModel.note, axis: .vertical)
                .lineLimit(1...3)
        }
    }
    
    private func saveTransaction() async {
        do {
            if viewModel.isEditing {
                try await viewModel.updateTransaction()
            } else {
                try await viewModel.saveTransaction()
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

#Preview {
    AddTransactionView(viewModel: .preview)
} 