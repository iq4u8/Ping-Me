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

## 📊 Progress

Overall: **~18% Complete**

- Frontend UI: **35%** — Auth flow, chat list, profile, settings screens built
- Backend: **5%** — Server skeleton + health check only
- E2EE: **3%** — Key manager scaffold
- WebSocket: **0%**
- Calling: **0%**
- Admin App: **0%**

## 💰 Budget

**₹0** — Built entirely on free-tier infrastructure.

## 📄 License

Private — All rights reserved.
