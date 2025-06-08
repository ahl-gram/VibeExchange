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
    @State private var showingCurrencyList = false
    @State private var showingConverter = false
    
    // State is now owned by the parent view
    @State private var fromCurrency: String = "USD"
    @State private var toCurrency: String = "EUR"
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                AppGradient.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    header
                    
                    // Main content
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Converter card now takes a closure for its action
                            ConverterCard(fromCurrency: $fromCurrency, toCurrency: $toCurrency) {
                                showingConverter = true
                            }
                            .padding(.horizontal, 20)

                            // Currency list card
                            CurrencyListCard()
                                .padding(.horizontal, 20)
                                .onTapGesture {
                                    showingCurrencyList = true
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
            // Pass the state down to the full converter view
            ConverterView(fromCurrency: $fromCurrency, toCurrency: $toCurrency)
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
    
    var displayCurrencies: [Currency] {
        // Simplified to just show the first 8 currencies from the view model
        return Array(viewModel.currencies.prefix(8))
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
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Converter Card
struct ConverterCard: View {
    @EnvironmentObject var viewModel: CurrencyViewModel
    @State private var amount: Double = 1.00
    @State private var amountString: String = "" // For direct text field binding
    @Binding var fromCurrency: String
    @Binding var toCurrency: String
    var onShowFullConverter: () -> Void
    
    private var convertedAmount: Double {
        return viewModel.convert(amount: amount, from: fromCurrency, to: toCurrency)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Quick Converter")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onShowFullConverter) {
                    HStack(spacing: 4) {
                        Text("Change currencies")
                            .font(.caption)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.15), in: Capsule())
                }
            }
            
            // Top input row
            HStack(spacing: 8) {
                if let currency = viewModel.getCurrency(by: fromCurrency) {
                    Text(currency.flag)
                        .font(.title)
                    Text(symbol(for: fromCurrency))
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                }

                TextField("Amount", text: $amountString)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                
                if let currency = viewModel.getCurrency(by: fromCurrency) {
                    Text(currency.code)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            // Controls row
            HStack {
                Button(action: {
                    amount = 1.00
                    updateAmountString() // Update the string when resetting
                    triggerHapticFeedback()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.body)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)

                Button(action: swapCurrencies) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 8)
            
            // Bottom display row
            HStack(spacing: 8) {
                if let toCurrencyData = viewModel.getCurrency(by: toCurrency) {
                    Text(toCurrencyData.flag)
                        .font(.title)
                    Text(symbol(for: toCurrency))
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    Text(numberFormatter(for: toCurrency).string(from: NSNumber(value: convertedAmount)) ?? "")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.3), value: convertedAmount)

                    Text(toCurrencyData.code)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .onAppear(perform: updateAmountString)
        .onChange(of: amountString) { _, newValue in
            validate(newValue: newValue)
        }
        .onChange(of: fromCurrency) { _, _ in
            updateAmountString()
        }
    }
    
    private func validate(newValue: String) {
        let formatter = numberFormatter(for: fromCurrency)
        let separator = formatter.decimalSeparator ?? "."
        
        // 1. Sanitize by removing invalid characters in a more direct way
        let sanitized = String(newValue.filter { "0123456789".contains($0) || String($0) == separator })

        // 2. Ensure only one decimal separator exists
        var finalSanitized = sanitized
        let separatorCount = finalSanitized.lazy.filter { String($0) == separator }.count
        if separatorCount > 1 {
            // If more than one, remove all but the first
            let components = finalSanitized.components(separatedBy: separator)
            // Use string interpolation for a more stable construction
            finalSanitized = "\(components[0])\(separator)\(Array(components.dropFirst()).joined())"
        }
        
        // 3. Limit to 2 decimal places
        if let decimalIndex = finalSanitized.firstIndex(of: Character(separator)) {
            let decimalPart = finalSanitized.suffix(from: finalSanitized.index(after: decimalIndex))
            if decimalPart.count > 2 {
                finalSanitized = String(finalSanitized.prefix(upTo: finalSanitized.index(after: decimalIndex)) + decimalPart.prefix(2))
            }
        }
        
        // 4. Update the source-of-truth Double, using a formatter that can parse the locale-specific string
        if let number = formatter.number(from: finalSanitized) {
            amount = number.doubleValue
        } else if finalSanitized.isEmpty {
            amount = 0
        } else if finalSanitized == separator {
            // Handle case where user just types the separator
            amount = 0
        }

        // 5. If sanitization changed the string, update the text field visually.
        // This must be dispatched to the next run loop to avoid issues with modifying state during a view update.
        if finalSanitized != newValue {
            DispatchQueue.main.async {
                self.amountString = finalSanitized
            }
        }
    }

    private func updateAmountString() {
        // Format the Double source-of-truth and display it
        amountString = numberFormatter(for: fromCurrency).string(from: NSNumber(value: amount)) ?? ""
    }
    
    private func numberFormatter(for currencyCode: String) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        // Use a more reliable method to find an appropriate locale for the currency.
        formatter.locale = locale(for: currencyCode)
        return formatter
    }

    private func symbol(for currencyCode: String) -> String {
        return locale(for: currencyCode).currencySymbol ?? ""
    }
    
    /// Finds a representative locale for a given currency code.
    private func locale(for currencyCode: String) -> Locale {
        // Create a locale identifier with the currency code.
        let components = [NSLocale.Key.currencyCode.rawValue: currencyCode]
        let identifier = NSLocale.localeIdentifier(fromComponents: components)
        
        // Find all available locales that use this currency.
        let availableLocales = Locale.availableIdentifiers.map { Locale(identifier: $0) }
        let currencyLocales = availableLocales.filter { $0.currency?.identifier == currencyCode }
        
        // A simple heuristic: prefer locales where the language code matches the country code prefix
        // (e.g., "de_DE" for Germany, "fr_FR" for France). This is often the primary locale for a region.
        // If none found, fall back to the first available locale for that currency, or a generic one.
        return currencyLocales.first { locale in
            guard let langCode = locale.language.languageCode?.identifier, let regionCode = locale.region?.identifier else { return false }
            return langCode.lowercased() == regionCode.lowercased()
        } ?? currencyLocales.first ?? Locale(identifier: identifier)
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

#Preview {
    ContentView()
        .environmentObject(CurrencyViewModel())
} 
