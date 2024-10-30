import SwiftUI

struct SpendingOverviewCard: View {
    let totalSpent: Decimal
    let monthlyChange: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Total Spending")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(totalSpent.formatted(.currency(code: "USD")))
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: monthlyChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text("\(abs(monthlyChange), specifier: "%.1f")%")
                Text("vs last month")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            .foregroundColor(monthlyChange >= 0 ? .red : .green)
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(radius: Theme.shadowRadius)
    }
}

#Preview {
    VStack {
        SpendingOverviewCard(totalSpent: 1234.56, monthlyChange: 12.5)
        SpendingOverviewCard(totalSpent: 987.65, monthlyChange: -8.3)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 