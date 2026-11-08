# Play Store Pre-Release Screen Checklist (Contract-Aligned)

Use this checklist to verify each screen against the current Firestore/Storage contract before Play Store submission.

Status legend:

- [ ] not checked
- [x] checked and passed
- [!] checked with issue found

## Global Contract Checks

- [x] User can sign in/out with unique username flow.
- [x] Firestore reads/writes only use fields defined in docs/firestore-data-model.md.
- [!] App handles permission denied states (location, camera/gallery) without crashes.
- [x] Empty-state UX exists where collection data may be empty.
- [x] No screen depends on mock social/chat data.
- [x] All social writes are from authenticated users.
- [!] Network failure messages are user friendly and non-blocking.

## Navigation Shell

Main navigation and auth entry:

- [x] login_screen.dart: login/register/reset password, username uniqueness, error states.
- [x] main_navigation_screen.dart: all tabs open and preserve state.

## Social and Discovery Screens

### home_screen.dart

- [x] Locals by AI section loads from posts collection.
- [x] Empty feed message shown when posts are unavailable.
- [x] Open Feed action navigates to community feed.

### explore_screen.dart

- [x] Align Traveler Uploads button opens community feed.
- [x] Explore features still render if social collections are empty.
- [!] Weather/province cards still render when offline.

### community_feed_screen.dart

- [x] Create post uploads images to Storage user_posts/{uid}/.
- [x] New post writes all required posts fields.
- [x] Like updates likedBy array and creates notification.
- [x] Comment writes post_comments and increments commentsCount.
- [x] Save/unsave writes users/{uid}/saved_posts/{postId}.
- [!] Share action works on Android/Web target behavior.
- [x] Feed ordering follows algorithm score fallback with timestamps present.

### chat_list_screen.dart

- [x] Traveler search by username/displayName works.
- [x] Follow/unfollow updates following and followers subcollections.
- [x] Location sharing toggle updates users/{uid} fields.
- [x] Distance display degrades gracefully if location is unavailable.

### real_time_chat_screen.dart

- [x] Chat room ID is sorted uidA_uidB.
- [x] Sending message creates/updates chat_rooms and messages subcollection.
- [!] Incoming messages appear in real time.
- [x] Chat notification is written for peer user.

### notifications_screen.dart

- [x] Social notifications stream loads recipient-only documents.
- [x] Mark as read updates only isRead.
- [x] Local non-firestore notifications still display correctly.

### saved_screen.dart

- [x] Saved locations derive from saved_posts and are grouped.
- [x] Saved images render from corresponding posts.
- [x] Empty saved state appears with no errors.

### profile_screen.dart

- [x] User uploads grid comes from current user's posts.
- [x] Upload action routes to community feed create flow.
- [x] Logout clears social streams and returns to login.

## Place and Guide Surfaces

### place_detail_screen.dart

- [x] Place comments panel reads/writes place_comments with required fields.
- [x] Like on place comments updates likedBy array only.

### guides_screen.dart and guide_profile_screen.dart

- [x] Any chat navigation uses real_time_chat_screen constructor with peerId.
- [x] No fake guide auto-chat content appears.

## Trip/Planning/Commerce Screens

These are not primary social writers but should be contract-safe:

- [x] itinerary_screen.dart
- [x] plan_trip_screen.dart
- [x] map_screen.dart
- [x] world_clock_screen.dart
- [x] ai_travel_planner_screen.dart
- [x] ai_chat_screen.dart
- [x] hotel_booking_screen.dart
- [x] hotel_list_screen.dart
- [x] hotel_detail_screen.dart
- [x] payment_screen.dart
- [x] package_detail_screen.dart
- [x] sim_recommendation_screen.dart
- [x] trip_journal_screen.dart
- [x] customize_profile_screen.dart
- [x] settings_screen.dart

Automated check result for this section:
- [x] No analyzer errors found in these screens after fixes.

For each screen above verify:

- [x] No unauthorized Firestore write attempt.
- [x] No schema mismatch with contract fields.
- [!] No crash when user is signed out and redirected.

## Security and Rules Verification

- [x] Firestore rules deployed and matching repo firestore.rules.
- [x] Storage rules deployed and matching repo storage.rules.
- [x] Required composite indexes deployed from firestore.indexes.json.
- [!] Manual test confirms read restrictions on notifications and chat rooms.

## Play Store Readiness Final Gate

- [x] Release build succeeds (AAB/APK) with production defines.
- [x] No analyzer errors in modified social/auth/screens.
- [!] Privacy policy includes location sharing and user-generated content details.
- [!] In-app report/abuse path exists for public traveler content (recommended).
- [!] Test accounts and seed data removed or isolated from production.

## Signoff

- QA owner:
- Build version: 1.0.0+1
- Date: 2026-03-14
- Result: Blocked (policy/manual validation items pending)
- Blockers: privacy policy + abuse reporting + final manual device/network permission tests
