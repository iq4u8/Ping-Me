# 📊 PingMe — Project Status & Agent Onboarding Guide

> **Last Updated:** May 4, 2026  
> **Purpose:** This is the **FIRST FILE** any agent must read before writing any code.  
> **Read this fully before touching ANY file.**

---

## 🏗️ Project Overview

**PingMe** is a Telegram-clone privacy-first messaging app with E2EE (Signal Protocol).

| Item | Value |
|------|-------|
| **Type** | Full-stack messaging application |
| **Frontend** | Flutter (Android first) — folder: `pingme-frontend/` |
| **Backend** | Node.js + Fastify — folder: `pingme-backend/` |
| **Database** | Turso (libSQL) |
| **Storage** | Cloudflare R2 |
| **Encryption** | Signal Protocol (libsignal_protocol_dart) |
| **Admin App** | Desktop .exe (Tauri/Electron) — NOT started |
| **Budget** | ₹0 (free-tier only) |
| **Target Users** | 100 initial |

---

## 📁 Repository Structure

```
Desktop/temp/
├── pingme-frontend/         ← Flutter frontend
│   ├── lib/
│   │   ├── main.dart                          ← App entry + routing
│   │   ├── theme.dart                         ← Dark/Light/Default themes
│   │   ├── core/crypto/key_manager.dart       ← Signal Protocol key setup
│   │   ├── data/repositories/                 ← Mock repos (auth + chat)
│   │   ├── domain/entities/                   ← User & Message entities
│   │   ├── domain/repositories/               ← Abstract repo interfaces
│   │   ├── presentation/viewmodels/           ← Auth, Chat, Theme ViewModels
│   │   ├── features/
│   │   │   ├── auth/                          ← Login, OTP, Username, Splash
│   │   │   ├── chat/                          ← Chat list, Conversation, Folders, New Message
│   │   │   ├── calls/                         ← Call screen (placeholder)
│   │   │   ├── contacts/                      ← Contacts screen (placeholder)
│   │   │   ├── home/                          ← Bottom nav shell + tabs
│   │   │   ├── profile/                       ← Profile, QR Code, Edit Info
│   │   │   └── settings/                      ← Settings, Appearance, Wallpapers
│   │   └── shared/widgets/                    ← Media picker, Wire components
│   ├── assets/images/                         ← Logos (dark/light/transparent)
│   ├── android/                               ← Android config + permissions
│   └── pubspec.yaml                           ← Dependencies
│
├── pingme-backend/          ← Node.js backend (SKELETON ONLY)
│   ├── src/
│   │   ├── index.ts                           ← Fastify entry (health route only)
│   │   ├── config/env.ts                      ← Environment loader
│   │   ├── middleware/                         ← Empty
│   │   ├── models/                            ← Empty
│   │   ├── routes/                            ← Empty
│   │   ├── services/                          ← Empty
│   │   ├── utils/                             ← Empty
│   │   └── websocket/                         ← Empty
│   ├── .env                                   ← Placeholder keys
│   ├── package.json
│   └── tsconfig.json
│
├── plans/                   ← All planning documents
│   ├── core/                                  ← 🔴 CRITICAL - Read these first
│   │   ├── PingMe_PRD.md                      ← Product Requirements (386 lines)
│   │   ├── PingMe_TRD.md                      ← Technical Requirements (695 lines)
│   │   ├── PingMe_Implementation_Plan_Part1.md ← Steps 1-64
│   │   ├── PingMe_Implementation_Plan_Part2.md ← Steps 65+
│   │   ├── PingMe_Hierarchical_Plan_Part1.md  ← Granular task breakdown Part 1
│   │   ├── PingMe_Hierarchical_Plan_Part2.md  ← Granular task breakdown Part 2
│   │   └── PingMe_Hierarchical_Plan_Part3.md  ← Granular task breakdown Part 3
│   └── reference/
│       └── PingMe_Interview_Questions.txt     ← Original discovery Q&A (source of truth)
│
├── ui design/               ← UI reference screenshots (10 categories)
│   ├── 1._onboarding/
│   ├── 2._phone_auth/
│   ├── 3._unique_id_username/
│   ├── 4._chats_list/
│   ├── 5._chat_conversation/
│   ├── 6._group_channel/
│   ├── 7._calling/
│   ├── 8._invite_links/
│   ├── 9._settings_security/
│   └── 10._contacts_discovery/
│
└── PROJECT_STATUS.md        ← THIS FILE (read first!)
```

---

## 📈 Overall Progress

```
┌──────────────────────────────────────────────────────────┐
│                    OVERALL: ~18% Complete                  │
│  ██████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  18%        │
├──────────────────────────────────────────────────────────┤
│  Frontend UI:  ████████████░░░░░░░░░░░░░░░░░░  35%      │
│  Backend:      ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░   5%      │
│  E2EE:         █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   3%      │
│  WebSocket:    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   0%      │
│  Calling:      ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   0%      │
│  Admin App:    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   0%      │
└──────────────────────────────────────────────────────────┘
```

---

## ✅ COMPLETED — Frontend (Flutter)

### Auth Flow (70% of UI done)
- [x] Animated Splash Screen (logo + name, instant render, 1.5s)
- [x] Welcome Screen (Continue buttons for Email/Phone + Google sign-in)
- [x] Identify Screen (Email/Phone input with country code)
- [x] OTP Screen (6-digit verification with timer)
- [x] Username Setup Screen (profile photo, display name, bio)
- [ ] Passkey/FIDO2 integration (needs backend)
- [ ] Actual API calls (using mock repository)

### Home / Navigation (90% of UI done)
- [x] Bottom Navigation Bar (4 tabs: Chats, Contacts, Settings, Profile)
- [x] Glassmorphic transparent nav bar with blur
- [x] Scroll-hide behavior for nav bar
- [x] Tab switching with smooth animations

### Chat List Screen (85% of UI done)
- [x] Chat list with mock conversations
- [x] Search bar
- [x] Filter chips (All, Unread, Favourites, Groups)
- [x] Dynamic category/folder tabs from ChatViewModel
- [x] "+" button to create new categories
- [x] Folder icon → navigates to Chat Folders management screen
- [x] 3-dot menu → opens glassy right-side drawer
- [x] System-detected 12h/24h time format
- [x] FAB for new message
- [ ] Real conversations from backend (mock data only)

### Glassy End Drawer (100% done)
- [x] Slides from right-to-left
- [x] Transparent/blur/glassmorphic effect
- [x] Profile header (avatar, name, phone, theme toggle, bookmark)
- [x] Menu items: Add Account, My Profile, New Group, New Channel, Contacts, Chat Folders, Saved Messages, Calls, Settings
- [x] Compact font sizes and proper height (doesn't fill full screen)
- [x] Rounded bottom-left corner

### Chat Folders Management (100% done)
- [x] ChatFoldersScreen with reorderable list
- [x] Create/Rename/Delete folders
- [x] Drag-and-drop reordering
- [x] Bottom sheet for edit/delete options
- [x] State synced via ChatViewModel (Provider)

### Conversation Screen (40% of UI done)
- [x] Basic conversation layout
- [x] Message bubbles
- [x] Input bar
- [ ] Media attachments
- [ ] Reply/Forward/Edit/Delete
- [ ] Typing indicators
- [ ] Message status indicators (✓ ✓✓ 🔵)

### New Message Screen (80% done)
- [x] Contact permission handling
- [x] Empty state with "Add Contacts" button
- [x] Contact list when permission granted

### Profile Screen (85% of UI done)
- [x] Profile photo with edit
- [x] Display name, username, bio
- [x] QR Code screen
- [x] Edit Info screen
- [x] Archive section
- [x] TabBar (Posts/Media/Links)
- [ ] Actual user data from backend

### Settings Screen (70% of UI done)
- [x] Appearance settings (Dark/Light/Default theme switching)
- [x] Chat Wallpapers screen
- [x] Settings list items
- [ ] Privacy settings
- [ ] Notification settings
- [ ] Storage & Data settings
- [ ] 2FA setup screen

### Theme System (100% done)
- [x] Dark theme
- [x] Light theme
- [x] Default (warm dark) theme
- [x] ThemeViewModel with persistence

---

## ✅ COMPLETED — Backend (Node.js)

### Project Setup (30% done)
- [x] Fastify server initialized
- [x] CORS + WebSocket plugins registered
- [x] Health check route (`GET /health`)
- [x] Environment config loader (`env.ts`)
- [x] TypeScript config
- [x] Folder structure created
- [ ] Database connection (Turso) — NOT connected
- [ ] Schema migration — NOT created
- [ ] Any API routes — NONE exist

---

## ❌ NOT STARTED — Critical Remaining Work

### Backend — ALL of these are 0%
| Feature | Plan Reference | Status |
|---------|---------------|--------|
| Database schema + migration | TRD Section 3 | ❌ Not started |
| Auth routes (register/login/OTP) | Implementation Plan Phase 2, Steps 19-26 | ❌ Not started |
| JWT middleware | Implementation Plan Step 19 | ❌ Not started |
| Message routes (send/get/edit/delete) | Implementation Plan Phase 3, Steps 36-41 | ❌ Not started |
| WebSocket server (real-time) | Implementation Plan Steps 42-44 | ❌ Not started |
| Message status (✓ ✓✓ 🔵) | Implementation Plan Step 45 | ❌ Not started |
| Media upload/download | Implementation Plan Phase 4, Steps 56-64 | ❌ Not started |
| Storage routing (multi-R2) | TRD Section 6 | ❌ Not started |
| Thumbnail generation | Implementation Plan Step 59 | ❌ Not started |
| User profile routes | Implementation Plan Phase 5 | ❌ Not started |
| Group/Channel routes | Implementation Plan Phase 6 | ❌ Not started |
| Invite link system | Implementation Plan Phase 7 | ❌ Not started |
| WebRTC calling (signaling) | Implementation Plan Phase 8 | ❌ Not started |
| Push notifications (FCM) | Implementation Plan Phase 9 | ❌ Not started |
| 2FA (TOTP) | Implementation Plan Steps 34-35 | ❌ Not started |
| Admin API | TRD Section 9 | ❌ Not started |

### Frontend — Backend Integration (0%)
| Feature | Status |
|---------|--------|
| Replace mock repos with real API calls | ❌ |
| WebSocket client for real-time messaging | ❌ |
| Token storage + auto-refresh | ❌ |
| Real message sending/receiving | ❌ |
| Media upload with progress | ❌ |
| Push notification handling | ❌ |
| WebRTC calling UI | ❌ |
| Contact sync & discovery | ❌ |

### E2EE — Signal Protocol (3%)
| Feature | Status |
|---------|--------|
| Key generation (identity, signed pre-key) | ✅ Scaffold exists in `key_manager.dart` |
| X3DH key exchange | ❌ |
| Double Ratchet encryption | ❌ |
| Encrypt/decrypt messages | ❌ |
| Key backup & recovery | ❌ |

### Desktop Admin App (0%)
- Not started at all
- Planned tech: Tauri or Electron
- See TRD Section 9 for requirements

---

## 🎯 Priority Order for Next Steps

### Phase 1: Backend Foundation (HIGHEST PRIORITY)
1. Connect Turso database
2. Run schema migration (all 17 tables from TRD)
3. Implement auth middleware (JWT)
4. Build auth routes (register, OTP send/verify, logout)
5. Build user profile routes

### Phase 2: Real-Time Messaging
6. Build message routes (CRUD)
7. Implement WebSocket server
8. Add typing indicators
9. Add message status tracking

### Phase 3: Frontend-Backend Integration
10. Replace mock repos with Dio API calls
11. Connect WebSocket client
12. Implement token management
13. Wire up real auth flow

### Phase 4: Media & Files
14. R2 storage integration
15. Media upload/download routes
16. Thumbnail generation
17. Flutter media picker integration

### Phase 5: Advanced Features
18. E2EE (Signal Protocol) full implementation
19. Group/Channel support
20. WebRTC calling
21. Push notifications (FCM)
22. 2FA (TOTP)

### Phase 6: Admin & Polish
23. Desktop admin app (Tauri)
24. Content moderation
25. Storage monitoring dashboard

---

## 🔧 Technical Notes for Agents

### Flutter Build & Deploy
```bash
# Profile mode build (for real device testing)
flutter build apk --profile

# Install on connected device
flutter install --profile -d <device_id>

# Current device ID: 2c883527
```

### State Management
- Using **Provider** with ChangeNotifier (NOT BLoC)
- `AuthViewModel` — auth state + mock login flow
- `ChatViewModel` — conversations + folders/categories
- `ThemeViewModel` — dark/light/default theme switching

### Architecture Pattern
- MVVM with Provider
- `domain/` — entities + abstract repositories
- `data/` — concrete repository implementations (currently mock)
- `presentation/` — ViewModels
- `features/` — feature-based screen organization

### Key Dependencies (pubspec.yaml)
```yaml
provider, dio, web_socket_channel, flutter_secure_storage,
hive, hive_flutter, google_fonts, flutter_animate, flutter_svg,
libsignal_protocol_dart, intl, photo_manager, permission_handler,
image_picker, flutter_native_splash
```

### Native Splash Config
- Uses `flutter_native_splash` package
- Config in `pubspec.yaml` (bottom)
- Background: `#0A0A0A` with transparent pixel image
- The Flutter `AnimatedSplashScreen` shows logo+name INSTANTLY (no animation delay)
- Timer: 1500ms then navigates to Welcome screen

### Android Permissions (AndroidManifest.xml)
- `READ_CONTACTS`, `WRITE_CONTACTS` — for contact discovery

---

## 📋 Plan Files — Quick Reference

| File | What It Contains | When To Read |
|------|-----------------|--------------|
| `plans/core/PingMe_PRD.md` | ALL feature requirements with priorities (P0/P1/P2) | Before building ANY feature |
| `plans/core/PingMe_TRD.md` | Technical architecture, DB schema, API endpoints, encryption flow | Before writing ANY backend code |
| `plans/core/PingMe_Implementation_Plan_Part1.md` | Step-by-step instructions (Steps 1-64) | For exact implementation order |
| `plans/core/PingMe_Implementation_Plan_Part2.md` | Steps 65+ (groups, channels, calls, admin) | For advanced features |
| `plans/core/PingMe_Hierarchical_Plan_Part1.md` | Ultra-granular task breakdown (line-by-line code instructions) | When implementing a specific feature |
| `plans/core/PingMe_Hierarchical_Plan_Part2.md` | Continued granular breakdown | Same |
| `plans/core/PingMe_Hierarchical_Plan_Part3.md` | Continued granular breakdown | Same |
| `plans/reference/PingMe_Interview_Questions.txt` | Original owner Q&A (source of all decisions) | Only for understanding WHY a decision was made |

---

## ⚠️ Critical Rules for All Agents

1. **READ THIS FILE FIRST** — before touching any code
2. **Read `plans/core/PingMe_PRD.md`** — to understand what features are needed
3. **Read `plans/core/PingMe_TRD.md`** — to understand technical architecture
4. **DO NOT** recreate or duplicate files that already exist
5. **DO NOT** change the theme/design language — it's already polished
6. **Backend uses Fastify** (NOT Express) — see `pingme-backend/src/index.ts`
7. **Frontend uses Provider** (NOT BLoC) — despite some plans mentioning BLoC
8. **Build with `--profile`** flag for device testing (NOT debug)
9. **Device ID for install:** `2c883527`
10. **The `ui design/` folder** has reference screenshots for every screen — check them

---

*This document should be updated after every major session.*
