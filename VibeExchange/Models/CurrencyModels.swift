import Foundation

// MARK: - API Response Models
struct ExchangeRateResponse: Codable {
    let result: String
    let documentation: String
    let termsOfUse: String
    let timeLastUpdateUnix: Int
    let timeLastUpdateUtc: String
    let timeNextUpdateUnix: Int
    let timeNextUpdateUtc: String
    let baseCode: String
    let conversionRates: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case result, documentation
        case termsOfUse = "terms_of_use"
        case timeLastUpdateUnix = "time_last_update_unix"
        case timeLastUpdateUtc = "time_last_update_utc"
        case timeNextUpdateUnix = "time_next_update_unix"
        case timeNextUpdateUtc = "time_next_update_utc"
        case baseCode = "base_code"
        case conversionRates = "conversion_rates"
    }
}

// MARK: - Currency Model
struct Currency: Identifiable, Codable, Hashable {
    let id = UUID()
    let code: String
    let name: String
    let flag: String
    var rate: Double
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case code, name, flag, rate, isFavorite
    }
    
    init(code: String, name: String, flag: String, rate: Double, isFavorite: Bool = false) {
        self.code = code
        self.name = name
        self.flag = flag
        self.rate = rate
        self.isFavorite = isFavorite
    }
    
    // Formatted rate display
    var formattedRate: String {
        if rate >= 1000 {
            return String(format: "%.2f", rate)
        } else if rate >= 100 {
            return String(format: "%.2f", rate)
        } else if rate >= 10 {
            return String(format: "%.2f", rate)
        } else if rate >= 1 {
            return String(format: "%.2f", rate)
        } else {
            return String(format: "%.4f", rate)
        }
    }
}

// MARK: - Predefined Currencies
extension Currency {
    static let predefinedCurrencies: [String: (name: String, flag: String)] = [
        "USD": ("US Dollar", "🇺🇸"),
        "EUR": ("Euro", "🇪🇺"),
        "GBP": ("British Pound", "🇬🇧"),
        "JPY": ("Japanese Yen", "🇯🇵"),
        "CAD": ("Canadian Dollar", "🇨🇦"),
        "AUD": ("Australian Dollar", "🇦🇺"),
        "CHF": ("Swiss Franc", "🇨🇭"),
        "CNY": ("Chinese Yuan", "🇨🇳")
    ]
    
    static func create(from code: String, rate: Double) -> Currency {
        let currencyInfo = predefinedCurrencies[code] ?? (name: code, flag: "💱")
        return Currency(
            code: code,
            name: currencyInfo.name,
            flag: currencyInfo.flag,
            rate: rate
        )
    }
}

// MARK: - App State Models
struct AppError: Identifiable {
    let id = UUID()
    let message: String
    let title: String
    
    init(message: String, title: String = "Error") {
        self.message = message
        self.title = title
    }
}

enum LoadingState {
    case idle
    case loading
    case loaded
    case failed(AppError)
} 