import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: transaction.category.icon)
                .font(.title2)
                .foregroundColor(transaction.type == .income ? .green : .primary)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.rawValue)
                    .font(.headline)
                
                if let note = transaction.note {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(transaction.amount.formatted(.currency(code: "USD")))
                .font(.headline)
                .foregroundColor(transaction.type == .income ? .green : .primary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        TransactionRowView(
            transaction: Transaction(
                amount: 50.0,
                category: .food,
                note: "Lunch",
                type: .expense
            )
        )
        
        TransactionRowView(
            transaction: Transaction(
                amount: 1000.0,
                category: .other,
                note: "Salary",
                type: .income
            )
        )
    }
} 