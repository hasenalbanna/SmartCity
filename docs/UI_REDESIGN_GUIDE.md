# Smart City: UI Redesign Guide (Senior UI Designer Playbook)

Date: 2026-11-08 | Stack: Flutter 3 (Web, Android, iOS) | Scope: whole app

A step-by-step method for redesigning the entire UI. It is written so a beginner can follow it and the result looks like senior work.

---

## 1. Audit: what is wrong today

| # | Problem | Where |
|---|---------|-------|
| 1 | Colors and sizes hard-coded in every screen (`Color(0xFF2563EB)`, `fontSize: 12`) | all 30+ screens |
| 2 | Light/dark handled by `isDark ? a : b` in each widget | everywhere |
| 3 | Mixed visual languages: black "liquid" Home vs. flat white Reports | Home vs. Reports/Bus |
| 4 | Travel-app leftovers (hotels, SIM cards, trip journal, guides) inside a Smart City app | `lib/screens/` |
| 5 | Inconsistent spacing (6, 10, 12, 14, 16, 18, 20 mixed) | all |
| 6 | Footer has 5 tabs, but most features are hidden in a drawer/shortcuts | `main_navigation_screen.dart` |
| 7 | No loading, empty or error states in most lists | issues, bus, feed |
| 8 | Accessibility: tiny 10-11px labels, low-contrast grey, no semantics | all |

**Step 1 for you:** screenshot every screen, put them in one board (Figma or a folder), and mark every inconsistency.

---

## 2. Decide the product direction first

1. **One-sentence goal:** "Citizens report problems, track buses and get city alerts in 2 taps."
2. **Delete or hide non-city screens** (hotels, SIM, guides, trip journal, payment). Fewer screens means a better UI.
3. **Pick 4-5 primary tabs only:**

| Tab | Purpose |
|-----|---------|
| Home | City status, alerts, quick actions |
| Report | Issue map and reporting wizard (main feature) |
| Transit | Live bus tracking |
| Alerts | AI alerts, notifications, community feed |
| Me | Profile, settings, language |

---

## 3. Build a design system (do this BEFORE touching screens)

Create `lib/theme/`:

```
lib/theme/
  app_colors.dart
  app_spacing.dart
  app_typography.dart
  app_radius.dart
  app_theme.dart      // ThemeData light + dark built from the files above
```

### 3.1 Color tokens (semantic, not literal)

| Token | Light | Dark | Use |
|-------|-------|------|-----|
| `primary` | #2563EB | #60A5FA | main buttons, active tab |
| `onPrimary` | #FFFFFF | #0B1220 | text on primary |
| `surface` | #FFFFFF | #151A23 | cards |
| `background` | #F6F8FB | #0B0F16 | page |
| `outline` | #E5E7EB | #263041 | borders |
| `textPrimary` | #0F172A | #F1F5F9 | headings |
| `textSecondary` | #64748B | #94A3B8 | captions |
| `success` | #16A34A | #4ADE80 | resolved |
| `warning` | #F59E0B | #FBBF24 | in progress |
| `danger` | #DC2626 | #F87171 | pending, SOS |

Rules:
- Use one brand color, plus status colors. Nothing else.
- Check contrast: body text must be at least 4.5:1 (WCAG AA).
- Replace `Color(0x...)` in widgets with `Theme.of(context).colorScheme.*` or `AppColors.*`.

### 3.2 Spacing scale (8-pt grid)

```dart
class AppSpace { static const xs=4.0, sm=8.0, md=12.0, lg=16.0, xl=24.0, xxl=32.0; }
```
Only these values are allowed. Page padding is `lg` (16). Gap between cards is `md` (12).

### 3.3 Typography (one family, 6 styles)

| Style | Size / weight | Use |
|-------|---------------|-----|
| display | 28 / 800 | page titles |
| title | 20 / 700 | section headers |
| subtitle | 16 / 600 | card titles |
| body | 14 / 400 | normal text |
| caption | 12 / 500 | meta, badges |
| button | 15 / 600 | buttons |

Bundle **Inter** locally in `assets/fonts/` and declare it in `pubspec.yaml`. Do not fetch fonts at runtime (this is what broke the web build earlier). Minimum text size is 12.

### 3.4 Shape, elevation, motion
- Radius: `sm 8`, `md 12`, `lg 20`, `pill 999`.
- Elevation: cards use a 1px outline and no heavy shadow. Only floating buttons and sheets get a soft shadow.
- Motion: 200-300 ms, `Curves.easeOutCubic`. Animate only meaning (selection, loading, new data).

### 3.5 Theme file
Build both themes from `ColorScheme`, then set `appBarTheme`, `cardTheme`, `inputDecorationTheme`, `elevatedButtonTheme`, `navigationBarTheme`, `chipTheme`, `bottomSheetTheme`, `dialogTheme` once. After this, screens contain almost no styling.

---

## 4. Reusable component library

Create `lib/widgets/ui/` and build each component once:

| Component | Replaces |
|-----------|----------|
| `AppButton` (primary / secondary / ghost, loading state) | 40+ custom `ElevatedButton`s |
| `AppCard` | repeated `Container` + `BoxDecoration` |
| `StatusChip` (pending / progress / resolved) | status pills in Reports |
| `SectionHeader(title, action)` | "Recent Reports / View All" |
| `AppTextField` | custom input containers in the wizard |
| `EmptyState(icon, title, action)` | blank lists |
| `ErrorState(retry)` | silent failures |
| `SkeletonBox` / `SkeletonList` | spinners |
| `AppScaffold` | page padding, SafeArea, background |
| `AppBottomSheet` | issue details, filters, voice modal |
| `StatTile` | numbers on Home (open issues, buses live) |

Rule: **no screen may build its own button, card or chip.**

---

## 5. Navigation and layout

1. Use Material 3 `NavigationBar` (5 destinations max) instead of the custom blurred footer. It gives accessibility and ripple behavior for free.
2. Use a floating "+ Report" action on Home and Reports (one primary action per screen).
3. Responsive breakpoints:
   - below 600 px: bottom nav, single column
   - 600-1024 px: `NavigationRail`, two columns
   - above 1024 px: side drawer, max content width 1100 px, centered
4. Wrap web pages in `ConstrainedBox(maxWidth: 1100)`. This fixes the "stretched phone UI on desktop" look.

---

## 6. Screen-by-screen redesign plan

### Home
- Greeting + city weather chip.
- A row of 3 `StatTile`s: open reports, buses live, active alerts.
- Quick actions grid (Report issue, Track bus, Voice report, Emergency).
- "Nearby issues" mini-map (OSM tiles) + the 3 latest reports.
- Remove: Explore Sri Lanka map, AI Insights cards for tourism, travel shortcuts.

### Reports (community_issues + wizard)
- Map on top (40 %), draggable sheet below (already close to the design). Keep.
- Replace the status button triplet with one `PopupMenu` ("Change status").
- Filter chips (All / Pending / In progress / Resolved) instead of the "View All" text.
- Wizard: step indicator with labels (Category, Location, Details), a sticky bottom "Continue" button, and inline validation.
- AI Triage card: collapsed by default and expandable, to avoid overload.

### Transit (smart bus)
- Full-bleed map, bottom sheet with route chips, ETA list, occupancy badge.
- Follow-bus toggle, and a "Next stop in X min" banner.

### Alerts
- Merge notifications and community feed. Group by Today / Earlier. Severity color on the leading edge.

### Profile / Settings
- Avatar header, grouped `ListTile` sections (Account, Language, Appearance, Security, About).
- Language switch in one place (not repeated as the fake "EN" pill).

### Login
- Single column, brand mark, large inputs, a clear primary button, and "Continue as guest".

### Screens to retire or hide
`hotel_*`, `sim_recommendation`, `guides`, `guide_profile`, `trip_*`, `payment`, `world_clock`, `schedule_calendar`, `active_trip`, `drive_setup`, `ai_travel_planner`, `chat_*`, `real_time_chat`. Move them behind a feature flag or delete them (also reduces app size).

---

## 7. States every screen must handle

| State | Pattern |
|-------|---------|
| Loading | skeleton placeholders (never a bare spinner) |
| Empty | icon + one line + primary action |
| Error | message + Retry |
| Offline | top banner, show cached data |
| Success | snackbar with Undo where possible |

---

## 8. Accessibility checklist
- Tap targets at least 48x48.
- Contrast at least 4.5:1 for text, 3:1 for icons and borders.
- `Semantics` labels on icon-only buttons and map markers.
- Respect system text scale (test 1.3x).
- Never rely on color alone: status chips also carry text and an icon.
- Support reduced motion (`MediaQuery.disableAnimations`).

---

## 9. Implementation order (safe, incremental)

| Phase | Work | Done when |
|-------|------|-----------|
| 1 | Add `lib/theme/*`, local Inter font, wire `app_theme.dart` into `main.dart` | app runs with new theme |
| 2 | Build `lib/widgets/ui/*` components | showcase page renders all |
| 3 | Replace navigation with `NavigationBar` and responsive shell | tabs work on mobile/web |
| 4 | Migrate Reports + Wizard | no hard-coded colors left in them |
| 5 | Migrate Transit, then Home | same |
| 6 | Migrate Alerts, Profile, Settings, Login | same |
| 7 | Retire travel screens | `flutter analyze` is clean |
| 8 | Accessibility and responsive pass | checklist in section 8 is green |
| 9 | Golden tests for key screens | tests pass |

Commit after each phase. Run `flutter analyze` and `flutter test` each time.

### Helpful commands
```bash
# find hard-coded colors still to migrate
Select-String -Path lib -Recurse -Pattern "Color\(0x" | Measure-Object
# find hard-coded font sizes
Select-String -Path lib -Recurse -Pattern "fontSize:" | Measure-Object
```
Goal: drive both counts toward zero outside `lib/theme/`.

---

## 10. Senior designer habits
1. Design the system first and screens second.
2. Fewer colors, fewer sizes, fewer components.
3. Hierarchy: one clear primary action and one clear title per screen.
4. Whitespace is a feature. When in doubt, add 8 px.
5. Test on a real small phone and a wide desktop window.
6. Review every screen in light and dark, at 1.0x and 1.3x text.
7. Get feedback early from 3 real citizens.

## 11. Recommended references
- Material 3 guidelines: m3.material.io
- Flutter theming: docs.flutter.dev/cookbook/design/themes
- WCAG contrast checker: webaim.org/resources/contrastchecker
- Inspiration: Citizen app, Google Maps transit, GOV.UK design system

---

## 12. Complete 24-Page System & UI Architecture Directory (`SmartCityDrawer`)

All **24 system pages and interactive modules** across the application are organized into **6 Architectural Categories** inside the **Left-Side Category Toggle Bar (`lib/widgets/smart_city_drawer.dart`)**, accessible from the **3-line Hamburger Menu Button (`☰`)** on `HomeScreen`, `CommunityIssuesScreen`, `SmartBusTrackingScreen`, `ProfileScreen`, and `MainNavigationScreen`:

| Category | # | Page / Module Name | Source File | Description |
|----------|---|--------------------|-------------|-------------|
| **1. Core Civic & SOS** | 1 | **Smart City Home Dashboard** | `lib/screens/home_screen.dart` | Live telemetry, Explore weather cover card, AI Insights & Instagram citizen feed |
| **1. Core Civic & SOS** | 2 | **Citizen Issue & Disaster Reports** | `lib/screens/community_issues_screen.dart` | 2-Mode Hub: Local Municipal Issues & Falcon AI Voice Guardian |
| **1. Core Civic & SOS** | 3 | **4-Step Issue Wizard & Falcon SOS** | `lib/screens/report_issue_wizard_screen.dart` | AI Vision hazard intake, GPS pin & `"Hey Falcon, wake up"` voice dispatch |
| **1. Core Civic & SOS** | 4 | **Civic Alerts & Weather Radar** | `lib/screens/civic_alerts_screen.dart` | 117 DMC monsoon warnings, flood telemetry & council work orders |
| **1. Core Civic & SOS** | 5 | **System Notifications & Inbox** | `lib/screens/system_feature_screens.dart` | Real-time work order updates & travel reminders (`NotificationsScreen`) |
| **2. Smart Transit & Map** | 6 | **Smart Bus Live Radar (Routes 22 & 48)** | `lib/screens/smart_bus_tracking_screen.dart` | Real-time bus GPS telemetry, seat occupancy & ETA countdown |
| **2. Smart Transit & Map** | 7 | **Interactive Island & Smart City Map** | `lib/screens/system_feature_screens.dart` | Full-screen OpenStreetMap with UNESCO heritage & civic issue pins (`MapScreen`) |
| **2. Smart Transit & Map** | 8 | **Live OSRM Route & Drive Engine** | `lib/screens/itinerary_screen.dart` | Multi-stop road routing, vehicle speed & fuel cost estimator |
| **3. Ceylon Explorer & AI** | 9 | **Explore Smart Regions & Provinces** | `lib/screens/explore_screen.dart` | Weather cover card, Must-See landmarks & 9 Sri Lanka provinces |
| **3. Ceylon Explorer & AI** | 10 | **Ceylon Explorer — AI Trip Planner** | `lib/screens/itinerary_screen.dart` | Unified 4-in-1 Route Engine, Hotels, SIM Advisor & Expense Splitter |
| **3. Ceylon Explorer & AI** | 11 | **AI Travel Itinerary Generator** | `lib/screens/ai_travel_planner_screen.dart` | Custom day-by-day Sri Lanka itinerary by USD budget & interests |
| **3. Ceylon Explorer & AI** | 12 | **Find Your Perfect Stay (Hotels)** | `lib/screens/hotel_booking_screen.dart` | Booking.com-style hotel explorer, interactive map & `HotelDetailScreen` |
| **3. Ceylon Explorer & AI** | 13 | **AI SIM Card & Coverage Advisor** | `lib/screens/sim_recommendation_screen.dart` | Dialog, Mobitel, Airtel & Hutch tourist eSIM/5G coverage matcher |
| **3. Ceylon Explorer & AI** | 14 | **Certified Local Tour Guides** | `lib/screens/system_feature_screens.dart` | Verified cultural, wildlife safari, surfing & hiking specialists (`GuidesScreen`) |
| **4. Social, Chat & Logs** | 15 | **Locals by AI — Instagram Feed** | `lib/screens/system_feature_screens.dart` | Full-screen citizen stories, photo uploads, likes & comments (`CommunityFeedScreen`) |
| **4. Social, Chat & Logs** | 16 | **Realtime Citizen & Guide Chat** | `lib/screens/system_feature_screens.dart` | Direct messaging with municipal dispatch & verified guides (`ChatListScreen`) |
| **4. Social, Chat & Logs** | 17 | **Trip Journal & Field Memories** | `lib/screens/system_feature_screens.dart` | Personal travel diary, route photos & distance archive (`TripJournalScreen`) |
| **4. Social, Chat & Logs** | 18 | **Saved Trips, Places & Stays** | `lib/screens/system_feature_screens.dart` | Bookmarked routes, heritage landmarks & luxury stays (`SavedScreen`) |
| **5. Time & Schedule** | 19 | **Travel & Civic Schedule Calendar** | `lib/screens/system_feature_screens.dart` | 7-day timeline for excursions, trains & ward inspections (`ScheduleCalendarScreen`) |
| **5. Time & Schedule** | 20 | **World Clock & Travel Timer** | `lib/screens/system_feature_screens.dart` | Colombo (UTC+5:30) multi-zone clock & excursion timer (`WorldClockScreen`) |
| **6. Account & Control** | 21 | **Citizen Profile & Civic Hub** | `lib/screens/profile_screen.dart` | Digital Citizen ID, Smart Transit Pass wallet & civic evidence vault |
| **6. Account & Control** | 22 | **Settings & Smart City Control Center** | `lib/screens/settings_screen.dart` | 2-column 11-Language grid, 6-Currency converter, Theme & Falcon AI calibration |
| **6. Account & Control** | 23 | **Smart City Pro & Revenue Storefront** | `lib/widgets/premium_store_modal.dart` | Falcon Shield+ Pro, Insurance Claim PDFs & Sponsored Map Pins |
| **6. Account & Control** | 24 | **Emergency SOS Beacon & Hotlines** | `lib/widgets/emergency_beacon_modal.dart` | 1990 Suwa Seriya, 117 DMC & instant GPS distress beacon |


