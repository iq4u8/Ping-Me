import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SavedMessagesScreen extends StatefulWidget {
  const SavedMessagesScreen({super.key});

  @override
  State<SavedMessagesScreen> createState() => _SavedMessagesScreenState();
}

class _SavedMessagesScreenState extends State<SavedMessagesScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _messages.insert(0, {
        'text': text,
        'time': TimeOfDay.now().format(context),
        'type': 'text',
      });
    });
    _msgCtrl.clear();
  }

  void _attachFile() {
    HapticFeedback.selectionClick();
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              leading: Icon(Icons.photo_outlined, color: cs.primary),
              title: Text('Photo', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _messages.insert(0, {'text': '📷 Photo saved', 'time': TimeOfDay.now().format(context), 'type': 'media'}));
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam_outlined, color: cs.primary),
              title: Text('Video', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _messages.insert(0, {'text': '🎬 Video saved', 'time': TimeOfDay.now().format(context), 'type': 'media'}));
              },
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file_outlined, color: cs.primary),
              title: Text('File', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _messages.insert(0, {'text': '📄 File saved', 'time': TimeOfDay.now().format(context), 'type': 'media'}));
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on_outlined, color: cs.primary),
              title: Text('Location', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _messages.insert(0, {'text': '📍 Location saved', 'time': TimeOfDay.now().format(context), 'type': 'media'}));
              },
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary.withOpacity(0.15),
              child: Icon(Icons.bookmark, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Saved Messages',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 80, color: colorScheme.primary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Your cloud notepad',
                          style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            'Forward messages here to save them.\nSend notes to yourself.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.15),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(msg['text'], style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(msg['time'], style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -1), blurRadius: 10),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.attach_file, color: colorScheme.onSurface.withOpacity(0.5)), onPressed: _attachFile),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.background,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: colorScheme.onSurface),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.send, color: colorScheme.primary), onPressed: _sendMessage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
