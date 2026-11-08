# Firestore Data Model Contract

Project: `ceylon-explorer-c2b08`

This document defines the Firestore/Storage contract used by the current app implementation.
It is the source of truth for collection names, required fields, ownership, and indexes.

## 1) Top-Level Collections

- `usernames`
- `users`
- `posts`
- `place_comments`
- `post_comments`
- `chat_rooms`
- `notifications`

## 2) Collection Schemas

## 2.1 `usernames/{username}`

Purpose: reserve unique usernames.

Required fields:

- `uid` (`string`) - owner user ID
- `createdAt` (`timestamp`) - server timestamp

Rules intent:

- Create only by authenticated user where `uid == request.auth.uid`
- No updates/deletes

Example:

```json
{
  "uid": "u_123",
  "createdAt": "<server-timestamp>"
}
```

## 2.2 `users/{uid}`

Purpose: user profile + optional location sharing state.

Required fields:

- `username` (`string`) - unique handle
- `displayName` (`string`)
- `avatarUrl` (`string`) - empty string allowed
- `locationSharingEnabled` (`boolean`)
- `createdAt` (`timestamp`) - server timestamp

Optional fields:

- `latitude` (`number`) - when sharing is enabled
- `longitude` (`number`) - when sharing is enabled
- `locationUpdatedAt` (`timestamp`) - server timestamp

Rules intent:

- Any authenticated user can read profiles
- Owner can create/update own profile
- Delete disabled

Example:

```json
{
  "username": "traveler01",
  "displayName": "traveler01",
  "avatarUrl": "",
  "locationSharingEnabled": true,
  "latitude": 6.9271,
  "longitude": 79.8612,
  "locationUpdatedAt": "<server-timestamp>",
  "createdAt": "<server-timestamp>"
}
```

### 2.2.1 `users/{uid}/following/{targetUid}`

Purpose: who this user follows.

Required fields:

- `createdAt` (`timestamp`)

Rules intent:

- Owner read/write only

### 2.2.2 `users/{uid}/followers/{followerUid}`

Purpose: who follows this user.

Required fields:

- `createdAt` (`timestamp`)

Rules intent:

- Read by owner
- Write allowed by authenticated users (current rules)

### 2.2.3 `users/{uid}/saved_posts/{postId}`

Purpose: saved/bookmarked posts.

Required fields:

- `placeId` (`string`)
- `placeName` (`string`)
- `savedAt` (`timestamp`)

Rules intent:

- Owner read/write only

## 2.3 `posts/{postId}`

Purpose: traveler upload feed.

Required fields:

- `placeId` (`string`)
- `placeName` (`string`)
- `userId` (`string`) - owner
- `userName` (`string`)
- `userAvatar` (`string`) - currently empty string in writes
- `caption` (`string`) - empty string allowed
- `photoUrls` (`array<string>`) - one or more URLs expected by UI
- `likedBy` (`array<string>`) - user IDs
- `commentsCount` (`number`) - integer counter
- `createdAt` (`timestamp`)

Optional fields:

- `latitude` (`number`)
- `longitude` (`number`)

Rules intent:

- Authenticated read
- Owner create/delete
- Owner update, plus limited non-owner updates for `likedBy` and `commentsCount`

Example:

```json
{
  "placeId": "ella",
  "placeName": "Ella",
  "userId": "u_123",
  "userName": "traveler01",
  "userAvatar": "",
  "caption": "Amazing sunrise",
  "photoUrls": ["https://..."],
  "likedBy": ["u_987"],
  "commentsCount": 2,
  "latitude": 6.8762,
  "longitude": 81.0608,
  "createdAt": "<server-timestamp>"
}
```

## 2.4 `place_comments/{commentId}`

Purpose: comments attached to a place ID.

Required fields:

- `placeId` (`string`)
- `userId` (`string`)
- `userName` (`string`)
- `userAvatar` (`string`)
- `text` (`string`)
- `photoUrls` (`array<string>`) - can be empty
- `likedBy` (`array<string>`) - can be empty
- `createdAt` (`timestamp`)

Rules intent:

- Authenticated read
- Owner create/delete
- Owner update, plus limited non-owner updates for `likedBy`

## 2.5 `post_comments/{commentId}`

Purpose: comments attached to post feed items.

Required fields:

- `postId` (`string`)
- `placeId` (`string`) - can be empty in code fallback
- `userId` (`string`)
- `userName` (`string`)
- `userAvatar` (`string`)
- `text` (`string`)
- `photoUrls` (`array<string>`) - currently empty array
- `likedBy` (`array<string>`) - currently empty array
- `createdAt` (`timestamp`)

Rules intent:

- Authenticated read
- Owner create/delete
- Owner update, plus limited non-owner updates for `likedBy`

## 2.6 `chat_rooms/{roomId}`

Purpose: one-to-one traveler chat room metadata.

`roomId` generation rule in app:

- Sort two UIDs lexicographically, then join with underscore: `uidA_uidB`

Required fields:

- `participants` (`array<string>`) - exactly 2 UIDs
- `updatedAt` (`timestamp`)
- `lastMessage` (`string`)

Rules intent:

- Read/update only by participants
- Create only if caller is one of participants and list size is 2
- Delete disabled

### 2.6.1 `chat_rooms/{roomId}/messages/{messageId}`

Purpose: real-time chat messages.

Required fields:

- `senderId` (`string`) - must match `request.auth.uid` on create
- `senderName` (`string`)
- `text` (`string`)
- `createdAt` (`timestamp`)

Rules intent:

- Read/create only by room participants
- Update/delete disabled

## 2.7 `notifications/{notificationId}`

Purpose: social notifications (like, comment, follow, chat).

Required fields:

- `recipientId` (`string`)
- `senderId` (`string`) - must match creator auth UID on create
- `type` (`string`) - expected values currently: `like`, `comment`, `follow`, `chat`
- `title` (`string`)
- `body` (`string`)
- `isRead` (`boolean`)
- `createdAt` (`timestamp`)

Rules intent:

- Recipient-only read
- Authenticated create where sender is self
- Recipient can only update `isRead`
- Delete disabled

## 3) Required Firestore Indexes

From `firestore.indexes.json`:

1. `notifications`

- `recipientId` ASC
- `createdAt` DESC

2. `post_comments`

- `postId` ASC
- `createdAt` DESC

Note:

- Current `posts` query is `orderBy(createdAt, desc)` only; this does not require a composite index.

## 4) Storage Contract

Bucket paths used by app:

1. `user_posts/{uid}/{fileName}`

- write allowed to owner only
- image content type only
- max 10 MB per file

2. `avatars/{uid}/{fileName}`

- write allowed to owner only
- image content type only
- max 5 MB per file

Default:

- all other paths denied

## 5) Client-Side Write Flows (Current)

1. Registration:

- create Firebase Auth user
- write `usernames/{username}`
- write `users/{uid}` profile

2. Create post:

- upload bytes to Storage `user_posts/...`
- write `posts/{postId}`

3. Like post:

- update `posts/{postId}.likedBy` array
- create `notifications/{id}` for owner

4. Comment post:

- write `post_comments/{commentId}`
- increment `posts/{postId}.commentsCount`
- create notification for owner

5. Follow user:

- write/delete `users/{uid}/following/{targetUid}`
- mirror write/delete `users/{targetUid}/followers/{uid}`
- create notification for target on follow

6. Live location share:

- update `users/{uid}` with `locationSharingEnabled`, coordinates, `locationUpdatedAt`

7. Chat:

- upsert `chat_rooms/{roomId}`
- add message in `chat_rooms/{roomId}/messages/{messageId}`
- create notification for peer

## 6) Data Validation Recommendations (Next Hardening)

Recommended future rule checks to add:

- enforce max caption length and message length
- enforce `photoUrls` array size limits
- restrict `type` in notifications to enum values
- ensure `commentsCount` is non-negative integer
- tighten followers writes so only `followerUid == request.auth.uid`

## 7) Versioning

Contract version: `v1`
Last updated: `2026-03-14`
Derived from:

- `lib/services/social_service.dart`
- `lib/services/auth_service.dart`
- `firestore.rules`
- `firestore.indexes.json`
