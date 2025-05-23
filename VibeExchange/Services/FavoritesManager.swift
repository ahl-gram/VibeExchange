import Foundation
import SwiftUI

class FavoritesManager: ObservableObject {
    @Published var favoriteCurrencyCodes: Set<String> = []
    @Published var showConfetti = false
    
    private let favoritesKey = "favorite_currencies"
    private let firstFavoriteKey = "first_favorite_added"
    private let maxFavorites = 5
    
    init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    func addToFavorites(_ currencyCode: String) {
        guard favoriteCurrencyCodes.count < maxFavorites else {
            return
        }
        
        let isFirstFavorite = favoriteCurrencyCodes.isEmpty && !hasAddedFirstFavorite()
        
        favoriteCurrencyCodes.insert(currencyCode)
        saveFavorites()
        
        if isFirstFavorite {
            markFirstFavoriteAdded()
            triggerConfetti()
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func removeFromFavorites(_ currencyCode: String) {
        favoriteCurrencyCodes.remove(currencyCode)
        saveFavorites()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func toggleFavorite(_ currencyCode: String) {
        if isFavorite(currencyCode) {
            removeFromFavorites(currencyCode)
        } else {
            addToFavorites(currencyCode)
        }
    }
    
    func isFavorite(_ currencyCode: String) -> Bool {
        return favoriteCurrencyCodes.contains(currencyCode)
    }
    
    func canAddMoreFavorites() -> Bool {
        return favoriteCurrencyCodes.count < maxFavorites
    }
    
    func favoritesCount() -> Int {
        return favoriteCurrencyCodes.count
    }
    
    func getRemainingFavoritesSlots() -> Int {
        return max(0, maxFavorites - favoriteCurrencyCodes.count)
    }
    
    // MARK: - Private Methods
    
    private func loadFavorites() {
        if let savedFavorites = UserDefaults.standard.object(forKey: favoritesKey) as? [String] {
            favoriteCurrencyCodes = Set(savedFavorites)
        }
    }
    
    private func saveFavorites() {
        let favoritesArray = Array(favoriteCurrencyCodes)
        UserDefaults.standard.set(favoritesArray, forKey: favoritesKey)
    }
    
    private func hasAddedFirstFavorite() -> Bool {
        return UserDefaults.standard.bool(forKey: firstFavoriteKey)
    }
    
    private func markFirstFavoriteAdded() {
        UserDefaults.standard.set(true, forKey: firstFavoriteKey)
    }
    
    private func triggerConfetti() {
        showConfetti = true
        
        // Hide confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showConfetti = false
        }
    }
    
    // MARK: - Utility Methods
    
    func sortCurrencies(_ currencies: [Currency]) -> [Currency] {
        return currencies.sorted { lhs, rhs in
            let lhsIsFavorite = isFavorite(lhs.code)
            let rhsIsFavorite = isFavorite(rhs.code)
            
            if lhsIsFavorite && !rhsIsFavorite {
                return true
            } else if !lhsIsFavorite && rhsIsFavorite {
                return false
            } else {
                return lhs.code < rhs.code
            }
        }
    }
    
    func getFavoriteCurrencies(from allCurrencies: [Currency]) -> [Currency] {
        return allCurrencies.filter { isFavorite($0.code) }
    }
    
    func getNonFavoriteCurrencies(from allCurrencies: [Currency]) -> [Currency] {
        return allCurrencies.filter { !isFavorite($0.code) }
    }
} 