import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
        title: Text('Help', style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _HelpTile(
                  icon: Icons.support_agent,
                  label: 'Support Group',
                  subtitle: 'Ask questions and get help from the community',
                  colorScheme: colorScheme,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: colorScheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text('Support Group', style: TextStyle(color: colorScheme.onSurface)),
                        content: Column(mainAxisSize: MainAxisSize.min, children: [
                          CircleAvatar(radius: 32, backgroundColor: colorScheme.primary.withOpacity(0.15), child: Icon(Icons.support_agent, color: colorScheme.primary, size: 32)),
                          const SizedBox(height: 16),
                          Text('Ping Me Community', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Join our support group to get help, report bugs, and share feedback with the community.', textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13, height: 1.4)),
                          const SizedBox(height: 4),
                          Text('1.2K members', style: TextStyle(color: colorScheme.primary, fontSize: 12)),
                        ]),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Later', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)))),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Joined Ping Me Community!'), backgroundColor: colorScheme.primary));
                            },
                            child: Text('Join Group', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _HelpTile(
                  icon: Icons.feedback_outlined,
                  label: 'Complaint Box',
                  subtitle: 'Report an issue or bug',
                  colorScheme: colorScheme,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Complaint reported.'), backgroundColor: colorScheme.primary),
                    );
                  },
                ),
                _HelpTile(
                  icon: Icons.info_outline,
                  label: 'About',
                  subtitle: 'Ping Me v1.0.0',
                  colorScheme: colorScheme,
                  isLast: true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showAboutDialog(context, colorScheme);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chat_bubble, size: 40, color: colorScheme.primary),
              ),
              const SizedBox(height: 20),
              Text('Ping Me', style: TextStyle(color: colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Version 1.0.0', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 14)),
              const SizedBox(height: 24),
              Text(
                'The world\'s fastest messaging app. Free and secure. Built with Flutter, designed to connect you seamlessly with friends, family, and the world.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              Divider(color: colorScheme.onSurface.withOpacity(0.1)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _InfoIcon(icon: Icons.security, label: 'Secure', colorScheme: colorScheme),
                  _InfoIcon(icon: Icons.speed, label: 'Fast', colorScheme: colorScheme),
                  _InfoIcon(icon: Icons.cloud_sync, label: 'Synced', colorScheme: colorScheme),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Close', style: TextStyle(color: colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _InfoIcon({required this.icon, required this.label, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: colorScheme.primary.withOpacity(0.7), size: 28),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
      ],
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final ColorScheme colorScheme;
  final bool isLast;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.colorScheme,
    this.isLast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(icon, color: colorScheme.primary, size: 26),
          title: Text(label, style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
          onTap: onTap,
        ),
        if (!isLast) Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.05), indent: 56),
      ],
    );
  }
}
