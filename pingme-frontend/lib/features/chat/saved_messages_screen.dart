import 'package:flutter/material.dart';

class SavedMessagesScreen extends StatelessWidget {
  const SavedMessagesScreen({super.key});

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
      body: Center(
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
      ),
    );
  }
}
