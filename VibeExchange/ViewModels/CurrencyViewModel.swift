import Foundation
import Combine
import UIKit

@MainActor
class CurrencyViewModel: ObservableObject {
    @Published var currencies: [Currency] = []
    @Published var loadingState: LoadingState = .idle
    @Published var lastUpdated: Date?
    @Published var searchText = ""
    @Published var errorMessage: AppError?
    @Published private var now = Date()
    
    private let currencyService = CurrencyService.shared
    private var refreshTimer: Timer?
    private var displayTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // A single task to manage all fetch requests to prevent race conditions
    private var fetchTask: Task<Void, Never>?
    
    // Auto-refresh interval (30 seconds when app is active)
    private let refreshInterval: TimeInterval = 30
    
    init() {
        setupAutoRefresh()
        loadCachedData()
    }
    
    deinit {
        refreshTimer?.invalidate()
        displayTimer?.invalidate()
        fetchTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    func fetchExchangeRates() async {
        // If a fetch task is already running, just wait for it to complete.
        if let fetchTask = fetchTask {
            return await fetchTask.value
        }
        
        // Create a new task for this fetch operation.
        let task = Task {
            self.loadingState = .loading
            
            do {
                let fetchedCurrencies = try await currencyService.fetchExchangeRates()
                self.currencies = fetchedCurrencies
                self.lastUpdated = Date()
                self.loadingState = .loaded
                
            } catch is CancellationError {
                // If the task was cancelled, don't show an error.
                // Just reset the state gracefully.
                self.loadingState = self.currencies.isEmpty ? .idle : .loaded
            } catch {
                self.handleError(error)
            }
            
            // The task is complete, so clear it.
            self.fetchTask = nil
        }
        
        self.fetchTask = task
        await task.value
    }
    
    func refreshRates() async {
        // Clear cache to force fresh data
        currencyService.clearCache()
        await fetchExchangeRates()
    }
    
    func convert(amount: Double, from: String, to: String) -> Double {
        return currencyService.convert(
            amount: amount,
            from: from,
            to: to,
            rates: currencies
        )
    }
    
    func getCurrency(by code: String) -> Currency? {
        return currencies.first { $0.code == code }
    }
    
    // MARK: - Computed Properties
    
    var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return currencies
        } else {
            return currencies.filter { currency in
                currency.code.localizedCaseInsensitiveContains(searchText) ||
                currency.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var isLoading: Bool {
        if case .loading = loadingState {
            return true
        }
        return false
    }
    
    var hasError: Bool {
        if case .failed = loadingState {
            return true
        }
        return false
    }
    
    var isDataStale: Bool {
        guard let lastUpdated = lastUpdated else { return true }
        return Date().timeIntervalSince(lastUpdated) > refreshInterval
    }
    
    var lastUpdatedString: String {
        guard let lastUpdated = lastUpdated else {
            return "Never"
        }
        
        let formatter = DateFormatter()
        let timeInterval = now.timeIntervalSince(lastUpdated)
        
        if timeInterval < 60 {
            return "Just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: lastUpdated)
        }
    }
    
    private func setupAutoRefresh() {
        // This timer updates the 'now' property every [refreshInterval] seconds,
        // which in turn causes any view that uses 'lastUpdatedString' to refresh.
        displayTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            self?.now = Date()
        }

        // Start auto-refresh timer
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchExchangeRatesIfNeeded()
            }
        }
        
        // Listen for app state changes
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.fetchExchangeRatesIfNeeded()
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchExchangeRatesIfNeeded() async {
        // Only fetch if data is stale
        guard isDataStale else { return }
        await fetchExchangeRates()
    }
    
    private func loadCachedData() {
        if let cacheTimestamp = currencyService.getCacheTimestamp() {
            lastUpdated = cacheTimestamp
        }
        
        // Try to load cached currencies
        Task {
            do {
                let cachedCurrencies = try await currencyService.fetchExchangeRates()
                currencies = cachedCurrencies
                loadingState = .loaded
            } catch {
                // If no cache available, that's okay - we'll fetch fresh data
                loadingState = .idle
            }
        }
    }
    
    private func handleError(_ error: Error) {
        let appError: AppError
        
        if let currencyError = error as? CurrencyServiceError {
            appError = AppError(
                message: currencyError.localizedDescription,
                title: "Exchange Rate Error"
            )
        } else {
            appError = AppError(
                message: error.localizedDescription,
                title: "Unexpected Error"
            )
        }
        
        loadingState = .failed(appError)
        errorMessage = appError
    }
    
    func dismissError() {
        errorMessage = nil
        if case .failed = loadingState {
            loadingState = currencies.isEmpty ? .idle : .loaded
        }
    }
    
    // MARK: - Search functionality
    
    func clearSearch() {
        searchText = ""
    }
} 