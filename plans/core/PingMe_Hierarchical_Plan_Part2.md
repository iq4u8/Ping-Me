# PingMe — Hierarchical Implementation Breakdown (Part 2/3)

## 3. CORE MESSAGING

### 3.1 Backend Message Routes
#### 3.1.1 Route Setup
3.1.1.1 Create `src/routes/messages.ts`
3.1.1.2 Export function accepting Fastify instance
3.1.1.3 Apply auth middleware to all routes in this module
3.1.1.4 In `src/index.ts`, register with prefix `/api/v1/messages`

#### 3.1.2 Send Message Endpoint
3.1.2.1 Define `POST /` route
3.1.2.2 Accept body: `{ conversationId, type, encryptedContent, replyToId?, selfDestructSeconds? }`
3.1.2.3 Validate sender is member of conversation via `conversation_members` query
3.1.2.4 Generate UUID for message ID
3.1.2.5 Insert into `messages` table with all fields
3.1.2.6 Query all members of the conversation
3.1.2.7 Insert `message_status` row per member with status `sent`
3.1.2.8 Broadcast `message:new` via WebSocket to all online members
3.1.2.9 For offline members: send FCM push notification
3.1.2.10 Return created message object

#### 3.1.3 Get Messages Endpoint
3.1.3.1 Define `GET /:convId` route
3.1.3.2 Accept query params: `limit` (default 50), `before` (cursor messageId)
3.1.3.3 Query `messages` joined with `message_status` for current user
3.1.3.4 Exclude rows where `deleted_for_self = 1` for this user
3.1.3.5 Exclude rows where `deleted_for_everyone = 1`
3.1.3.6 Order by `created_at DESC`
3.1.3.7 Limit by `limit` param
3.1.3.8 If `before` provided: add WHERE `created_at < (select created_at from messages where id = before)`
3.1.3.9 Return array of messages

#### 3.1.4 Edit Message Endpoint
3.1.4.1 Define `PUT /:id` route
3.1.4.2 Accept body: `{ encryptedContent }`
3.1.4.3 Query message by ID
3.1.4.4 Validate `sender_id` matches `request.user.id`
3.1.4.5 Calculate time difference: `now - created_at`
3.1.4.6 If difference > 5 minutes: return 403 with error
3.1.4.7 Update `encrypted_content` in messages table
3.1.4.8 Set `is_edited = 1`
3.1.4.9 Set `edited_at = current timestamp`
3.1.4.10 Broadcast `message:edited` via WebSocket
3.1.4.11 Return updated message

#### 3.1.5 Delete Message Endpoint
3.1.5.1 Define `DELETE /:id` route
3.1.5.2 Accept body: `{ deleteForEveryone }`
3.1.5.3 Query message by ID
3.1.5.4 If `deleteForEveryone` is true:
3.1.5.5   Validate sender_id matches request.user.id
3.1.5.6   Set `deleted_for_everyone = 1` on message row
3.1.5.7   Broadcast `message:deleted` to all conversation members
3.1.5.8 If `deleteForEveryone` is false:
3.1.5.9   Set `deleted_for_self = 1` in `message_status` for this user only
3.1.5.10 Return `{ success: true }`

#### 3.1.6 React to Message Endpoint
3.1.6.1 Define `POST /:id/react` route
3.1.6.2 Accept body: `{ emoji }`
3.1.6.3 Check if reaction already exists for this user+message+emoji
3.1.6.4 If exists: delete it (toggle off)
3.1.6.5 If not exists: insert into `message_reactions`
3.1.6.6 Broadcast `message:reaction` via WebSocket
3.1.6.7 Return updated reactions list for this message

### 3.2 WebSocket Server
#### 3.2.1 Connection Manager
3.2.1.1 Create `src/websocket/manager.ts`
3.2.1.2 Create Map: `connections = new Map<string, WebSocket[]>()`
3.2.1.3 Export function `addConnection(userId, ws)`: push ws to user's array
3.2.1.4 Export function `removeConnection(userId, ws)`: filter out ws from array
3.2.1.5 Export function `sendToUser(userId, event, data)`: JSON.stringify and send to all user's connections
3.2.1.6 Export function `sendToConversation(convId, event, data, excludeUserId?)`: query members, send to each online member except excluded
3.2.1.7 Export function `isUserOnline(userId)`: return true if user has active connections

#### 3.2.2 Event Handlers
3.2.2.1 Create `src/websocket/handlers.ts`
3.2.2.2 Export function `handleMessage(userId, rawData)`: parse JSON, route by event type
3.2.2.3 Handle `typing:start`: broadcast `typing:indicator` to conversation members
3.2.2.4 Handle `typing:stop`: broadcast typing stopped to conversation members
3.2.2.5 Handle `presence:update`: update `users.status` and `last_seen` in DB
3.2.2.6 Broadcast `presence:changed` to relevant users
3.2.2.7 Handle `message:send`: validate, save to DB, broadcast
3.2.2.8 Handle `message:edit`: validate 5-min window, update DB, broadcast
3.2.2.9 Handle `message:delete`: validate ownership, update DB, broadcast
3.2.2.10 Handle `message:react`: toggle reaction in DB, broadcast

#### 3.2.3 WebSocket Endpoint
3.2.3.1 In `src/index.ts`, register WebSocket route at path `/ws`
3.2.3.2 On upgrade: extract `token` query parameter
3.2.3.3 Verify JWT token
3.2.3.4 If invalid: close connection with 4001 code
3.2.3.5 If valid: call `addConnection(userId, ws)`
3.2.3.6 Update user status to `online` in DB
3.2.3.7 Broadcast `presence:changed` with status `online`
3.2.3.8 On message: call `handleMessage(userId, data)`
3.2.3.9 On close: call `removeConnection(userId, ws)`
3.2.3.10 If user has no remaining connections: set status to `offline`, update `last_seen`
3.2.3.11 Broadcast `presence:changed` with status `offline`

### 3.3 Message Status Service
3.3.1 Create `src/services/message_status.ts`
3.3.2 Export function `markDelivered(messageId, userId)`: update status to `delivered` in `message_status`
3.3.3 Broadcast `message:status` event to message sender with `{ messageId, status: 'delivered' }`
3.3.4 Export function `markRead(messageId, userId)`: update status to `read`
3.3.5 Broadcast `message:status` to sender with `{ messageId, status: 'read' }`
3.3.6 Export function `markAllRead(conversationId, userId)`: batch update all unread messages for user in this conversation

### 3.4 Flutter Chat UI
#### 3.4.1 Conversations List Screen
3.4.1.1 Create `lib/features/chat/presentation/screens/conversations_list_screen.dart`
3.4.1.2 Create StatefulWidget `ConversationsListScreen`
3.4.1.3 Add ListView.builder for conversation list
3.4.1.4 Each list item shows: avatar, name, last message preview, unread badge, timestamp
3.4.1.5 Sort conversations by last message time descending
3.4.1.6 Add pull-to-refresh functionality
3.4.1.7 Add FloatingActionButton to start new chat
3.4.1.8 Add search icon in AppBar for searching conversations
3.4.1.9 On tap item: navigate to ChatScreen with conversation ID

#### 3.4.2 Chat Screen
3.4.2.1 Create `lib/features/chat/presentation/screens/chat_screen.dart`
3.4.2.2 Accept `conversationId` as constructor parameter
3.4.2.3 Add AppBar with contact name, avatar, online status dot
3.4.2.4 Add ListView.builder with `reverse: true` for message list
3.4.2.5 Load messages from repository with pagination
3.4.2.6 Add scroll listener: when reaching top, load more messages
3.4.2.7 Add MessageInput widget at bottom
3.4.2.8 Show typing indicator widget above input when other user is typing
3.4.2.9 Listen to WebSocket for new messages, edits, deletes, reactions
3.4.2.10 On long-press message: show context menu (reply, edit, delete, react, forward, pin)

#### 3.4.3 Message Bubble Widget
3.4.3.1 Create `lib/features/chat/presentation/widgets/message_bubble.dart`
3.4.3.2 Accept `message` object as parameter
3.4.3.3 Render sender name (only in group chats)
3.4.3.4 Render message content based on type (text, image, video, voice, etc.)
3.4.3.5 Show timestamp at bottom-right
3.4.3.6 Show status indicator: single check (sent), double check (delivered), blue double check (read)
3.4.3.7 Show "edited" label if `is_edited == true`
3.4.3.8 Show reply-to preview if `replyToId` exists
3.4.3.9 Show emoji reactions row below bubble if reactions exist
3.4.3.10 Align right for own messages, left for others
3.4.3.11 Use different bubble colors for own vs others

#### 3.4.4 Message Input Widget
3.4.4.1 Create `lib/features/chat/presentation/widgets/message_input.dart`
3.4.4.2 Add TextField with max 4096 character limit
3.4.4.3 Show character count when approaching limit
3.4.4.4 Add attachment button (opens picker sheet)
3.4.4.5 Add send button (enabled only when text is not empty)
3.4.4.6 Show "Replying to..." bar above input when in reply mode
3.4.4.7 Add voice recording button (hold to record)
3.4.4.8 On text change: emit typing start via WebSocket (debounced 3 seconds)

### 3.5 Flutter Chat Data Layer
3.5.1 Create `lib/features/chat/data/chat_repository.dart`
3.5.2 Add method `getConversations()` calling `GET /conversations`
3.5.3 Add method `getMessages(convId, before?)` calling `GET /messages/:convId`
3.5.4 Add method `sendMessage(convId, type, content)` calling `POST /messages`
3.5.5 Add method `editMessage(id, content)` calling `PUT /messages/:id`
3.5.6 Add method `deleteMessage(id, forEveryone)` calling `DELETE /messages/:id`
3.5.7 Add method `reactToMessage(id, emoji)` calling `POST /messages/:id/react`
3.5.8 Add method `searchMessages(query)` calling `GET /messages/search`

### 3.6 Flutter Chat BLoC
3.6.1 Create `lib/features/chat/domain/chat_bloc.dart`
3.6.2 Define states: `ConversationsLoaded`, `MessagesLoaded`, `MessageSending`, `MessageSent`, `ChatError`
3.6.3 Define events: `LoadConversations`, `LoadMessages`, `SendMessage`, `EditMessage`, `DeleteMessage`, `NewMessageReceived`
3.6.4 Handle `LoadConversations`: call repository, emit ConversationsLoaded
3.6.5 Handle `LoadMessages`: call repository with pagination, emit MessagesLoaded
3.6.6 Handle `SendMessage`: emit Sending, call repository, emit Sent
3.6.7 Handle `NewMessageReceived`: add to current messages list, emit updated state

### 3.7 Flutter WebSocket Client
#### 3.7.1 WebSocket Manager
3.7.1.1 Create `lib/core/network/websocket_manager.dart`
3.7.1.2 Connect to `ws://<wsUrl>/ws?token=<jwt>`
3.7.1.3 Implement auto-reconnect with exponential backoff: 1s, 2s, 4s, 8s, max 30s
3.7.1.4 On message received: parse JSON, extract event type and data
3.7.1.5 Route event to appropriate BLoC via stream controller
3.7.1.6 Export method `send(event, data)` to send JSON via WebSocket
3.7.1.7 Handle connection state changes: connecting, connected, disconnected

#### 3.7.2 WebSocket Events
3.7.2.1 Create `lib/core/network/websocket_events.dart`
3.7.2.2 Define class `WsEvent` with `type` and `data` fields
3.7.2.3 Define `MessageNewEvent` with `fromJson` factory
3.7.2.4 Define `MessageEditedEvent` with `fromJson` factory
3.7.2.5 Define `MessageDeletedEvent` with `fromJson` factory
3.7.2.6 Define `MessageReactionEvent` with `fromJson` factory
3.7.2.7 Define `MessageStatusEvent` with `fromJson` factory
3.7.2.8 Define `TypingIndicatorEvent` with `fromJson` factory
3.7.2.9 Define `PresenceChangedEvent` with `fromJson` factory
3.7.2.10 Define `CallIncomingEvent` with `fromJson` factory
3.7.2.11 Define `CallSignalEvent` with `fromJson` factory
3.7.2.12 Define `CallEndedEvent` with `fromJson` factory

## 4. MEDIA & FILE HANDLING

### 4.1 Backend Media Upload
4.1.1 Create `src/routes/media.ts`
4.1.2 Register with prefix `/api/v1/media` with auth middleware
4.1.3 Install `@fastify/multipart`: `npm install @fastify/multipart`
4.1.4 Register multipart plugin in Fastify

#### 4.1.5 Upload Endpoint
4.1.5.1 Define `POST /upload` route
4.1.5.2 Accept multipart form with file field and metadata
4.1.5.3 Validate file size: images 10MB, videos 50MB, voice 15MB, documents 25MB
4.1.5.4 If exceeds limit: return 413 error
4.1.5.5 Generate UUID for file ID
4.1.5.6 Call `selectStorageAccount()` from storage router
4.1.5.7 Construct bucket key: `<type>/<userId>/<fileId>.<ext>`
4.1.5.8 Upload file buffer to selected R2 account
4.1.5.9 If upload fails: call `failoverUpload()` to try next account
4.1.5.10 Insert row into `files` table with file metadata
4.1.5.11 Update `used_bytes` on the storage account
4.1.5.12 Return `{ fileId, url, thumbnailUrl? }`

#### 4.1.6 Download Endpoint
4.1.6.1 Define `GET /:fileId` route
4.1.6.2 Query `files` table by fileId
4.1.6.3 Get storage account details from `storage_accounts` table
4.1.6.4 Generate presigned URL from correct R2 account with 1-hour expiry
4.1.6.5 Return `{ url }` or redirect to presigned URL

### 4.2 Storage Router Service
4.2.1 Create `src/services/storage_router.ts`
4.2.2 Export function `selectStorageAccount()`:
4.2.3   Query `storage_accounts` where `is_active = 1`
4.2.4   Sort by `priority` ascending
4.2.5   Among same priority: pick account with most free space (`total_capacity_bytes - used_bytes`)
4.2.6   Return selected account
4.2.7 Export function `failoverUpload(buffer, key, mime)`:
4.2.8   Get sorted list of active accounts
4.2.9   Try upload on first account
4.2.10  If fails: try next account
4.2.11  Continue until success or all accounts exhausted
4.2.12  If all fail: throw error

### 4.3 Thumbnail Service
4.3.1 Run `npm install sharp`
4.3.2 Create `src/services/thumbnail.ts`
4.3.3 Export function `generateThumbnail(imageBuffer)`:
4.3.4   Use sharp to resize to max 100px width
4.3.5   Set quality to 60%
4.3.6   Return thumbnail buffer
4.3.7 In upload endpoint: if file is image, generate thumbnail
4.3.8 Upload thumbnail with key suffix `_thumb`
4.3.9 Store thumbnail key in files table or return alongside original URL

### 4.4 Flutter Media Components
#### 4.4.1 Media Message Widget
4.4.1.1 Create `lib/features/chat/presentation/widgets/media_message.dart`
4.4.1.2 For image type: show thumbnail, tap for full image
4.4.1.3 For video type: show thumbnail with play button overlay
4.4.1.4 For voice type: show waveform, play/pause button, duration text
4.4.1.5 For document type: show file icon, filename, size, download button

#### 4.4.2 Media Repository
4.4.2.1 Create `lib/features/chat/data/media_repository.dart`
4.4.2.2 Add method `uploadFile(File file, String type)` using Dio multipart
4.4.2.3 Return upload progress via stream for progress indicator
4.4.2.4 Add method `getFileUrl(String fileId)` calling `GET /media/:fileId`

#### 4.4.3 Attachment Picker
4.4.3.1 Create `lib/shared/widgets/image_picker_sheet.dart`
4.4.3.2 Show bottom sheet with grid of options
4.4.3.3 Option: Camera (opens device camera)
4.4.3.4 Option: Gallery (opens image picker)
4.4.3.5 Option: Video (opens video picker)
4.4.3.6 Option: Document (opens file picker)
4.4.3.7 Option: Location (opens location picker)
4.4.3.8 Option: Poll (opens poll creation form)
4.4.3.9 Option: Contact (opens contact picker)
4.4.3.10 Return selected file/data to MessageInput widget

---

*Continued in Part 3/3...*
