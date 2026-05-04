import 'package:flutter/material.dart';

class CreateChannelScreen extends StatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isPublic = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
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
        title: Text(
          'New Channel',
          style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          // Channel photo
          Center(
            child: GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                radius: 50,
                backgroundColor: colorScheme.surface,
                child: Icon(Icons.campaign, color: colorScheme.onSurface.withOpacity(0.5), size: 32),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Channel name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Channel name',
                hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                border: InputBorder.none,
              ),
              style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
          // Description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                border: InputBorder.none,
              ),
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          // Public / Private toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _ChannelTypeTile(
                  icon: Icons.public,
                  label: 'Public Channel',
                  subtitle: 'Anyone can find and join',
                  isSelected: _isPublic,
                  colorScheme: colorScheme,
                  onTap: () => setState(() => _isPublic = true),
                ),
                Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.05), indent: 56),
                _ChannelTypeTile(
                  icon: Icons.lock_outline,
                  label: 'Private Channel',
                  subtitle: 'Invite link only',
                  isSelected: !_isPublic,
                  colorScheme: colorScheme,
                  onTap: () => setState(() => _isPublic = false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Create button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _nameController.text.trim().isNotEmpty ? () {
                Navigator.pop(context);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Create Channel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelTypeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _ChannelTypeTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
