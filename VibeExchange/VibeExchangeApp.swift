import SwiftUI

@main
struct VibeExchangeApp: App {
    @StateObject private var viewModel = CurrencyViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    Task {
                        await viewModel.fetchExchangeRates()
                    }
                }
        }
    }
} 