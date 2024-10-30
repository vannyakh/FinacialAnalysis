import SwiftUI

struct AnalysisView: View {
    @StateObject private var viewModel = AnalysisViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacing) {
                    SpendingOverviewCard(
                        totalSpent: viewModel.totalSpent,
                        monthlyChange: viewModel.monthlyChangePercentage
                    )
                    .padding(.horizontal)
                    
                    CategoryBreakdownChart(data: viewModel.categoryBreakdown)
                        .frame(height: 300)
                        .padding()
                    
                    MonthlyTrendChart(data: viewModel.monthlyTrend)
                        .frame(height: 250)
                        .padding()
                    
                    TopSpendingList(categories: viewModel.topSpendingCategories)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Analysis")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Time Period", selection: $viewModel.selectedTimePeriod) {
                            ForEach(TimePeriod.allCases) { period in
                                Text(period.displayName)
                                    .tag(period)
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
} 