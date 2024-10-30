import SwiftUI
import Charts

struct MonthlyTrendChart: View {
    let data: [MonthlySpending]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Trend")
                .font(.headline)
            
            Chart {
                ForEach(data) { spending in
                    LineMark(
                        x: .value("Month", spending.date),
                        y: .value("Amount", spending.amount)
                    )
                    .foregroundStyle(Theme.accentColor)
                    
                    AreaMark(
                        x: .value("Month", spending.date),
                        y: .value("Amount", spending.amount)
                    )
                    .foregroundStyle(Theme.accentColor.opacity(0.1))
                    
                    PointMark(
                        x: .value("Month", spending.date),
                        y: .value("Amount", spending.amount)
                    )
                    .foregroundStyle(Theme.accentColor)
                }
            }
            .chartXAxis {
                AxisMarks(preset: .month)
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

struct MonthlySpending: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Decimal
} 