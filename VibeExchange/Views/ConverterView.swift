import SwiftUI

struct ConverterView: View {
    @EnvironmentObject var viewModel: CurrencyViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var fromAmount: String = "1.00"
    @Binding var fromCurrency: String
    @Binding var toCurrency: String
    @State private var showingFromCurrencyPicker = false
    @State private var showingToCurrencyPicker = false
    @FocusState private var amountFieldFocused: Bool
    
    private var convertedAmount: Double {
        let inputAmount = Double(fromAmount) ?? 0
        return viewModel.convert(amount: inputAmount, from: fromCurrency, to: toCurrency)
    }
    
    private var fromCurrencyData: Currency? {
        return viewModel.getCurrency(by: fromCurrency)
    }
    
    private var toCurrencyData: Currency? {
        return viewModel.getCurrency(by: toCurrency)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppGradient.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // From Currency Card
                        fromCurrencyCard
                        
                        // Swap Button
                        swapButton
                        
                        // To Currency Card
                        toCurrencyCard
                        
                        // Exchange Rate Info
                        exchangeRateInfo
                        
                        // Quick Amount Buttons
                        quickAmountButtons
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .dismissKeyboardOnTap()
            }
            .navigationTitle("Currency Converter")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        fromAmount = "0"
                        amountFieldFocused = true
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingFromCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $fromCurrency, title: "From Currency")
        }
        .sheet(isPresented: $showingToCurrencyPicker) {
            CurrencyPickerView(selectedCurrency: $toCurrency, title: "To Currency")
        }
    }
    
    // MARK: - From Currency Card
    private var fromCurrencyCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("From")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
            
            // Currency selector
            Button(action: {
                showingFromCurrencyPicker = true
            }) {
                HStack(spacing: 12) {
                    if let currency = fromCurrencyData {
                        Text(currency.flag)
                            .font(.title)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currency.code)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text(currency.name)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Amount input
            HStack {
                TextField("Amount", text: $fromAmount)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .keyboardType(.decimalPad)
                    .focused($amountFieldFocused)
                    .onChange(of: fromAmount) { _, newValue in
                        formatAmountInput(newValue)
                    }
                
                Spacer()
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Swap Button
    private var swapButton: some View {
        Button(action: swapCurrencies) {
            Image(systemName: "arrow.up.arrow.down")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: convertedAmount)
    }
    
    // MARK: - To Currency Card
    private var toCurrencyCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("To")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
            
            // Currency selector
            Button(action: {
                showingToCurrencyPicker = true
            }) {
                HStack(spacing: 12) {
                    if let currency = toCurrencyData {
                        Text(currency.flag)
                            .font(.title)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currency.code)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text(currency.name)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Converted amount display
            HStack {
                Text(String(format: "%.2f", convertedAmount))
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .animation(.easeInOut(duration: 0.3), value: convertedAmount)
                
                Spacer()
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Exchange Rate Info
    private var exchangeRateInfo: some View {
        VStack(spacing: 8) {
            if let fromCurrencyData = fromCurrencyData,
               let toCurrencyData = toCurrencyData {
                
                let rate = viewModel.convert(amount: 1.0, from: fromCurrency, to: toCurrency)
                
                Text("1 \(fromCurrencyData.code) = \(String(format: "%.4f", rate)) \(toCurrencyData.code)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Last updated: \(viewModel.lastUpdatedString)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Quick Amount Buttons
    private var quickAmountButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Amounts")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(quickAmounts, id: \.self) { amount in
                    Button(action: {
                        fromAmount = amount
                        triggerHapticFeedback()
                    }) {
                        Text(amount)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private let quickAmounts = ["1", "10", "100", "1000", "5", "50", "500", "5000"]
    
    // MARK: - Helper Methods
    
    private func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
        
        triggerHapticFeedback()
    }
    
    private func formatAmountInput(_ input: String) {
        // Remove any non-numeric characters except decimal point
        let filtered = input.filter { $0.isNumber || $0 == "." }
        
        // Ensure only one decimal point
        let components = filtered.components(separatedBy: ".")
        if components.count > 2 {
            fromAmount = components[0] + "." + components[1]
        } else {
            fromAmount = filtered
        }
    }
    
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Currency Picker View
struct CurrencyPickerView: View {
    @EnvironmentObject var viewModel: CurrencyViewModel
    @Binding var selectedCurrency: String
    @Environment(\.dismiss) private var dismiss
    let title: String
    @State private var searchText = ""

    private var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return viewModel.currencies
        } else {
            return viewModel.currencies.filter {
                $0.code.localizedCaseInsensitiveContains(searchText) ||
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppGradient.background
                    .ignoresSafeArea()

                VStack {
                    SearchBar(searchText: $searchText)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    List(filteredCurrencies) { currency in
                        Button(action: {
                            selectedCurrency = currency.code
                            dismiss()
                        }) {
                            HStack {
                                Text(currency.flag)
                                    .font(.largeTitle)
                                VStack(alignment: .leading) {
                                    Text(currency.code)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(currency.name)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Dismiss Keyboard Extension
extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    ConverterView(fromCurrency: .constant("USD"), toCurrency: .constant("EUR"))
        .environmentObject(CurrencyViewModel())
} 