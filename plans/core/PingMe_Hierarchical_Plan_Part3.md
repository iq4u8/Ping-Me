# PingMe — Hierarchical Implementation Breakdown (Part 3/3)

## 5. ENCRYPTION (Signal Protocol)

### 5.1 Flutter Key Management
5.1.1 Add `libsignal_protocol_dart` to `pubspec.yaml`
5.1.2 Run `flutter pub get`
5.1.3 Create `lib/core/crypto/key_manager.dart`
5.1.4 Generate Identity Key Pair using `KeyHelper.generateIdentityKeyPair()`
5.1.5 Generate Signed Pre-Key using `KeyHelper.generateSignedPreKey()`
5.1.6 Generate 100 One-Time Pre-Keys using `KeyHelper.generatePreKeys()`
5.1.7 Store all private keys in `flutter_secure_storage`
5.1.8 Upload public Identity Key to server via `POST /api/v1/keys/upload`
5.1.9 Upload public Signed Pre-Key to server
5.1.10 Upload all 100 public One-Time Pre-Keys to server

### 5.2 Backend Key Distribution
5.2.1 Create `src/routes/keys.ts`
5.2.2 Register with prefix `/api/v1/keys` with auth middleware
5.2.3 Create `key_bundles` table: user_id, identity_key, signed_prekey, signed_prekey_signature
5.2.4 Create `one_time_prekeys` table: id, user_id, prekey_id, public_key, is_consumed
5.2.5 Implement `POST /upload`: store identity key, signed prekey, and one-time prekeys
5.2.6 Implement `GET /:userId`: return identity key + signed prekey + one unused one-time prekey
5.2.7 Mark consumed one-time prekey as `is_consumed = 1`
5.2.8 Implement `POST /replenish`: accept and store new batch of one-time prekeys
5.2.9 Add logic: if user's unused prekeys < 10, send notification to client to replenish

### 5.3 Session Establishment
5.3.1 Create `lib/core/crypto/session_manager.dart`
5.3.2 Add method `initSession(targetUserId)`:
5.3.3   Fetch target's key bundle from `GET /api/v1/keys/:userId`
5.3.4   Build `PreKeyBundle` from response data
5.3.5   Run X3DH protocol via `SessionBuilder.processPreKeyBundle()`
5.3.6   Store resulting session state in encrypted Hive box
5.3.7 Add method `hasSession(targetUserId)`: check if session exists locally
5.3.8 Add method `getSession(targetUserId)`: retrieve session from local store

### 5.4 Message Encryption/Decryption
5.4.1 Create `lib/core/crypto/message_crypto.dart`
5.4.2 Add method `encrypt(plaintext, targetUserId)`:
5.4.3   Get or initialize session for target user
5.4.4   Encode plaintext to UTF-8 bytes
5.4.5   Encrypt using `SessionCipher.encrypt()`
5.4.6   Return ciphertext bytes
5.4.7 Add method `decrypt(ciphertext, senderUserId)`:
5.4.8   Get session for sender user
5.4.9   Decrypt using `SessionCipher.decrypt()`
5.4.10  Decode UTF-8 bytes to plaintext string
5.4.11  Return plaintext

### 5.5 Integration with Chat
5.5.1 In `chat_repository.dart` `sendMessage`: call `encrypt(content, recipientId)` before API call
5.5.2 Send ciphertext as `encryptedContent` field
5.5.3 On receiving message via WebSocket: call `decrypt(encryptedContent, senderId)`
5.5.4 Display decrypted plaintext in chat UI

### 5.6 Group Encryption (Sender Keys)
5.6.1 Create `lib/core/crypto/group_crypto.dart`
5.6.2 On joining group: generate Sender Key for this group
5.6.3 Distribute Sender Key to each group member via pairwise E2EE (using existing sessions)
5.6.4 On sending group message: encrypt with own Sender Key
5.6.5 On receiving group message: decrypt with sender's Sender Key

### 5.7 Key Backup
5.7.1 Create `lib/core/crypto/key_backup.dart`
5.7.2 Add method `exportKeys(passphrase)`: derive AES-256 key from passphrase via PBKDF2
5.7.3 Encrypt all local keys with derived key
5.7.4 Save encrypted blob to local file
5.7.5 Add method `importKeys(file, passphrase)`: derive key from passphrase
5.7.6 Decrypt blob and restore all keys to secure storage

### 5.8 Zero-Knowledge Validation
5.8.1 Backend: add validation on `POST /messages` that `encrypted_content` is base64-encoded binary
5.8.2 Reject any message where content appears to be plaintext
5.8.3 Never log or inspect message content on server

### 5.9 Encryption Badge UI
5.9.1 Create `lib/features/chat/presentation/widgets/encryption_badge.dart`
5.9.2 Show small lock icon in chat screen AppBar
5.9.3 On tap: show dialog with key fingerprint for manual verification

## 6. GROUPS & CHANNELS

### 6.1 Backend Conversation Routes
6.1.1 Create `src/routes/conversations.ts`
6.1.2 Register with prefix `/api/v1/conversations` with auth middleware

#### 6.1.3 Create Conversation
6.1.3.1 Define `POST /` route
6.1.3.2 Accept: `{ type, title, description, isPublic, memberIds[] }`
6.1.3.3 Validate type is `group` or `channel`
6.1.3.4 Generate UUID for conversation
6.1.3.5 Insert into `conversations` table
6.1.3.6 Insert creator into `conversation_members` with role `creator`
6.1.3.7 Insert each memberIds entry with role `member`
6.1.3.8 Return conversation object

#### 6.1.4 Update Conversation
6.1.4.1 Define `PUT /:id` route
6.1.4.2 Query caller's role from `conversation_members`
6.1.4.3 Validate role is `creator` or `admin`
6.1.4.4 Update provided fields in `conversations` table
6.1.4.5 Broadcast update via WebSocket

#### 6.1.5 Member Management
6.1.5.1 Define `POST /:id/members` to add member
6.1.5.2 Validate caller is admin+
6.1.5.3 Check current member count < max_members
6.1.5.4 Insert into `conversation_members`
6.1.5.5 Broadcast `member:joined`
6.1.5.6 Define `DELETE /:id/members/:userId` to remove/leave
6.1.5.7 Validate caller is admin+ OR userId is self
6.1.5.8 Delete from `conversation_members`
6.1.5.9 If no members remain: delete all conversation data
6.1.5.10 Broadcast `member:left`

#### 6.1.6 Role Management
6.1.6.1 Define `PUT /:id/members/:userId/role`
6.1.6.2 Accept `{ role }`
6.1.6.3 Only creator can set role to `admin`
6.1.6.4 Admins can set role to `moderator`
6.1.6.5 Update role in `conversation_members`

#### 6.1.7 Channel Restrictions
6.1.7.1 In message send endpoint: if conversation type is `channel`
6.1.7.2 Check sender role is `creator` or `admin`
6.1.7.3 If member/moderator: return 403 "Only admins can post in channels"

### 6.2 Invite Link Routes
6.2.1 Create `src/routes/invites.ts`
6.2.2 Register with prefix `/api/v1/invites` with auth middleware
6.2.3 Define `POST /`: generate 8-char alphanumeric link_code, insert into `invite_links`
6.2.4 Define `GET /:code`: return invite info (group name, member count)
6.2.5 Define `POST /:code/join`: validate link active/not expired/usage limit
6.2.6   If `requires_approval`: create pending join request, notify admins
6.2.7   Else: add user to `conversation_members`, increment `current_uses`
6.2.8 Define `DELETE /:id`: validate caller is admin, set `is_active = 0`

### 6.3 Flutter Group UI
6.3.1 Create `lib/features/groups/presentation/screens/create_group_screen.dart`
6.3.2 Add form: group name, description, photo picker, public/private toggle
6.3.3 Add member selector from contacts
6.3.4 On submit: call create conversation API
6.3.5 Create `lib/features/groups/presentation/screens/group_info_screen.dart`
6.3.6 Show group photo, name, description
6.3.7 Show member list with role badges
6.3.8 Show invite link section with copy/share/QR buttons
6.3.9 Show admin settings (slow mode, permissions) for admins only

## 7. VOICE & VIDEO CALLING

### 7.1 Backend Call Routes
7.1.1 Create `src/routes/calls.ts`
7.1.2 Register with prefix `/api/v1/calls` with auth middleware
7.1.3 Define `POST /initiate`: accept `{ conversationId, callType }`, generate call UUID, insert into `call_logs` with status `ringing`, send `call:incoming` to recipient via WebSocket, return call object
7.1.4 Define `POST /:id/answer`: update status to `active`, set `started_at`, notify caller via `call:answered`
7.1.5 Define `POST /:id/end`: set `ended_at`, calculate duration, set status `completed` or `missed`, send `call:ended`, trigger FCM for missed calls
7.1.6 Define `GET /history`: return paginated call logs for current user
7.1.7 WebSocket handler for `call:signal`: relay SDP/ICE data between caller and callee without storing

### 7.2 Flutter Call Manager
7.2.1 Create `lib/features/calls/data/call_manager.dart`
7.2.2 Import `flutter_webrtc`
7.2.3 Add method `initiateCall(userId, type)`: create RTCPeerConnection with STUN config
7.2.4 Create SDP offer and send via WebSocket `call:signal`
7.2.5 Add method `answerCall(callId, sdpOffer)`: create SDP answer, send back
7.2.6 Handle ICE candidate exchange via WebSocket
7.2.7 Monitor `getStats()` for adaptive bitrate
7.2.8 If packet loss > 5%: reduce video resolution
7.2.9 If network improves: increase quality

### 7.3 Flutter Call UI
7.3.1 Create `lib/features/calls/presentation/screens/call_screen.dart`: active call with avatar, timer, mute/speaker/end buttons, video preview
7.3.2 Create `lib/features/calls/presentation/screens/incoming_call_screen.dart`: full-screen overlay with accept/decline buttons, play ringtone
7.3.3 Create `lib/features/calls/presentation/screens/call_history_screen.dart`: list past calls with type icon, direction, duration, timestamp

## 8. USER PROFILE & PRIVACY

### 8.1 Backend User Routes
8.1.1 Create `src/routes/users.ts`, register at `/api/v1/users`
8.1.2 `GET /me`: return full profile of authenticated user
8.1.3 `PUT /me`: update display_name, bio, phone, phoneVisible, lastSeenPrivacy
8.1.4 `GET /:username`: return public profile respecting privacy settings
8.1.5 `POST /block/:userId`: insert into `blocked_users`, enforce blocking
8.1.6 `DELETE /block/:userId`: remove from `blocked_users`
8.1.7 `DELETE /me`: set `deletion_scheduled_at = now + 7 days`, schedule cleanup

### 8.2 Privacy Service
8.2.1 Create `src/services/privacy.ts`
8.2.2 Function `filterLastSeen(requester, target)`: check target's privacy setting, return or hide last_seen
8.2.3 Apply filter in `GET /users/:username` and presence events

### 8.3 Push Notifications
8.3.1 Install `firebase-admin` in backend
8.3.2 Create `src/services/push.ts`
8.3.3 On new message to offline user: send FCM with title (sender name) and body (respecting preview setting)
8.3.4 On missed call: send FCM notification
8.3.5 On group invite: send FCM notification

### 8.4 Flutter Profile & Settings UI
8.4.1 Create profile screen: photo, name, bio, username, edit button
8.4.2 Create other-user profile screen: photo, name, bio, message/call/block/report buttons
8.4.3 Create privacy settings screen: last seen, profile photo, read receipts, phone visibility toggles
8.4.4 Create notification settings screen: preview, per-chat mute, DND mode
8.4.5 Create theme.dart: define light and dark ThemeData, system preference default, store preference in Hive

## 9. DESKTOP ADMIN APP

9.1 Create `pingme-admin/` directory
9.2 Initialize Tauri project: `npm create tauri-app@latest ./` with React
9.3 Backend: create `src/routes/admin.ts` at prefix `/admin/v1/*` with separate admin JWT middleware
9.4 Create `admin_users` table (id, username, password_hash, role, created_at), seed owner account
9.5 Implement `GET /admin/v1/dashboard/stats`: total users, active users, message volume, storage used
9.6 Implement `GET /admin/v1/users`: paginated user list with search
9.7 Implement `POST /admin/v1/users/:id/ban` and `/unban`
9.8 Implement `GET /admin/v1/storage/overview`: per-account usage stats
9.9 Implement `POST /admin/v1/storage/accounts`: add new R2 account after credential verification
9.10 Implement `GET /admin/v1/health`: ping all services and return status
9.11 Implement `GET /admin/v1/audit-logs`: query audit_logs table
9.12 Build React dashboard page with charts (recharts)
9.13 Build user management page with search table and ban/unban actions
9.14 Build storage manager page with progress bars and add-account form

## 10. TESTING

10.1 Backend: install `vitest` and `supertest`
10.2 Write unit tests for auth validation (username rules, reserved names, case-insensitivity)
10.3 Write unit tests for OTP rate limiting (tier escalation logic)
10.4 Write unit tests for message edit window validation
10.5 Write integration tests for auth flow (register → login → get profile)
10.6 Write integration tests for message flow (send → edit → delete)
10.7 Write integration tests for group flow (create → add member → message → remove)
10.8 Write tests for storage router (least-full selection, failover)
10.9 Flutter: write unit tests for message_crypto.dart (encrypt/decrypt roundtrip)
10.10 Flutter: write widget tests for message_bubble.dart
10.11 Flutter: write integration test for auth flow
10.12 Set up GitHub Actions CI: run backend tests, Flutter tests, build APK on every push

## 11. DEPLOYMENT

11.1 Create Cloudflare Workers project: `npx wrangler init pingme-api`
11.2 Configure `wrangler.toml` with env vars
11.3 Deploy API with `wrangler deploy`
11.4 Deploy WebSocket server to Railway with Dockerfile
11.5 Set up Infisical project with dev/staging/production environments
11.6 Configure Firebase project, add `google-services.json` to Flutter
11.7 Set up Sentry free tier for backend error monitoring
11.8 Build Flutter release APK and AAB
11.9 Create Google Play Console listing, upload to Internal Testing
11.10 Build admin `.exe` with `npm run tauri build`, distribute privately

## 12. POST-LAUNCH MONITORING

12.1 Create hourly cron: check storage account usage, alert at 70%/85%/95%
12.2 Create DB usage monitor: track Turso reads, alert at 80% of 500M limit
12.3 Create weekly integrity checker: verify all file references in DB match R2
12.4 Add Firebase Crashlytics to Flutter app
12.5 Create changelog table and display in admin app
12.6 Implement config hot-reload: poll Infisical every 60s, verify + swap on change
12.7 Set up UptimeRobot for API/WS endpoint monitoring
