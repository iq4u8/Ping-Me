import 'package:flutter/material.dart';

class ChatWallpapersScreen extends StatelessWidget {
  const ChatWallpapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Dummy chats for demonstration
    final List<String> dummyChats = ['Ankit', 'Rahul', 'Priya', 'Team Group'];

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Chat Wallpapers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 16),
            
            // Universal Wallpaper
            Text(
              'Default Wallpaper',
              style: TextStyle(color: colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.wallpaper, color: colorScheme.primary),
                ),
                title: Text('Change Default Wallpaper', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500)),
                subtitle: Text('Applies to all chats', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
                trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.3), size: 22),
                onTap: () {
                  // TODO: Open image picker to set default wallpaper
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Custom Wallpapers per Chat
            Text(
              'Custom Wallpaper per Chat',
              style: TextStyle(color: colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
              ),
              child: Column(
                children: List.generate(dummyChats.length, (index) {
                  final chatName = dummyChats[index];
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            chatName[0],
                            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(chatName, style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500)),
                        subtitle: Text('Default wallpaper', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 13)),
                        trailing: Icon(Icons.edit, color: colorScheme.primary, size: 20),
                        onTap: () {
                          // TODO: Open image picker to set custom wallpaper for this specific chat
                        },
                      ),
                      if (index < dummyChats.length - 1)
                        Divider(height: 1, thickness: 1, color: colorScheme.onSurface.withOpacity(0.05), indent: 72),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
