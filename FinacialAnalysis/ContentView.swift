//
//  ContentView.swift
//  FinacialAnalysis
//
//  Created by Soriya Van on 30/10/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
            
            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "creditcard.fill")
                }
            
            BudgetView()
                .tabItem {
                    Label("Budget", systemImage: "chart.pie.fill")
                }
            
            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
        .tint(.accentColor)
    }
}

#Preview {
    ContentView()
}
