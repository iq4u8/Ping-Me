import 'package:flutter/material.dart';

class EditInfoScreen extends StatelessWidget {
  const EditInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        title: Text(
          'Account',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Your Info Section
          Text(
            'Your Info',
            style: TextStyle(color: colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.phone_outlined, color: colorScheme.onSurface.withOpacity(0.7)),
                  title: Text('+91 xxxxxx', style: TextStyle(color: colorScheme.onSurface)),
                  subtitle: Text('Tap to change phone number', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                  onTap: () {},
                ),
                Divider(height: 1, indent: 56, color: colorScheme.onSurface.withOpacity(0.1)),
                ListTile(
                  leading: Icon(Icons.alternate_email, color: colorScheme.primary),
                  title: Text('Add Username', style: TextStyle(color: colorScheme.primary)),
                  onTap: () {},
                ),
                Divider(height: 1, indent: 56, color: colorScheme.onSurface.withOpacity(0.1)),
                ListTile(
                  leading: Icon(Icons.cake_outlined, color: colorScheme.primary),
                  title: Text('Add Birthday', style: TextStyle(color: colorScheme.primary)),
                  onTap: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 24),
            child: Text.rich(
              TextSpan(
                text: 'Only your contacts can see your birthday.\n',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                children: [
                  TextSpan(text: 'Change >', style: TextStyle(color: colorScheme.primary)),
                ],
              ),
            ),
          ),

          // Your Name Section
          Text(
            'Your name',
            style: TextStyle(color: colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: TextEditingController(text: 'Ping Me'),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'First name',
                      hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                    ),
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                  ),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.onSurface.withOpacity(0.1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Last name',
                      hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                    ),
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Your Bio Section
          Text(
            'Your bio',
            style: TextStyle(color: colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Write about yourself...',
                      hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                    ),
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                  ),
                ),
                Text('70', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 24),
            child: Text.rich(
              TextSpan(
                text: 'You can add a few lines about yourself. Choose\nwho can see your bio in ',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                children: [
                  TextSpan(text: 'Settings.', style: TextStyle(color: colorScheme.primary)),
                ],
              ),
            ),
          ),

          // Add Personal Channel
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Icon(Icons.campaign_outlined, color: colorScheme.primary),
              title: Text('Add Personal channel', style: TextStyle(color: colorScheme.primary)),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 16),

          // Log Out
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
