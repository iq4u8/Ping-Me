# PingMe — Implementation Plan (Part 2 of 2)

*Continues from Part 1 (Steps 1–64)*

---

## PHASE 5 — ENCRYPTION (Signal Protocol) (Steps 65–74)

65. Flutter: Install `libsignal_protocol_dart` package in `pubspec.yaml`. This provides X3DH key agreement and Double Ratchet.
    - **Why:** Battle-tested Signal Protocol implementation for Dart.

66. Create `lib/core/crypto/key_manager.dart` — on first registration: generate Identity Key Pair (long-term), Signed Pre-Key (rotates monthly), 100 One-Time Pre-Keys. Store private keys in `flutter_secure_storage`. Upload public keys to server via `POST /api/v1/keys/upload`.
    - **Why:** E2EE key generation per TRD Section 5.

67. Backend: Create `src/routes/keys.ts` — `POST /api/v1/keys/upload` stores user's public Identity Key, Signed Pre-Key, and One-Time Pre-Keys. `GET /api/v1/keys/:userId` returns the target user's public key bundle (consuming one One-Time Pre-Key). `POST /api/v1/keys/replenish` uploads more One-Time Pre-Keys when supply runs low.
    - **Why:** Server-side key distribution for X3DH.

68. Create `lib/core/crypto/session_manager.dart` — function `initSession(targetUserId)`: fetch target's key bundle from server, perform X3DH to establish shared secret, initialize Double Ratchet session. Store session state locally in Hive (encrypted).
    - **Why:** Establish encrypted session between two users.

69. Create `lib/core/crypto/message_crypto.dart` — function `encrypt(plaintext, targetUserId)`: get or init session, use Double Ratchet to encrypt. Returns ciphertext bytes. Function `decrypt(ciphertext, senderUserId)`: use session's ratchet state to decrypt. Returns plaintext string.
    - **Why:** Per-message encrypt/decrypt using forward-secrecy ratchet.

70. Integrate encryption into `chat_repository.dart` — before sending: `encrypt(content, recipientId)` then send ciphertext via API. On receiving: `decrypt(ciphertext, senderId)` then display plaintext.
    - **Why:** E2EE integrated into message flow transparently.

71. For group messages: implement Sender Keys protocol — each member generates a Sender Key, distributes it to all members via pairwise E2EE. Messages encrypted once with Sender Key, decrypted by all members.
    - **Why:** Efficient group E2EE without encrypting per-member.

72. Create `lib/core/crypto/key_backup.dart` — function `exportKeys(passphrase)`: encrypt all local keys with user-chosen passphrase (PBKDF2 + AES-256), save to local file. Function `importKeys(file, passphrase)`: decrypt and restore keys.
    - **Why:** Local encrypted key backup for device recovery (PRD C6/C7).

73. Backend: Ensure ALL message-related database queries only store/return `encrypted_content` (BLOB). No plaintext ever touches the server. Add server-side validation that message content field is binary/base64, never raw text.
    - **Why:** Zero-knowledge server enforcement (PRD C3).

74. Flutter: Create `lib/features/chat/presentation/widgets/encryption_badge.dart` — small lock icon shown in chat header confirming E2EE is active. Tappable to show key fingerprint for manual verification.
    - **Why:** Visual E2EE confirmation for user trust.

---

## PHASE 6 — GROUPS & CHANNELS (Steps 75–86)

75. Backend: Create `src/routes/conversations.ts` — register with prefix `/api/v1/conversations`.
    - **Why:** Conversation (group/channel/direct) route module.

76. Implement `POST /api/v1/conversations` — accept `{ type, title, description, isPublic, memberIds[] }`. Type must be `group` or `channel`. Generate UUID. Insert into `conversations`. Insert creator into `conversation_members` with role `creator`. Insert initial members with role `member`. Return conversation object.
    - **Why:** Group/channel creation (PRD D4 — any user can create).

77. Implement `PUT /api/v1/conversations/:id` — accept `{ title?, description?, photoUrl?, slowModeSeconds?, maxMembers?, isPublic? }`. Validate caller has `creator` or `admin` role. Update fields. Broadcast update via WebSocket.
    - **Why:** Group settings management.

78. Implement `POST /api/v1/conversations/:id/members` — accept `{ userId, role? }`. Validate caller is admin+. Check max_members limit (200 for groups). Insert into `conversation_members`. Broadcast `member:joined` event.
    - **Why:** Add members to group.

79. Implement `DELETE /api/v1/conversations/:id/members/:userId` — validate caller is admin+ OR userId is self (leaving). Remove from `conversation_members`. If last member removed, trigger cleanup of all conversation data. Broadcast `member:left`.
    - **Why:** Remove members or leave group. Auto-cleanup when empty per PRD data rules.

80. Implement role management — `PUT /api/v1/conversations/:id/members/:userId/role` — accept `{ role }`. Only creator can promote to admin. Admins can promote to moderator. Validate role hierarchy: creator > admin > moderator > member.
    - **Why:** Granular admin roles (PRD D3).

81. Backend: For channels (type = `channel`) — modify message sending to validate `sender role in ('creator', 'admin')`. Regular members/subscribers can only read. No member limit on channels.
    - **Why:** Channels are admin-post-only with unlimited subscribers (PRD D2).

82. Backend: Create `src/routes/invites.ts` — `POST /api/v1/invites` accepts `{ conversationId, maxUses?, expiresAt?, requiresApproval? }`. Generate unique link_code (8-char alphanumeric). Insert into `invite_links`. Return `https://pingme.app/join/<code>`.
    - **Why:** Invite link creation (PRD E1).

83. Implement `POST /api/v1/invites/:code/join` — lookup invite_link by code. Validate: is_active, not expired, uses < maxUses. If requiresApproval: create join request, notify admins. Else: add user to conversation_members. Increment current_uses.
    - **Why:** Join via invite link with optional approval (PRD E4).

84. Implement `DELETE /api/v1/invites/:id` — validate caller is admin of the conversation. Set `is_active = 0`. Generate new link_code if requested.
    - **Why:** Revoke/regenerate invite links (PRD E5).

85. Flutter: Create `lib/features/groups/presentation/screens/create_group_screen.dart` — form with: group name, description, photo, public/private toggle, member selector. On submit call create conversation API.
    - **Why:** Group creation UI.

86. Flutter: Create `lib/features/groups/presentation/screens/group_info_screen.dart` — show group photo, name, description, member list with roles, invite link section, admin settings (slow mode, permissions). Edit buttons visible only to admins.
    - **Why:** Group management UI.

---

## PHASE 7 — VOICE & VIDEO CALLING (Steps 87–96)

87. Backend: Create `src/routes/calls.ts` with `POST /api/v1/calls/initiate` — accept `{ conversationId, callType }` (voice/video). Generate call UUID. Insert into `call_logs` with status `ringing`. Send `call:incoming` WebSocket event to all recipient devices. Return call object.
    - **Why:** Call initiation endpoint.

88. Implement `POST /api/v1/calls/:id/answer` — update call_logs status to `active`, set `started_at`. Notify caller via `call:answered` WebSocket event.
    - **Why:** Call answer endpoint.

89. Implement `POST /api/v1/calls/:id/end` — update call_logs: set `ended_at`, calculate `duration_seconds`, set status to `completed`. If unanswered, set status to `missed`. Send `call:ended` to all participants. Trigger FCM notification for missed calls.
    - **Why:** Call end + missed call notification (PRD B6).

90. Backend: WebSocket handler for `call:signal` — relay WebRTC signaling data (SDP offers/answers, ICE candidates) between caller and callee. Do NOT store or inspect this data.
    - **Why:** WebRTC signaling relay via WebSocket (TRD Section 8).

91. Flutter: Create `lib/features/calls/presentation/screens/call_screen.dart` — show caller/callee avatar and name. Buttons: mute, speaker, end call. For video: show local preview (small) and remote video (full screen). Timer showing call duration.
    - **Why:** Active call UI.

92. Flutter: Create `lib/features/calls/data/call_manager.dart` — use `flutter_webrtc` package. Function `initiateCall(userId, type)`: create RTCPeerConnection with STUN config (`stun.l.google.com:19302`), create SDP offer, send via WebSocket signaling. Function `answerCall(callId, sdpOffer)`: create SDP answer, send back. Handle ICE candidate exchange.
    - **Why:** WebRTC peer connection management.

93. Implement adaptive bitrate — in `call_manager.dart`, monitor `RTCPeerConnection.getStats()`. If packet loss > 5% or bitrate drops: reduce video resolution and frame rate. If network improves: gradually increase quality back.
    - **Why:** Auto-adjust call quality based on network (PRD B5).

94. Flutter: Create `lib/features/calls/presentation/screens/incoming_call_screen.dart` — full-screen overlay when `call:incoming` received. Show caller name/avatar. Buttons: Accept (green), Decline (red). Play ringtone.
    - **Why:** Incoming call UI.

95. Flutter: Create `lib/features/calls/presentation/screens/call_history_screen.dart` — list of past calls from `GET /api/v1/calls/history`. Show: contact name, call type icon (voice/video), direction (incoming/outgoing/missed), duration, timestamp.
    - **Why:** Call log screen (PRD B7).

96. Implement multi-device ring — backend sends `call:incoming` to ALL active WebSocket connections for the target user. First device to answer gets the call; others receive `call:answered` to stop ringing.
    - **Why:** Ring on all devices (PRD B9).

---

## PHASE 8 — USER PROFILE & PRIVACY (Steps 97–106)

97. Backend: Create `src/routes/users.ts` — `GET /api/v1/users/me` returns full profile. `PUT /api/v1/users/me` accepts `{ displayName?, bio?, phone?, phoneVisible?, lastSeenPrivacy? }`. `GET /api/v1/users/:username` returns public profile (respecting privacy settings).
    - **Why:** Profile CRUD endpoints.

98. Implement `POST /api/v1/users/block/:userId` — insert into `blocked_users`. Remove blocked user from seeing blocker's last seen, profile photo, online status. Prevent blocked user from sending messages. Return success.
    - **Why:** Block user feature (PRD H4).

99. Implement `DELETE /api/v1/users/me` — begin 7-day deletion grace period. Set `deletion_scheduled_at` on user record. After 7 days (via cron/scheduled task): execute full cleanup per TRD Section 12.
    - **Why:** Account deletion with grace period.

100. Backend: Create `src/services/privacy.ts` — function `filterLastSeen(requestingUser, targetUser)`: check target's `last_seen_privacy` setting. Return last_seen timestamp only if allowed. Apply same logic to online status and profile photo visibility.
     - **Why:** Privacy-aware data filtering (PRD H3).

101. Flutter: Create `lib/features/profile/presentation/screens/profile_screen.dart` — show profile photo (tappable to view full), display name, bio, username. Edit button to modify. Show "Set Profile Photo" using image_picker.
     - **Why:** User's own profile view/edit screen.

102. Flutter: Create `lib/features/profile/presentation/screens/user_profile_screen.dart` — view other user's profile. Show: photo, name, bio, username. Buttons: Message, Voice Call, Video Call, Block, Report.
     - **Why:** Other user's profile view.

103. Flutter: Create `lib/features/settings/presentation/screens/privacy_settings_screen.dart` — toggles for: Last seen (everyone/contacts/nobody), Profile photo visibility, Read receipts on/off, Phone number visibility. Each toggle calls `PUT /api/v1/users/me`.
     - **Why:** Privacy settings UI (PRD H3, R10).

104. Backend: Implement push notifications — integrate FCM. On events (new message, missed call, group invite): check if user is offline (no active WebSocket). If offline: send FCM push with title and body (body respects user's notification preview setting).
     - **Why:** Push notifications (PRD H5).

105. Flutter: Create `lib/features/settings/presentation/screens/notification_settings_screen.dart` — toggles: show preview content, per-chat mute, custom notification sound, DND mode with schedule.
     - **Why:** Notification settings UI (PRD H6/H7/H8).

106. Flutter: Implement theme switching in `lib/app/theme.dart` — define `lightTheme` and `darkTheme` with MaterialApp ThemeData. Use system preference by default. Allow user override in settings. Store preference in Hive.
     - **Why:** Dark/Light/System theme (PRD R2).

---

## PHASE 9 — DESKTOP ADMIN APP (Steps 107–118)

107. Create new project directory `pingme-admin/`. Initialize Tauri app: `npm create tauri-app@latest ./` with React frontend.
     - **Why:** Desktop admin app as separate .exe (TRD Section 9).

108. Backend: Create `src/routes/admin.ts` — register ALL admin endpoints under `/admin/v1/*` prefix. Apply separate admin auth middleware that checks a different JWT issued only to super admin accounts (stored in a separate `admin_users` table, NOT the regular `users` table).
     - **Why:** Admin API completely isolated from user API.

109. Create `admin_users` table — `id, username, password_hash, role (super_admin/moderator/viewer), created_at`. Seed with initial owner account.
     - **Why:** Admin auth is fully separate from app user auth.

110. Implement `GET /admin/v1/dashboard/stats` — return: total users, active users (online now), total messages (today/week/month), total storage used, API requests count, new signups today.
     - **Why:** Dashboard analytics (PRD L2).

111. Implement `GET /admin/v1/users` — paginated user list with search. `POST /admin/v1/users/:id/ban` — set banned flag, terminate all sessions, send WebSocket disconnect. `POST /admin/v1/users/:id/unban` — remove banned flag.
     - **Why:** User management (PRD L4).

112. Implement `GET /admin/v1/storage/overview` — query all `storage_accounts`, return: per-account label, provider, used_bytes, total_capacity_bytes, percentage, is_active. Also return: aggregate totals, storage breakdown by file_type from `files` table.
     - **Why:** Storage monitoring (PRD M1/M2/M3).

113. Implement `POST /admin/v1/storage/accounts` — accept `{ label, provider, configSecretKey, totalCapacityBytes, priority }`. Verify the credentials work (test upload + delete) before saving. Insert into `storage_accounts`. Return new account.
     - **Why:** Add storage accounts dynamically (PRD N1).

114. Implement `GET /admin/v1/health` — ping each: Turso DB connection, every R2 storage account (list objects), Infisical connectivity, FCM endpoint. Return status per service with response time.
     - **Why:** System health check (PRD P3).

115. Implement `GET /admin/v1/audit-logs` — query `audit_logs` table (create this table: id, admin_user_id, action, target, details JSON, ip_address, timestamp). Log every admin action.
     - **Why:** Audit trail (PRD O6).

116. Admin React UI: Build dashboard page with charts (use recharts library): user growth line chart, message volume bar chart, storage usage donut chart with per-account breakdown, days-until-full prediction.
     - **Why:** Visual admin dashboard.

117. Admin React UI: Build user management page — searchable table of all users. Row actions: view profile, ban/unban, delete content. Bulk actions.
     - **Why:** User management interface.

118. Admin React UI: Build storage manager page — list all storage accounts with visual meters (progress bars). Button to add new account (form with label, credentials, capacity). Toggle to activate/deactivate. Show historical trend chart.
     - **Why:** Storage management interface.

---

## PHASE 10 — TESTING (Steps 119–125)

119. Backend: Install `vitest` and `supertest`. Create `tests/` directory. Write unit tests for: auth registration validation (username rules, reserved names, case-insensitivity), OTP rate limiting logic (verify tier escalation), message edit window validation.
     - **Why:** Critical business logic must be tested.

120. Backend: Write integration tests for: full auth flow (register → login → get profile), message flow (send → receive → edit → delete), group flow (create → add member → send message → remove member).
     - **Why:** End-to-end API flow verification.

121. Backend: Write tests for storage router — mock multiple storage accounts, verify least-full selection, verify failover when primary fails.
     - **Why:** Storage routing is critical infrastructure logic.

122. Flutter: Write unit tests for `message_crypto.dart` — verify encrypt/decrypt roundtrip, verify different sessions produce different ciphertext, verify forward secrecy (old keys can't decrypt new messages).
     - **Why:** Encryption correctness is non-negotiable.

123. Flutter: Write widget tests for `message_bubble.dart` — verify render for each message type (text, image, voice), verify status indicators display correctly, verify edit label shows when is_edited is true.
     - **Why:** UI component correctness.

124. Flutter: Write integration test for auth flow — mock API, verify: welcome screen → OTP screen → username setup → home screen navigation.
     - **Why:** Critical user journey testing.

125. Set up GitHub Actions CI — on push: run backend tests (`npm test`), run Flutter tests (`flutter test`), build APK (`flutter build apk`). Fail pipeline if any tests fail.
     - **Why:** Automated quality gate.

---

## PHASE 11 — DEPLOYMENT (Steps 126–133)

126. Create Cloudflare Workers project for API: `npx wrangler init pingme-api`. Configure `wrangler.toml` with environment variables. Deploy with `wrangler deploy`.
     - **Why:** Free-tier API hosting (100K requests/day).

127. If WebSocket not supported on Workers: deploy WebSocket server to Railway. Create `Dockerfile` for the Node.js backend. Push to Railway via GitHub integration.
     - **Why:** Railway supports persistent WebSocket connections.

128. Set up Infisical project — create `pingme` project with environments: `dev`, `staging`, `production`. Store all secrets (Turso URL, R2 keys, JWT secret, FCM key, SMTP creds). Install Infisical SDK in backend.
     - **Why:** Centralized secrets management (PRD O1).

129. Configure Firebase project — enable Cloud Messaging. Download `google-services.json` and place in `android/app/`. Configure Flutter Firebase initialization in `main.dart`.
     - **Why:** Push notifications setup.

130. Set up Sentry free tier — create project for Node.js backend. Install `@sentry/node`. Initialize in `src/index.ts` with DSN. Capture all unhandled exceptions.
     - **Why:** Error monitoring (TRD Section 17).

131. Build Flutter APK: `flutter build apk --release`. Build AAB: `flutter build appbundle --release`. Test APK on physical device.
     - **Why:** Production Android build.

132. Create Google Play Console developer account. Create app listing for PingMe. Upload AAB to Internal Testing track. Add 100 testers.
     - **Why:** Distribution to initial 100 users (PRD launch goal).

133. Build admin app: `cd pingme-admin && npm run tauri build`. This produces `.exe` installer. Distribute to owner/dev team only via private channel.
     - **Why:** Admin desktop app distribution.

---

## PHASE 12 — POST-LAUNCH MONITORING (Steps 134–140)

134. Implement storage usage cron job — scheduled task runs every hour: query all storage accounts, calculate percentages. If any account > 70%: send alert email + admin app notification. If > 85%: send urgent alert. If > 95%: send critical alert.
     - **Why:** Storage monitoring alerts (PRD M5).

135. Implement DB usage monitoring — track Turso read count via API. Alert at 80% of 500M monthly reads. Show current usage in admin dashboard.
     - **Why:** Free tier limit monitoring (PRD M7).

136. Implement storage integrity checker — scheduled weekly task: scan `files` table, verify each file exists in its mapped R2 account. Report orphaned files, broken links, missing files in admin dashboard.
     - **Why:** Storage integrity (PRD Q6).

137. Set up Firebase Crashlytics in Flutter app — add `firebase_crashlytics` package. Initialize in `main.dart`. Wrap `runApp` in `runZonedGuarded` to capture all Flutter errors.
     - **Why:** App crash monitoring (target < 0.5%).

138. Implement admin changelog — every system event (new storage account added, user banned, config changed) creates entry in `changelog` table. Display in admin app as timeline.
     - **Why:** System changelog (PRD P7).

139. Implement config hot-reload — backend polls Infisical every 60 seconds for config changes. On change detected: verify new credentials work (test connection), then swap live config. Log change to audit log.
     - **Why:** Hot-reload config without redeployment (PRD O2).

140. Set up uptime monitoring — use free tier of UptimeRobot or similar. Monitor: API health endpoint, WebSocket endpoint, R2 availability. Alert admin on downtime.
     - **Why:** Service availability monitoring.

---

## Priority Execution Order (MVP Focus)

For a 2-person team targeting 100 users, execute phases in this order:

| Order | Phase | Why First |
|-------|-------|-----------|
| 1 | Phase 1 (Setup) | Foundation — nothing works without it |
| 2 | Phase 2 (Auth) | Users need to register/login |
| 3 | Phase 3 (Messaging) | Core P0 feature |
| 4 | Phase 4 (Media) | Messages need media support |
| 5 | Phase 5 (Encryption) | Core differentiator — E2EE everything |
| 6 | Phase 7 (Calling) | Second P0 feature |
| 7 | Phase 6 (Groups) | P0 for groups, P1 for channels |
| 8 | Phase 8 (Profile) | Polish user experience |
| 9 | Phase 11 (Deploy) | Get it live for 100 users |
| 10 | Phase 10 (Testing) | Stabilize before wider rollout |
| 11 | Phase 9 (Admin App) | Needed only after real users are on platform |
| 12 | Phase 12 (Monitoring) | Scale monitoring after initial launch |

---

## Non-Goals (Explicitly Excluded from MVP)

- iOS / Web / Desktop client apps
- In-app camera
- Bot / Chatbot API
- Nearby People feature
- Scheduled messages
- Noise cancellation / background blur in video
- Slow mode in groups
- Content moderation AI (manual review via admin app is sufficient at 100 users)

---

*End of Implementation Plan — 140 steps across 12 phases*
