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
    
    // State is now owned by the parent view
    @State private var fromCurrency: String = "USD"
    @State private var toCurrency: String = "EUR"
    @State private var amount: Double = 1.00
    @State private var amountString: String = "1.00"
    @State private var shouldClearOnNextInput: Bool = true

    private var decimalSeparator: String {
        return "."
    }
    
    var body: some View {
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
                        ConverterCard(amount: $amount, amountString: $amountString, fromCurrency: $fromCurrency, toCurrency: $toCurrency, shouldClearOnNextInput: $shouldClearOnNextInput)
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                }
                .refreshable {
                    await viewModel.refreshRates()
                }
                
                CustomKeyboardView(text: $amountString, decimalSeparator: decimalSeparator, shouldClearOnNextInput: $shouldClearOnNextInput)
            }
        }
        .onAppear {
            // Initialize amount string when the view appears
            self.amountString = numberFormatter().string(from: NSNumber(value: amount)) ?? ""
        }
        .onChange(of: amountString) { _, newValue in
            validate(newValue: newValue)
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

    private func validate(newValue: String) {
        let separator = "."
        
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
        if let number = numberFormatter().number(from: finalSanitized) {
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
                self.amountString = self.formatForDisplay(finalSanitized)
            }
        } else {
            let formattedString = formatForDisplay(newValue)
            if formattedString != newValue {
                DispatchQueue.main.async {
                    self.amountString = formattedString
                }
            }
        }
    }
    
    private func formatForDisplay(_ string: String) -> String {
        let separator = "."
        var numberPart = string
        var fractionPart = ""

        if let range = string.range(of: separator) {
            numberPart = String(string[..<range.lowerBound])
            fractionPart = String(string[range.lowerBound...])
        }
        
        numberPart = numberPart.replacingOccurrences(of: ",", with: "")
        
        guard let number = inputFormatter().number(from: numberPart),
              let formattedNumberPart = inputFormatter().string(from: number) else {
            if numberPart.isEmpty {
                return fractionPart
            }
            return string
        }

        return formattedNumberPart + fractionPart
    }
    
    private func inputFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US")
        formatter.usesGroupingSeparator = true
        return formatter
    }
    
    private func outputFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US")
        formatter.usesGroupingSeparator = true
        return formatter
    }
    
    private func numberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US")
        return formatter
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
    @Binding var amount: Double
    @Binding var amountString: String
    @Binding var fromCurrency: String
    @Binding var toCurrency: String
    @Binding var shouldClearOnNextInput: Bool

    private var convertedAmount: Double {
        return viewModel.convert(amount: amount, from: fromCurrency, to: toCurrency)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Top input row
            HStack(spacing: 8) {
                CurrencyPickerMenu(selectedCurrency: $fromCurrency)

                Text(amountString)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 4) // Add some padding to align with TextField

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
                    shouldClearOnNextInput = true
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
                CurrencyPickerMenu(selectedCurrency: $toCurrency)

                Spacer()

                Text(outputFormatter().string(from: NSNumber(value: convertedAmount)) ?? "")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .animation(.easeInOut(duration: 0.3), value: convertedAmount)

                if let toCurrencyData = viewModel.getCurrency(by: toCurrency) {
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
    }
    
    private func updateAmountString() {
        // Format the Double source-of-truth and display it
        amountString = outputFormatter().string(from: NSNumber(value: amount)) ?? ""
    }
    
    private func outputFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US")
        formatter.usesGroupingSeparator = true
        return formatter
    }

    private func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
        updateAmountString()
        shouldClearOnNextInput = true
        
        triggerHapticFeedback()
    }
    
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Currency Picker Menu
struct CurrencyPickerMenu: View {
    @EnvironmentObject var viewModel: CurrencyViewModel
    @Binding var selectedCurrency: String
    
    var body: some View {
        Menu {
            Picker("Currency", selection: $selectedCurrency) {
                ForEach(viewModel.currencies) { currency in
                    Text("\(currency.flag) \(currency.name)")
                        .tag(currency.code)
                }
            }
        } label: {
            HStack {
                if let currency = viewModel.getCurrency(by: selectedCurrency) {
                    Text(currency.flag)
                        .font(.title)
                    Text(currency.code)
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
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
