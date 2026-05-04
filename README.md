# 📱 Ping Me

> A privacy-first, end-to-end encrypted messaging application built to compete with Telegram.

## 🏗️ Project Structure

```
Ping-Me/
├── pingme-frontend/    ← Flutter mobile app (Android)
├── pingme-backend/     ← Node.js + Fastify API server
├── plans/              ← PRD, TRD & Implementation plans
│   ├── core/           ← Critical planning documents
│   └── reference/      ← Discovery interview & source material
├── ui design/          ← UI reference screenshots
└── PROJECT_STATUS.md   ← Current progress & agent onboarding guide
```

## ✨ Key Features

| Feature | Status |
|---------|--------|
| 🔐 E2EE (Signal Protocol) | In Progress |
| 💬 Rich Messaging (text, media, voice, docs) | Frontend UI Ready |
| 📞 Voice & Video Calls (WebRTC) | Planned |
| 👥 Groups & Channels | Planned |
| 🔗 Invite Links & QR Codes | Planned |
| 🎨 Dark/Light/Custom Themes | ✅ Done |
| 🔑 Passkey / Google Auth | Planned |
| 🖥️ Desktop Admin App (.exe) | Planned |

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Mobile** | Flutter (Dart) — Android first |
| **Backend** | Node.js + Fastify |
| **Database** | Turso (libSQL) |
| **Storage** | Cloudflare R2 |
| **Real-time** | WebSocket |
| **Encryption** | Signal Protocol |
| **Calling** | WebRTC |
| **Auth** | Google Passkey + OTP |

## 🚀 Getting Started

### Frontend (Flutter)
```bash
cd pingme-frontend
flutter pub get
flutter run
```

### Backend (Node.js)
```bash
cd pingme-backend
npm install
cp .env.example .env   # Configure your environment
npm run dev
```

## 📋 Documentation

- **[PROJECT_STATUS.md](./PROJECT_STATUS.md)** — Current progress, what's done, what's pending
- **[PRD](./plans/core/PingMe_PRD.md)** — Product Requirements Document
- **[TRD](./plans/core/PingMe_TRD.md)** — Technical Requirements Document
- **[Implementation Plan](./plans/core/)** — Step-by-step build guide

## 📊 Progress & Collaboration Sync

<div align="center">
  <img src="https://img.shields.io/badge/Status-Active_Development-brightgreen?style=for-the-badge&logo=github" alt="Status" />
  <img src="https://img.shields.io/badge/Phase-Backend_Core-blue?style=for-the-badge&logo=node.js" alt="Phase" />
  <img src="https://img.shields.io/badge/Pushed_By-Paradox-black?style=for-the-badge&logo=hackerone&logoColor=red" alt="Architect" />
</div>

<br/>

### 🏆 Collaborative Forge
> Built iteratively by the best.

| Architect / Entity | Contribution Zone | Status |
| :--- | :--- | :--- |
| **👑 Paradox** *(Lead)* | Backend Architecture, Auth, WebSockets, E2EE, Systems Design | 🔥 Pushing Limits |
| **🤖 Antigravity** | Code Scaffolding, Infrastructure, Co-Pilot | ⚡ Support |

---

### 🚀 Backend Milestone Tracker

- [x] **Phase 1-3:** Turso Database & 17 Tables Setup 
- [x] **Phase 4:** Core Authentication System (JWT, OTP, Sessions)
- [x] **Phase 5:** Cloudflare R2 Media Integration
- [x] **Phase 6:** WebSocket Real-time Messaging (Sent/Delivered/Read)
- [x] **Phase 8:** Groups, Channels, User Profiles, Privacy Settings
- [ ] **Phase 7:** E2E Encryption (Signal Protocol) - *In Progress*

Overall: **~45% Complete**

- Frontend UI: **35%** — Auth flow, chat list, profile, settings screens built
- Backend: **65%** — DB, Auth, WebSockets, Storage, and Groups/Channels are LIVE.
- E2EE: **10%** — Key manager scaffold
- WebSocket: **100%** — Real-time messaging complete
- Calling: **0%**
- Admin App: **0%**

## 💰 Budget

**₹0** — Built entirely on free-tier infrastructure.

## 📄 License

Private — All rights reserved.
