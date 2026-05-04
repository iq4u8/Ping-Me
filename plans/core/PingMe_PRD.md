# 📱 PingMe — Product Requirements Document (PRD)

> **Version:** 1.0  
> **Date:** May 3, 2026  
> **Status:** Draft — Awaiting Stakeholder Review  
> **Product:** PingMe Messaging App  
> **Competitor Benchmark:** Telegram  
> **Team:** 2-person team (brothers)

---

## 1. Executive Summary

**PingMe** is a privacy-first, end-to-end encrypted messaging application designed to compete with Telegram. It offers rich messaging (text, media, voice, documents, stickers, GIFs, polls, location, contacts), voice/video calling with adaptive quality, E2EE across all communications, groups & channels, and a powerful desktop-only admin control panel for the app owner/developer team.

### Key Differentiators
| Area | PingMe Approach |
|------|----------------|
| **Privacy** | E2EE on everything by default (no opt-in "secret chat" mode) |
| **Authentication** | Passkey / Google Passkey auto-login; phone number optional |
| **Admin Control** | Separate desktop `.exe` admin app — completely invisible to end users |
| **Budget** | Free-tier infrastructure only (₹0/month at launch) |
| **Monetization** | 100% free, no ads, no subscriptions |

---

## 2. Product Vision & Goals

### Vision
Build a secure, fast, and beautiful messaging platform that gives users Telegram-level functionality with **stronger default privacy** and **ultra-low bandwidth support** (usable even on 2G networks).

### Launch Goals
| Goal | Target |
|------|--------|
| Initial user base | 100 users |
| Platform | Android (Flutter) |
| Core features | Chat + Calls + E2EE |
| Budget | ₹0 free-tier infrastructure |

### Future Roadmap (Post-MVP)
- iOS app
- Web app
- Windows/Mac desktop client
- In-app camera
- Public bot/chatbot API (Telegram-style)

---

## 3. User Personas

### Persona 1: End User (App User)
- Sends/receives messages, makes calls
- Manages their own profile, privacy settings
- Joins/creates groups and channels
- **Cannot** see or access any admin/backend controls

### Persona 2: In-App Group/Channel Admin
- Manages group/channel settings, members, pins
- Has roles: Creator / Admin / Moderator / Member
- **Cannot** access the desktop admin app or backend controls

### Persona 3: App Owner / Super Admin / Dev Team
- Accesses the **desktop admin app (.exe) only**
- Monitors all analytics, storage, system health
- Manages storage accounts, database accounts, config
- Bans/unbans users, deletes content
- **Completely separate** from in-app admins — invisible to app users

> **⚠️ IMPORTANT:**  
> In-app group/channel admins and the app owner/super admin team are **completely different roles** operating in **completely different interfaces**. App users cannot see, know about, or access the desktop admin panel.

---

## 4. Feature Requirements

### 4.1 — CHATTING

| ID | Feature | Requirement | Priority |
|----|---------|-------------|----------|
| A1 | Message types | Text, Images, Videos, Voice Notes, Documents, Stickers, GIFs, Location, Polls, Contact Cards | P0 |
| A2 | Message status | Sent ✓ / Delivered ✓✓ / Read 🔵 | P0 |
| A3 | Edit messages | Yes — within 5 minutes of sending | P0 |
| A4 | Delete messages | Delete for self (anytime) + Delete for everyone (no time limit) | P0 |
| A5 | Reply & threads | Reply to specific messages; threaded conversations | P0 |
| A6 | Message forwarding | With original sender name + without sender name (both options) | P1 |
| A7 | Typing indicator | "XYZ is typing..." shown in real-time | P0 |
| A8 | Online / Last Seen | Visible (with privacy controls) | P0 |
| A9 | Message search | Full-text search inside chats | P1 |
| A10 | Chat backup | Local device only (no cloud backup) | P1 |
| A11 | Max message length | 4,096 characters (Telegram standard) | P0 |
| A12 | Self-destruct messages | Auto-delete after configurable time | P1 |
| A13 | Message reactions | Emoji reactions on messages | P1 |
| A14 | Pinned messages | Pin messages in 1-on-1 chats | P1 |
| A15 | Saved Messages | Personal cloud notepad (like Telegram) | P2 |

### 4.2 — CALLING

| ID | Feature | Requirement | Priority |
|----|---------|-------------|----------|
| B1 | Call types | Voice calls + Video calls | P0 |
| B2 | Group calls | Yes — max 10 participants | P1 |
| B3 | Call recording | ❌ Not supported | — |
| B4 | Screen sharing | ❌ Not supported | — |
| B5 | Adaptive quality | Auto-adjust based on network conditions | P0 |
| B6 | Missed call notifications | Yes | P0 |
| B7 | Call history / logs | Full call log in app | P0 |
| B8 | Noise cancellation / bg blur | Yes for video calls | P2 |
| B9 | Ring on all devices | Yes — ring on all logged-in devices simultaneously | P1 |

### 4.3 — ENCRYPTION

| ID | Feature | Requirement | Priority |
|----|---------|-------------|----------|
| C1 | E2EE scope | **All** messages and chats by default (not opt-in) | P0 |
| C2 | Protocol | Signal Protocol (industry gold standard) | P0 |
| C3 | Zero-knowledge server | Yes — server cannot read any messages | P0 |
| C4 | Call encryption | All calls E2EE | P0 |
| C5 | Key exchange | On-device generated + server-assisted key distribution | P0 |
| C6 | Device loss recovery | Recovery via encrypted local backup passphrase | P1 |
| C7 | Key backup | User's local encrypted backup (not cloud-stored) | P1 |

### 4.4 — GROUPS & CHANNELS

| ID | Feature | Requirement | Priority |
|----|---------|-------------|----------|
| D1 | Groups | All members can chat; max 200 members (initial limit) | P0 |
| D2 | Channels | Admin-only posts; unlimited subscribers | P1 |
| D3 | Admin roles | Creator / Admin / Moderator / Member with granular permissions | P0 |
| D4 | Who can create | Any registered user | P0 |
| D5 | Discovery | Public groups in directory; private = invite-only | P1 |
| D6 | Pinned messages | Yes in groups and channels | P1 |
| D7 | Add members | Admins + anyone with invite link | P0 |
| D8 | Join requests | Admin approval for private groups; auto-join for public | P1 |
| D9 | Group profile | Description + profile photo | P0 |
| D10 | Slow mode | Configurable cooldown between member messages | P2 |

### 4.5 — INVITE / JOIN LINKS

| ID | Feature | Requirement | Priority |
|----|---------|-------------|----------|
| E1 | Link types | One-time use + reusable links | P0 |
| E2 | Expiry | Configurable expiration time | P1 |
| E3 | QR codes | QR code generation for group/channel join | P1 |
| E4 | Admin approval | Optional — configurable per group | P1 |
| E5 | Revoke/regenerate | Admin can revoke and regenerate links | P0 |
| E6 | Usage limits | Configurable max joins per link | P2 |

### 4.6 — UNIQUE ID & USERNAME

| ID | Feature | Requirement | Priority |
|----|---------|-------------|----------|
| F1 | ID format | Alphanumeric (auto-generated) | P0 |
| F2 | ID generation | Auto-generated by system | P0 |
| F3 | ID change | ❌ Cannot be changed after creation | P0 |
| F4 | Username change | Unlimited changes allowed | P0 |
| F5 | Username length | Minimum 6 characters | P0 |
| F6 | Reserved usernames | Block app-related names (admin, support, pingme, etc.) | P0 |
| F7 | Case sensitivity | Case-insensitive (@User = @user = @USER) | P0 |
| F8 | Username usage | Used for both login and user discovery | P0 |

> **📝 NOTE:** Any changes to user IDs/usernames by the super admin team are done **exclusively** through the desktop admin app.

### 4.7 — AUTHENTICATION

| ID | Feature | Requirement | Priority |
|----|---------|-------------|----------|
| G1 | Phone number | Optional (not required for signup) | P0 |
| G2 | Hide phone number | Yes — user can hide from everyone | P0 |
| G3 | Contact sync | ❌ No phone contacts sync | — |
| G4 | Countries | Global support from day 1 | P0 |
| G5 | OTP methods | WhatsApp OTP or Email OTP (user's choice) | P0 |
| G6 | Login methods | Phone (WhatsApp OTP), Username, Email, **Google Passkey** | P0 |
| G7 | OTP retry limits | 3 attempts → 1hr lock → 3 attempts → 4hr lock → 3 attempts → 24hr lock | P0 |
| G8 | International numbers | Supported from day 1 | P0 |

**Passkey / Google Passkey:** Primary login method — automatic, passwordless authentication.

### 4.8 — PROFILE, PRIVACY & NOTIFICATIONS

| ID | Feature | Requirement | Priority |
|----|---------|-------------|----------|
| H1 | Profile picture | Yes (with multiple photo history) | P0 |
| H2 | Bio / About | Yes | P0 |
| H3 | Last seen privacy | Everyone / Contacts only / Nobody / Custom | P0 |
| H4 | Block users | Yes | P0 |
| H5 | Push notifications | Yes | P0 |
| H6 | Notification preview | Configurable (show/hide content) | P1 |
| H7 | Per-chat settings | Mute + custom notification sound | P1 |
| H8 | DND / Silent mode | Yes | P1 |
| H9 | Multiple profile photos | Photo history like Telegram | P2 |

### 4.9 — PLATFORM & INFRASTRUCTURE

| Item | Decision |
|------|----------|
| **Launch platform** | Android only |
| **Framework** | Flutter |
| **Initial users** | 100 |
| **Infrastructure** | Mix of free tools |
| **Monthly budget** | ₹0 (free tier only) |
| **Backend language** | Best fit (recommended: Node.js or Go) |
| **Future platforms** | iOS → Web → Windows → Mac (one by one) |

### 4.10 — MONETIZATION & LEGAL

| Item | Decision |
|------|----------|
| **Pricing** | 100% Free |
| **Monetization** | None (no ads, no subscriptions) |
| **Compliance** | Indian IT Act compliance |
| **Data retention** | Messages stored until deletion; E2EE = no plaintext on server |
| **Data export** | User can export their data |
| **Account deletion** | Full account deletion supported |

**Data Cleanup Rules:**
- When a user deletes their account, their side of all 1-on-1 chats is removed
- In 1-on-1: if both users delete accounts → all data permanently removed from backend
- In groups/channels: if all members leave/delete → all data permanently cleaned from storage

### 4.11 — SECURITY & MODERATION

| ID | Feature | Requirement | Priority |
|----|---------|-------------|----------|
| K1 | 2FA | Yes — TOTP-based | P0 |
| K2 | Active devices | View all sessions + remote logout | P0 |
| K3 | Report abuse | Yes — report spam/abuse feature | P0 |
| K4 | Content moderation | Hybrid: automated AI filters + manual review via admin app | P1 |
| K5 | Session timeout | Auto-logout after 30 days of inactivity | P2 |
| K6 | Anti-screenshot | Yes — in self-destruct / secret message mode | P1 |

---

## 5. Desktop Admin App Requirements

> **⚠️ CAUTION:**  
> The desktop admin app is a **separate `.exe` application** for Windows. It is ONLY accessible by the app owner, super admins, and the development team. No app user can see, access, or know about this system.

### 5.1 — Admin Dashboard

| Feature | Description |
|---------|-------------|
| **Format** | Desktop application (.exe) for Windows |
| **Analytics** | Total users, active users, message volume, storage used, API usage |
| **Admin roles** | Super Admin / Moderator / Read-only Viewer |
| **User management** | Ban/unban users from dashboard |
| **Content management** | Delete messages/content from dashboard |
| **Real-time alerts** | High server load, DB failure, API limit hit — via email + in-app notification |

### 5.2 — Storage Monitoring

| Feature | Description |
|---------|-------------|
| Real-time storage usage | Current used vs total capacity (media + database) |
| Visual storage meter | Progress bar showing usage (e.g., 7.2 GB / 10 GB) |
| Storage breakdown | Images / Videos / Voice notes / Documents — per category |
| Per-user storage | ❌ Not visible to admin |
| Usage alerts | Configurable thresholds (70% / 85% / 95%) |
| Alert recipients | **Only** app owner + super admins |
| Alert methods | In-app admin notification + Email |
| DB row count alerts | Alert at 80% of free tier limits |
| Historical trends | Storage growth over 7 / 30 / 90 days |
| Days-until-full prediction | Auto-calculated based on growth rate |
| Per-account breakdown | Each R2/storage account shown separately |

### 5.3 — Storage Upgrade System

| Feature | Description |
|---------|-------------|
| Add storage accounts | Add new Cloudflare R2 accounts via dashboard UI |
| Add DB accounts | Add new Turso database accounts via dashboard UI |
| File distribution | New files → new account only (no rebalancing) |
| Intelligent routing | Auto-pick least-full bucket for uploads |
| Account labels | Labeled (e.g., "Primary R2", "Media Overflow") |
| Auto-failover | If one account fails/full → auto-route to next |
| Priority order | Primary → Secondary → Tertiary fallback |
| Multi-provider support | Extensible to R2 + B2 + Wasabi (future) |
| File-to-bucket mapping | Central registry tracking file locations |

### 5.4 — Config Management

| Feature | Description |
|---------|-------------|
| Secrets storage | **Infisical** |
| Hot-reload | New keys activate without redeployment (after verification) |
| Auto-propagation | New env vars propagate to all Workers (after verification) |
| Environment separation | dev / staging / production configs |
| Config Manager UI | Add/remove/edit storage accounts from admin dashboard |
| Audit log | Track who changed what, when, from which IP |
| Secret rotation | Auto-rotate API keys on configurable schedule |

### 5.5 — Auto-Updates & Upgrades

| Feature | Description |
|---------|-------------|
| Auto-update on new storage | System picks up new accounts without redeployment |
| Health checks | Auto-ping all storage accounts, DB connections, APIs |
| Auto-retry on failure | If write fails → retry on next account |
| Zero-downtime | Adding storage never interrupts active users |
| Changelog | Visible in admin panel with timestamps |
| Admin notifications | Push + Email when auto-upgrade happens |
| Rollback | Admin can instantly disable problematic accounts |

### 5.6 — Conflict Prevention

| Feature | Description |
|---------|-------------|
| Duplicate prevention | Hash-based routing with unique file IDs |
| Deduplication | ❌ No dedup — store separately per user |
| File ID uniqueness | Globally unique across all accounts (UUID) |
| Account removal | Files remain accessible to active users; cleanup when all parties delete |
| Integrity checker | Periodic scan for broken links, orphan files |

---

## 6. Advanced Features

| ID | Feature | Status | Priority |
|----|---------|--------|----------|
| R1 | Multi-language | Yes + in-app translator | P1 |
| R2 | Theme | Dark / Light / System auto | P0 |
| R3 | Message translation | Translate received messages | P2 |
| R4 | Scheduled messages | ❌ Not supported | — |
| R5 | Draft auto-save | Yes | P1 |
| R6 | Voice speed control | 0.5x / 1x / 1.5x / 2x | P2 |
| R7 | Animated stickers | Yes — Telegram-compatible sticker packs | P1 |
| R8 | In-app camera | 🔮 Future | — |
| R9 | Link preview | Thumbnail + title for URLs | P1 |
| R10 | Read receipts toggle | User can turn off | P1 |
| R11 | Nearby People | 🔮 Future | — |
| R12 | Bot API | 🔮 Future | — |

---

## 7. Launch Priorities

### Must Be Perfect at Launch (P0)
1. **Chatting** — Must work even on 2G connections
2. **Calling** — Adaptive quality; best possible audio/video
3. **Encryption** — E2EE on everything; zero-knowledge server

### MVP Cut Candidates
- Channels, Noise cancellation, Sticker packs, Translation, Slow mode

### Beat Telegram On
- Default E2EE (Telegram requires opt-in)
- Passkey-first authentication
- Ultra-low bandwidth messaging (2G support)

---

## 8. Success Metrics

| Metric | Target |
|--------|--------|
| Message delivery rate | > 99.5% |
| Message latency (good network) | < 500ms |
| Message latency (2G) | < 5s |
| Call connection success | > 95% |
| App crash rate | < 0.5% |

---

## 9. Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Free-tier limits hit early | Multi-account sharding + alerts at 70% |
| 2-person team bandwidth | Strict P0 focus; cut P2 features |
| E2EE complexity | Use battle-tested Signal Protocol library |
| 2G support challenge | Compress payloads; offline queue; progressive loading |

---

### Glossary
| Term | Definition |
|------|-----------|
| E2EE | End-to-End Encryption |
| R2 | Cloudflare R2 — S3-compatible object storage |
| Turso | Edge-first SQLite database (libSQL) |
| Infisical | Open-source secrets management platform |
| Passkey | FIDO2/WebAuthn passwordless authentication |

---

*Generated from PingMe Discovery Interview v2.0 — May 3, 2026*
