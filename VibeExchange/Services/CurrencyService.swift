import Foundation

class CurrencyService: ObservableObject {
    static let shared = CurrencyService()
    
    private var apiKey: String? {
        return ConfigurationManager.shared.getAPIKey()
    }
    
    private var baseURL: String {
        return ConfigurationManager.shared.getBaseURL() ?? "https://v6.exchangerate-api.com/v6"
    }
    
    private let cacheKey = "cached_exchange_rates"
    private let cacheTimeKey = "cache_timestamp"
    private let cacheValidityDuration: TimeInterval = 10 * 60 // 10 minutes
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchExchangeRates(baseCurrency: String = "USD") async throws -> [Currency] {
        // Check cache first
        if let cachedRates = getCachedRates(), isCacheValid() {
            return cachedRates
        }
        
        // Fetch from API
        let rates = try await fetchFromAPI(baseCurrency: baseCurrency)
        cacheRates(rates)
        return rates
    }
    
    func convert(amount: Double, from fromCurrency: String, to toCurrency: String, rates: [Currency]) -> Double {
        guard let fromRate = rates.first(where: { $0.code == fromCurrency })?.rate,
              let toRate = rates.first(where: { $0.code == toCurrency })?.rate else {
            return 0
        }
        
        // Convert to USD first, then to target currency
        let usdAmount = amount / fromRate
        return usdAmount * toRate
    }
    
    // MARK: - Private Methods
    
    private func fetchFromAPI(baseCurrency: String) async throws -> [Currency] {
        guard let apiKey = self.apiKey else {
            throw CurrencyServiceError.missingAPIKey
        }
        
        guard let url = URL(string: "\(baseURL)/\(apiKey)/latest/\(baseCurrency)") else {
            throw CurrencyServiceError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CurrencyServiceError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw CurrencyServiceError.httpError(httpResponse.statusCode)
            }
            
            let exchangeResponse = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            
            guard exchangeResponse.result == "success" else {
                throw CurrencyServiceError.apiError(exchangeResponse.result)
            }
            
            return convertToCurrencies(from: exchangeResponse.conversionRates)
            
        } catch let error as CurrencyServiceError {
            throw error
        } catch {
            throw CurrencyServiceError.networkError(error.localizedDescription)
        }
    }
    
    private func convertToCurrencies(from rates: [String: Double]) -> [Currency] {
        let majorCurrencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY"]
        
        // Only add major currencies
        let currencies: [Currency] = majorCurrencies.compactMap { code in
            guard let rate = rates[code] else { return nil }
            return Currency.create(from: code, rate: rate)
        }
        
        return currencies
    }
    
    // MARK: - Caching
    
    private func cacheRates(_ rates: [Currency]) {
        do {
            let data = try JSONEncoder().encode(rates)
            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: cacheTimeKey)
        } catch {
            print("Failed to cache rates: \(error)")
        }
    }
    
    private func getCachedRates() -> [Currency]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode([Currency].self, from: data)
        } catch {
            print("Failed to decode cached rates: \(error)")
            return nil
        }
    }
    
    private func isCacheValid() -> Bool {
        guard let cacheTime = UserDefaults.standard.object(forKey: cacheTimeKey) as? Date else {
            return false
        }
        
        return Date().timeIntervalSince(cacheTime) < cacheValidityDuration
    }
    
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: cacheTimeKey)
    }
    
    func getCacheTimestamp() -> Date? {
        return UserDefaults.standard.object(forKey: cacheTimeKey) as? Date
    }
}

// MARK: - Error Types

enum CurrencyServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case networkError(String)
    case decodingError
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .apiError(let message):
            return "API Error: \(message)"
        case .networkError(let message):
            return "Network Error: \(message)"
        case .decodingError:
            return "Failed to decode response"
        case .missingAPIKey:
            return "API key is missing"
        }
    }
} 