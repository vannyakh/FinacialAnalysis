import SwiftUI
import Charts

struct SpendingChartView: View {
    let data: [SpendingData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Spending")
                .font(.headline)
            
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Category", item.category.rawValue),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(by: .value("Category", item.category.rawValue))
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(preset: .aligned)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(radius: Theme.shadowRadius)
    }
}

struct SpendingData: Identifiable {
    let id = UUID()
    let category: Category
    let amount: Decimal
} 