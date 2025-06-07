# Vibe Exchange - Real-Time Currency Exchange iOS App

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" alt="iOS Version">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift Version">
  <img src="https://img.shields.io/badge/Architecture-MVVM%20+%20Proxy-purple.svg" alt="Architecture">
  <img src="https://img.shields.io/badge/Security-API%20Proxy-green.svg" alt="Security">
</p>

Vibe Exchange is a beautiful, intuitive iOS application that provides real-time exchange rates for major world currencies. Built with SwiftUI, following Apple's Human Interface Guidelines, and using a secure backend proxy, it delivers a delightful user experience with smooth animations, haptic feedback, and an appealing gradient design.

## ✨ Features

### Core Functionality
- **Live Exchange Rates** - Real-time currency data proxied through a secure backend server.
- **Quick Converter** - Instant currency conversion with swap functionality.
- **Favorites System** - Mark up to 5 favorite currencies for quick access.
- **Search & Discovery** - Find currencies by name or ISO code.
- **Offline Cache** - Last known rates available when offline.

### Delightful Experience
- **Beautiful UI** - Purple-blue gradient design with glassmorphism effects.
- **Smooth Animations** - Fluid transitions and micro-interactions.
- **Haptic Feedback** - Tactile responses for user actions.
- **Confetti Animation** - Celebration when adding first favorite.
- **Pull-to-Refresh** - Intuitive data refresh gesture.

### Technical Excellence
- **Secure API Proxy** - The app communicates with a secure Vercel backend, which manages the third-party API keys. The keys are never exposed to the client.
- **iOS 17+ Support** - Latest SwiftUI features and APIs.
- **Dark Mode** - Full support for system appearance.
- **VoiceOver Ready** - Accessibility compliant.
- **Auto-Refresh** - Background updates every 30 seconds.
- **MVVM Architecture** - Clean, testable code structure.

## 🚀 Getting Started

This project has two parts: the iOS application and a serverless backend. Both must be configured for the app to work.

### 1. Backend Server Setup

The backend is a serverless proxy built for Vercel. It manages the API keys and makes requests on behalf of the iOS app.

1.  **Navigate to Server Directory**
    ```bash
    cd VibeExchangeServer
    ```

2.  **Install Vercel CLI**
    ```bash
    npm install -g vercel
    ```

3.  **Link to Your Vercel Project**
    ```bash
    vercel link
    ```
    Follow the prompts to link to your Vercel project.

4.  **Set Environment Variables**
    You need to set two secret keys on Vercel.
    - `EXCHANGE_RATE_API_KEY`: Your key from exchangerate-api.com.
    - `APP_AUTH_KEY`: A unique secret key you create to secure your proxy. You can generate one with `uuidgen`.
    ```bash
    # Add the API key for the exchange rate service
    vercel env add EXCHANGE_RATE_API_KEY

    # Add the secret key for authenticating your app
    vercel env add APP_AUTH_KEY
    ```
    You will be prompted to paste the value for each key.

5.  **Deploy to Production**
    ```bash
    vercel --prod
    ```
    After deployment, Vercel will provide you with a production URL. **Copy this URL.**

### 2. iOS App Setup

1.  **Clone the Repository**
    ```bash
    git clone <repository-url>
    cd VibeExchangeProjFolder
    ```

2.  **Create Secrets File**
    The app uses an `.xcconfig` file to manage secrets securely. This file is ignored by Git. Create it now:
    ```bash
    touch VibeExchange/Config/Secrets.xcconfig
    ```

3.  **Add Authentication Key**
    Open `VibeExchange/Config/Secrets.xcconfig` and add the `APP_AUTH_KEY` that you created and set on the Vercel server.
    ```
    APP_AUTH_KEY = "YOUR_APP_AUTH_KEY_HERE"
    ```

4.  **Configure Server URL**
    Open `VibeExchange/Services/CurrencyService.swift` and replace the placeholder URL with your Vercel production URL from the previous step.
    ```swift
    private var baseURL: String {
        return "https://your-vercel-deployment-url.vercel.app/api/exchange-rate"
    }
    ```

5.  **Open and Run in Xcode**
    ```bash
    open VibeExchange.xcodeproj
    ```
    - Select your target device or simulator.
    - Press `Cmd + R` to build and run.

## 🔒 Security Model

The app uses a secure proxy pattern to protect the third-party API key.

- **No Client-Side API Keys**: The key for `exchangerate-api.com` is stored securely as an environment variable on the Vercel server and is never included in the iOS app.
- **App Authentication**: The iOS app authenticates with the Vercel proxy using a secret key (`APP_AUTH_KEY`). This ensures that only your app can access your proxy.
- **Secure Key Management**: The `APP_AUTH_KEY` on the client side is stored in a `Secrets.xcconfig` file, which is listed in `.gitignore` to prevent it from being committed to version control.
- **App Transport Security (ATS)**: ATS is enabled to enforce secure HTTPS connections for all network requests.

## 📱 App Structure

```
VibeExchange/
├── Configuration.plist           # Encrypted API configuration
├── Models/
│   └── CurrencyModels.swift      # Data models and API response structures
├── Services/
│   ├── CurrencyService.swift     # API communication and caching
│   ├── FavoritesManager.swift    # Favorites persistence and management
│   └── KeychainManager.swift     # Secure storage for sensitive data
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
