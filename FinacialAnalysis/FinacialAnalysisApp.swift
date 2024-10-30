//
//  FinacialAnalysisApp.swift
//  FinacialAnalysis
//
//  Created by Soriya Van on 30/10/24.
//

import SwiftUI
import SwiftData

@main
struct FinacialAnalysisApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .modelContainer(for: [Transaction.self, Budget.self])
    }
}
