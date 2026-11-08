# Smart City

<p align="center">
  <img src="assets/app_icon.png" alt="Smart City Logo" width="120"/>
</p>

<p align="center">
  <strong>Your AI-Powered Smart City & Exploration Companion</strong><br/>
  Explore, Drive, and Discover like never before.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.1-blue" />
  <img src="https://img.shields.io/badge/flutter-3.x-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/AI-Gemini-orange?logo=google" />
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-green" />
</p>

---

## 🌏 About

**Smart City** is a full-featured, AI-powered travel and urban companion application. It empowers citizens, tourists, and locals to discover, plan, navigate, and share their experiences — all in one premium app.

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🗺️ **Explore** | Discover Sri Lanka's provinces, places, and hidden gems |
| 🚗 **Start Drive** | Real-time GPS navigation with live vehicle tracking |
| 🤖 **LITA AI** | Gemini-powered voice travel companion — speaks and listens in real-time |
| 🏨 **Hotel Booking** | Browse and book hotels across Sri Lanka |
| 🗓️ **AI Itinerary** | AI-generated personalized trip plans |
| 👥 **Guides** | Connect with local certified tour guides |
| 💬 **Community** | Share travel posts, stories, and tips |
| 📔 **Trip Journal** | Document your travel memories |
| 🕐 **World Clock** | Time zones for international travelers |
| 📱 **SIM Recommendations** | Best data plans for tourists |
| 🔔 **Notifications** | Real-time travel alerts |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart) |
| AI | Google Gemini 1.5 Flash API |
| Maps | Flutter Map + OpenStreetMap |
| Navigation | Real-time GPS (Geolocator) |
| Backend | Firebase (Auth, Firestore, Storage) |
| Voice | flutter_tts + speech_to_text |
| Geocoding | Nominatim (OpenStreetMap) |
| State Management | Provider |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.9.2`
- Dart SDK `^3.0`
- A `dart_defines.json` file with your API keys

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/yourorg/ceylon_explorer.git
cd ceylon_explorer

# 2. Create dart_defines.json in the project root
cat > dart_defines.json << EOF
{
  "GEMINI_API_KEY": "YOUR_GEMINI_API_KEY_HERE",
  "ITINERARY_API_BASE_URL": ""
}
EOF

# 3. Install dependencies
flutter pub get

# 4. Run the app (Web)
flutter run -d web-server --web-port 8080 --dart-define-from-file=dart_defines.json

# 5. Run on Android / iOS
flutter run --dart-define-from-file=dart_defines.json
```

### Firebase Setup
1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Download `google-services.json` and place in `android/app/`
3. Download `GoogleService-Info.plist` and place in `ios/Runner/`
4. Enable Authentication, Firestore, and Storage in the Firebase console

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── screens/                     # All 32 app screens
│   ├── home_screen.dart
│   ├── active_trip_screen.dart  # Live GPS drive tracking
│   ├── drive_setup_screen.dart  # Trip configuration
│   ├── explore_screen.dart      # Discovery & places
│   ├── itinerary_screen.dart    # AI trip planner
│   ├── profile_screen.dart      # User profile & history
│   └── ...
├── services/                    # Business logic & APIs
│   ├── lita_ai_service.dart     # Gemini voice AI
│   ├── geocoding_service.dart   # Location search
│   ├── routing_service.dart     # Route calculation
│   └── trip_history_service.dart
└── widgets/                     # Reusable UI components
```

---

## 📄 License

Copyright © 2026 Ceylon Explorer. All rights reserved.
