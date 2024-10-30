import SwiftUI
import Charts

struct CategoryBreakdownChart: View {
    let data: [CategorySpending]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)
            
            Chart {
                ForEach(data) { category in
                    SectorMark(
                        angle: .value("Spending", category.amount),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Category", category.name))
                }
            }
            .frame(height: 200)
            
            // Legend
            VStack(spacing: 8) {
                ForEach(data) { category in
                    HStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 8, height: 8)
                        Text(category.name)
                            .font(.caption)
                        Spacer()
                        Text(category.amount.formatted(.currency(code: "USD")))
                            .font(.caption)
                        Text("(\(Int(category.percentage * 100))%)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(radius: Theme.shadowRadius)
    }
}

struct CategorySpending: Identifiable {
    let id = UUID()
    let name: String
    let amount: Decimal
    let percentage: Double
    let color: Color
} 