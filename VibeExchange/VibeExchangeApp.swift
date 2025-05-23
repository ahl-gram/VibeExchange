import SwiftUI

@main
struct VibeExchangeApp: App {
    @StateObject private var currencyViewModel = CurrencyViewModel()
    @StateObject private var favoritesManager = FavoritesManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(currencyViewModel)
                .environmentObject(favoritesManager)
                .onAppear {
                    Task {
                        await currencyViewModel.fetchExchangeRates()
                    }
                }
        }
    }
} 