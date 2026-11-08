# Google Play Metadata Rejection Remediation Guide

This guide is for resolving the Google Play rejection:

- Policy area: Metadata
- Affected release: Version code 6

## 1) What is most likely blocking your release

Google flagged metadata quality, which usually means one or more of these in Play Console listing assets:

- Misleading claims (for example: "best", "No.1", "official", "guaranteed")
- Keyword stuffing in title or short description
- Features mentioned in listing but not clearly available in app
- Screenshots or promo images with exaggerated claims or heavy marketing text
- Anonymous or unattributed testimonials in full description
- Poorly formatted, repetitive, or non-descriptive text

## 2) Immediate fixes to apply

### A. Title and in-app naming consistency

Use the same human-readable brand name across app and listing:

- Ceylon Explorer

### B. Remove risky language from listing

Delete any words/phrases like these if present:

- best, No.1, #1, top, guaranteed, 100% accurate, official
- "users say..." or unnamed testimonials
- any feature claim that cannot be demonstrated in the app

### C. Keep description factual and feature-based

Describe only what the app does today:

- itinerary planning
- map/location-based exploration
- hotel browsing
- traveler feed, chat, saved places

### D. Screenshot rules

Use only real in-app screens from production build.
Do not include:

- fake ratings, fake badges, fake awards
- pricing promises not shown in app
- text overlays that claim unsupported capabilities

## 3) Safe listing copy you can paste in Play Console

## App title (max 30 chars)

Ceylon Explorer

## Short description (max 80 chars)

Plan Sri Lanka trips with maps, stays, itineraries, and traveler updates.

## Full description (policy-safe draft)

Ceylon Explorer helps you plan and manage travel in Sri Lanka with practical tools for discovery, planning, and trip organization.

Key features:

- Discover destinations across Sri Lanka with photos and travel context
- Build trip itineraries and organize plans in one place
- Explore maps and location-aware travel information
- Browse stays and travel-related details
- Save places and review them later
- Connect through traveler posts and chat features

Ceylon Explorer is designed to support trip planning workflows from inspiration to on-trip reference.

Notes:

- Some features may depend on device permissions (such as location, photos, and notifications).
- Availability of certain content may vary by user activity and network connection.

## 4) Play Console step-by-step (from beginning)

1. Open Play Console.
2. Go to your app: Ceylon Explorer.
3. Open Store presence > Main store listing.
4. Replace Title, Short description, Full description with compliant text.
5. Remove any anonymous testimonials and superlative claims.
6. Re-upload screenshots from current app build only.
7. Ensure screenshots match actual features in the submitted release.
8. Open Policy status and re-check warning details.
9. Go to App content and verify declarations are complete.
10. Go to Data safety and ensure collected data declarations match real behavior.
11. Go to Release > Production (or Closed testing track), create new release.
12. Upload new AAB with incremented version code.
13. Add release notes (factual, short, no marketing claims).
14. Review and roll out to review.

## 5) If app targets children

If your target audience includes children, review and complete Families Policy requirements in App content.
If not for children, keep target audience set appropriately and avoid child-directed metadata.

## 6) Pre-submit verification checklist

- Title is clean and not keyword-stuffed.
- Description has no testimonials and no unverifiable claims.
- Screenshots are real, recent, and feature-accurate.
- Icon and promo graphics are brand-safe and non-misleading.
- Data safety form is consistent with app behavior.
- Privacy policy URL is reachable and current.
- New release has incremented version code.

## 7) Escalation path if rejected again

If rejected again, submit appeal with:

- exact text before vs after changes
- screenshot set before vs after
- explanation that unsupported claims/testimonials were removed
- confirmation that listing now reflects only implemented features
