# Firestore ER Diagram (One Page)

This diagram reflects the live schema used by the current app code and security rules.

```mermaid
erDiagram
  USERS {
    string uid PK
    string username
    string displayName
    string avatarUrl
    boolean locationSharingEnabled
    number latitude
    number longitude
    timestamp locationUpdatedAt
    timestamp createdAt
  }

  USERNAMES {
    string username PK
    string uid
    timestamp createdAt
  }

  POSTS {
    string postId PK
    string userId FK
    string userName
    string placeId
    string placeName
    string userAvatar
    string caption
    array photoUrls
    array likedBy
    number commentsCount
    number latitude
    number longitude
    timestamp createdAt
  }

  PLACE_COMMENTS {
    string commentId PK
    string placeId
    string userId FK
    string userName
    string userAvatar
    string text
    array photoUrls
    array likedBy
    timestamp createdAt
  }

  POST_COMMENTS {
    string commentId PK
    string postId FK
    string placeId
    string userId FK
    string userName
    string userAvatar
    string text
    array photoUrls
    array likedBy
    timestamp createdAt
  }

  CHAT_ROOMS {
    string roomId PK
    array participants
    string lastMessage
    timestamp updatedAt
  }

  CHAT_MESSAGES {
    string messageId PK
    string roomId FK
    string senderId FK
    string senderName
    string text
    timestamp createdAt
  }

  NOTIFICATIONS {
    string notificationId PK
    string recipientId FK
    string senderId FK
    string type
    string title
    string body
    boolean isRead
    timestamp createdAt
  }

  USER_FOLLOWING {
    string targetUid PK
    string ownerUid FK
    timestamp createdAt
  }

  USER_FOLLOWERS {
    string followerUid PK
    string ownerUid FK
    timestamp createdAt
  }

  USER_SAVED_POSTS {
    string postId PK
    string ownerUid FK
    string placeId
    string placeName
    timestamp savedAt
  }

  USERS ||--|| USERNAMES : reserves
  USERS ||--o{ POSTS : creates
  USERS ||--o{ PLACE_COMMENTS : writes
  USERS ||--o{ POST_COMMENTS : writes
  USERS ||--o{ USER_FOLLOWING : owns
  USERS ||--o{ USER_FOLLOWERS : owns
  USERS ||--o{ USER_SAVED_POSTS : owns
  POSTS ||--o{ POST_COMMENTS : has
  CHAT_ROOMS ||--o{ CHAT_MESSAGES : has
  USERS ||--o{ NOTIFICATIONS : receives
  USERS ||--o{ NOTIFICATIONS : sends
```

Notes:

- user_follower/following/saved_posts are subcollections under users/{uid}.
- chat_messages are subcollection documents under chat_rooms/{roomId}/messages/{messageId}.
- usernames is a reservation map for unique handles.
