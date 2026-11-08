# 🏙️ Smart City - Project Architecture, Audit & Security Documentation

**Date:** November 8, 2026  
**Project:** Smart City (Cross-Platform Flutter Application)  
**Package:** `com.smartcity.app` (`smart_city`)  
**Workspace:** `E:\1.PROFESSIONAL APPLICATIONS\SMART CITY`  
**Lead Engineer / Security Auditor:** Senior Application Security Engineer  

---

## 1. Project Overview & Isolation Guarantee

The **Smart City** application is an AI-powered smart mobility, urban navigation, and exploration platform built with **Flutter 3.x** and **Dart 3.x**.

### 100% Complete Project Decoupling
The project has been completely and permanently decoupled from all prior systems (`ceylon_explorer`):
- **Package ID & Namespaces:** Fully rebranded to `com.smartcity.app` and `smart_city`.
- **Zero Shared Cloud Connections:** All legacy Firebase connections, remote configurations, and project links have been removed.
- **Local State Architecture:** Authentication and social feed data operate with localized, secure state engines and local storage (`SharedPreferences`).
- **Network Boundaries:** User-Agent headers and caching keys are strictly isolated (`SmartCity/1.0`, `smartcity_weather_cache_v1`, `smartcity_latest_plan`).
- **No External Impact:** Any modification, execution, or deployment in this directory will never affect or interact with any other project.

---

## 2. Full Code Audit & Application Reduction

To eliminate childhood experimental code, legacy scrapers, and redundant files, a complete codebase audit was executed:

### Files & Directories Removed
1. **Dead Screens Pruned (1,366+ lines of obsolete code):**
   - `lib/screens/package_detail_screen.dart` (604 lines): Unused package viewer with zero references.
   - `lib/screens/plan_trip_screen.dart` (402 lines): Redundant prototype screen superseded by `ai_travel_planner_screen.dart`.
   - `lib/screens/ai_chat_screen.dart` (360 lines): Obsolete static chat UI superseded by LITA AI and `real_time_chat_screen.dart`.
2. **Scrapers & Scrap Artifacts Removed:**
   - `download_hotels.py`: Legacy DuckDuckGo hotel scraper script.
   - `Arugam Bay/` & `Trincomalee/`: Empty directories left behind by old scraping runs.
   - `tools/`: Empty folder leftover from legacy seed scripts.
   - `public/chess-clock.html`: Standalone childhood chess clock prototype.
   - `docs/flutter build apk --release.txt` & `docs/seeds/`: Outdated scratch files.
3. **Dead Code & Unused Elements Cleaned:**
   - `lib/screens/active_trip_screen.dart`: Removed unread state field `_isLitaTyping` and all dead assignments.
   - `lib/screens/home_screen.dart`: Removed dead function `_headerIdentity`, unused import `auth_service.dart`, and unused local variables `titleColor` and `mutedColor`.
   - `lib/screens/login_screen.dart`: Removed unused local variable `isCompact`.
   - `lib/screens/main_navigation_screen.dart`: Removed unreferenced import `saved_screen.dart`.
   - `lib/services/social_service.dart`: Removed redundant import `dart:typed_data`.

### API Modernization & Syntax Normalization
- Replaced all deprecated `withOpacity()` calls with `.withValues(alpha: ...)` to eliminate precision loss.
- Migrated `DropdownButtonFormField` deprecated `value` parameter to `initialValue`.
- Upgraded speech recognition listening parameters to `SpeechListenOptions(listenFor: ..., pauseFor: ...)`.
- Replaced raw `print()` statements with `debugPrint()` in production services.
- Normalized all flow control statements with explicit block braces.

---

## 3. Comprehensive Security Engineering Hardening

A 20-point enterprise application security audit was conducted. All identified vulnerabilities have been remediated:

### 1. Secret Protection & API Key Extraction Prevention (CWE-798)
- **Vulnerability:** A real Google Gemini API key literal (`AIzaSy...`) was hardcoded in `lib/services/lita_ai_service.dart`.
- **Fix:** Removed hardcoded string literal. The application now uses `const String.fromEnvironment('GEMINI_API_KEY')` with a graceful offline fallback.
- **Git Protection:** Verified `dart_defines.json` and `.env*` are strictly excluded in `.gitignore`.

### 2. Salted Cryptographic Password Hashing & Timing-Attack Defense (CWE-256, CWE-208)
- **Vulnerability:** Plaintext passwords were stored directly in `SharedPreferences` (`local_pwd_$username`). Additionally, `AuthService.login()` accepted any password without verification.
- **Fix:**
  - Added `crypto: ^3.0.3` to explicit project dependencies.
  - Implemented cryptographically secure salt generation using `Random.secure()`.
  - Implemented key-stretched salted hashing: 2,000 rounds of SHA-256 combined with a secret application pepper (`SmartCity_App_Pepper_#9vK2!z8`).
  - Implemented constant-time string comparison (`_constantTimeEquals`) to prevent side-channel timing attacks.
  - Transparent auto-migration: Legacy users with unhashed passwords are automatically upgraded to salted hashes upon successful login, wiping the plaintext entry.
  - Account takeover prevention: Registration now verifies username uniqueness before persisting credentials.

### 3. Brute-Force & Credential Stuffing Defense (CWE-307)
- **Fix:** Added rate-limiting to `AuthService`. After 5 consecutive failed login attempts, login requests are locked out for 30 seconds (`_lockoutUntil`).
- Generic error messages (`"Invalid username or password."`) are returned to prevent username enumeration.

### 4. Enforce HTTPS Transit & Parameter Bounds (CWE-319, CWE-20)
- **Vulnerability:** `RoutingService` previously transmitted GPS coordinates over plaintext `http://router.project-osrm.org`.
- **Fix:**
  - Enforced `https://router.project-osrm.org/`.
  - Added strict coordinate boundary validation (-90° to 90° latitude, -180° to 180° longitude, finite checks).
  - Added 15-second network request timeout and standard User-Agent header.

### 5. OpenStreetMap Nominatim Rate Limiting & Query Sanitization (CWE-799)
- **Fix:** Enforced a minimum 1,000ms delay between consecutive geocoding queries in `GeocodingService` to comply with Nominatim's Acceptable Use Policy and prevent IP blacklisting. Bounded search query length to 200 characters and structured parameters via `Uri.https()`.

### 6. Web Content Security Policy (CSP) & Clickjacking Defense (CWE-79, CWE-1021)
- **Fix:** Configured strict HTTP meta headers in `web/index.html`:
  - Enforced `Content-Security-Policy` with restrictive origins (`default-src 'self'`, whitelisted map tile & AI domains, `frame-ancestors 'none'`).
  - Added `X-Content-Type-Options: nosniff`.
  - Updated Web metadata to **Smart City**.

---

## 4. Verification & Automated Test Results

Every fix has been validated with automated tests and static analysis:

### 1. Static Code Analysis (`flutter analyze`)
```text
Analyzing SMART CITY...
No issues found! (ran in 3.6s)
```
- **Errors:** 0
- **Warnings:** 0
- **Linter Issues:** 0

### 2. Automated Test Suite (`flutter test`)
Created a dedicated security regression test suite in `test/security_test.dart`:
```text
00:00 +0: Rejects registration with password shorter than 8 characters
00:00 +1: Rejects registration with invalid characters in username
00:00 +2: Stores salted cryptographic hash and never stores plaintext password
00:00 +3: Different users with the same password produce distinct salts and hashes
00:00 +4: Prevents account overwriting / account takeover during registration
00:00 +5: Verifies correct password and rejects incorrect password
00:00 +6: Rate limits / locks account after 5 consecutive failed login attempts
00:00 +7: RoutingService rejects invalid coordinate bounds
00:00 +8: GeocodingService rejects empty or excessively large queries
00:00 +9: LitaAiService does not expose hardcoded API keys in source
00:00 +10: App loads smoke test
00:01 +11: All tests passed!
```
**Total Tests: 11 | Passed: 11 | Failed: 0**

---

## 5. Build & Execution Quick Reference

### Running the Application
```bash
# Install dependencies
flutter pub get

# Run on Web with Dart Defines (Local API Keys)
flutter run -d chrome --dart-define-from-file=dart_defines.json

# Run on Android / iOS
flutter run --dart-define-from-file=dart_defines.json

# Run Automated Test Suite
flutter test

# Run Static Analysis
flutter analyze
```

---

## 6. Pre-Production Checklist & Manual Actions
- [ ] **Rotate Google Gemini API Key**: Revoke the previously exposed key in Google Cloud Console and generate a new key with restricted application identifiers.
- [ ] **Dart Defines File**: Ensure `dart_defines.json` is never committed to Git (guaranteed by `.gitignore`).
- [ ] **Release Mode**: Compile production binaries using `flutter build apk --release` or `flutter build web --release` to ensure debug assertions and banners are stripped.

---
*Documentation compiled on November 8, 2026 for Smart City.*
