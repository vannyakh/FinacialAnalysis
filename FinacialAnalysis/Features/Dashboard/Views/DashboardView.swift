import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    BalanceCardView(
                        balance: viewModel.totalBalance,
                        income: viewModel.monthlyIncome,
                        expenses: viewModel.monthlyExpenses
                    )
                    .padding(.horizontal)
                    
                    RecentTransactionsView(
                        transactions: viewModel.recentTransactions,
                        onTransactionTap: { transaction in
                            // Handle transaction selection
                        }
                    )
                    .padding(.horizontal)
                    
                    SpendingChartView(data: viewModel.monthlySpendingData)
                        .frame(height: 300)
                        .padding()
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refreshData()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
}

#Preview {
    DashboardView()
} 