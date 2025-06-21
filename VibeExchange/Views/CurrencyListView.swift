import SwiftUI

struct CurrencyListView: View {
    @EnvironmentObject var viewModel: CurrencyViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AppGradient.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    SearchBar(searchText: $viewModel.searchText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)

                    // Currency list
                    List {
                        ForEach(viewModel.filteredCurrencies) { currency in
                            CurrencyListRow(currency: currency)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("All Currencies")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Currency List Row
struct CurrencyListRow: View {
    let currency: Currency

    var body: some View {
        HStack(spacing: 12) {
            Text(currency.flag)
                .font(.largeTitle)

            VStack(alignment: .leading, spacing: 2) {
                Text(currency.code)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(currency.name)
                    .font(.caption)
                    .foregroundColor(.primary)
            }

            Spacer()

            Text(currency.formattedRate)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var searchText: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search by code or name...", text: $searchText)
                .foregroundColor(.primary)
                .tint(.primary)
                .focused($isFocused)

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isFocused = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
    }
}

#Preview {
    CurrencyListView()
        .environmentObject(CurrencyViewModel())
} 
