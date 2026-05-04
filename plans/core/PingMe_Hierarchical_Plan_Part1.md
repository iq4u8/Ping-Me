# PingMe — Hierarchical Implementation Breakdown (Part 1/3)

## 1. PROJECT SETUP & TOOLING

### 1.1 Backend Setup
#### 1.1.1 Initialize Project
1.1.1.1 Create directory `pingme-backend/`
1.1.1.2 Run `npm init -y` inside `pingme-backend/`
1.1.1.3 Run `npm install fastify @fastify/cors @fastify/websocket @libsql/client uuid jsonwebtoken bcryptjs dotenv`
1.1.1.4 Run `npm install -D typescript @types/node ts-node nodemon`

#### 1.1.2 Configure TypeScript
1.1.2.1 Create `tsconfig.json` in project root
1.1.2.2 Set `compilerOptions.target` to `ES2022`
1.1.2.3 Set `compilerOptions.module` to `NodeNext`
1.1.2.4 Set `compilerOptions.outDir` to `dist/`
1.1.2.5 Set `compilerOptions.strict` to `true`

#### 1.1.3 Create Folder Structure
1.1.3.1 Create `src/` directory
1.1.3.2 Create `src/routes/`
1.1.3.3 Create `src/services/`
1.1.3.4 Create `src/middleware/`
1.1.3.5 Create `src/models/`
1.1.3.6 Create `src/utils/`
1.1.3.7 Create `src/websocket/`
1.1.3.8 Create `src/config/`

#### 1.1.4 Environment Config
1.1.4.1 Create `.env` file with placeholder values
1.1.4.2 Create `src/config/env.ts`
1.1.4.3 Import `dotenv` and call `config()`
1.1.4.4 Export typed object with keys: `DATABASE_URL`, `JWT_SECRET`, `R2_ACCESS_KEY`, `R2_SECRET_KEY`, `R2_BUCKET_NAME`, `R2_ENDPOINT`, `INFISICAL_TOKEN`, `FCM_SERVER_KEY`, `SMTP_HOST`, `SMTP_USER`, `SMTP_PASS`
1.1.4.5 Add validation: throw error if any required key is missing

#### 1.1.5 Entry Point
1.1.5.1 Create `src/index.ts`
1.1.5.2 Import and instantiate Fastify with `{ logger: true }`
1.1.5.3 Register `@fastify/cors` plugin
1.1.5.4 Register `@fastify/websocket` plugin
1.1.5.5 Add health check route `GET /health` returning `{ status: 'ok' }`
1.1.5.6 Call `fastify.listen({ port: 3000, host: '0.0.0.0' })`

#### 1.1.6 Package Scripts
1.1.6.1 Add `"dev": "nodemon src/index.ts"` to `package.json` scripts
1.1.6.2 Add `"build": "tsc"` to scripts
1.1.6.3 Add `"start": "node dist/index.js"` to scripts

### 1.2 Database Setup
#### 1.2.1 Create Turso Account
1.2.1.1 Go to turso.tech and create a free account
1.2.1.2 Create a database named `pingme-prod`
1.2.1.3 Copy the database connection URL
1.2.1.4 Copy the auth token
1.2.1.5 Add both to `.env` as `DATABASE_URL` and `DATABASE_AUTH_TOKEN`

#### 1.2.2 Database Client
1.2.2.1 Create `src/config/database.ts`
1.2.2.2 Import `createClient` from `@libsql/client`
1.2.2.3 Initialize client with URL and authToken from env config
1.2.2.4 Export the singleton `db` client

#### 1.2.3 Schema File
1.2.3.1 Create `src/models/schema.sql`
1.2.3.2 Add `CREATE TABLE users` statement with columns: id, username, display_name, bio, phone, email, phone_visible, last_seen, last_seen_privacy, status, created_at, updated_at
1.2.3.3 Add `CREATE TABLE sessions` with: id, user_id, device_info, ip_address, passkey_credential_id, created_at, last_active, is_active
1.2.3.4 Add `CREATE TABLE conversations` with: id, type, title, description, photo_url, created_by, max_members, slow_mode_seconds, is_public, created_at, updated_at
1.2.3.5 Add `CREATE TABLE conversation_members` with: conversation_id, user_id, role, joined_at, muted_until
1.2.3.6 Add `CREATE TABLE messages` with: id, conversation_id, sender_id, type, encrypted_content, reply_to_id, forwarded_from, is_edited, edited_at, self_destruct_seconds, created_at, deleted_for_everyone
1.2.3.7 Add `CREATE TABLE message_status` with: message_id, user_id, status, status_at, deleted_for_self
1.2.3.8 Add `CREATE TABLE message_reactions` with: message_id, user_id, emoji, created_at
1.2.3.9 Add `CREATE TABLE pinned_messages` with: conversation_id, message_id, pinned_by, pinned_at
1.2.3.10 Add `CREATE TABLE files` with: id, storage_account_id, bucket_key, file_type, file_size, mime_type, uploaded_by, created_at
1.2.3.11 Add `CREATE TABLE storage_accounts` with: id, label, provider, total_capacity_bytes, used_bytes, priority, is_active, config_secret_key, created_at
1.2.3.12 Add `CREATE TABLE db_accounts` with: id, label, provider, connection_secret_key, is_active, priority, created_at
1.2.3.13 Add `CREATE TABLE otp_attempts` with: identifier, attempt_count, locked_until, lock_tier, last_attempt
1.2.3.14 Add `CREATE TABLE user_2fa` with: user_id, totp_secret_encrypted, is_enabled, backup_codes_encrypted
1.2.3.15 Add `CREATE TABLE blocked_users` with: blocker_id, blocked_id, created_at
1.2.3.16 Add `CREATE TABLE reports` with: id, reporter_id, reported_user_id, reported_message_id, reason, status, created_at
1.2.3.17 Add `CREATE TABLE invite_links` with: id, conversation_id, created_by, link_code, max_uses, current_uses, expires_at, requires_approval, is_active, created_at
1.2.3.18 Add `CREATE TABLE call_logs` with: id, conversation_id, caller_id, call_type, started_at, ended_at, duration_seconds, status

#### 1.2.4 Migration Script
1.2.4.1 Create `src/models/migrate.ts`
1.2.4.2 Read `schema.sql` file contents
1.2.4.3 Split content by semicolons into individual statements
1.2.4.4 Loop through each statement and call `db.execute(statement)`
1.2.4.5 Log success message per table created
1.2.4.6 Log error and exit if any statement fails
1.2.4.7 Add `"migrate": "ts-node src/models/migrate.ts"` to package.json scripts

### 1.3 Storage Setup
#### 1.3.1 Cloudflare R2 Account
1.3.1.1 Create free Cloudflare account at cloudflare.com
1.3.1.2 Navigate to R2 Object Storage
1.3.1.3 Create bucket named `pingme-media`
1.3.1.4 Generate R2 API token with read/write permissions
1.3.1.5 Copy Access Key ID and Secret Access Key
1.3.1.6 Copy R2 endpoint URL
1.3.1.7 Add all three values to `.env` file

#### 1.3.2 Storage Service
1.3.2.1 Run `npm install @aws-sdk/client-s3`
1.3.2.2 Create `src/services/storage.ts`
1.3.2.3 Import `S3Client`, `PutObjectCommand`, `GetObjectCommand`, `DeleteObjectCommand`
1.3.2.4 Initialize S3Client with R2 endpoint, region `auto`, and credentials from env
1.3.2.5 Export function `uploadFile(buffer, key, mimeType)` that puts object and returns file URL
1.3.2.6 Export function `getFileUrl(key)` that generates presigned URL with 1hr expiry
1.3.2.7 Export function `deleteFile(key)` that deletes object by key

### 1.4 Flutter App Setup
#### 1.4.1 Initialize Project
1.4.1.1 Run `flutter create pingme_app --org com.pingme --platforms android`
1.4.1.2 Navigate into `pingme_app/` directory

#### 1.4.2 Add Dependencies
1.4.2.1 Open `pubspec.yaml`
1.4.2.2 Add `flutter_bloc` under dependencies
1.4.2.3 Add `dio`
1.4.2.4 Add `web_socket_channel`
1.4.2.5 Add `flutter_webrtc`
1.4.2.6 Add `hive` and `hive_flutter`
1.4.2.7 Add `firebase_messaging` and `firebase_core`
1.4.2.8 Add `image_picker`
1.4.2.9 Add `cached_network_image`
1.4.2.10 Add `intl`
1.4.2.11 Add `qr_flutter`
1.4.2.12 Add `flutter_secure_storage`
1.4.2.13 Add `json_annotation` and `equatable`
1.4.2.14 Add `go_router`
1.4.2.15 Run `flutter pub get`

#### 1.4.3 Create Folder Structure
1.4.3.1 Create `lib/app/`
1.4.3.2 Create `lib/core/config/`
1.4.3.3 Create `lib/core/crypto/`
1.4.3.4 Create `lib/core/network/`
1.4.3.5 Create `lib/core/storage/`
1.4.3.6 Create `lib/features/auth/data/`
1.4.3.7 Create `lib/features/auth/domain/`
1.4.3.8 Create `lib/features/auth/presentation/`
1.4.3.9 Create `lib/features/chat/data/`
1.4.3.10 Create `lib/features/chat/domain/`
1.4.3.11 Create `lib/features/chat/presentation/`
1.4.3.12 Create `lib/features/calls/`
1.4.3.13 Create `lib/features/groups/`
1.4.3.14 Create `lib/features/channels/`
1.4.3.15 Create `lib/features/profile/`
1.4.3.16 Create `lib/features/settings/`
1.4.3.17 Create `lib/shared/widgets/`
1.4.3.18 Create `lib/shared/utils/`
1.4.3.19 Create `lib/shared/constants/`
1.4.3.20 Create `lib/l10n/`

#### 1.4.4 App Config
1.4.4.1 Create `lib/core/config/app_config.dart`
1.4.4.2 Define `static const String apiBaseUrl`
1.4.4.3 Define `static const String wsUrl`
1.4.4.4 Define `static const int maxMessageLength = 4096`
1.4.4.5 Define `static const int maxGroupMembers = 200`
1.4.4.6 Define `static const int editWindowMinutes = 5`
1.4.4.7 Define `static const int minUsernameLength = 6`

---

## 2. AUTHENTICATION & AUTHORIZATION

### 2.1 Backend Auth Middleware
#### 2.1.1 Create Auth Middleware
2.1.1.1 Create `src/middleware/auth.ts`
2.1.1.2 Export async function `authMiddleware(request, reply)`
2.1.1.3 Extract `Authorization` header from request
2.1.1.4 Check header exists and starts with `Bearer `
2.1.1.5 Extract token string after `Bearer `
2.1.1.6 Call `jsonwebtoken.verify(token, JWT_SECRET)`
2.1.1.7 Attach decoded `{ id, username }` to `request.user`
2.1.1.8 If token missing: return 401 with `{ error: 'Token required' }`
2.1.1.9 If token invalid: return 401 with `{ error: 'Invalid token' }`

### 2.2 Backend Auth Routes
#### 2.2.1 Route Setup
2.2.1.1 Create `src/routes/auth.ts`
2.2.1.2 Export function that accepts Fastify instance
2.2.1.3 Register all auth routes inside this function
2.2.1.4 In `src/index.ts`, import and register auth routes with prefix `/api/v1/auth`

#### 2.2.2 Registration Endpoint
2.2.2.1 Define `POST /register` route
2.2.2.2 Accept body: `{ email?, phone?, username, display_name }`
2.2.2.3 Validate username length >= 6 characters
2.2.2.4 Convert username to lowercase
2.2.2.5 Check username against reserved list: `['admin','support','pingme','system','help','official']`
2.2.2.6 Query `users` table to check username uniqueness (case-insensitive)
2.2.2.7 Generate UUID for new user ID using `uuid.v4()`
2.2.2.8 Insert new row into `users` table
2.2.2.9 Generate JWT access token with `{ id, username }` payload, expiry 7 days
2.2.2.10 Generate JWT refresh token with `{ id }` payload, expiry 30 days
2.2.2.11 Create row in `sessions` table with device info and IP
2.2.2.12 Return `{ user, accessToken, refreshToken }`

#### 2.2.3 OTP Send Endpoint
2.2.3.1 Define `POST /otp/send` route
2.2.3.2 Accept body: `{ identifier, method }` where method is `email` or `whatsapp`
2.2.3.3 Query `otp_attempts` table for this identifier
2.2.3.4 Check if `locked_until` > current time; if so return 429 with lockout duration
2.2.3.5 Generate random 6-digit OTP number
2.2.3.6 Hash OTP using bcrypt
2.2.3.7 Store hashed OTP in `otp_codes` table with identifier and 5-minute expiry
2.2.3.8 If method is `email`: send OTP via SMTP using nodemailer
2.2.3.9 If method is `whatsapp`: send OTP via WhatsApp Business API
2.2.3.10 Return `{ success: true, expiresIn: 300 }`

#### 2.2.4 OTP Verify Endpoint
2.2.4.1 Define `POST /otp/verify` route
2.2.4.2 Accept body: `{ identifier, otp }`
2.2.4.3 Query stored OTP hash for this identifier
2.2.4.4 Check OTP not expired (created_at + 5min > now)
2.2.4.5 Compare submitted OTP against stored hash using bcrypt
2.2.4.6 If invalid: increment `attempt_count` in `otp_attempts`
2.2.4.7 If `attempt_count` reaches 3: set `lock_tier = 1`, `locked_until = now + 1 hour`
2.2.4.8 If `attempt_count` reaches 6: set `lock_tier = 2`, `locked_until = now + 4 hours`
2.2.4.9 If `attempt_count` reaches 9: set `lock_tier = 3`, `locked_until = now + 24 hours`
2.2.4.10 Return 401 with `{ error, remainingAttempts, lockoutDuration? }`
2.2.4.11 If valid: find user by identifier or flag as new registration needed
2.2.4.12 Generate JWT access and refresh tokens
2.2.4.13 Create session in `sessions` table
2.2.4.14 Reset `attempt_count` to 0 in `otp_attempts`
2.2.4.15 Delete used OTP from `otp_codes`
2.2.4.16 Return `{ user, accessToken, refreshToken, isNewUser }`

#### 2.2.5 Logout Endpoint
2.2.5.1 Define `POST /logout` route with auth middleware
2.2.5.2 Get current session ID from JWT payload
2.2.5.3 Update `sessions` table: set `is_active = 0` where id matches
2.2.5.4 Return `{ success: true }`

#### 2.2.6 Session Management Endpoints
2.2.6.1 Define `GET /sessions` route with auth middleware
2.2.6.2 Query `sessions` where `user_id = request.user.id` and `is_active = 1`
2.2.6.3 Return array of `{ id, device_info, ip_address, created_at, last_active }`
2.2.6.4 Define `DELETE /sessions/:id` route with auth middleware
2.2.6.5 Verify session belongs to `request.user.id`
2.2.6.6 Set `is_active = 0` on that session
2.2.6.7 Return `{ success: true }`

### 2.3 Flutter Auth UI
#### 2.3.1 Welcome Screen
2.3.1.1 Create `lib/features/auth/presentation/screens/welcome_screen.dart`
2.3.1.2 Create StatelessWidget `WelcomeScreen`
2.3.1.3 Add app logo centered at top
2.3.1.4 Add tagline text "Private. Fast. Yours."
2.3.1.5 Add button "Continue with Passkey"
2.3.1.6 Add button "Continue with Email"
2.3.1.7 Add button "Continue with Phone"
2.3.1.8 Apply dark gradient background
2.3.1.9 Wire each button to navigate to corresponding screen

#### 2.3.2 OTP Screen
2.3.2.1 Create `lib/features/auth/presentation/screens/otp_screen.dart`
2.3.2.2 Accept `identifier` and `method` as constructor parameters
2.3.2.3 Add 6-digit OTP input field with auto-focus
2.3.2.4 Add countdown timer starting at 60 seconds
2.3.2.5 Add "Resend OTP" button enabled only when timer reaches 0
2.3.2.6 On submit: call `verifyOtp` from auth repository
2.3.2.7 On success: navigate to username setup screen
2.3.2.8 On failure: show error with remaining attempts

#### 2.3.3 Username Setup Screen
2.3.3.1 Create `lib/features/auth/presentation/screens/username_setup_screen.dart`
2.3.3.2 Add text field for username with live validation (min 6 chars)
2.3.3.3 Add text field for display name
2.3.3.4 Add optional text field for bio
2.3.3.5 Add optional profile photo picker button
2.3.3.6 Add submit button
2.3.3.7 On submit: call `register` from auth repository
2.3.3.8 On success: navigate to home/conversations screen

### 2.4 Flutter Auth Data Layer
#### 2.4.1 Auth Repository
2.4.1.1 Create `lib/features/auth/data/auth_repository.dart`
2.4.1.2 Add method `sendOtp(String identifier, String method)` calling `POST /auth/otp/send`
2.4.1.3 Add method `verifyOtp(String identifier, String otp)` calling `POST /auth/otp/verify`
2.4.1.4 Add method `register(String username, String displayName, String? email, String? phone)` calling `POST /auth/register`
2.4.1.5 Add method `logout()` calling `POST /auth/logout`
2.4.1.6 Add method `getSessions()` calling `GET /auth/sessions`
2.4.1.7 Add method `revokeSession(String sessionId)` calling `DELETE /auth/sessions/:id`

#### 2.4.2 Auth BLoC
2.4.2.1 Create `lib/features/auth/domain/auth_bloc.dart`
2.4.2.2 Define states: `AuthInitial`, `AuthLoading`, `AuthOtpSent`, `AuthAuthenticated`, `AuthError`
2.4.2.3 Define events: `SendOtp`, `VerifyOtp`, `Register`, `Logout`
2.4.2.4 Handle `SendOtp`: emit Loading, call sendOtp, emit OtpSent or Error
2.4.2.5 Handle `VerifyOtp`: emit Loading, call verifyOtp, save tokens, emit Authenticated or Error
2.4.2.6 Handle `Register`: emit Loading, call register, emit Authenticated or Error
2.4.2.7 Handle `Logout`: call logout, clear tokens, emit Initial

### 2.5 Token Management
2.5.1 Create `lib/core/network/token_manager.dart`
2.5.2 Initialize `FlutterSecureStorage` instance
2.5.3 Add method `saveTokens(String access, String refresh)` writing to secure storage
2.5.4 Add method `getAccessToken()` reading from secure storage
2.5.5 Add method `getRefreshToken()` reading from secure storage
2.5.6 Add method `clearTokens()` deleting both from secure storage

### 2.6 API Client
2.6.1 Create `lib/core/network/api_client.dart`
2.6.2 Initialize Dio instance with `baseUrl` from app_config
2.6.3 Add request interceptor: read access token from TokenManager
2.6.4 Attach `Authorization: Bearer <token>` header to every request
2.6.5 Add response interceptor: on 401, attempt token refresh
2.6.6 If refresh succeeds: retry original request with new token
2.6.7 If refresh fails: clear tokens and navigate to login screen

### 2.7 2FA (TOTP)
#### 2.7.1 Backend 2FA
2.7.1.1 Run `npm install otplib`
2.7.1.2 Define `POST /api/v1/auth/2fa/enable` with auth middleware
2.7.1.3 Generate TOTP secret using `otplib.authenticator.generateSecret()`
2.7.1.4 Encrypt secret and store in `user_2fa` table
2.7.1.5 Generate otpauth URI for QR code
2.7.1.6 Return `{ qrUri, secret }`
2.7.1.7 Define `POST /api/v1/auth/2fa/verify`
2.7.1.8 Accept `{ code }`, verify against stored TOTP secret
2.7.1.9 Return success or error
2.7.1.10 Define `POST /api/v1/auth/2fa/disable` with auth middleware
2.7.1.11 Require current TOTP code for verification
2.7.1.12 Delete row from `user_2fa` table

#### 2.7.2 Flutter 2FA UI
2.7.2.1 Create `lib/features/settings/screens/two_factor_screen.dart`
2.7.2.2 Show QR code image from otpauth URI
2.7.2.3 Add input field for verification code
2.7.2.4 Add enable/disable toggle
2.7.2.5 Wire to 2FA API endpoints

---

*Continued in Part 2/3...*
