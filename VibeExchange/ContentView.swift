import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: CurrencyViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Currency Exchange View
            CurrencyExchangeView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Exchange")
                }
                .tag(0)
            
            // Favorites/History View (placeholder for future)
            CurrencyListView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Rates")
                }
                .tag(1)
            
            // Settings View (placeholder for future)
            Text("Settings")
                .font(.title2)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppGradient.background)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(2)
        }
    }
}

// MARK: - Currency Row View
struct CurrencyRowView: View {
    let currency: Currency
    
    var body: some View {
        HStack(spacing: 12) {
            // Flag and currency code
            HStack(spacing: 8) {
                Text(currency.flag)
                    .font(.title2)
                
                Text(currency.code)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Exchange rate
            Text(currency.formattedRate)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - App Gradient
struct AppGradient {
    static let background = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.4, green: 0.2, blue: 0.9),  // Purple
            Color(red: 0.2, green: 0.4, blue: 1.0)   // Blue
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

#Preview {
    ContentView()
        .environmentObject(CurrencyViewModel())
} 
