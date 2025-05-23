import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: CurrencyViewModel
    @EnvironmentObject var favoritesManager: FavoritesManager
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
            Text("Coming Soon")
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppGradient.background)
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag(1)
            
            // Settings View (placeholder for future)
            Text("Settings")
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppGradient.background)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.white)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
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

struct CurrencyExchangeView: View {
    @EnvironmentObject var viewModel: CurrencyViewModel
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showingCurrencyList = false
    @State private var showingConverter = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                AppGradient.background
                    .ignoresSafeArea()
                
                // Confetti overlay
                if favoritesManager.showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
                
                VStack(spacing: 0) {
                    // Header
                    header
                    
                    // Main content
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Currency list card
                            CurrencyListCard()
                                .padding(.horizontal, 20)
                                .onTapGesture {
                                    showingCurrencyList = true
                                }
                            
                            // Converter card
                            ConverterCard()
                                .padding(.horizontal, 20)
                                .onTapGesture {
                                    showingConverter = true
                                }
                            
                            // Bottom spacing for tab bar
                            Color.clear.frame(height: 100)
                        }
                        .padding(.top, 20)
                    }
                    .refreshable {
                        await viewModel.refreshRates()
                    }
                }
            }
        }
        .alert(item: $viewModel.errorMessage) { error in
            Alert(
                title: Text(error.title),
                message: Text(error.message),
                dismissButton: .default(Text("OK")) {
                    viewModel.dismissError()
                }
            )
        }
        .sheet(isPresented: $showingCurrencyList) {
            CurrencyListView()
        }
        .sheet(isPresented: $showingConverter) {
            ConverterView()
        }
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Vibe Exchange")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.refreshRates()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.white)
                        .opacity(viewModel.isLoading ? 0.5 : 1.0)
                        .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                        .animation(
                            viewModel.isLoading ? 
                            .linear(duration: 1.0).repeatForever(autoreverses: false) : 
                            .default,
                            value: viewModel.isLoading
                        )
                }
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            if !viewModel.lastUpdatedString.isEmpty {
                HStack {
                    Text("Last updated: \(viewModel.lastUpdatedString)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Currency List Card
struct CurrencyListCard: View {
    @EnvironmentObject var viewModel: CurrencyViewModel
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var displayCurrencies: [Currency] {
        let sortedCurrencies = favoritesManager.sortCurrencies(viewModel.currencies)
        return Array(sortedCurrencies.prefix(8)) // Show top 8 currencies
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with tap hint
            HStack {
                Text("Exchange Rates")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Tap to see all")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ForEach(displayCurrencies) { currency in
                CurrencyRowView(currency: currency)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.bottom, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Currency Row View
struct CurrencyRowView: View {
    let currency: Currency
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Flag and currency code
            HStack(spacing: 8) {
                Text(currency.flag)
                    .font(.title2)
                
                Text(currency.code)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Exchange rate
            Text(currency.formattedRate)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            // Favorite button
            Button(action: {
                favoritesManager.toggleFavorite(currency.code)
            }) {
                Image(systemName: favoritesManager.isFavorite(currency.code) ? "star.fill" : "star")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Converter Card
struct ConverterCard: View {
    @EnvironmentObject var viewModel: CurrencyViewModel
    @State private var amount: String = "1.00"
    @State private var fromCurrency: String = "USD"
    @State private var toCurrency: String = "EUR"
    
    private var convertedAmount: Double {
        let inputAmount = Double(amount) ?? 0
        return viewModel.convert(amount: inputAmount, from: fromCurrency, to: toCurrency)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with tap hint
            HStack {
                Text("Quick Converter")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Tap for full converter")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Amount input
            HStack {
                Text("$")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(amount)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: swapCurrencies) {
                    Image(systemName: "arrow.right")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Converted amount display
            HStack {
                if let fromCurrencyData = viewModel.getCurrency(by: fromCurrency),
                   let toCurrencyData = viewModel.getCurrency(by: toCurrency) {
                    Text("\(fromCurrencyData.flag) \(String(format: "%.2f", convertedAmount)) \(toCurrencyData.code)")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.3), value: convertedAmount)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            
            // Control buttons
            HStack(spacing: 20) {
                Button(action: {
                    // Update amount
                    let newAmount = (Double(amount) ?? 1.0) * 10
                    amount = String(format: "%.0f", newAmount)
                    triggerHapticFeedback()
                }) {
                    Image(systemName: "arrow.2.circlepath")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.ultraThinMaterial))
                }
                
                Button(action: {
                    // Reset to 1
                    amount = "1.00"
                    triggerHapticFeedback()
                }) {
                    Image(systemName: "camera.viewfinder")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.ultraThinMaterial))
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
        
        triggerHapticFeedback()
    }
    
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
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

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { _ in
                ConfettiPiece()
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    @State private var position = CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                         y: -20)
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0
    
    private let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    private let color = Color.random(from: [.red, .blue, .green, .yellow, .orange, .purple, .pink])
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 6, height: 6)
            .position(position)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.easeOut(duration: 3.0)) {
                    position.y = UIScreen.main.bounds.height + 20
                    opacity = 0
                    rotation = 360
                }
            }
    }
}

extension Color {
    static func random(from colors: [Color]) -> Color {
        return colors.randomElement() ?? .white
    }
}

#Preview {
    ContentView()
        .environmentObject(CurrencyViewModel())
        .environmentObject(FavoritesManager())
} 