import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 16),
            // Section 1: Account
            _SectionContainer(
              colorScheme: colorScheme,
              children: [
                _SettingsTile(icon: Icons.vpn_key_outlined, label: 'Account', colorScheme: colorScheme, onTap: () => Navigator.pushNamed(context, '/account')),
                _SettingsTile(icon: Icons.lock_outline, label: 'Privacy', colorScheme: colorScheme, onTap: () => Navigator.pushNamed(context, '/privacy')),
                _SettingsTile(icon: Icons.security_outlined, label: 'Security', colorScheme: colorScheme, isLast: true, onTap: () => Navigator.pushNamed(context, '/security')),
              ],
            ),
            const SizedBox(height: 16),
            // Section 2: Settings
            _SectionContainer(
              colorScheme: colorScheme,
              children: [
                _SettingsTile(icon: Icons.notifications_outlined, label: 'Notifications', colorScheme: colorScheme, onTap: () => Navigator.pushNamed(context, '/notifications')),
                _SettingsTile(icon: Icons.data_usage_outlined, label: 'Data & Storage', colorScheme: colorScheme, onTap: () => Navigator.pushNamed(context, '/data_storage')),
                _SettingsTile(
                  icon: Icons.palette_outlined, 
                  label: 'Appearance', 
                  colorScheme: colorScheme, 
                  isLast: true,
                  onTap: () => Navigator.pushNamed(context, '/appearance'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Section 3: Help
            _SectionContainer(
              colorScheme: colorScheme,
              children: [
                _SettingsTile(icon: Icons.help_outline, label: 'Help', colorScheme: colorScheme, onTap: () => Navigator.pushNamed(context, '/help')),
                _SettingsTile(icon: Icons.people_outline, label: 'Invite Friends', colorScheme: colorScheme, isLast: true, onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: colorScheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text('Invite Friends', style: TextStyle(color: colorScheme.onSurface)),
                      content: Text('Share this link with your friends:\npingme.app/invite/user123', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: TextStyle(color: colorScheme.primary))),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Link copied to clipboard!'), backgroundColor: colorScheme.primary));
                          },
                          child: Text('Copy Link', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final List<Widget> children;
  final ColorScheme colorScheme;

  const _SectionContainer({required this.children, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final bool isLast;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.colorScheme,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Icon(icon, color: colorScheme.onSurface.withOpacity(0.7), size: 24),
          title: Text(label, style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500)),
          trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.3), size: 22),
          onTap: onTap ?? () {},
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.onSurface.withOpacity(0.05),
            indent: 56,
          ),
      ],
    );
  }
}
