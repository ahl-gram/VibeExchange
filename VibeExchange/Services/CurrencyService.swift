import Foundation

class CurrencyService: ObservableObject {
    static let shared = CurrencyService()

    // MARK: - Configuration
    
    // The production URL for your Vercel proxy
    private var baseURL: String {
        return "https://vibe-exchange-server-alexs-projects-d051cfd1.vercel.app/api/exchange-rate"
    }

    // The secret key to authenticate with your Vercel proxy
    private var appAuthKey: String {
        // Read the key from the Info.plist file, which gets its value from Secrets.xcconfig
        guard let key = Bundle.main.object(forInfoDictionaryKey: "AppAuthKey") as? String else {
            // This is a fatal error because the app cannot function without the key.
            // Crashing immediately makes the problem obvious during development.
            fatalError("AppAuthKey not found in Info.plist. Make sure it is set in Secrets.xcconfig.")
        }
        return key
    }

    // MARK: - Caching Configuration
    private let cacheKey = "cached_exchange_rates"
    private let cacheTimeKey = "cache_timestamp"
    private let cacheValidityDuration: TimeInterval = 60 * 60 // 1 hour
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Fetches the latest exchange rates, using a cached version if available and valid.
    func fetchExchangeRates(baseCurrency: String = "USD") async throws -> [Currency] {
        // Check cache first
        if let cachedRates = getCachedRates(), isCacheValid() {
            return cachedRates
        }
        
        // Fetch from the proxy server
        let rates = try await fetchFromProxy(baseCurrency: baseCurrency)
        cacheRates(rates)
        return rates
    }
    
    /// Converts an amount from a source currency to a target currency using a given set of rates.
    func convert(amount: Double, from fromCurrency: String, to toCurrency: String, rates: [Currency]) -> Double {
        guard let fromRate = rates.first(where: { $0.code == fromCurrency })?.rate,
              let toRate = rates.first(where: { $0.code == toCurrency })?.rate else {
            return 0
        }
        
        // Convert to USD first, then to target currency
        let usdAmount = amount / fromRate
        return usdAmount * toRate
    }
    
    // MARK: - Private Network Fetching
    
    private func fetchFromProxy(baseCurrency: String) async throws -> [Currency] {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "base", value: baseCurrency)
        ]

        guard let url = components?.url else {
            throw CurrencyServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(appAuthKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CurrencyServiceError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw CurrencyServiceError.httpError(httpResponse.statusCode)
            }
            
            let exchangeResponse = try JSONDecoder().decode(ExchangeRates.self, from: data)
            
            guard exchangeResponse.result == "success" else {
                if let errorDetails = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw CurrencyServiceError.apiError(errorDetails.errorType)
                }
                throw CurrencyServiceError.apiError("Unknown API error")
            }
            
            return convertToCurrencies(from: exchangeResponse.conversion_rates)
            
        } catch let error as CurrencyServiceError {
            throw error
        } catch {
            throw CurrencyServiceError.networkError(error.localizedDescription)
        }
    }
    
    private func convertToCurrencies(from rates: [String: Double]) -> [Currency] {
        let majorCurrencyCodes = Currency.predefinedCurrencies.keys
        
        // Only add major currencies
        let currencies: [Currency] = majorCurrencyCodes.compactMap { code in
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

// MARK: - Data Models & Errors

struct ExchangeRates: Decodable {
    let result: String
    let documentation: String
    let terms_of_use: String
    let time_last_update_unix: Int
    let time_last_update_utc: String
    let time_next_update_unix: Int
    let time_next_update_utc: String
    let base_code: String
    let conversion_rates: [String: Double]
}

struct ErrorResponse: Decodable {
    let result: String
    let errorType: String
    
    enum CodingKeys: String, CodingKey {
        case result
        case errorType = "error-type"
    }
}

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
