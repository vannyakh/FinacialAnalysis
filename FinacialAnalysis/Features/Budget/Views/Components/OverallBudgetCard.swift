import SwiftUI

struct OverallBudgetCard: View {
    let spent: Decimal
    let budget: Decimal
    
    private var progress: Double {
        Double(spent / budget)
    }
    
    private var remainingAmount: Decimal {
        budget - spent
    }
    
    private var progressColor: Color {
        switch progress {
        case ..<0.5:
            return .green
        case 0.5..<0.8:
            return .yellow
        case 0.8..<1.0:
            return .orange
        default:
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Monthly Overview")
                    .font(.headline)
                Spacer()
                Menu {
                    Button("Set Budget") { }
                    Button("View History") { }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 8) {
                ProgressView(value: min(progress, 1.0))
                    .tint(progressColor)
                    .scaleEffect(y: 2)
                
                HStack {
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(spent.formatted(.currency(code: "USD"))) of \(budget.formatted(.currency(code: "USD")))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Spent")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(spent.formatted(.currency(code: "USD")))
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Remaining")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(remainingAmount.formatted(.currency(code: "USD")))
                        .font(.headline)
                        .foregroundColor(remainingAmount >= 0 ? .green : .red)
                }
            }
            
            if remainingAmount < 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Over budget by \(abs(remainingAmount).formatted(.currency(code: "USD")))")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .shadow(radius: Theme.shadowRadius)
    }
}

#Preview {
    VStack {
        OverallBudgetCard(spent: 800, budget: 1000)
        OverallBudgetCard(spent: 1200, budget: 1000)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 