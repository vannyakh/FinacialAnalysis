import SwiftUI

struct TopSpendingList: View {
    let categories: [CategorySpending]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Spending Categories")
                .font(.headline)
            
            ForEach(categories.prefix(5)) { category in
                HStack {
                    Circle()
                        .fill(category.color)
                        .frame(width: 8, height: 8)
                    
                    Text(category.name)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(category.amount.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                if category.id != categories.prefix(5).last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(radius: Theme.shadowRadius)
    }
}

#Preview {
    TopSpendingList(categories: [
        CategorySpending(name: "Food", amount: 500, percentage: 0.3, color: .blue),
        CategorySpending(name: "Transport", amount: 300, percentage: 0.2, color: .green),
        CategorySpending(name: "Entertainment", amount: 200, percentage: 0.15, color: .orange)
    ])
    .padding()
    .background(Color(.systemGroupedBackground))
} 