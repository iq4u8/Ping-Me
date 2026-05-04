import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../presentation/viewmodels/chat_viewmodel.dart';
import '../../shared/widgets/custom_media_picker.dart';

class ConversationScreen extends StatefulWidget {
  final String nodeName;
  const ConversationScreen({super.key, required this.nodeName});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isMicMode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatViewModel>(context, listen: false).loadMessages(widget.nodeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatVM = Provider.of<ChatViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/user_profile', arguments: widget.nodeName),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primary.withOpacity(0.15),
                child: Text(
                  widget.nodeName.isNotEmpty ? widget.nodeName[0].toUpperCase() : '?',
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nodeName,
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'last seen recently',
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call_outlined, color: colorScheme.onSurface),
            onPressed: () {
              HapticFeedback.selectionClick();
              showModalBottomSheet(
                context: context,
                backgroundColor: colorScheme.surface,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (ctx) => SafeArea(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(height: 8),
                    ListTile(
                      leading: Icon(Icons.call, color: colorScheme.primary),
                      title: Text('Voice Call', style: TextStyle(color: colorScheme.onSurface)),
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling ${widget.nodeName}...'), backgroundColor: colorScheme.primary));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.videocam, color: colorScheme.primary),
                      title: Text('Video Call', style: TextStyle(color: colorScheme.onSurface)),
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video calling ${widget.nodeName}...'), backgroundColor: colorScheme.primary));
                      },
                    ),
                    const SizedBox(height: 8),
                  ]),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              switch (value) {
                case 'search': break;
                case 'mute': break;
                case 'wallpaper': Navigator.pushNamed(context, '/chat_wallpapers'); break;
                case 'clear': _showClearChatDialog(context, colorScheme); break;
                case 'block': _showBlockDialog(context, colorScheme); break;
                case 'report': break;
              }
            },
            itemBuilder: (context) => [
              _menuItem(Icons.search, 'Search', 'search', colorScheme),
              _menuItem(Icons.volume_off_outlined, 'Mute', 'mute', colorScheme),
              _menuItem(Icons.wallpaper, 'Wallpaper', 'wallpaper', colorScheme),
              const PopupMenuDivider(),
              _menuItem(Icons.cleaning_services_outlined, 'Clear Chat', 'clear', colorScheme),
              _menuItem(Icons.block, 'Block', 'block', colorScheme, isDanger: true),
              _menuItem(Icons.flag_outlined, 'Report', 'report', colorScheme, isDanger: true),
            ],
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Column(
        children: [
          // Bio / Pinned Message Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bio',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Silence is my signature.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: chatVM.isLoading
                ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    reverse: true,
                    itemCount: chatVM.currentMessages.length,
                    itemBuilder: (context, index) {
                      final msg = chatVM.currentMessages.reversed.toList()[index];
                      return GestureDetector(
                        onLongPress: () => _showMessageActions(context, colorScheme, msg.isMe),
                        child: ChatBubble(
                          isMe: msg.isMe,
                          text: msg.content,
                        ),
                      );
                    },
                  ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Theme.of(context).colorScheme.background,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.sentiment_satisfied_alt, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                          onPressed: () {
                            // Emoji picker
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            maxLines: 5,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Message',
                              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 16),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                            ),
                            onChanged: (text) {
                              setState(() {}); // Update to show/hide send
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                          onPressed: () async {
                            final selectedAsset = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SizedBox(
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: const CustomMediaPickerBottomSheet(),
                              ),
                            );
                            if (selectedAsset != null) {
                              // Handle selected asset
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _messageController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          chatVM.send(widget.nodeName, _messageController.text);
                          _messageController.clear();
                          setState(() {});
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMicMode = !_isMicMode;
                          });
                        },
                        onLongPress: () {
                          // Handle hold to record
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: Icon(
                              _isMicMode ? Icons.mic : Icons.videocam,
                              key: ValueKey<bool>(_isMicMode),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(IconData icon, String label, String value, ColorScheme cs, {bool isDanger = false}) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, color: isDanger ? Colors.red.shade400 : cs.onSurface.withOpacity(0.7), size: 20),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: isDanger ? Colors.red.shade400 : cs.onSurface)),
      ]),
    );
  }

  void _showClearChatDialog(BuildContext context, ColorScheme cs) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Clear Chat', style: TextStyle(color: cs.onSurface)),
      content: Text('Delete all messages in this chat?', style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: cs.onSurface.withOpacity(0.5)))),
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Clear', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600))),
      ],
    ));
  }

  void _showBlockDialog(BuildContext context, ColorScheme cs) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Block ${widget.nodeName}?', style: TextStyle(color: cs.onSurface)),
      content: Text('They won\'t be able to message you or see your profile.', style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: cs.onSurface.withOpacity(0.5)))),
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Block', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600))),
      ],
    ));
  }

  void _showMessageActions(BuildContext context, ColorScheme cs, bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: cs.onSurface.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
          ListTile(leading: Icon(Icons.reply, color: cs.onSurface), title: Text('Reply', style: TextStyle(color: cs.onSurface)), onTap: () => Navigator.pop(ctx)),
          ListTile(leading: Icon(Icons.copy, color: cs.onSurface), title: Text('Copy', style: TextStyle(color: cs.onSurface)), onTap: () => Navigator.pop(ctx)),
          ListTile(leading: Icon(Icons.forward, color: cs.onSurface), title: Text('Forward', style: TextStyle(color: cs.onSurface)), onTap: () => Navigator.pop(ctx)),
          if (isMe) ListTile(leading: Icon(Icons.edit, color: cs.onSurface), title: Text('Edit', style: TextStyle(color: cs.onSurface)), onTap: () => Navigator.pop(ctx)),
          ListTile(leading: Icon(Icons.push_pin_outlined, color: cs.onSurface), title: Text('Pin', style: TextStyle(color: cs.onSurface)), onTap: () => Navigator.pop(ctx)),
          ListTile(leading: Icon(Icons.emoji_emotions_outlined, color: cs.onSurface), title: Text('React', style: TextStyle(color: cs.onSurface)), onTap: () => Navigator.pop(ctx)),
          Divider(color: cs.onSurface.withOpacity(0.1)),
          ListTile(leading: Icon(Icons.delete_outline, color: Colors.red.shade400), title: Text('Delete for me', style: TextStyle(color: Colors.red.shade400)), onTap: () => Navigator.pop(ctx)),
          if (isMe) ListTile(leading: Icon(Icons.delete_forever, color: Colors.red.shade400), title: Text('Delete for everyone', style: TextStyle(color: Colors.red.shade400)), onTap: () => Navigator.pop(ctx)),
        ]),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String text;

  const ChatBubble({super.key, required this.isMe, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.jetBrainsMono(
                color: isMe ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '12:00 PM', // Placeholder timestamp
                  style: TextStyle(
                    color: isMe ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7) : Theme.of(context).dividerColor,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
