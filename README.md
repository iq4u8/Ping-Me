<div align="center">

```
██████╗ ██╗███╗   ██╗ ██████╗     ███╗   ███╗███████╗
██╔══██╗██║████╗  ██║██╔════╝     ████╗ ████║██╔════╝
██████╔╝██║██╔██╗ ██║██║  ███╗    ██╔████╔██║█████╗  
██╔═══╝ ██║██║╚██╗██║██║   ██║    ██║╚██╔╝██║██╔══╝  
██║     ██║██║ ╚████║╚██████╔╝    ██║ ╚═╝ ██║███████╗
╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚═╝     ╚═╝╚══════╝
```

**A privacy-first, end-to-end encrypted messenger. Built to compete with Telegram.**

[![Status](https://img.shields.io/badge/Status-Active_Development-22c55e?style=for-the-badge&logo=github&logoColor=white)](https://github.com/iq4u8/Ping-Me)
[![Backend](https://img.shields.io/badge/Backend-Node.js_+_Fastify-f97316?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://github.com/iq4u8/Ping-Me)
[![Mobile](https://img.shields.io/badge/Mobile-Flutter-54C5F8?style=for-the-badge&logo=flutter&logoColor=white)](https://github.com/iq4u8/Ping-Me)
[![DB](https://img.shields.io/badge/DB-Turso_libSQL-4F46E5?style=for-the-badge&logo=sqlite&logoColor=white)](https://github.com/iq4u8/Ping-Me)
[![Storage](https://img.shields.io/badge/Storage-Cloudflare_R2-F6821F?style=for-the-badge&logo=cloudflare&logoColor=white)](https://github.com/iq4u8/Ping-Me)
[![License](https://img.shields.io/badge/License-Private-dc2626?style=for-the-badge)](https://github.com/iq4u8/Ping-Me)

</div>

---

## ⚡ What Is Ping Me?

Ping Me is a **production-grade, privacy-first messaging platform** built from the ground up with a philosophy of *zero compromise* on security. No telemetry. No third-party ads. No data harvesting. Built with ₹0 on free-tier infra — proving that enterprise-grade architecture doesn't need enterprise budgets.

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                                │
│                                                                     │
│    ┌──────────────────┐          ┌────────────────────────┐         │
│    │  Flutter App     │          │  (Future) Desktop App  │         │
│    │  (Android First) │          │  Electron / Tauri      │         │
│    └────────┬─────────┘          └───────────┬────────────┘         │
└─────────────┼─────────────────────────────────┼─────────────────────┘
              │  HTTPS / WSS                    │  HTTPS / WSS
┌─────────────▼─────────────────────────────────▼─────────────────────┐
│                          API GATEWAY                                │
│                                                                     │
│              ┌──────────────────────────────┐                       │
│              │   Node.js + Fastify Server   │                       │
│              │   JWT Auth Middleware        │                       │
│              │   Rate Limiting + CORS       │                       │
│              └──────┬──────────────┬────────┘                       │
└─────────────────────┼──────────────┼──────────────────────────────  ┘
                      │              │
         ┌────────────▼──┐    ┌──────▼──────────────┐
         │  REST Routes  │    │  WebSocket Manager   │
         │               │    │                      │
         │  /auth        │    │  Connection Pool     │
         │  /users       │    │  Event Broadcast     │
         │  /messages    │    │  Presence Tracking   │
         │  /media       │    │  Delivery Receipts   │
         │  /groups      │    └──────────────────────┘
         │  /channels    │
         └──────┬────────┘
                │
   ┌────────────┴─────────────────────────────────┐
   │               DATA LAYER                     │
   │                                              │
   │  ┌─────────────────┐   ┌──────────────────┐  │
   │  │  Turso (libSQL) │   │  Cloudflare R2   │  │
   │  │  17 Tables      │   │  Media Storage   │  │
   │  │  Edge Replicas  │   │  Thumbnails      │  │
   │  └─────────────────┘   └──────────────────┘  │
   └──────────────────────────────────────────────┘
```

---

## 📊 Build Progress

> **Overall Completion: `▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░` 55%**

---

### 🔴 Backend — `65% Complete`

```
Database Schema (17 Tables)   ████████████████████ 100% ✅
Auth System (JWT + OTP)       ████████████████████ 100% ✅
Cloudflare R2 Storage         ████████████████████ 100% ✅
WebSocket Real-time           ████████████████████ 100% ✅
Message Status Engine         ████████████████████ 100% ✅
Media Upload + Thumbnails     ████████████████████ 100% ✅
User Profiles & Search        ████████████████████ 100% ✅
Groups & Channels             ████████████████████ 100% ✅
Privacy & Settings            ████████████████████ 100% ✅
E2E Encryption (Signal)       ████░░░░░░░░░░░░░░░░  20% 🔄
Voice & Video (WebRTC)        ░░░░░░░░░░░░░░░░░░░░   0% ⏳
Push Notifications            ░░░░░░░░░░░░░░░░░░░░   0% ⏳
```

---

### 🔵 Frontend (Flutter) — `65% Complete` (Golden UI Completed)

```
Onboarding Screen             ████████████████████ 100% ✅
Auth UI & Google Sign-In      ████████████████████ 100% ✅
Chat List & Folders           ████████████████████ 100% ✅
Conversation & Saved Msg      ████████████████████ 100% ✅
Profile & Edit Info           ████████████████████ 100% ✅
Settings & Appearance         ████████████████████ 100% ✅
Groups / Channels UI          ████████████████████ 100% ✅
Backend API Integration       ██░░░░░░░░░░░░░░░░░░  10% 🔄
WebSocket Client Hook         ░░░░░░░░░░░░░░░░░░░░   0% ⏳
Calling Screen (WebRTC)       ░░░░░░░░░░░░░░░░░░░░   0% ⏳
```

---

### 🔐 Security Layer — `12% Complete`

```
Signal Protocol (E2EE)        ████░░░░░░░░░░░░░░░░  20% 🔄
Key Exchange (X3DH)           ░░░░░░░░░░░░░░░░░░░░   0% ⏳
Double Ratchet Algorithm      ░░░░░░░░░░░░░░░░░░░░   0% ⏳
Sealed Sender Messages        ░░░░░░░░░░░░░░░░░░░░   0% ⏳
```

---

## ✅ Live API Endpoints

> **Base URL:** `http://localhost:3000/api/v1`  
> All protected routes require: `Authorization: Bearer <JWT>`

### 🔑 Auth
| Method | Endpoint | Description | Auth |
| :---: | :--- | :--- | :---: |
| `POST` | `/auth/register` | Register new user | ❌ |
| `POST` | `/auth/verify-otp` | Verify OTP & get JWT | ❌ |
| `POST` | `/auth/login` | Login with phone | ❌ |
| `POST` | `/auth/refresh` | Refresh access token | ✅ |
| `POST` | `/auth/logout` | Invalidate session | ✅ |

### 👤 Users
| Method | Endpoint | Description | Auth |
| :---: | :--- | :--- | :---: |
| `GET` | `/users/me` | Get own profile | ✅ |
| `PUT` | `/users/me` | Update profile | ✅ |
| `GET` | `/users/search?q=` | Search users by ID/name | ✅ |
| `GET` | `/users/:id` | Get user profile | ✅ |

### 💬 Messages
| Method | Endpoint | Description | Auth |
| :---: | :--- | :--- | :---: |
| `GET` | `/messages/:conversationId` | Get messages in convo | ✅ |
| `POST` | `/messages` | Send a message | ✅ |
| `PUT` | `/messages/:id/status` | Update delivery/read status | ✅ |
| `DELETE` | `/messages/:id` | Delete message | ✅ |

### 📁 Media
| Method | Endpoint | Description | Auth |
| :---: | :--- | :--- | :---: |
| `POST` | `/media/upload` | Upload file to R2 | ✅ |
| `GET` | `/media/:id` | Get media URL | ✅ |
| `DELETE` | `/media/:id` | Delete media | ✅ |

### 👥 Groups & Channels
| Method | Endpoint | Description | Auth |
| :---: | :--- | :--- | :---: |
| `POST` | `/groups` | Create group | ✅ |
| `GET` | `/groups/:id` | Get group info | ✅ |
| `POST` | `/groups/:id/members` | Add member | ✅ |
| `DELETE` | `/groups/:id/members/:userId` | Remove member | ✅ |
| `POST` | `/channels` | Create channel | ✅ |
| `GET` | `/channels/:id` | Get channel info | ✅ |
| `POST` | `/channels/:id/subscribe` | Subscribe to channel | ✅ |

### 🔒 Privacy & Settings
| Method | Endpoint | Description | Auth |
| :---: | :--- | :--- | :---: |
| `GET` | `/settings/privacy` | Get privacy settings | ✅ |
| `PUT` | `/settings/privacy` | Update privacy settings | ✅ |
| `PUT` | `/settings/notifications` | Update notification prefs | ✅ |

### ⚡ WebSocket Events
| Event | Direction | Description |
| :--- | :---: | :--- |
| `message:new` | Server → Client | New incoming message |
| `message:delivered` | Server → Client | Message delivered to recipient |
| `message:read` | Server → Client | Message read by recipient |
| `presence:online` | Server → Client | User came online |
| `presence:offline` | Server → Client | User went offline |
| `typing:start` | Client → Server | User started typing |
| `typing:stop` | Client → Server | User stopped typing |

---

## 🗃️ Database Schema (17 Tables)

```
users               sessions            otp_codes
messages            conversations       conversation_members
media_files         message_status      groups
group_members       channels            channel_subscribers
user_settings       privacy_settings    contacts
blocked_users       call_logs
```

---

## 🛠️ Tech Stack

<div align="center">

| Layer | Technology | Why |
| :--- | :--- | :--- |
| **Runtime** | Node.js 20 LTS | Battle-tested, massive ecosystem |
| **Framework** | Fastify | 2x faster than Express, schema validation built-in |
| **Language** | TypeScript | Type safety, no runtime surprises |
| **Database** | Turso (libSQL) | SQLite at the edge, globally replicated, free tier |
| **Storage** | Cloudflare R2 | S3-compatible, zero egress fees |
| **Real-time** | WebSocket (ws) | Native, low-overhead, full control |
| **Auth** | JWT + OTP | Stateless + phone verification |
| **Mobile** | Flutter (Dart) | Single codebase, native performance |
| **Encryption** | Signal Protocol | Gold standard in E2EE |
| **Calling** | WebRTC | Peer-to-peer, no relay cost |

</div>

---

## 🗂️ Project Structure

```
Ping-Me/
├── 📁 pingme-backend/
│   └── src/
│       ├── config/         ← Env vars, constants
│       ├── middlewares/    ← Auth guard, error handler
│       ├── models/         ← Schema SQL, migrations
│       ├── routes/         ← auth, users, messages, media, groups
│       ├── services/       ← Business logic layer
│       │   ├── authService.ts
│       │   ├── otpService.ts
│       │   ├── storage.ts         ← Cloudflare R2
│       │   ├── thumbnailService.ts
│       │   ├── messageStatusService.ts
│       │   └── privacyService.ts
│       ├── websocket/      ← Manager + event handlers
│       └── utils/          ← DB client (Turso)
│
├── 📁 pingme-frontend/     ← Flutter app (Android first)
│   └── lib/
│       ├── features/       ← Screens (chat, profile, settings)
│       ├── shared/         ← Reusable widgets
│       └── theme.dart      ← Design system
│
├── 📁 plans/
│   ├── core/               ← PRD, TRD, Implementation Plans
│   └── reference/          ← Discovery interviews
│
├── 📁 ui design/           ← Reference screenshots per screen
├── 📄 PROJECT_STATUS.md    ← Detailed phase tracker
├── 📄 CONTRIBUTING.md      ← Branch rules & workflow
└── 📄 README.md            ← You are here
```

---

## 🚀 Getting Started

### Backend
```bash
cd pingme-backend
npm install
cp .env.example .env   # Fill in Turso URL, R2 keys, JWT secret
npm run dev            # Starts on :3000
```

### Frontend
```bash
cd pingme-frontend
flutter pub get
flutter run            # Connect a physical Android device or emulator
```

---

## 🔄 Current Sprint — Backend Phase 7: E2EE

```
┌──────────────────────────────────────────────────────┐
│  SPRINT: Signal Protocol Integration                 │
│  Status: 🔄 IN PROGRESS                              │
├──────────────────────────────────────────────────────┤
│                                                      │
│  [ ] X3DH Key Exchange Protocol                      │
│  [ ] Identity & Pre-Key Bundle Generation            │
│  [ ] Double Ratchet Algorithm                        │
│  [ ] Sealed Sender Message Envelopes                 │
│  [ ] Key Backup & Rotation                           │
│                                                      │
│  Next: Frontend WebSocket Integration                │
└──────────────────────────────────────────────────────┘
```

---

## 👨‍💻 Built By

| | |
| :--- | :--- |
| **👑 Paradox** | Solo architect, engineer & designer. Backend, mobile, systems design, E2EE — all of it. |

---

## 📋 Documentation

| Doc | Description |
| :--- | :--- |
| **[PROJECT_STATUS.md](./PROJECT_STATUS.md)** | Granular phase-by-phase tracker |
| **[CONTRIBUTING.md](./CONTRIBUTING.md)** | Branch rules, commit format, workflow |
| **[PRD](./plans/core/PingMe_PRD.md)** | Product requirements |
| **[TRD](./plans/core/PingMe_TRD.md)** | Technical requirements & decisions |
| **[Implementation Plan](./plans/core/)** | Step-by-step build roadmap |

---

## 💰 Infrastructure Cost

**₹0** — Entirely on free-tier services.

| Service | Free Tier Used | Limit |
| :--- | :--- | :--- |
| Turso | ✅ | 500 DBs, 9GB storage |
| Cloudflare R2 | ✅ | 10GB/mo storage, zero egress |
| Render / Railway | 🔜 | Backend hosting (free tier) |

---

<div align="center">

*Private — All rights reserved.*

**Built with obsession. Shipped with precision.**

</div>
