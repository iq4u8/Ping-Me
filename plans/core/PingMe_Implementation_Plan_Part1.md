# PingMe — Implementation Plan (Part 1 of 2)

## Assumptions
- Backend: Node.js with Fastify (best free-tier fit)
- Deploy: Cloudflare Workers (API) + Railway (WebSocket server)
- DB: Turso (libSQL) | Storage: Cloudflare R2 | Secrets: Infisical
- Mobile: Flutter (Android first) | Admin: Tauri (.exe)
- Budget: ₹0 — free tiers only

## Ambiguities Called Out
1. WhatsApp OTP requires Business API ($) — may need SMS fallback or email-only at MVP
2. Signal Protocol in Dart has no official library — will use `libsignal_protocol_dart` community fork
3. Group E2EE with 200 members is extremely complex — recommend Sender Keys approach
4. "Passkey" on Android requires Google Play Services — devices without it need OTP fallback

---

## PHASE 1 — PROJECT SETUP & TOOLING (Steps 1–18)

### Backend Setup

1. Create directory `pingme-backend/`. Run `npm init -y` inside it.
   - **Why:** Initialize the Node.js backend project.

2. Install core dependencies: `npm install fastify @fastify/cors @fastify/websocket @libsql/client uuid jsonwebtoken bcryptjs dotenv`
   - **Why:** Fastify for HTTP, WebSocket plugin for real-time, libsql client for Turso, uuid for IDs, jwt for auth tokens.

3. Install dev dependencies: `npm install -D typescript @types/node ts-node nodemon`
   - **Why:** TypeScript for type safety during development.

4. Create `tsconfig.json` with `target: ES2022`, `module: NodeNext`, `outDir: dist/`, `strict: true`.
   - **Why:** Configure TypeScript compiler.

5. Create `src/` directory with subdirectories: `src/routes/`, `src/services/`, `src/middleware/`, `src/models/`, `src/utils/`, `src/websocket/`, `src/config/`.
   - **Why:** Establish clean project structure per TRD.

6. Create `src/config/env.ts` — load environment variables from `.env` file. Export typed config object with keys: `DATABASE_URL`, `JWT_SECRET`, `R2_ACCESS_KEY`, `R2_SECRET_KEY`, `R2_BUCKET_NAME`, `R2_ENDPOINT`, `INFISICAL_TOKEN`, `FCM_SERVER_KEY`, `SMTP_HOST`, `SMTP_USER`, `SMTP_PASS`.
   - **Why:** Centralize all config; never use `process.env` directly elsewhere.

7. Create `src/index.ts` — instantiate Fastify server, register CORS plugin, register WebSocket plugin, import route modules, listen on port 3000.
   - **Why:** Main entry point for the backend.

8. Add scripts to `package.json`: `"dev": "nodemon src/index.ts"`, `"build": "tsc"`, `"start": "node dist/index.js"`.
   - **Why:** Development and production run commands.

### Database Setup

9. Create a free Turso account at turso.tech. Create a database named `pingme-prod`. Copy the connection URL and auth token.
   - **Why:** Primary database for all app data.

10. Create `src/config/database.ts` — initialize `@libsql/client` with the Turso URL and auth token from env config. Export a singleton `db` client.
    - **Why:** Single reusable database connection.

11. Create `src/models/schema.sql` — paste ALL CREATE TABLE statements from TRD Section 3 (users, sessions, conversations, conversation_members, messages, message_status, message_reactions, pinned_messages, files, storage_accounts, db_accounts, otp_attempts, user_2fa, blocked_users, reports, invite_links, call_logs).
    - **Why:** Full database schema ready for migration.

12. Create `src/models/migrate.ts` — read `schema.sql`, split by semicolons, execute each statement via `db.execute()`. Log success/failure per table.
    - **Why:** Run migrations against Turso to create all tables.

### Storage Setup

13. Create a free Cloudflare account. Create an R2 bucket named `pingme-media`. Generate API tokens with read/write access. Save credentials.
    - **Why:** Object storage for images, videos, voice notes, documents.

14. Install R2 client: `npm install @aws-sdk/client-s3`. Create `src/services/storage.ts` — initialize S3Client pointing to R2 endpoint. Export functions: `uploadFile(buffer, key, mimeType)` returns file URL, `getFileUrl(key)` returns signed URL, `deleteFile(key)`.
    - **Why:** Abstracted storage layer for all media operations.

### Flutter App Setup

15. Run `flutter create pingme_app --org com.pingme --platforms android`. Navigate into the created directory.
    - **Why:** Initialize Flutter project for Android only.

16. Open `pubspec.yaml`. Add dependencies: `flutter_bloc`, `dio`, `web_socket_channel`, `flutter_webrtc`, `hive`, `hive_flutter`, `firebase_messaging`, `firebase_core`, `image_picker`, `cached_network_image`, `intl`, `qr_flutter`, `flutter_secure_storage`, `json_annotation`, `equatable`, `go_router`.
    - **Why:** All core packages per TRD Section 15.

17. Create the folder structure inside `lib/` exactly as specified in TRD Section 14: `app/`, `core/config/`, `core/crypto/`, `core/network/`, `core/storage/`, `features/auth/data/`, `features/auth/domain/`, `features/auth/presentation/`, `features/chat/data/`, `features/chat/domain/`, `features/chat/presentation/`, `features/calls/`, `features/groups/`, `features/channels/`, `features/profile/`, `features/settings/`, `shared/widgets/`, `shared/utils/`, `shared/constants/`, `l10n/`.
    - **Why:** Clean architecture folder structure.

18. Create `lib/core/config/app_config.dart` — define constants: `apiBaseUrl`, `wsUrl`, `maxMessageLength = 4096`, `maxGroupMembers = 200`, `editWindowMinutes = 5`, `minUsernameLength = 6`.
    - **Why:** Single source of truth for app-wide constants.

---

## PHASE 2 — AUTHENTICATION & AUTHORIZATION (Steps 19–35)

### Backend Auth

19. Create `src/middleware/auth.ts` — export a Fastify preHandler hook that: extracts Bearer token from Authorization header, verifies JWT using `jsonwebtoken`, attaches `request.user = { id, username }` to the request. Return 401 if token missing/invalid.
    - **Why:** All protected routes need JWT validation.

20. Create `src/routes/auth.ts` — define route file. Register it in `src/index.ts` with prefix `/api/v1/auth`.
    - **Why:** Auth route module.

21. Implement `POST /api/v1/auth/register` — accept body `{ email?, phone?, username, display_name }`. Validate: username >= 6 chars, username not in reserved list (`admin`, `support`, `pingme`, `system`, `help`, `official`), username case-insensitive (lowercase before storing). Generate UUID for user ID. Insert into `users` table. Generate JWT access token (expires 7d) and refresh token (expires 30d). Return `{ user, accessToken, refreshToken }`.
    - **Why:** User registration endpoint.

22. Implement `POST /api/v1/auth/otp/send` — accept `{ identifier, method }` where method is `email` or `whatsapp`. Check `otp_attempts` table for rate limiting (3 attempts → 1hr lock → 3 → 4hr → 3 → 24hr). Generate 6-digit OTP. Store hashed OTP in a temporary table or cache with 5-min expiry. Send OTP via SMTP (email) or WhatsApp Business API. Return `{ success: true, expiresIn: 300 }`.
    - **Why:** OTP delivery with tiered rate limiting per PRD G7.

23. Implement `POST /api/v1/auth/otp/verify` — accept `{ identifier, otp }`. Verify OTP hash matches. If valid: find or create user, generate JWT tokens, create session in `sessions` table with device_info and IP. If invalid: increment `attempt_count` in `otp_attempts`, apply lock tier if threshold reached. Return tokens on success, error on failure.
    - **Why:** OTP verification with progressive lockout.

24. Implement `POST /api/v1/auth/logout` — require auth middleware. Set `is_active = 0` on the current session in `sessions` table. Return `{ success: true }`.
    - **Why:** Logout current device.

25. Implement `DELETE /api/v1/auth/sessions/:id` — require auth middleware. Verify the session belongs to `request.user.id`. Set `is_active = 0`. Return success.
    - **Why:** Remote logout of other devices (PRD K2).

26. Implement `GET /api/v1/auth/sessions` — require auth middleware. Query `sessions` table where `user_id = request.user.id AND is_active = 1`. Return list with device_info, ip_address, created_at, last_active.
    - **Why:** View all active sessions (PRD K2).

### Flutter Auth UI

27. Create `lib/features/auth/presentation/screens/welcome_screen.dart` — display app logo, tagline "Private. Fast. Yours.", and three buttons: "Continue with Passkey", "Continue with Email", "Continue with Phone". Use dark theme with gradient background.
    - **Why:** First screen user sees; entry point for all auth flows.

28. Create `lib/features/auth/presentation/screens/otp_screen.dart` — accept email or phone as parameter. Show input field for 6-digit OTP. Show countdown timer (resend after 60s). On verify: call `POST /auth/otp/verify`. Show error with remaining attempts if failed. Navigate to username setup on success.
    - **Why:** OTP verification screen.

29. Create `lib/features/auth/presentation/screens/username_setup_screen.dart` — text field for username (min 6 chars, show live validation). Text field for display name. Optional bio field. Optional profile photo picker. On submit: call `POST /auth/register`. Navigate to home on success.
    - **Why:** Complete profile during first signup.

30. Create `lib/features/auth/data/auth_repository.dart` — methods: `sendOtp(identifier, method)`, `verifyOtp(identifier, otp)`, `register(username, displayName, email, phone)`, `logout()`, `getSessions()`, `revokeSession(sessionId)`. Each method calls corresponding API endpoint via Dio.
    - **Why:** Data layer connecting UI to backend API.

31. Create `lib/features/auth/domain/auth_bloc.dart` using flutter_bloc — states: `AuthInitial`, `AuthLoading`, `AuthOtpSent`, `AuthAuthenticated`, `AuthError`. Events: `SendOtp`, `VerifyOtp`, `Register`, `Logout`. Process each event through `auth_repository`.
    - **Why:** State management for auth flow.

### JWT Token Management

32. Create `lib/core/network/token_manager.dart` — use `flutter_secure_storage` to store/retrieve `accessToken` and `refreshToken`. Methods: `saveTokens(access, refresh)`, `getAccessToken()`, `getRefreshToken()`, `clearTokens()`.
    - **Why:** Secure token persistence on device.

33. Create `lib/core/network/api_client.dart` — initialize Dio instance with `baseUrl` from app_config. Add interceptor: on every request, attach `Authorization: Bearer <accessToken>` header. On 401 response, attempt token refresh; if refresh fails, navigate to login.
    - **Why:** Centralized HTTP client with auto-auth.

### 2FA (TOTP)

34. Backend: Install `npm install otplib`. Create `POST /api/v1/auth/2fa/enable` — generate TOTP secret, encrypt it, store in `user_2fa` table, return QR code URI. Create `POST /api/v1/auth/2fa/verify` — verify TOTP code. Create `POST /api/v1/auth/2fa/disable` — remove 2FA after verification.
    - **Why:** TOTP-based 2FA per PRD K1.

35. Flutter: Create `lib/features/settings/screens/two_factor_screen.dart` — show QR code for Google Authenticator setup. Input field to verify first TOTP code. Toggle to enable/disable 2FA.
    - **Why:** 2FA management UI.

---

## PHASE 3 — CORE MESSAGING (Steps 36–55)

### Backend Messaging

36. Create `src/routes/messages.ts` — register with prefix `/api/v1/messages`. Apply auth middleware to all routes.
    - **Why:** Message route module.

37. Implement `POST /api/v1/messages` — accept `{ conversationId, type, encryptedContent, replyToId?, selfDestructSeconds? }`. Validate: sender is member of conversation. Generate UUID for message. Insert into `messages` table. Insert `message_status` row for each conversation member with status `sent`. Broadcast `message:new` via WebSocket to all online members. Trigger FCM push notification to offline members. Return created message.
    - **Why:** Core message sending with E2EE ciphertext storage.

38. Implement `GET /api/v1/messages/:convId` — accept query params `limit=50`, `before=<messageId>` for cursor pagination. Query messages joined with message_status (for current user). Exclude messages where `deleted_for_self = 1` for this user. Return array sorted by `created_at DESC`.
    - **Why:** Paginated message history with per-user delete filtering.

39. Implement `PUT /api/v1/messages/:id` — accept `{ encryptedContent }`. Validate: sender_id matches request.user.id. Validate: `created_at` is within 5 minutes of now. Update `encrypted_content`, set `is_edited = 1`, `edited_at = NOW()`. Broadcast `message:edited` via WebSocket. Return updated message.
    - **Why:** Edit messages within 5-minute window (PRD A3).

40. Implement `DELETE /api/v1/messages/:id` — accept `{ deleteForEveryone: boolean }`. If `deleteForEveryone`: set `deleted_for_everyone = 1` on message row, broadcast `message:deleted` to all members. If self-only: set `deleted_for_self = 1` in `message_status` for this user only.
    - **Why:** Two delete modes per PRD A4. Delete-for-everyone has no time limit.

41. Implement `POST /api/v1/messages/:id/react` — accept `{ emoji }`. Upsert into `message_reactions`. Broadcast `message:reaction` via WebSocket. Return success.
    - **Why:** Emoji reactions on messages (PRD A13).

### WebSocket Server

42. Create `src/websocket/manager.ts` — maintain a Map of `userId → WebSocket[]` (array for multi-device). Export functions: `addConnection(userId, ws)`, `removeConnection(userId, ws)`, `sendToUser(userId, event, data)`, `sendToConversation(conversationId, event, data, excludeUserId?)`.
    - **Why:** Central WebSocket connection manager for all real-time features.

43. Create `src/websocket/handlers.ts` — handle incoming WebSocket messages by event type: `message:send` → validate & save to DB → broadcast. `typing:start` / `typing:stop` → broadcast to conversation. `presence:update` → update `users.status` and `last_seen`, broadcast `presence:changed`. `message:edit`, `message:delete`, `message:react` → validate & process → broadcast.
    - **Why:** WebSocket event handlers per TRD Section 4.2.

44. In `src/index.ts`, register WebSocket upgrade route at `/ws`. On connection: require JWT token as query param, verify it, call `addConnection`. On close: call `removeConnection`, update user status to `offline`.
    - **Why:** WebSocket endpoint with authentication.

### Message Status & Receipts

45. Create `src/services/message_status.ts` — function `markDelivered(messageId, userId)`: update `message_status` set `status = 'delivered'`, broadcast `message:status` to sender. Function `markRead(messageId, userId)`: update to `'read'`, broadcast. Function `markAllRead(conversationId, userId)`: batch update all unread messages.
    - **Why:** Sent ✓ / Delivered ✓✓ / Read 🔵 indicators (PRD A2).

### Flutter Chat UI

46. Create `lib/features/chat/presentation/screens/conversations_list_screen.dart` — show list of all conversations sorted by last message time. Each item shows: avatar, name, last message preview (decrypted), unread count badge, last message time. Pull-to-refresh. FAB to start new chat.
    - **Why:** Main chat list (home screen).

47. Create `lib/features/chat/presentation/screens/chat_screen.dart` — message list (ListView.builder, reverse). Message input bar at bottom with text field + attachment button + send button. Show typing indicator above input when other user is typing. Long-press message for context menu (reply, edit, delete, react, forward, pin).
    - **Why:** Core 1-on-1 and group chat screen.

48. Create `lib/features/chat/presentation/widgets/message_bubble.dart` — render single message. Show sender name (in groups), message content, time, status indicators (✓/✓✓/🔵). Show "edited" label if `is_edited`. Show reply-to preview if `replyToId` exists. Show reactions row below message.
    - **Why:** Individual message rendering component.

49. Create `lib/features/chat/presentation/widgets/message_input.dart` — text field with max 4096 chars counter. Attachment picker (image, video, voice, document, location, poll, contact). Send button. Show "replying to..." bar when replying. Voice recording button (hold to record).
    - **Why:** Message composition widget.

50. Create `lib/features/chat/data/chat_repository.dart` — methods: `getConversations()`, `getMessages(convId, before?)`, `sendMessage(convId, type, content)`, `editMessage(id, content)`, `deleteMessage(id, forEveryone)`, `reactToMessage(id, emoji)`, `searchMessages(query)`.
    - **Why:** Chat data layer.

51. Create `lib/features/chat/domain/chat_bloc.dart` — states: `ConversationsLoaded`, `MessagesLoaded`, `MessageSending`, `MessageSent`. Handle loading, sending, receiving (via WebSocket), editing, deleting.
    - **Why:** Chat state management.

### WebSocket Client (Flutter)

52. Create `lib/core/network/websocket_manager.dart` — connect to `ws://server/ws?token=JWT`. Auto-reconnect with exponential backoff (1s, 2s, 4s, 8s, max 30s). Parse incoming JSON events and route to appropriate BLoC. Send events as JSON. Handle connection state changes.
    - **Why:** Persistent WebSocket connection for real-time features.

53. Create `lib/core/network/websocket_events.dart` — define typed event classes for all WebSocket events listed in TRD 4.2. Each class has `toJson()` and `fromJson()` factory.
    - **Why:** Type-safe WebSocket event handling.

### Typing Indicator

54. Backend: In WebSocket handler for `typing:start` — broadcast `typing:indicator` to all other members of the conversation. Auto-expire typing state after 5 seconds if no new `typing:start` received.
    - **Why:** Real-time typing indicator (PRD A7).

55. Flutter: In `message_input.dart`, on text change — emit `typing:start` via WebSocket (debounced to max 1 event per 3 seconds). In `chat_screen.dart`, listen for `typing:indicator` events and show "User is typing..." animation.
    - **Why:** Typing indicator UI.

---

## PHASE 4 — MEDIA & FILE HANDLING (Steps 56–64)

56. Backend: Implement `POST /api/v1/media/upload` — accept multipart form data (file + metadata). Generate UUID file ID. Use storage router: query `storage_accounts` for active accounts sorted by priority, pick least-full. Upload to R2 via S3 client. Insert into `files` table with `storage_account_id`, `bucket_key`, `file_type`, `file_size`, `mime_type`. Update `used_bytes` on storage account. Return `{ fileId, url }`.
    - **Why:** Media upload with intelligent storage routing per TRD Section 6.

57. Backend: Implement `GET /api/v1/media/:fileId` — query `files` table to find storage account and bucket key. Generate a signed URL (expiry 1 hour) from the correct R2 account. Return redirect or URL.
    - **Why:** Media download with multi-account lookup.

58. Backend: Create `src/services/storage_router.ts` — function `selectStorageAccount()`: query active storage accounts, sort by priority, return the one with most free space. Function `failoverUpload(buffer, key, mime)`: try primary, on failure try next, return result or throw after all fail.
    - **Why:** Intelligent storage routing with auto-failover.

59. Backend: Create `src/services/thumbnail.ts` — install `sharp` (`npm install sharp`). Function `generateThumbnail(imageBuffer)`: resize to max 100px width, quality 60%, return Buffer. Store thumbnail alongside original with `_thumb` suffix.
    - **Why:** Tiny thumbnails for 2G/low-bandwidth progressive loading (TRD Section 13).

60. Flutter: Create `lib/features/chat/presentation/widgets/media_message.dart` — for image messages: show thumbnail first (from message metadata), tap to load full image. For video: show thumbnail + play button. For voice: show waveform + play/pause + duration. For document: show file icon + name + size + download button.
    - **Why:** Media rendering in chat with progressive loading.

61. Flutter: Create `lib/features/chat/data/media_repository.dart` — methods: `uploadFile(File, type)` using multipart Dio request, `downloadFile(fileId)`, `getFileUrl(fileId)`. Show upload progress via stream.
    - **Why:** Media upload/download with progress tracking.

62. Flutter: Create `lib/shared/widgets/image_picker_sheet.dart` — bottom sheet with options: Camera, Gallery, Video, Document, Location, Poll, Contact Card. Each option opens the appropriate system picker.
    - **Why:** Attachment picker UI for all supported types (PRD A1).

63. Backend: Add file size limits — Images: 10MB, Videos: 50MB, Voice notes: 15MB, Documents: 25MB. Validate in upload endpoint before processing. Return 413 if exceeded.
    - **Why:** Prevent storage abuse on free tier.

64. Backend: Implement voice note upload — accept audio file, store with `type = 'voice'`. Return duration metadata extracted using a lightweight audio parser.
    - **Why:** Voice note support (PRD A1).

*Continued in Part 2...*
