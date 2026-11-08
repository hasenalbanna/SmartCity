# Ceylon Explorer — Changelog

All notable changes to Ceylon Explorer are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.1] — August 17, 2026

### 🚀 Added
- **LITA AI Voice Companion** — Real-time AI travel friend powered by Google Gemini 1.5 Flash
  - Speaks and listens in real-time using flutter_tts and speech_to_text
  - Greets user by name on first interaction
  - Auto-listens after finishing speaking for seamless conversation
  - Pink pulse wave animation while speaking
  - Red pulse wave animation while listening
  - Female voice with pitch tuning
- **Start Drive Feature** — Full GPS-tracked trip experience
  - Live vehicle marker on map (updates with real device GPS)
  - Real-time speedometer display (km/h)
  - Draggable picture-in-picture minimap overlay
  - Recent Destinations quick-select chips
- **Trip Save Dialog** — Rich trip details on save
  - Custom trip name entry
  - Star rating (1–5)
- **Trip Summary Screen** — Full post-trip statistics
  - Trip name, rating, route, vehicle, distance, duration, max speed
- **Profile Trip Grid** — Instagram-style trip history
  - Tap any saved trip to view full summary
- **Animated "Start Drive" Button** — Car icon slides left-to-right in a loop
- **Drive Setup Map Preview** — Interactive route map before starting trip

### 🔧 Changed
- Removed "Saved" icon from bottom navigation footer
- "Saved Trips" and "Saved Places" moved to Profile screen as tabs
- LITA modal redesigned: fully transparent, no background, shows map beneath
- LITA mic replaced with girl icon (face_3) for personality
- Buttons across the app use strict Black (light mode) / White (dark mode) styling

### 🐛 Fixed
- `google_generative_ai` import error (removed invalid `generate_content_request.dart` import)
- `_sendMessageToLita()` return type changed from `void` to `Future<void>`
- TTS speech rate corrected from 0.47 (slow-motion) to 1.0 (normal)
- Gemini API key corrected to use the project's valid `AIzaSy...` key
- Chat session now resets automatically after network errors (auto-retry logic)

---

## [1.0.0] — August 2026 (Initial Release)

### 🚀 Added
- **Home Screen** with search, featured places, and category quick-access
- **Explore Screen** — Browse all 9 Sri Lanka provinces and destinations
- **Place Detail Screen** — Full info, photos, reviews for each location
- **Interactive Map Screen** — Full-screen OpenStreetMap view
- **AI Itinerary Planner** — Gemini-powered personalized trip generation with PDF export
- **Hotel Listing & Booking** — Browse, filter, and book hotels
- **Local Guides** — Find and book certified Sri Lankan tour guides
- **Community Feed** — Social travel posts, likes, and comments
- **Real-time Chat** — Direct messaging between travelers
- **Trip Journal** — Document travel memories with photos and notes
- **World Clock** — Time zones for international travelers
- **SIM Recommendations** — Best data plans for tourists
- **User Authentication** — Google Sign-In via Firebase Auth
- **Profile Screen** — User profile with trip history
- **Dark Mode / Light Mode** — Full theme support
- **Notifications Screen** — Travel alerts and updates
- **Schedule Calendar** — Trip calendar view
- **GeocodingService** — Real-world location search using Nominatim API
- **RoutingService** — Route calculation using OSRM API
- **TripHistoryService** — Local trip storage with Provider state management

---

## Upcoming — [1.1.0] (Planned Q4 2026)

### Planned Features
- [ ] Offline map tile caching
- [ ] Multi-language support (Sinhala, Tamil)
- [ ] LITA Premium voice profiles
- [ ] Augmented Reality place markers
- [ ] Public transport timetable integration
- [ ] Group trip planning
- [ ] In-app payments for guide bookings
- [ ] Push notifications for trip reminders
