# Ceylon Explorer — Technical Architecture Document

**Version:** 1.0.1 | **Date:** August 2026

---

## 1. System Overview

Ceylon Explorer is a **cross-platform mobile application** built with Flutter, targeting Android, iOS, and Web. It follows a layered architecture with a clear separation between UI, business logic, and data layers.

```
┌──────────────────────────────────────────────────┐
│                 UI Layer (Screens)               │
│  home, explore, drive, profile, community, ...   │
├──────────────────────────────────────────────────┤
│             Business Logic Layer                 │
│    Services: LITA AI, Routing, Geocoding,        │
│    Trip History, Location, Booking               │
├──────────────────────────────────────────────────┤
│               Data Layer                         │
│  Firebase Firestore │ Local State │ REST APIs    │
├────────────┬────────┴───────┬─────────────────────┤
│  Firebase  │  OpenStreetMap │  Google Gemini API  │
│  (Backend) │  (Maps/Geo)    │  (AI Companion)     │
└────────────┴────────────────┴─────────────────────┘
```

---

## 2. Technology Stack

### 2.1 Frontend
| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Flutter | 3.x |
| Language | Dart | ^3.9.2 |
| State Management | Provider | ^6.x |
| Navigation | Flutter Navigator 2.0 | - |
| Maps | flutter_map | ^6.1.0 |
| Map Tiles | OpenStreetMap (Nominatim) | - |

### 2.2 AI & Intelligence
| Component | Technology |
|-----------|-----------|
| AI Conversations | Google Gemini 1.5 Flash |
| Text-to-Speech | flutter_tts ^3.8.5 |
| Speech-to-Text | speech_to_text ^6.6.0 |
| Itinerary Generation | Gemini API + local ML fallback |

### 2.3 Backend & Infrastructure
| Component | Technology |
|-----------|-----------|
| Authentication | Firebase Auth (Google Sign-In) |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Real-time Updates | Firestore Streams |

### 2.4 Device APIs
| Feature | Package |
|---------|---------|
| GPS / Location | geolocator ^11.0.0 |
| Camera / Gallery | image_picker |
| Local Storage | shared_preferences |
| PDF Export | pdf + printing |
| Deep Links | url_launcher |

---

## 3. Module Architecture

### 3.1 Screens (32 total)

```
lib/screens/
├── Core Navigation
│   ├── main_navigation_screen.dart    # Bottom nav shell
│   ├── home_screen.dart               # Main landing page
│   └── login_screen.dart              # Auth entry
│
├── Drive Module
│   ├── drive_setup_screen.dart        # Trip configuration
│   └── active_trip_screen.dart        # Live GPS tracking + LITA
│
├── Explore Module
│   ├── explore_screen.dart            # Province & place discovery
│   ├── place_detail_screen.dart       # Detailed place view
│   └── map_screen.dart                # Interactive map
│
├── Planning Module
│   ├── itinerary_screen.dart          # AI trip planner
│   ├── plan_trip_screen.dart          # Manual planning
│   └── schedule_calendar_screen.dart  # Calendar view
│
├── Booking Module
│   ├── hotel_list_screen.dart
│   ├── hotel_detail_screen.dart
│   ├── hotel_booking_screen.dart
│   └── payment_screen.dart
│
├── Social Module
│   ├── community_feed_screen.dart
│   ├── ai_chat_screen.dart
│   ├── chat_list_screen.dart
│   └── real_time_chat_screen.dart
│
└── Profile Module
    ├── profile_screen.dart             # Trip history (Instagram-style)
    ├── customize_profile_screen.dart
    ├── trip_journal_screen.dart
    └── trip_summary_screen.dart
```

### 3.2 Services

```
lib/services/
├── lita_ai_service.dart         # Gemini AI + TTS + STT
├── geocoding_service.dart       # Nominatim location search
├── routing_service.dart         # OSRM route calculation
├── trip_history_service.dart    # Local trip storage (Provider)
└── location_service.dart        # GPS stream management
```

---

## 4. Data Models

### 4.1 TripHistoryItem
```dart
class TripHistoryItem {
  String id;           // UUID
  String tripName;     // User-defined name
  String fromLocation; // Start point
  String toLocation;   // Destination
  String vehicle;      // Car, Train, Bus, etc.
  double distanceKm;   // Calculated GPS distance
  Duration timeTaken;  // Trip duration
  double maxSpeedKmH;  // Peak speed recorded
  double rating;       // 1.0–5.0 user rating
  DateTime date;       // Trip timestamp
  String mapPreviewUrl;// Asset image path
}
```

---

## 5. Key Data Flows

### 5.1 LITA AI Voice Flow
```
User speaks
    │
    ▼
speech_to_text (device-local STT)
    │  Recognized text
    ▼
LitaAiService.sendMessage()
    │  Text + context (speed, destination)
    ▼
Google Gemini 1.5 Flash API
    │  AI response text
    ▼
flutter_tts (device-local TTS)
    │  Spoken response
    ▼
User hears LITA
    │
    ▼ (auto-listen again)
speech_to_text
```

### 5.2 Drive Tracking Flow
```
User taps "Start Trip"
    │
    ▼
Geolocator.getPositionStream()
    │  Position updates every 5m
    ├─► Update vehicle marker on map
    ├─► Calculate cumulative distance
    └─► Calculate speed (m/s → km/h)
    │
    ▼
User taps "Save Trip" (green ✓)
    │
    ▼
Save Trip Details dialog
    │  Name, rating
    ▼
TripHistoryService.addTrip()
    │
    ▼
Profile screen (Instagram grid)
```

---

## 6. Security Architecture

| Concern | Mitigation |
|---------|------------|
| API Key Exposure | Keys stored in `dart_defines.json`, never committed to git |
| Firebase Rules | Role-based Firestore security rules |
| Auth | Firebase Authentication with Google Sign-In |
| Data Transit | HTTPS/TLS for all API calls |
| Voice Data | Processed in real-time only; never stored server-side |

---

## 7. Performance Considerations

- **Map Tiles:** OpenStreetMap tiles are cached by the browser/OS
- **Provider State:** Minimal rebuilds using `context.watch` selectively
- **Images:** Asset images used for province/place previews
- **GPS:** `distanceFilter: 5` meters to reduce battery drain during trips

---

## 8. Third-Party Services & Licenses

| Service | Usage | License |
|---------|-------|---------|
| OpenStreetMap | Map tiles & geocoding | ODbL |
| OSRM | Route calculation | BSD 2-Clause |
| Google Gemini | AI conversations | Google Cloud Terms |
| Firebase | Auth, Database, Storage | Google Cloud Terms |
| flutter_map | Map rendering | MIT |
