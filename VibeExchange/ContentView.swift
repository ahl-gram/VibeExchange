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
            
            // Currency List View
            CurrencyListView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Rates")
                }
                .tag(1)
            
            // Settings View (placeholder for future)
            ZStack {
                AppGradient.background
                    .ignoresSafeArea()
                
                Text("Settings")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(2)
            
            // About View
            AboutView()
                .tabItem {
                    Image(systemName: "info.circle.fill")
                    Text("About")
                }
                .tag(3)
        }
        .accentColor(.white)
        .onAppear {
            setupTabBarAppearance()
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
    static var background: some View {
        AdaptiveGradientView()
    }

    private struct AdaptiveGradientView: View {
        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark ?
                    [
                        Color(red: 0.4, green: 0.2, blue: 0.9),  // Purple
                        Color(red: 0.2, green: 0.4, blue: 1.0)   // Blue
                    ] :
                    [
                        Color(red: 0.8, green: 0.75, blue: 1.0), // Light Purple
                        Color(red: 0.75, green: 0.8, blue: 1.0)   // Light Blue
                    ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        ZStack {
            AppGradient.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Vibe Exchange")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if let version = Bundle.main.version, let build = Bundle.main.build {
                    Text("Version \(version) (Build \(build))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.top, 40)
        }
    }
}

// MARK: - Bundle Helper
extension Bundle {
    var version: String? {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    var build: String? {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}

#Preview {
    ContentView()
        .environmentObject(CurrencyViewModel())
} 
