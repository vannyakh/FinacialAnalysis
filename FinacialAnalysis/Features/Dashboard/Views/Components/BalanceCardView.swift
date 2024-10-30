import SwiftUI

struct BalanceCardView: View {
    let balance: Decimal
    let income: Decimal
    let expenses: Decimal
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(balance.formatted(.currency(code: "USD")))
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
            
            HStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text("Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(income.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                Divider()
                
                VStack(alignment: .trailing) {
                    Text("Expenses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(expenses.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(radius: Theme.shadowRadius)
    }
} 