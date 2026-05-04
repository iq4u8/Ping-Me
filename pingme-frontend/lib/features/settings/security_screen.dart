import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFAEnabled = false;
  bool _passcodeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Security', style: TextStyle(color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(cs, [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              secondary: Icon(Icons.security, color: cs.onSurface.withOpacity(0.7), size: 24),
              title: Text('Two-Factor Auth', style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
              subtitle: Text('Use Google Authenticator', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
              value: _twoFAEnabled, activeColor: cs.primary,
              onChanged: (v) => setState(() => _twoFAEnabled = v),
            ),
            Divider(height: 1, color: cs.onSurface.withOpacity(0.05), indent: 56),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              secondary: Icon(Icons.pin_outlined, color: cs.onSurface.withOpacity(0.7), size: 24),
              title: Text('App Passcode', style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
              subtitle: Text('Lock app with PIN', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
              value: _passcodeEnabled, activeColor: cs.primary,
              onChanged: (v) => setState(() => _passcodeEnabled = v),
            ),
          ]),
          const SizedBox(height: 24),
          _card(cs, [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Icon(Icons.devices, color: cs.onSurface.withOpacity(0.7), size: 24),
              title: Text('Active Sessions', style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
              subtitle: Text('1 device connected', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
              trailing: Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.3), size: 22),
              onTap: () => Navigator.pushNamed(context, '/active_sessions'),
            ),
          ]),
          const SizedBox(height: 24),
          _card(cs, [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Icon(Icons.key, color: cs.onSurface.withOpacity(0.7), size: 24),
              title: Text('Encryption Keys', style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
              subtitle: Text('Export or verify your keys', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
              trailing: Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.3), size: 22),
              onTap: () {
                HapticFeedback.selectionClick();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: cs.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text('Encryption Keys', style: TextStyle(color: cs.onSurface)),
                    content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: cs.background, borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          Icon(Icons.fingerprint, color: cs.primary, size: 32),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Device Key', style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('a7f3...b2d9', style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 12, fontFamily: 'monospace')),
                          ])),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      Text('Your messages are end-to-end encrypted. Only you and the recipient can read them.', style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 13, height: 1.4)),
                    ]),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: TextStyle(color: cs.onSurface.withOpacity(0.5)))),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Keys exported to clipboard'), backgroundColor: cs.primary));
                        },
                        child: Text('Export', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _card(ColorScheme cs, List<Widget> ch) => Container(decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)), child: Column(children: ch));
}
