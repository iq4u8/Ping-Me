# Ping Me — Frontend

A premium, Telegram-inspired messaging application built with **Flutter** and **Dart**.

## 📱 Features

### Authentication & Onboarding
- **Swipeable Welcome Screen** — 3 theme slides (Warm, Light, Dark) with auto-theme switching, unique taglines, dot indicators, and inspirational quotes
- **Bottom Sheet Auth Flow** — Slide-up popup with Google Sign-In (proper multi-color G logo) and email/OTP flow
- **OTP Verification** — 6-box digit input with auto-focus shifting, countdown timer, resend logic, and a clean spinner overlay
- **Username Setup** — First/Last name entry with avatar upload and passkey registration prompt

### Chat System
- **Chat List** — Real-time conversation tiles with swipe-to-archive (left) and swipe-to-delete (right) with confirmation dialog
- **Conversation Screen** — Full message input, attachment picker (Photo, Video, File, Audio, Location), emoji/sticker support, call buttons (Voice/Video) with type picker
- **Saved Messages** — Working notepad: type messages, send, and see them appear as chat bubbles with timestamps; attachment menu for media/files/location
- **Search** — Integrated search bar in the chat list header

### Folders & Organization
- **Chat Folders** — Create, rename, reorder (drag-handle), and delete custom categories
- **Folder Context Menu** — Long-press any tab for Telegram-style options: Edit, Reorder, Mute All, Mute for..., Mark all as read, Sort, Set as default, Delete/Hide
- **Category Selection** — Folder creation dialog includes checkboxes for Direct Chats, Groups, Channels

### Groups & Channels
- **Create Group** — Multi-step flow with name, avatar (camera permission handling), friend selection (optional), bio
- **Create Channel** — Dedicated channel creation with permission-aware photo picker

### Profile & Contacts
- **Profile Screen** — Tabbed interface (Media, Files, Links, Audio) with smooth switching
- **Edit Info** — Live-editable First/Last name, bio with character counter (70 max), username dialog, birthday date picker, phone change dialog, and functional logout with navigation reset
- **QR Code** — Dynamic QR with rotating color themes, countdown timer, share/copy action, and scanner dialog
- **User Profile** — Tap any contact to see bio, username, shared media, notification mute picker (1h/8h/1d/3d/Forever)

### Settings
- **Account** — Change phone number, set username, add birthday, create personal channel, log out
- **Privacy** — Granular controls: Last Seen, Profile Photo, Bio, Phone Number, Read Receipts, Forwarded Messages, Calls, Voice Messages, Groups & Channels visibility; Blocked Users list with empty state
- **Security** — Two-Factor Auth toggle, App Passcode toggle, Active Sessions (with individual & bulk terminate), Encryption Keys viewer with export
- **Notifications** — Full notification preference toggles
- **Data & Storage** — Storage usage breakdown dialog (Photos/Videos/Files/Cache with progress bars), auto-download toggles, cache clearing with confirmation
- **Appearance** — Theme switcher (Default/Light/Dark), app icon toggle, Chat Wallpaper picker, Dashboard Wallpaper picker (both via gallery)
- **Help** — Support Group join dialog (with member count), Complaint Box, custom premium About dialog with app info + feature icons (Secure, Fast, Synced)

### Side Panel (Drawer)
- **Glassmorphic Drawer** — Blurred background, profile info, theme cycle button, bookmark shortcut
- **Full Navigation** — Add Account, My Profile, New Group, New Channel, Contacts, Chat Folders, Saved Messages, Calls, Settings — all linked and functional

### UX Polish
- **Haptic Feedback** — `HapticFeedback.selectionClick()` on all tap interactions, `heavyImpact()` on destructive actions
- **Animations** — Scale-down FAB, fade+slide transitions on welcome screen, animated size changes on auth popup
- **Vibration** — System-level vibration on key interactions
- **Device Permissions** — Runtime CAMERA, RECORD_AUDIO, VIBRATE permissions with graceful denial handling

## 🎨 Themes

| Theme | Background | Primary | Style |
|-------|-----------|---------|-------|
| **Default (Warm)** | `#1A120B` | `#F2BE8C` | Dark brown, cozy aesthetic |
| **Light** | `#FFFFFF` | `#3390EC` | Clean white, Telegram Blue |
| **Dark** | `#000000` | `#3390EC` | Pure dark, Telegram Blue |

## 🏗 Architecture

```
lib/
├── data/repositories/       # Auth & Chat repository implementations
├── domain/models/            # Conversation, Message, User models
├── features/
│   ├── auth/                 # Welcome, Identify, OTP, Username screens
│   ├── calls/                # Call history
│   ├── channels/             # Channel creation
│   ├── chat/                 # Chat list, Conversation, Saved Messages, Folders
│   ├── contacts/             # Contact list
│   ├── groups/               # Group creation
│   ├── home/                 # Bottom navigation host
│   ├── profile/              # Edit info, QR code, User profile
│   └── settings/             # All settings sub-screens
├── presentation/viewmodels/  # Auth, Chat, Theme ViewModels (Provider)
├── shared/widgets/           # Reusable components (WireButton, MediaPicker)
├── main.dart                 # App entry, routing, provider setup
└── theme.dart                # 3 theme definitions (Default, Light, Dark)
```

## 🚀 Getting Started

```bash
# Clone and install
git clone <repo-url>
cd pingme-frontend
flutter pub get

# Run in debug
flutter run

# Build release APK
flutter build apk --release
```

## 📦 Key Dependencies

- `provider` — State management
- `google_fonts` — Inter, Space Grotesk, Playfair Display typography
- `flutter_animate` — Declarative animations
- `permission_handler` — Runtime permissions
- `photo_manager` — Gallery access
- `image_picker` — Camera/gallery image selection
- `hive` / `flutter_secure_storage` — Local data persistence (ready for backend binding)

## 📌 Status

**Current State: Golden UI** — All screens, buttons, dialogs, and interactions are fully designed and functional with mock data. Zero "coming soon" placeholders remain. Ready for backend API integration.
