# Ceylon Explorer — API Documentation

**Version:** 1.0.1 | **Date:** August 2026

---

## Overview

Ceylon Explorer integrates with the following external APIs and services:

| Service | Purpose | Type |
|---------|---------|------|
| Google Gemini 1.5 Flash | LITA AI conversations | REST / SDK |
| Nominatim (OpenStreetMap) | Location geocoding & search | REST |
| OSRM | Route calculation | REST |
| Firebase Auth | User authentication | SDK |
| Cloud Firestore | Database | SDK |
| Firebase Storage | File/image storage | SDK |

---

## 1. Google Gemini AI

### Configuration
```dart
// lib/services/lita_ai_service.dart
final model = GenerativeModel(
  model: 'gemini-1.5-flash',
  apiKey: 'YOUR_API_KEY', // From dart_defines.json
  systemInstruction: Content.system('You are LITA, a lovable travel companion...'),
);
final chatSession = model.startChat();
```

### Send a Message
```dart
final response = await chatSession.sendMessage(Content.text(userMessage));
final reply = response.text;
```

### Context Injection
Trip context is prepended automatically:
```
[Context: going to Galle at 60 km/h] Hello LITA!
```

### Error Handling
- Auto-retry up to 2 times on network failure
- 15-second timeout per request
- Chat session reset on failure

### API Key Setup
Store in `dart_defines.json`:
```json
{
  "GEMINI_API_KEY": "AIzaSy..."
}
```
Run with: `flutter run --dart-define-from-file=dart_defines.json`

---

## 2. Nominatim Geocoding API (OpenStreetMap)

### Base URL
```
https://nominatim.openstreetmap.org
```

### Search for a Location
```http
GET /search?q={query}&format=json&limit=5&countrycodes=lk
```

**Parameters:**
| Parameter | Value | Description |
|-----------|-------|-------------|
| `q` | string | Search query (e.g., "Galle Fort") |
| `format` | `json` | Response format |
| `limit` | `5` | Max results |
| `countrycodes` | `lk` | Restrict to Sri Lanka |

**Response:**
```json
[
  {
    "place_id": 123456,
    "display_name": "Galle Fort, Galle, Southern Province, Sri Lanka",
    "lat": "6.0278",
    "lon": "80.2168"
  }
]
```

### Implementation
```dart
// lib/services/geocoding_service.dart
class GeocodingService {
  Future<List<GeocodingResult>> search(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(query)}'
      '&format=json&limit=5&countrycodes=lk'
    );
    // Returns List<GeocodingResult> with name, lat, lon
  }
}
```

**Rate Limits:** Max 1 request/second. User-Agent header required.

---

## 3. OSRM Routing API

### Base URL
```
https://router.project-osrm.org
```

### Get a Route
```http
GET /route/v1/driving/{lon1},{lat1};{lon2},{lat2}?overview=full&geometries=geojson
```

**Example:**
```http
GET /route/v1/driving/79.8612,6.9271;80.2210,6.0535?overview=full&geometries=geojson
```

**Response:**
```json
{
  "routes": [{
    "distance": 112500,
    "duration": 6840,
    "geometry": {
      "coordinates": [[79.86, 6.92], [80.22, 6.05], ...]
    }
  }]
}
```

### Implementation
```dart
// lib/services/routing_service.dart
class RoutingService {
  Future<List<LatLng>> getRoute(LatLng from, LatLng to) async {
    // Returns list of LatLng points for the route polyline
  }
}
```

---

## 4. Geolocator (Device GPS)

### Request Permissions
```dart
LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
}
```

### Stream Real-time Position
```dart
// lib/screens/active_trip_screen.dart
Geolocator.getPositionStream(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5, // Update every 5 meters
  ),
).listen((Position position) {
  final speedKmH = position.speed * 3.6; // m/s → km/h
  final latLng = LatLng(position.latitude, position.longitude);
});
```

---

## 5. Flutter TTS (Text-to-Speech)

```dart
final tts = FlutterTts();
await tts.setLanguage("en-US");
await tts.setSpeechRate(1.0);   // Normal speed
await tts.setPitch(1.5);        // Higher = more feminine
await tts.speak("Hello, I am LITA!");
await tts.stop();
```

### Voice Selection (Female)
```dart
final voices = await tts.getVoices as List;
// Filter for voices containing 'female', 'zira', 'karen', etc.
await tts.setVoice({"name": voiceName, "locale": "en-US"});
```

---

## 6. Speech to Text

```dart
final stt = SpeechToText();
bool enabled = await stt.initialize();

await stt.listen(
  onResult: (result) {
    final words = result.recognizedWords;
    final isFinal = result.finalResult; // True when user stops speaking
  },
  listenFor: Duration(seconds: 30),
  pauseFor: Duration(seconds: 3),   // Auto-stop after 3s silence
);

await stt.stop();
bool isListening = stt.isListening;
```

---

## 7. Firebase Services

### Authentication
```dart
// Google Sign-In
final userCredential = await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
final user = FirebaseAuth.instance.currentUser;
```

### Firestore
```dart
// Write trip data
await FirebaseFirestore.instance.collection('trips').add({
  'userId': user.uid,
  'tripName': 'Weekend in Galle',
  'distance': 112.5,
  'date': Timestamp.now(),
});

// Read trips
final snapshot = await FirebaseFirestore.instance
  .collection('trips')
  .where('userId', isEqualTo: user.uid)
  .get();
```

---

## 8. OpenStreetMap Tile Server

### Configuration in flutter_map
```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.example.ceylon_explorer',
)
```

**Attribution:** All maps must display "© OpenStreetMap contributors"

---

## Error Codes & Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `LITA: 403 Forbidden` | Invalid Gemini API key | Check `dart_defines.json` key starts with `AIzaSy` |
| `LITA: connection closed` | Unstable network | Auto-retries 2x; switch to WiFi |
| `Location permission denied` | User denied GPS | Show settings dialog |
| `STT not initialized` | Mic permission denied | Request mic permission |
| `Route not found` | OSRM unreachable | Check internet; fallback to straight-line |
