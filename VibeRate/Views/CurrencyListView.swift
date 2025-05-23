import SwiftUI

struct CurrencyListView: View {
    @EnvironmentObject var viewModel: CurrencyViewModel
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showingSearchResults = false
    
    var filteredCurrencies: [Currency] {
        let currencies = searchText.isEmpty ? viewModel.currencies : viewModel.filteredCurrencies
        return favoritesManager.sortCurrencies(currencies)
    }
    
    var favoriteCurrencies: [Currency] {
        return favoritesManager.getFavoriteCurrencies(from: filteredCurrencies)
    }
    
    var nonFavoriteCurrencies: [Currency] {
        return favoritesManager.getNonFavoriteCurrencies(from: filteredCurrencies)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppGradient.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    SearchBar(text: $searchText, isSearching: $showingSearchResults)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    // Currency list
                    if viewModel.isLoading {
                        LoadingView()
                    } else {
                        currencyList
                    }
                }
            }
            .navigationTitle("Currencies")
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
                    Button(action: {
                        Task {
                            await viewModel.refreshRates()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
    
    private var currencyList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Favorites section
                if !favoriteCurrencies.isEmpty && searchText.isEmpty {
                    favoritesSection
                }
                
                // All currencies section
                allCurrenciesSection
                
                // Bottom padding
                Color.clear.frame(height: 50)
            }
        }
        .refreshable {
            await viewModel.refreshRates()
        }
    }
    
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Favorites")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(favoriteCurrencies.count)/5")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            VStack(spacing: 8) {
                ForEach(favoriteCurrencies) { currency in
                    CurrencyListRow(currency: currency)
                }
            }
            .padding(.horizontal, 16)
            
            Divider()
                .background(.white.opacity(0.3))
                .padding(.horizontal, 20)
                .padding(.top, 8)
        }
    }
    
    private var allCurrenciesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(searchText.isEmpty ? "All Currencies" : "Search Results")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if !searchText.isEmpty {
                    Text("\(filteredCurrencies.count) found")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, searchText.isEmpty ? 16 : 8)
            
            VStack(spacing: 8) {
                ForEach(searchText.isEmpty ? nonFavoriteCurrencies : filteredCurrencies) { currency in
                    CurrencyListRow(currency: currency)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Currency List Row
struct CurrencyListRow: View {
    let currency: Currency
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Flag and currency info
            HStack(spacing: 12) {
                Text(currency.flag)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.code)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(currency.name)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // Exchange rate
            VStack(alignment: .trailing, spacing: 2) {
                Text(currency.formattedRate)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("to USD")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Favorite button
            Button(action: {
                favoritesManager.toggleFavorite(currency.code)
            }) {
                Image(systemName: favoritesManager.isFavorite(currency.code) ? "star.fill" : "star")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!favoritesManager.canAddMoreFavorites() && !favoritesManager.isFavorite(currency.code))
            .opacity((!favoritesManager.canAddMoreFavorites() && !favoritesManager.isFavorite(currency.code)) ? 0.5 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                
                TextField("Search currencies...", text: $text)
                    .foregroundColor(.white)
                    .focused($isTextFieldFocused)
                    .onTapGesture {
                        isSearching = true
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
            )
            
            if isSearching {
                Button("Cancel") {
                    text = ""
                    isSearching = false
                    isTextFieldFocused = false
                }
                .foregroundColor(.white)
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isSearching)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Loading currencies...")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CurrencyListView()
        .environmentObject(CurrencyViewModel())
        .environmentObject(FavoritesManager())
} 