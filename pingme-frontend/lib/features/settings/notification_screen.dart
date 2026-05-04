import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _messagePreview = true;
  bool _groupNotif = true;
  bool _channelNotif = true;
  bool _callNotif = true;
  bool _vibrate = true;
  bool _inAppSounds = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Notifications', style: TextStyle(color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Messages', cs),
          const SizedBox(height: 8),
          _card(cs, [
            _sw(Icons.visibility_outlined, 'Message Preview', 'Show content in notification', _messagePreview, cs, (v) => setState(() => _messagePreview = v)),
            Divider(height: 1, color: cs.onSurface.withOpacity(0.05), indent: 56),
            _sw(Icons.group_outlined, 'Group Notifications', 'Get notified for group messages', _groupNotif, cs, (v) => setState(() => _groupNotif = v)),
            Divider(height: 1, color: cs.onSurface.withOpacity(0.05), indent: 56),
            _sw(Icons.campaign_outlined, 'Channel Notifications', 'Get notified for channel posts', _channelNotif, cs, (v) => setState(() => _channelNotif = v)),
          ]),
          const SizedBox(height: 24),
          _label('Calls', cs),
          const SizedBox(height: 8),
          _card(cs, [
            _sw(Icons.call_outlined, 'Call Notifications', 'Ring for incoming calls', _callNotif, cs, (v) => setState(() => _callNotif = v)),
          ]),
          const SizedBox(height: 24),
          _label('General', cs),
          const SizedBox(height: 8),
          _card(cs, [
            _sw(Icons.vibration, 'Vibrate', 'Vibrate on notification', _vibrate, cs, (v) => setState(() => _vibrate = v)),
            Divider(height: 1, color: cs.onSurface.withOpacity(0.05), indent: 56),
            _sw(Icons.volume_up_outlined, 'In-App Sounds', 'Play sounds inside the app', _inAppSounds, cs, (v) => setState(() => _inAppSounds = v)),
          ]),
          const SizedBox(height: 24),
          _card(cs, [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Icon(Icons.restart_alt, color: Colors.orange.shade400, size: 24),
              title: Text('Reset All Notifications', style: TextStyle(color: Colors.orange.shade400, fontSize: 15, fontWeight: FontWeight.w500)),
              onTap: () => showDialog(context: context, builder: (ctx) => AlertDialog(
                backgroundColor: cs.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text('Reset?', style: TextStyle(color: cs.onSurface)),
                content: Text('Reset all notification settings to default?', style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: cs.onSurface.withOpacity(0.5)))),
                  TextButton(onPressed: () { Navigator.pop(ctx); setState(() { _messagePreview = true; _groupNotif = true; _channelNotif = true; _callNotif = true; _vibrate = true; _inAppSounds = true; }); }, child: Text('Reset', style: TextStyle(color: Colors.orange.shade400, fontWeight: FontWeight.w600))),
                ],
              )),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _label(String t, ColorScheme cs) => Padding(padding: const EdgeInsets.only(left: 4), child: Text(t, style: TextStyle(color: cs.primary, fontSize: 14, fontWeight: FontWeight.w600)));
  Widget _card(ColorScheme cs, List<Widget> ch) => Container(decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)), child: Column(children: ch));
  Widget _sw(IconData icon, String title, String sub, bool val, ColorScheme cs, Function(bool) onChanged) => SwitchListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    secondary: Icon(icon, color: cs.onSurface.withOpacity(0.7), size: 24),
    title: Text(title, style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
    subtitle: Text(sub, style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
    value: val, activeColor: cs.primary, onChanged: onChanged,
  );
}
