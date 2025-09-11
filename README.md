# 🕌 Eslamy - Flutter Islamic App

A beautiful Flutter application for Islamic content with Hadith collection and favorites system.

## ✨ Features

- **🎨 Modern UI Design** - Clean, intuitive interface with beautiful animations
- **📱 Splash Screen** - Auto-navigation to home screen
- **📖 Hadith Collection** - Browse through authentic hadiths with pagination
- **❤️ Favorites System** - Save your favorite hadiths with SQLite storage
- **🔄 Real-time Updates** - Instant UI updates with Riverpod state management
- **📱 Responsive Design** - Optimized for both iOS and Android

## 🛠️ Tech Stack

- **Flutter** - Cross-platform mobile development
- **Riverpod** - State management
- **Dio** - HTTP networking with interceptors
- **SQLite** - Local database for favorites
- **Material Design** - Modern UI components

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  dio: ^5.9.0
  flutter_riverpod: ^2.6.1
  sqflite: ^2.4.1
  path: ^1.9.0
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- iOS Simulator or Android Emulator
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/eslamy-flutter-app.git
   cd eslamy-flutter-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Structure

```
lib/
├── core/
│   └── network/
│       └── dio_provider.dart          # HTTP client configuration
├── features/
│   ├── splash/
│   │   └── presentation/pages/
│   │       └── splash_page.dart       # Splash screen
│   ├── home/
│   │   └── presentation/pages/
│   │       └── home_page.dart         # Main home screen
│   ├── hadith/
│   │   ├── models/
│   │   │   └── hadith.dart           # Hadith data models
│   │   ├── service/
│   │   │   └── hadith_service.dart   # API service
│   │   ├── presentation/
│   │   │   ├── controllers/
│   │   │   │   └── hadith_providers.dart
│   │   │   └── pages/
│   │   │       └── hadith_list_page.dart
│   │   └── hadith_constants.dart     # API configuration
│   └── favorites/
│       ├── models/
│       │   └── favorite_hadith.dart  # Favorite data models
│       ├── service/
│       │   ├── favorites_service.dart
│       │   └── favorites_database.dart # SQLite database
│       └── presentation/
│           ├── controllers/
│           │   └── favorites_providers.dart
│           └── pages/
│               └── favorites_page.dart
└── main.dart                         # App entry point
```

## 🎯 Key Features

### 🏠 Home Screen
- Beautiful welcome interface
- Navigation to different sections
- Modern card-based design

### 📖 Hadith Collection
- **Infinite Scroll** - Load more hadiths as you scroll
- **Pull to Refresh** - Refresh the list manually
- **Error Handling** - Graceful error states with retry options
- **Modern Cards** - Each hadith displayed in a beautiful card

### ❤️ Favorites System
- **Heart Icons** - Tap to add/remove from favorites
- **SQLite Storage** - Persistent local storage
- **Visual Feedback** - Floating snackbars with icons
- **Favorites Page** - View all your saved hadiths
- **Remove Options** - Remove individual items or clear all

### 🔧 State Management
- **Riverpod Providers** - Clean state management
- **Real-time Updates** - Instant UI updates
- **Error Handling** - Comprehensive error states

## 🎨 UI/UX Features

- **Material Design 3** - Modern design language
- **Smooth Animations** - Delightful user interactions
- **Responsive Layout** - Works on all screen sizes
- **Dark/Light Theme** - System theme support
- **Accessibility** - Proper touch targets and semantics

## 📊 Database Schema

```sql
CREATE TABLE favorites (
  id TEXT PRIMARY KEY,
  hadith_id INTEGER NOT NULL,
  title TEXT,
  narrator TEXT,
  body TEXT,
  saved_at TEXT NOT NULL
);

CREATE INDEX idx_hadith_id ON favorites(hadith_id);
```

## 🔗 API Integration

- **Hadith API** - Integration with hadithapi.com
- **Dio Interceptors** - Rate limiting and error handling
- **Pagination** - Efficient data loading
- **Offline Support** - Favorites work without internet

## 🚀 Future Enhancements

- [ ] Search functionality
- [ ] Categories and filters
- [ ] Audio playback for hadiths
- [ ] Sharing functionality
- [ ] Push notifications
- [ ] User authentication
- [ ] Cloud sync for favorites

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Ahmed Taha**
- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- [Hadith API](https://www.hadithapi.com/) for providing authentic hadith data
- Flutter team for the amazing framework
- Riverpod team for excellent state management
- Material Design for beautiful UI components

---

⭐ **Star this repository if you found it helpful!**