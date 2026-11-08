# Ceylon Explorer — Product Requirements Document (PRD)

**Document Version:** 1.0
**Status:** Approved
**Date:** August 2026
**Owner:** Ceylon Explorer Product Team

---

## 1. Product Overview

### 1.1 Vision
To be the **#1 digital travel companion for Sri Lanka** — making every journey smarter, safer, and more memorable through AI.

### 1.2 Mission
Empower every traveler in Sri Lanka — tourist or local — with intelligent tools to explore, navigate, book, and share their experiences through a single, beautifully designed app.

### 1.3 Problem Statement
Travelers in Sri Lanka face:
- **Fragmentation:** Using 4–6 different apps for maps, bookings, guides, and planning
- **Generic tools:** Google Maps and TripAdvisor are global, not Sri Lanka-specific
- **Loneliness:** Solo travelers have no companion during long drives and explorations
- **Language barriers:** International tourists struggle with local information

### 1.4 Solution
A single, deeply local, AI-first app that covers the entire travel journey from planning to sharing.

---

## 2. User Personas

### Persona 1: International Tourist — "Sarah"
- **Age:** 28 | UK | Backpacker
- **Goals:** Discover authentic Sri Lanka, navigate safely, find good hotels
- **Pain Points:** Doesn't know local roads, language barrier, overwhelmed by choices
- **How Ceylon Explorer Helps:** AI guides, local-specific maps, LITA for company during drives

### Persona 2: Local Traveler — "Kasun"
- **Age:** 22 | Colombo | Weekend Explorer
- **Goals:** Plan affordable weekend trips, share experiences, find hidden gems
- **Pain Points:** Hard to find trip inspiration, no easy planning tools
- **How Ceylon Explorer Helps:** AI itinerary planner, community feed, trip journal

### Persona 3: Travel Agent — "Priya"
- **Age:** 35 | Kandy | Tour Operator
- **Goals:** Create itineraries for clients, manage guide bookings
- **Pain Points:** Manual, time-consuming planning process
- **How Ceylon Explorer Helps:** AI itinerary export (PDF), guide management features

---

## 3. Feature Requirements

### 3.1 Core Features (MVP — v1.0)

#### FR-001: User Authentication
- **Must Have:** Google Sign-In via Firebase Auth
- **Must Have:** Email/password registration
- **Must Have:** Profile creation with name and photo

#### FR-002: Home Screen
- **Must Have:** Search bar for destinations
- **Must Have:** "Start Drive" button with car animation
- **Must Have:** Featured places carousel
- **Must Have:** Quick-access category buttons

#### FR-003: Explore
- **Must Have:** Browse all 9 Sri Lanka provinces
- **Must Have:** Place detail pages with photos, description, and location
- **Must Have:** Save places to favorites
- **Should Have:** Province-based filtering

#### FR-004: Start Drive / GPS Navigation
- **Must Have:** Live GPS location tracking (Geolocator)
- **Must Have:** Vehicle type selection (Car, Bus, Train, Flight, Lorry, Tuk-tuk, Cycle, Walk)
- **Must Have:** Destination search with autocomplete (Nominatim)
- **Must Have:** Route display on interactive map (flutter_map + OSRM)
- **Must Have:** Real-time vehicle marker movement
- **Must Have:** Speedometer display (km/h)
- **Must Have:** Draggable picture-in-picture minimap
- **Must Have:** Save Trip dialog (name + rating)
- **Should Have:** Recent destinations quick-select

#### FR-005: LITA AI Companion
- **Must Have:** Voice listening (speech_to_text)
- **Must Have:** AI response generation (Google Gemini 1.5 Flash)
- **Must Have:** Voice output (flutter_tts)
- **Must Have:** Personalized greeting (asks user's name on first use)
- **Must Have:** Pink pulse wave animation while speaking
- **Must Have:** Red pulse wave animation while listening
- **Must Have:** Auto-listen after finishing speaking
- **Must Have:** Text input fallback

#### FR-006: Trip History
- **Must Have:** Save trips automatically after drive
- **Must Have:** Instagram-style grid on profile screen
- **Must Have:** Full trip summary page (name, route, distance, time, max speed, rating)
- **Should Have:** Trip journal entry

#### FR-007: Hotel Booking
- **Must Have:** Browse hotel listings
- **Must Have:** Hotel detail pages
- **Must Have:** Booking flow with date selection
- **Should Have:** Payment processing

#### FR-008: Local Guides
- **Must Have:** Guide listing and profiles
- **Must Have:** Booking request
- **Should Have:** Real-time chat with guide

#### FR-009: AI Itinerary Planner
- **Must Have:** Input: airport, budget, days, interests
- **Must Have:** AI-generated day-by-day itinerary
- **Must Have:** PDF export
- **Should Have:** Save to calendar

#### FR-010: Community
- **Must Have:** Social feed (posts, likes)
- **Must Have:** Real-time chat
- **Should Have:** Travel groups

---

## 4. Non-Functional Requirements

| Requirement | Target |
|-------------|--------|
| App Load Time | < 3 seconds on 4G |
| Map Rendering | < 2 seconds |
| LITA Response Time | < 3 seconds (network dependent) |
| Crash Rate | < 0.1% of sessions |
| Supported OS | Android 8.0+, iOS 14+, Modern Browsers |
| Accessibility | WCAG 2.1 AA compliance |
| Dark Mode | Full support |

---

## 5. Design Requirements

- **Color Theme:** Black/White with accent colors — strict Black buttons in light mode, White buttons in dark mode
- **Typography:** Google Fonts (modern sans-serif)
- **Animations:** Micro-animations throughout (car animation, pulse waves, transitions)
- **Maps:** OpenStreetMap (free, no usage limits)
- **Style:** Premium, glassmorphism, dark-mode first

---

## 6. Success Metrics

| Metric | 3-Month Target | 12-Month Target |
|--------|---------------|-----------------|
| Downloads | 5,000 | 50,000 |
| Daily Active Users | 500 | 8,000 |
| Avg Session Length | 8 min | 12 min |
| Trip Saves Per User | 2 | 10 |
| LITA Interactions/Day | 200 | 5,000 |
| App Store Rating | 4.3+ | 4.5+ |
| Hotel Booking Revenue | $2,000/mo | $25,000/mo |

---

## 7. Out of Scope (v1.0)

- Offline map downloads
- Multi-language support (Phase 2)
- Augmented Reality points-of-interest
- Public transport timetable integration
- Ride-hailing integration
