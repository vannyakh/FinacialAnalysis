import SwiftUI

struct BudgetCategoryRow: View {
    let category: Category
    let spent: Decimal
    let limit: Decimal
    let onTap: () -> Void
    
    private var progress: Double {
        Double(truncating: NSDecimalNumber(decimal: spent).dividing(by: NSDecimalNumber(decimal: limit)))
        
    }
    
    private var progressColor: Color {
        switch progress {
        case ..<0.5: return .green
        case 0.5..<0.8: return .yellow
        case 0.8..<1.0: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: category.icon)
                        .foregroundColor(progressColor)
                        .frame(width: 24, height: 24)
                    
                    Text(category.rawValue)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(spent.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: min(progress, 1.0))
                    .tint(progressColor)
                
                HStack {
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("of \(limit.formatted(.currency(code: "USD")))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(radius: Theme.shadowRadius)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        BudgetCategoryRow(
            category: .food,
            spent: 750,
            limit: 1000,
            onTap: {}
        )
        BudgetCategoryRow(
            category: .entertainment,
            spent: 200,
            limit: 150,
            onTap: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 
