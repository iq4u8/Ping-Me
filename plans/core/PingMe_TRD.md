# 🛠️ PingMe — Technical Requirements Document (TRD)

> **Version:** 1.0 | **Date:** May 3, 2026 | **Status:** Draft  
> **Companion:** [PingMe_PRD.md](./PingMe_PRD.md)

---

## 1. System Architecture Overview

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Flutter App │────▶│  API Gateway /   │────▶│  Core Backend    │
│  (Android)   │◀────│  WebSocket Layer │◀────│  (Node.js / Go)  │
└─────────────┘     └──────────────────┘     └────────┬────────┘
                                                       │
                    ┌──────────────────────────────────┼──────────────────┐
                    │                    │              │                  │
              ┌─────▼─────┐     ┌───────▼───┐   ┌─────▼─────┐   ┌───────▼──────┐
              │ Turso DB   │     │ Cloudflare │   │ Infisical  │   │  Push/OTP    │
              │ (libSQL)   │     │ R2 Storage │   │ (Secrets)  │   │  Services    │
              └────────────┘     └───────────┘   └───────────┘   └──────────────┘

┌───────────────────────────────────────────────────────────────────────┐
│  Desktop Admin App (.exe) — Electron/Tauri — Owner/SuperAdmin ONLY  │
└───────────────────────────────────────────────────────────────────────┘
```

---

## 2. Technology Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **Mobile App** | Flutter (Dart) | Cross-platform ready; Android first |
| **Backend** | Node.js (Express/Fastify) or Go | Real-time capable; free-tier friendly |
| **Database** | Turso (libSQL) | Edge-first; generous free tier (9GB storage, 500M reads/mo) |
| **Object Storage** | Cloudflare R2 | S3-compatible; 10GB free; no egress fees |
| **Real-time** | WebSocket (Socket.io / ws) | Typing indicators, presence, live messages |
| **Encryption** | Signal Protocol (libsignal) | Industry gold standard E2EE |
| **Auth** | Google Passkey (FIDO2/WebAuthn) + OTP | Passwordless primary; OTP fallback |
| **Secrets** | Infisical | Open-source; free tier; hot-reload capable |
| **Push Notifications** | Firebase Cloud Messaging (FCM) | Free; reliable for Android |
| **OTP Delivery** | WhatsApp Business API / SMTP | User's choice at signup |
| **Admin App** | Electron or Tauri | Desktop .exe for Windows |
| **Calling** | WebRTC | P2P encrypted voice/video |
| **Deployment** | Cloudflare Workers / Railway / Fly.io | Free tiers available |

---

## 3. Database Schema (Turso/libSQL)

### 3.1 — Core Tables

```sql
-- Users
CREATE TABLE users (
  id TEXT PRIMARY KEY,              -- UUID, immutable
  username TEXT UNIQUE NOT NULL,    -- min 6 chars, case-insensitive
  display_name TEXT,
  bio TEXT,
  phone TEXT,                       -- optional, encrypted
  email TEXT,                       -- optional, encrypted
  phone_visible BOOLEAN DEFAULT 0,
  last_seen TIMESTAMP,
  last_seen_privacy TEXT DEFAULT 'everyone', -- everyone/contacts/nobody
  status TEXT DEFAULT 'offline',    -- online/offline/recently
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

-- Auth / Sessions
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users(id),
  device_info TEXT,                 -- JSON: device name, OS, app version
  ip_address TEXT,
  passkey_credential_id TEXT,       -- FIDO2 credential
  created_at TIMESTAMP,
  last_active TIMESTAMP,
  is_active BOOLEAN DEFAULT 1
);

-- Conversations (1-on-1 and groups)
CREATE TABLE conversations (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,               -- 'direct' / 'group' / 'channel'
  title TEXT,                       -- for groups/channels
  description TEXT,
  photo_url TEXT,
  created_by TEXT REFERENCES users(id),
  max_members INTEGER DEFAULT 200,
  slow_mode_seconds INTEGER DEFAULT 0,
  is_public BOOLEAN DEFAULT 0,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Conversation Members
CREATE TABLE conversation_members (
  conversation_id TEXT REFERENCES conversations(id),
  user_id TEXT REFERENCES users(id),
  role TEXT DEFAULT 'member',       -- creator/admin/moderator/member
  joined_at TIMESTAMP,
  muted_until TIMESTAMP,
  PRIMARY KEY (conversation_id, user_id)
);

-- Messages (E2EE — server stores ciphertext only)
CREATE TABLE messages (
  id TEXT PRIMARY KEY,              -- globally unique UUID
  conversation_id TEXT REFERENCES conversations(id),
  sender_id TEXT REFERENCES users(id),
  type TEXT NOT NULL,               -- text/image/video/voice/doc/sticker/gif/location/poll/contact
  encrypted_content BLOB,           -- E2EE ciphertext
  reply_to_id TEXT,                 -- for threaded replies
  forwarded_from TEXT,              -- original message ref (nullable)
  is_edited BOOLEAN DEFAULT 0,
  edited_at TIMESTAMP,
  self_destruct_seconds INTEGER,    -- NULL = no auto-delete
  created_at TIMESTAMP,
  deleted_for_everyone BOOLEAN DEFAULT 0
);

-- Message Status (per-recipient)
CREATE TABLE message_status (
  message_id TEXT REFERENCES messages(id),
  user_id TEXT REFERENCES users(id),
  status TEXT DEFAULT 'sent',       -- sent/delivered/read
  status_at TIMESTAMP,
  deleted_for_self BOOLEAN DEFAULT 0,
  PRIMARY KEY (message_id, user_id)
);

-- Message Reactions
CREATE TABLE message_reactions (
  message_id TEXT REFERENCES messages(id),
  user_id TEXT REFERENCES users(id),
  emoji TEXT NOT NULL,
  created_at TIMESTAMP,
  PRIMARY KEY (message_id, user_id, emoji)
);

-- Pinned Messages
CREATE TABLE pinned_messages (
  conversation_id TEXT REFERENCES conversations(id),
  message_id TEXT REFERENCES messages(id),
  pinned_by TEXT REFERENCES users(id),
  pinned_at TIMESTAMP,
  PRIMARY KEY (conversation_id, message_id)
);
```

### 3.2 — Media & Storage Tables

```sql
-- File Registry (maps file to storage account)
CREATE TABLE files (
  id TEXT PRIMARY KEY,              -- globally unique UUID
  storage_account_id TEXT,          -- which R2 account
  bucket_key TEXT,                  -- key within the bucket
  file_type TEXT,                   -- image/video/voice/document
  file_size INTEGER,                -- bytes
  mime_type TEXT,
  uploaded_by TEXT REFERENCES users(id),
  created_at TIMESTAMP
);

-- Storage Accounts (managed by admin app)
CREATE TABLE storage_accounts (
  id TEXT PRIMARY KEY,
  label TEXT,                       -- "Primary R2", "Media Overflow"
  provider TEXT,                    -- 'cloudflare_r2' / 'backblaze_b2' / etc.
  total_capacity_bytes BIGINT,
  used_bytes BIGINT DEFAULT 0,
  priority INTEGER DEFAULT 0,      -- lower = higher priority
  is_active BOOLEAN DEFAULT 1,
  config_secret_key TEXT,           -- Infisical secret reference
  created_at TIMESTAMP
);

-- Database Accounts (multi-Turso)
CREATE TABLE db_accounts (
  id TEXT PRIMARY KEY,
  label TEXT,
  provider TEXT DEFAULT 'turso',
  connection_secret_key TEXT,       -- Infisical reference
  is_active BOOLEAN DEFAULT 1,
  priority INTEGER DEFAULT 0,
  created_at TIMESTAMP
);
```

### 3.3 — Auth & Security Tables

```sql
-- OTP tracking
CREATE TABLE otp_attempts (
  identifier TEXT,                  -- phone or email
  attempt_count INTEGER DEFAULT 0,
  locked_until TIMESTAMP,
  lock_tier INTEGER DEFAULT 0,     -- 0=none, 1=1hr, 2=4hr, 3=24hr
  last_attempt TIMESTAMP
);

-- 2FA (TOTP)
CREATE TABLE user_2fa (
  user_id TEXT PRIMARY KEY REFERENCES users(id),
  totp_secret_encrypted BLOB,
  is_enabled BOOLEAN DEFAULT 0,
  backup_codes_encrypted BLOB
);

-- Blocked Users
CREATE TABLE blocked_users (
  blocker_id TEXT REFERENCES users(id),
  blocked_id TEXT REFERENCES users(id),
  created_at TIMESTAMP,
  PRIMARY KEY (blocker_id, blocked_id)
);

-- Reports
CREATE TABLE reports (
  id TEXT PRIMARY KEY,
  reporter_id TEXT REFERENCES users(id),
  reported_user_id TEXT,
  reported_message_id TEXT,
  reason TEXT,
  status TEXT DEFAULT 'pending',    -- pending/reviewed/actioned
  created_at TIMESTAMP
);
```

### 3.4 — Invite Links

```sql
CREATE TABLE invite_links (
  id TEXT PRIMARY KEY,
  conversation_id TEXT REFERENCES conversations(id),
  created_by TEXT REFERENCES users(id),
  link_code TEXT UNIQUE,
  max_uses INTEGER,                 -- NULL = unlimited
  current_uses INTEGER DEFAULT 0,
  expires_at TIMESTAMP,             -- NULL = never
  requires_approval BOOLEAN DEFAULT 0,
  is_active BOOLEAN DEFAULT 1,
  created_at TIMESTAMP
);
```

### 3.5 — Call Logs

```sql
CREATE TABLE call_logs (
  id TEXT PRIMARY KEY,
  conversation_id TEXT,
  caller_id TEXT REFERENCES users(id),
  call_type TEXT,                   -- 'voice' / 'video'
  started_at TIMESTAMP,
  ended_at TIMESTAMP,
  duration_seconds INTEGER,
  status TEXT                       -- completed/missed/declined
);
```

---

## 4. API Architecture

### 4.1 — REST Endpoints

```
AUTH
  POST   /api/v1/auth/register          — Register with email/phone/passkey
  POST   /api/v1/auth/login             — Login (passkey/OTP)
  POST   /api/v1/auth/otp/send          — Send OTP (WhatsApp/Email)
  POST   /api/v1/auth/otp/verify        — Verify OTP
  POST   /api/v1/auth/passkey/register  — Register passkey credential
  POST   /api/v1/auth/passkey/verify    — Verify passkey login
  POST   /api/v1/auth/logout            — Logout current session
  DELETE /api/v1/auth/sessions/:id      — Remote logout a session
  GET    /api/v1/auth/sessions          — List active sessions

USERS
  GET    /api/v1/users/me               — Get own profile
  PUT    /api/v1/users/me               — Update profile
  GET    /api/v1/users/:username        — Get user by username
  POST   /api/v1/users/block/:userId    — Block user
  DELETE /api/v1/users/block/:userId    — Unblock user
  DELETE /api/v1/users/me               — Delete account

CONVERSATIONS
  POST   /api/v1/conversations          — Create group/channel
  GET    /api/v1/conversations          — List user's conversations
  GET    /api/v1/conversations/:id      — Get conversation details
  PUT    /api/v1/conversations/:id      — Update group settings
  POST   /api/v1/conversations/:id/members — Add member
  DELETE /api/v1/conversations/:id/members/:userId — Remove member

MESSAGES
  POST   /api/v1/messages               — Send message (encrypted)
  GET    /api/v1/messages/:convId       — Get messages (paginated)
  PUT    /api/v1/messages/:id           — Edit message (within 5 min)
  DELETE /api/v1/messages/:id           — Delete message
  POST   /api/v1/messages/:id/react     — Add reaction
  GET    /api/v1/messages/search        — Search messages

MEDIA
  POST   /api/v1/media/upload           — Upload file to R2
  GET    /api/v1/media/:fileId          — Download/stream file

CALLS
  POST   /api/v1/calls/initiate         — Start a call
  POST   /api/v1/calls/:id/answer       — Answer call
  POST   /api/v1/calls/:id/end          — End call
  GET    /api/v1/calls/history          — Call logs

INVITE LINKS
  POST   /api/v1/invites                — Create invite link
  GET    /api/v1/invites/:code          — Get invite info
  POST   /api/v1/invites/:code/join     — Join via link
  DELETE /api/v1/invites/:id            — Revoke link
```

### 4.2 — WebSocket Events

```
CLIENT → SERVER:
  message:send          — Send encrypted message
  message:edit          — Edit message
  message:delete        — Delete message
  message:react         — Add/remove reaction
  typing:start          — Start typing indicator
  typing:stop           — Stop typing indicator
  presence:update       — Online/offline status
  call:signal           — WebRTC signaling

SERVER → CLIENT:
  message:new           — New message received
  message:edited        — Message was edited
  message:deleted       — Message was deleted
  message:reaction      — Reaction added/removed
  message:status        — Delivery/read receipt update
  typing:indicator      — Someone is typing
  presence:changed      — User online/offline
  call:incoming         — Incoming call
  call:signal           — WebRTC signaling
  call:ended            — Call ended
```

---

## 5. Encryption Architecture (Signal Protocol)

```
┌──────────────┐                           ┌──────────────┐
│   User A     │                           │   User B     │
│              │                           │              │
│ Identity Key │    Key Exchange (X3DH)     │ Identity Key │
│ Signed PreKey│◄─────────────────────────▶│ Signed PreKey│
│ One-Time Keys│    via Server             │ One-Time Keys│
│              │                           │              │
│ ┌──────────┐ │   Double Ratchet          │ ┌──────────┐ │
│ │ Ratchet  │ │◄─────────────────────────▶│ │ Ratchet  │ │
│ │ State    │ │   (Per-message keys)      │ │ State    │ │
│ └──────────┘ │                           │ └──────────┘ │
└──────────────┘                           └──────────────┘
        │                                          │
        ▼                                          ▼
  Plaintext → Encrypt → Ciphertext ──SERVER── Ciphertext → Decrypt → Plaintext
                          (server sees ONLY ciphertext)
```

**Key Points:**
- X3DH (Extended Triple Diffie-Hellman) for initial key agreement
- Double Ratchet for forward secrecy (every message has unique key)
- Server stores ONLY ciphertext — zero-knowledge architecture
- Keys generated and stored on-device only
- Recovery: encrypted local backup with user-chosen passphrase

---

## 6. Storage Routing System

```
Upload Request
      │
      ▼
┌─────────────────┐
│ Storage Router   │
│                  │
│ 1. Get active    │
│    accounts      │
│ 2. Sort by       │
│    priority      │
│ 3. Pick least-   │
│    full bucket   │
│ 4. Upload file   │
│ 5. Save mapping  │
│    to file_registry│
└────────┬─────────┘
         │
    ┌────┴────┐ Failure?
    │         │
    ▼         ▼
 Success   Retry on next account
    │         │
    ▼         ▼
 Return    If all fail → error
 file_id
```

**Rules:**
- New files always go to least-full active account
- No rebalancing of old files
- File-to-bucket mapping stored in `files` table
- All accounts active by default
- Auto-failover on write failure

---

## 7. Authentication Flow

```
┌─────────────────────────────────────────────────┐
│                  SIGNUP FLOW                     │
├─────────────────────────────────────────────────┤
│                                                  │
│  1. User opens app                               │
│  2. Choose: Email / Phone / Passkey              │
│     ├─ Passkey → FIDO2 registration → Done      │
│     ├─ Email → Enter email → OTP sent → Verify  │
│     └─ Phone → Enter phone → WhatsApp OTP → Verify│
│  3. Set username (min 6 chars)                   │
│  4. Set display name + optional bio/photo        │
│  5. Generate E2EE key pair on device             │
│  6. Upload public keys to server                 │
│  7. Account ready                                │
│                                                  │
├─────────────────────────────────────────────────┤
│                  LOGIN FLOW                      │
├─────────────────────────────────────────────────┤
│                                                  │
│  Primary: Google Passkey (automatic, 1-tap)      │
│  Fallback: Username + OTP (email/WhatsApp)       │
│                                                  │
│  OTP Rate Limiting:                              │
│  Attempt 1-3 → OK                                │
│  Fail 3x → Lock 1 hour                          │
│  Attempt 4-6 → OK                                │
│  Fail 3x → Lock 4 hours                         │
│  Attempt 7-9 → OK                                │
│  Fail 3x → Lock 24 hours                        │
│                                                  │
└─────────────────────────────────────────────────┘
```

---

## 8. WebRTC Calling Architecture

```
┌─────────┐    Signaling (WebSocket)    ┌─────────┐
│ Caller  │◄──────────────────────────▶│ Callee  │
│         │                             │         │
│         │    P2P Media (SRTP/E2EE)    │         │
│         │◄═══════════════════════════▶│         │
└─────────┘                             └─────────┘

- ICE candidates exchanged via WebSocket signaling
- STUN server: Google's free STUN (stun.l.google.com:19302)
- TURN server: Metered.ca free tier (fallback for NAT traversal)
- Adaptive bitrate: auto-adjust quality based on network stats
- Group calls: mesh topology for ≤4, SFU for 5-10 participants
```

---

## 9. Desktop Admin App Architecture

```
┌─────────────────────────────────────────────────┐
│          Desktop Admin App (.exe)                 │
│          Built with: Electron / Tauri            │
├─────────────────────────────────────────────────┤
│                                                  │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │Dashboard │ │Users     │ │Storage Manager   │ │
│  │Analytics │ │Mgmt      │ │& Config          │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │System    │ │Audit     │ │Alerts &          │ │
│  │Health    │ │Logs      │ │Notifications     │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
│                                                  │
│  Auth: Separate admin credentials (not app auth) │
│  Access: Super Admin + Owner + Dev team ONLY     │
│  Invisible to all app users                      │
│                                                  │
└──────────────────┬──────────────────────────────┘
                   │ HTTPS + Admin JWT
                   ▼
          ┌────────────────┐
          │ Admin API       │
          │ /admin/v1/*     │
          │ (Separate from  │
          │  user API)      │
          └────────────────┘
```

**Admin API Endpoints:**
```
GET    /admin/v1/dashboard/stats      — Analytics overview
GET    /admin/v1/users                — List/search users
POST   /admin/v1/users/:id/ban       — Ban user
POST   /admin/v1/users/:id/unban     — Unban user
DELETE /admin/v1/messages/:id         — Delete content
GET    /admin/v1/storage/overview     — Storage stats
POST   /admin/v1/storage/accounts     — Add storage account
DELETE /admin/v1/storage/accounts/:id — Remove storage account
GET    /admin/v1/health               — System health check
GET    /admin/v1/config               — View config
PUT    /admin/v1/config               — Update config
GET    /admin/v1/audit-logs           — Audit trail
```

---

## 10. Infrastructure — Free Tier Strategy

| Service | Free Tier | Usage |
|---------|-----------|-------|
| **Turso** | 9 GB storage, 500M reads/mo | Primary database |
| **Cloudflare R2** | 10 GB storage, 1M Class A ops/mo | Media storage |
| **Cloudflare Workers** | 100K requests/day | API hosting |
| **Firebase (FCM)** | Unlimited push notifications | Push notifications |
| **Infisical** | 5 team members, unlimited secrets | Secrets management |
| **Railway** | $5 free credit/month | Backend hosting (alt) |
| **Fly.io** | 3 shared VMs, 3 GB storage | Backend hosting (alt) |
| **Metered.ca** | Free TURN server credits | WebRTC TURN fallback |

**Scaling Strategy:**
- Multi-account sharding (multiple R2 + Turso accounts)
- Alert at 70%/85%/95% usage thresholds
- Add new free-tier accounts dynamically via admin app

---

## 11. Security Requirements

| Requirement | Implementation |
|-------------|---------------|
| E2EE (all messages) | Signal Protocol (libsignal-protocol-dart) |
| E2EE (calls) | SRTP with DTLS key exchange |
| Zero-knowledge server | Server stores only ciphertext |
| 2FA | TOTP (Google Authenticator compatible) |
| Passkey auth | FIDO2/WebAuthn via platform authenticator |
| Anti-screenshot | FLAG_SECURE on Android for secret chats |
| Session management | JWT + refresh tokens; remote logout |
| Rate limiting | OTP: 3-attempt tiers; API: per-IP throttling |
| Input validation | Server-side validation on all inputs |
| SQL injection | Parameterized queries (libSQL driver) |

---

## 12. Data Cleanup & Retention

```
ACCOUNT DELETION FLOW:
  1. User requests deletion → 7-day grace period
  2. After grace period:
     a. Remove user from all groups/channels
     b. In 1-on-1 chats:
        - If other user exists → mark messages as "deleted user"
        - If BOTH deleted → permanently delete all messages + media
     c. In groups/channels:
        - If members remain → messages stay (attributed to "deleted user")
        - If ALL members gone → permanently delete everything
     d. Delete all user media from R2
     e. Delete user record from database
     f. Purge all sessions and keys
```

---

## 13. Low-Bandwidth Optimization (2G Support)

| Technique | Detail |
|-----------|--------|
| Message compression | Gzip/Brotli compression on all payloads |
| Image thumbnails | Send tiny thumbnail first, full image on demand |
| Progressive loading | Text first, then media placeholders, then actual media |
| Offline queue | Messages queued locally when offline, sent when connected |
| Delta sync | Only sync new messages, not full history |
| Binary protocol | Consider Protocol Buffers instead of JSON for wire format |
| Connection pooling | Reuse WebSocket connection; auto-reconnect |

---

## 14. Project Structure (Flutter)

```
pingme/
├── android/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── routes.dart
│   │   └── theme.dart
│   ├── core/
│   │   ├── config/
│   │   ├── crypto/              — Signal Protocol implementation
│   │   ├── network/             — HTTP client, WebSocket manager
│   │   └── storage/             — Local DB (SQLite/Hive)
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── chat/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── calls/
│   │   ├── contacts/
│   │   ├── groups/
│   │   ├── channels/
│   │   ├── profile/
│   │   └── settings/
│   ├── shared/
│   │   ├── widgets/
│   │   ├── utils/
│   │   └── constants/
│   └── l10n/                    — Localization files
├── test/
├── pubspec.yaml
└── README.md
```

---

## 15. Key Flutter Dependencies

```yaml
dependencies:
  flutter_bloc:            # State management
  dio:                     # HTTP client
  web_socket_channel:      # WebSocket
  flutter_webrtc:          # Voice/Video calls
  cryptography:            # Encryption primitives
  hive:                    # Local storage
  firebase_messaging:      # Push notifications
  passkeys:                # FIDO2/WebAuthn
  image_picker:            # Media selection
  cached_network_image:    # Image caching
  intl:                    # i18n
  qr_flutter:              # QR code generation
```

---

## 16. Deployment Pipeline

```
Developer Push → GitHub → CI (GitHub Actions)
                              │
                    ┌─────────┴─────────┐
                    │                    │
              Flutter Build        Backend Deploy
              (APK/AAB)           (Cloudflare Workers
                    │              or Railway)
                    ▼                    ▼
              Play Store          Production
              (Internal Track)    Environment
```

**Environments:** `dev` → `staging` → `production`

---

## 17. Monitoring & Alerting

| What | Tool | Alert To |
|------|------|----------|
| Server errors | Sentry (free tier) | Admin app + Email |
| Storage usage | Custom health check | Admin app + Email |
| DB limits | Turso dashboard + custom | Admin app + Email |
| API rate limits | Cloudflare analytics | Admin app |
| App crashes | Firebase Crashlytics | Admin app + Email |

**Alert recipients: Owner + Super Admins ONLY (via desktop admin app)**

---

*Generated from PingMe Discovery Interview v2.0 — May 3, 2026*
