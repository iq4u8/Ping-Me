-- PingMe Database Schema

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT UNIQUE,
    bio TEXT,
    profile_photo_url TEXT,
    status TEXT DEFAULT 'offline',
    last_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_seen_privacy TEXT CHECK(last_seen_privacy IN ('everyone', 'contacts', 'nobody')) DEFAULT 'everyone',
    profile_photo_privacy TEXT CHECK(profile_photo_privacy IN ('everyone', 'contacts', 'nobody')) DEFAULT 'everyone',
    phone_visible INTEGER DEFAULT 0,
    read_receipts_enabled INTEGER DEFAULT 1,
    notifications_enabled INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Sessions Table
CREATE TABLE IF NOT EXISTS sessions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    device_info TEXT,
    ip_address TEXT,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_active DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Conversations Table
CREATE TABLE IF NOT EXISTS conversations (
    id TEXT PRIMARY KEY,
    type TEXT CHECK(type IN ('one-to-one', 'group', 'channel')) NOT NULL,
    name TEXT, -- Null for one-to-one
    description TEXT,
    avatar_url TEXT,
    creator_id TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Conversation Members Table
CREATE TABLE IF NOT EXISTS conversation_members (
    conversation_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    role TEXT CHECK(role IN ('member', 'admin', 'owner')) DEFAULT 'member',
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (conversation_id, user_id),
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Messages Table
CREATE TABLE IF NOT EXISTS messages (
    id TEXT PRIMARY KEY,
    conversation_id TEXT NOT NULL,
    sender_id TEXT NOT NULL,
    type TEXT CHECK(type IN ('text', 'image', 'video', 'voice', 'file', 'location', 'poll', 'contact')) DEFAULT 'text',
    encrypted_content TEXT NOT NULL, -- Ciphertext for E2EE
    reply_to_id TEXT,
    is_edited INTEGER DEFAULT 0,
    edited_at DATETIME,
    deleted_for_everyone INTEGER DEFAULT 0,
    self_destruct_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (reply_to_id) REFERENCES messages(id) ON DELETE SET NULL
);

-- Message Status Table (Delivery/Read Receipts)
CREATE TABLE IF NOT EXISTS message_status (
    message_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    status TEXT CHECK(status IN ('sent', 'delivered', 'read')) DEFAULT 'sent',
    deleted_for_self INTEGER DEFAULT 0,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (message_id, user_id),
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Message Reactions Table
CREATE TABLE IF NOT EXISTS message_reactions (
    message_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    emoji TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (message_id, user_id, emoji),
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Pinned Messages Table
CREATE TABLE IF NOT EXISTS pinned_messages (
    conversation_id TEXT NOT NULL,
    message_id TEXT NOT NULL,
    pinned_by TEXT NOT NULL,
    pinned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (conversation_id, message_id),
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    FOREIGN KEY (pinned_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Files/Media Table
CREATE TABLE IF NOT EXISTS files (
    id TEXT PRIMARY KEY,
    storage_account_id TEXT NOT NULL,
    bucket_key TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    mime_type TEXT NOT NULL,
    uploader_id TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uploader_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Storage Accounts Table (For Multi-account R2 routing)
CREATE TABLE IF NOT EXISTS storage_accounts (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    endpoint TEXT NOT NULL,
    access_key TEXT NOT NULL,
    secret_key TEXT NOT NULL,
    bucket_name TEXT NOT NULL,
    priority INTEGER DEFAULT 1,
    used_bytes INTEGER DEFAULT 0,
    is_active INTEGER DEFAULT 1
);

-- OTP Attempts Table (Rate Limiting)
CREATE TABLE IF NOT EXISTS otp_attempts (
    identifier TEXT NOT NULL, -- email or phone
    attempt_count INTEGER DEFAULT 0,
    last_attempt_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    lock_until DATETIME,
    tier INTEGER DEFAULT 0,
    PRIMARY KEY (identifier)
);

-- OTPs Table (Actual codes)
CREATE TABLE IF NOT EXISTS otps (
    identifier TEXT NOT NULL,
    hashed_otp TEXT NOT NULL,
    expires_at DATETIME NOT NULL,
    PRIMARY KEY (identifier)
);

-- User 2FA Table
CREATE TABLE IF NOT EXISTS user_2fa (
    user_id TEXT PRIMARY KEY,
    secret TEXT NOT NULL, -- Encrypted TOTP secret
    is_enabled INTEGER DEFAULT 0,
    backup_codes TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Contacts Table
CREATE TABLE IF NOT EXISTS contacts (
    user_id TEXT NOT NULL,
    contact_user_id TEXT NOT NULL,
    nickname TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, contact_user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Blocked Users Table
CREATE TABLE IF NOT EXISTS blocked_users (
    user_id TEXT NOT NULL,
    blocked_user_id TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, blocked_user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (blocked_user_id) REFERENCES users(id) ON DELETE CASCADE
);
