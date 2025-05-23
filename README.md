# Vibe Exchange - Real-Time Currency Exchange iOS App

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" alt="iOS Version">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift Version">
  <img src="https://img.shields.io/badge/Version-0.1-green.svg" alt="App Version">
</p>

Vibe Exchange is a beautiful, intuitive iOS application that provides real-time exchange rates for major world currencies. Built with SwiftUI and following Apple's Human Interface Guidelines, it delivers a delightful user experience with smooth animations, haptic feedback, and a stunning gradient design.

## ✨ Features

### Core Functionality
- **Live Exchange Rates** - Real-time currency data from exchangerate-api.com
- **Quick Converter** - Instant currency conversion with swap functionality
- **Favorites System** - Mark up to 5 favorite currencies for quick access
- **Search & Discovery** - Find currencies by name or ISO code
- **Offline Cache** - Last known rates available when offline

### Delightful Experience
- **Beautiful UI** - Purple-blue gradient design with glassmorphism effects
- **Smooth Animations** - Fluid transitions and micro-interactions
- **Haptic Feedback** - Tactile responses for user actions
- **Confetti Animation** - Celebration when adding first favorite
- **Pull-to-Refresh** - Intuitive data refresh gesture

### Technical Excellence
- **iOS 17+ Support** - Latest SwiftUI features and APIs
- **Dark Mode** - Full support for system appearance
- **VoiceOver Ready** - Accessibility compliant
- **Auto-Refresh** - Background updates every 30 seconds
- **MVVM Architecture** - Clean, testable code structure

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 SDK
- macOS 14.0 or later

### Installation

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd VibeExchangeProjFolder
   ```

2. **Open in Xcode**
   ```bash
   open VibeExchange.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### API Key
The app comes pre-configured with an API key for exchangerate-api.com. For production use, replace the API key in `CurrencyService.swift`:

```swift
private let apiKey = "your-api-key-here"
```

## 📱 App Structure

```
VibeExchange/
├── Models/
│   └── CurrencyModels.swift      # Data models and API response structures
├── Services/
│   ├── CurrencyService.swift     # API communication and caching
│   └── FavoritesManager.swift    # Favorites persistence and management
├── ViewModels/
│   └── CurrencyViewModel.swift   # Business logic and state management
├── Views/
│   ├── CurrencyListView.swift    # Currency list with search
│   └── ConverterView.swift       # Dedicated converter interface
├── ContentView.swift             # Main app interface
└── VibeExchangeApp.swift        # App entry point
```

## 🎯 Key Components

### CurrencyService
- Handles API communication with exchangerate-api.com
- Implements intelligent caching (10-minute TTL)
- Provides offline fallback functionality
- Supports exponential backoff for error handling

### FavoritesManager
- Manages up to 5 favorite currencies
- Persists preferences using UserDefaults
- Triggers confetti animation for first favorite
- Provides haptic feedback for interactions

### CurrencyViewModel
- Coordinates between services and UI
- Manages loading states and error handling
- Implements auto-refresh functionality
- Provides search and filtering capabilities

## 💡 Design Philosophy

Vibe Exchange follows Apple's Human Interface Guidelines and modern iOS design principles:

- **Visual Hierarchy** - Clear information architecture
- **Consistency** - Uniform design patterns throughout
- **Feedback** - Immediate response to user actions
- **Accessibility** - Full VoiceOver and Dynamic Type support
- **Performance** - 60fps animations and quick response times

## 🔄 Auto-Refresh System

The app intelligently refreshes exchange rates:
- Every 30 seconds when app is active
- When app returns to foreground
- When user manually pulls to refresh
- Respects API rate limits (1,000 calls/day)

## 📊 Currency Data

### Supported Currencies
- 150+ currencies from exchangerate-api.com
- Major currencies prioritized in display
- Real-time exchange rates updated continuously
- ISO 4217 currency codes supported

### Caching Strategy
- 10-minute cache validity for balance of freshness and performance
- Offline cache persists indefinitely
- Graceful degradation when API unavailable
- Cache timestamp displayed to users

## 🎨 Visual Design

### Color Palette
- **Primary Gradient**: Purple (#6633FF) to Blue (#3366FF)
- **Text**: White with opacity variations
- **Accent**: System blue for interactive elements
- **Background**: Ultra-thin material with blur effects

### Typography
- **Large Title**: App name and section headers
- **Headline**: Currency codes and amounts
- **Body**: Currency names and descriptions
- **Caption**: Metadata and timestamps

## 🛠 Technical Requirements

- **Minimum iOS Version**: 17.0
- **Architecture**: MVVM with Repository pattern
- **UI Framework**: SwiftUI
- **Networking**: URLSession with async/await
- **Data Persistence**: UserDefaults (lightweight data)
- **Testing**: Unit tests for business logic (future)

## 📋 Future Enhancements

The current MVP provides a solid foundation for future features:

- **Historical Charts** - Price trends and analysis
- **Rate Alerts** - Notifications for target rates
- **Widget Support** - Home screen and lock screen widgets
- **Apple Watch App** - Companion watchOS application
- **Cryptocurrency** - Bitcoin, Ethereum, and altcoins
- **Offline Packs** - Enhanced offline functionality

## 🔒 Privacy & Security

- **No Personal Data Collection** - App doesn't collect user information
- **API Key Security** - Encrypted storage of API credentials
- **GDPR Compliant** - Privacy-first approach
- **App Transport Security** - HTTPS-only communications

## 📄 License

This project is created for educational and portfolio purposes. The exchange rate data is provided by exchangerate-api.com under their terms of service.

## 🤝 Contributing

This is a portfolio project, but feedback and suggestions are welcome! Please feel free to:
- Report bugs or issues
- Suggest new features
- Provide UI/UX feedback
- Share performance improvements

## 📞 Contact

**Alexander Lee**  
iOS Developer  
Email: [your-email@example.com]  
LinkedIn: [your-linkedin-profile]  
Portfolio: [your-portfolio-website]

---

Built with ❤️ using SwiftUI and modern iOS development practices. 