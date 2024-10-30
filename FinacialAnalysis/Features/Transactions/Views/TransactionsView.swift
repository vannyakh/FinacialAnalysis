import SwiftUI

struct TransactionsView: View {
    @StateObject private var viewModel = TransactionsViewModel()
    @State private var showingAddTransaction = false
    @State private var selectedTransaction: Transaction?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.groupedTransactions) { group in
                    Section(header: TransactionDateHeader(date: group.date)) {
                        ForEach(group.transactions) { transaction in
                            TransactionRowView(transaction: transaction)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTransaction = transaction
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.deleteTransaction(transaction)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        selectedTransaction = transaction
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Filter", selection: $viewModel.selectedFilter) {
                            ForEach(TransactionFilter.allCases) { filter in
                                Text(filter.title)
                                    .tag(filter)
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search transactions"
            )
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(viewModel: AddTransactionViewModel())
            }
            .sheet(item: $selectedTransaction) { transaction in
                AddTransactionView(
                    viewModel: AddTransactionViewModel(transaction: transaction)
                )
            }
        }
    }
}

struct TransactionDateHeader: View {
    let date: Date
    
    var body: some View {
        Text(date.formatted(date: .abbreviated, time: .omitted))
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .textCase(nil)
    }
}

#Preview {
    TransactionsView()
} 