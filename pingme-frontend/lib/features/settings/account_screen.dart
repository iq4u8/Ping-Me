import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

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
        title: Text('Account', style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Phone Number
          _AccountSection(
            colorScheme: colorScheme,
            children: [
              _AccountTile(
                icon: Icons.phone_outlined,
                label: 'Phone Number',
                value: '+91 xxxxxx',
                colorScheme: colorScheme,
                onTap: () => _showChangePhoneDialog(context, colorScheme),
              ),
              _AccountTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: 'Not set',
                colorScheme: colorScheme,
                onTap: () => _showChangeEmailDialog(context, colorScheme),
              ),
              _AccountTile(
                icon: Icons.alternate_email,
                label: 'Username',
                value: '@username',
                colorScheme: colorScheme,
                onTap: () => _showChangeUsernameDialog(context, colorScheme),
              ),
              _AccountTile(
                icon: Icons.info_outline,
                label: 'Bio',
                value: 'Available',
                colorScheme: colorScheme,
                isLast: true,
                onTap: () => _showChangeBioDialog(context, colorScheme),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active Sessions
          _AccountSection(
            colorScheme: colorScheme,
            children: [
              _AccountTile(
                icon: Icons.devices_outlined,
                label: 'Active Sessions',
                value: '1 device',
                colorScheme: colorScheme,
                isLast: true,
                onTap: () => Navigator.pushNamed(context, '/active_sessions'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Danger Zone
          _AccountSection(
            colorScheme: colorScheme,
            children: [
              _AccountTile(
                icon: Icons.logout,
                label: 'Log Out',
                colorScheme: colorScheme,
                isDanger: true,
                onTap: () => _showLogoutDialog(context, colorScheme),
              ),
              _AccountTile(
                icon: Icons.delete_forever_outlined,
                label: 'Delete Account',
                colorScheme: colorScheme,
                isDanger: true,
                isLast: true,
                onTap: () => _showDeleteAccountDialog(context, colorScheme),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showChangePhoneDialog(BuildContext context, ColorScheme colorScheme) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Phone Number', style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter new phone number',
                prefixIcon: Icon(Icons.phone, color: colorScheme.onSurface.withOpacity(0.5)),
                filled: true,
                fillColor: colorScheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: TextStyle(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Send OTP', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context, ColorScheme colorScheme) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set Email', style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter email address',
                prefixIcon: Icon(Icons.email_outlined, color: colorScheme.onSurface.withOpacity(0.5)),
                filled: true,
                fillColor: colorScheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: TextStyle(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Verify Email', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeUsernameDialog(BuildContext context, ColorScheme colorScheme) {
    final controller = TextEditingController(text: 'username');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Username', style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Min 6 characters. Only letters, numbers, underscores.', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                prefixText: '@ ',
                prefixStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                filled: true,
                fillColor: colorScheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: TextStyle(color: colorScheme.onSurface),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]'))],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeBioDialog(BuildContext context, ColorScheme colorScheme) {
    final controller = TextEditingController(text: 'Available');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Bio', style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Any details such as age, occupation or city. Example: 23 y.o. designer from San Francisco.', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLength: 70,
              decoration: InputDecoration(
                hintText: 'Bio',
                filled: true,
                fillColor: colorScheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: TextStyle(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out', style: TextStyle(color: colorScheme.onSurface)),
        content: Text('Are you sure you want to log out?', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Account', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold)),
        content: Text(
          'This action is irreversible. All your messages, contacts, and data will be permanently deleted after a 7-day grace period.',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)))),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Delete My Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  final ColorScheme colorScheme;
  final List<Widget> children;

  const _AccountSection({required this.colorScheme, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final ColorScheme colorScheme;
  final bool isLast;
  final bool isDanger;
  final VoidCallback? onTap;

  const _AccountTile({required this.icon, required this.label, this.value, required this.colorScheme, this.isLast = false, this.isDanger = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconColor = isDanger ? Colors.red.shade400 : colorScheme.onSurface.withOpacity(0.7);
    final labelColor = isDanger ? Colors.red.shade400 : colorScheme.onSurface;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Icon(icon, color: iconColor, size: 24),
          title: Text(label, style: TextStyle(color: labelColor, fontSize: 16, fontWeight: FontWeight.w500)),
          subtitle: value != null ? Text(value!, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 13)) : null,
          trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.3), size: 22),
          onTap: onTap,
        ),
        if (!isLast) Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.05), indent: 56),
      ],
    );
  }
}
