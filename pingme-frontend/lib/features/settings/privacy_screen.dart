import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});
  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String _lastSeen = 'Everyone';
  String _profilePhoto = 'Everyone';
  String _bio = 'Everyone';
  String _phoneVisibility = 'My Contacts';
  
  bool _readReceipts = true;
  String _forwardedMessages = 'Everyone';
  String _calls = 'Everyone';
  String _voiceMessages = 'Everyone';

  String _groupsChannels = 'Everyone';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Privacy', style: TextStyle(color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Who can see my...', cs),
          const SizedBox(height: 8),
          _card(cs, [
            _dropTile(Icons.access_time, 'Last Seen', _lastSeen, ['Everyone','My Contacts','Nobody'], cs, (v) => setState(() => _lastSeen = v)),
            _dropTile(Icons.photo_camera_outlined, 'Profile Photo', _profilePhoto, ['Everyone','My Contacts','Nobody'], cs, (v) => setState(() => _profilePhoto = v)),
            _dropTile(Icons.info_outline, 'Bio', _bio, ['Everyone','My Contacts','Nobody'], cs, (v) => setState(() => _bio = v)),
            _dropTile(Icons.phone_outlined, 'Phone Number', _phoneVisibility, ['Everyone','My Contacts','Nobody'], cs, (v) => setState(() => _phoneVisibility = v), last: true),
          ]),
          const SizedBox(height: 24),
          _label('Messages', cs),
          const SizedBox(height: 8),
          _card(cs, [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              secondary: Icon(Icons.done_all, color: cs.onSurface.withOpacity(0.7), size: 24),
              title: Text('Read Receipts', style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
              subtitle: Text('Show when you\'ve read messages', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
              value: _readReceipts, activeColor: cs.primary,
              onChanged: (v) => setState(() => _readReceipts = v),
            ),
            Divider(height: 1, color: cs.onSurface.withOpacity(0.05), indent: 56),
            _dropTile(Icons.forward, 'Forwarded Messages', _forwardedMessages, ['Everyone','My Contacts','Nobody'], cs, (v) => setState(() => _forwardedMessages = v)),
            _dropTile(Icons.call_outlined, 'Calls', _calls, ['Everyone','My Contacts','Nobody'], cs, (v) => setState(() => _calls = v)),
            _dropTile(Icons.mic_none, 'Voice Messages', _voiceMessages, ['Everyone','My Contacts','Nobody'], cs, (v) => setState(() => _voiceMessages = v), last: true),
          ]),
          const SizedBox(height: 24),
          _label('Groups & Channels', cs),
          const SizedBox(height: 8),
          _card(cs, [
            _dropTile(Icons.groups_outlined, 'Groups & Channels', _groupsChannels, ['Everyone','My Contacts','Nobody'], cs, (v) => setState(() => _groupsChannels = v), last: true),
          ]),
          const SizedBox(height: 24),
          _card(cs, [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Icon(Icons.block, color: Colors.red.shade400, size: 24),
              title: Text('Blocked Users', style: TextStyle(color: Colors.red.shade400, fontSize: 16, fontWeight: FontWeight.w500)),
              subtitle: Text('0 users', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 13)),
              trailing: Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.3), size: 22),
              onTap: () {
                HapticFeedback.selectionClick();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: cs.surface,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (ctx) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Blocked Users', style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 32),
                      Icon(Icons.block, size: 64, color: cs.onSurface.withOpacity(0.15)),
                      const SizedBox(height: 16),
                      Text('No blocked users', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 15)),
                      const SizedBox(height: 8),
                      Text('You can block users from their profile page.', textAlign: TextAlign.center, style: TextStyle(color: cs.onSurface.withOpacity(0.3), fontSize: 13)),
                      const SizedBox(height: 24),
                    ]),
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

  Widget _label(String t, ColorScheme cs) => Padding(padding: const EdgeInsets.only(left: 4), child: Text(t, style: TextStyle(color: cs.primary, fontSize: 14, fontWeight: FontWeight.w600)));

  Widget _card(ColorScheme cs, List<Widget> ch) => Container(decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)), child: Column(children: ch));

  Widget _dropTile(IconData icon, String label, String value, List<String> opts, ColorScheme cs, Function(String) onChanged, {bool last = false}) {
    return Column(children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(icon, color: cs.onSurface.withOpacity(0.7), size: 24),
        title: Text(label, style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: GestureDetector(
          onTap: () => showModalBottomSheet(context: context, backgroundColor: cs.surface,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (ctx) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...opts.map((o) => RadioListTile<String>(value: o, groupValue: value, title: Text(o, style: TextStyle(color: cs.onSurface)), activeColor: cs.primary, onChanged: (v) { onChanged(v!); Navigator.pop(ctx); })),
            ]))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(value, style: TextStyle(color: cs.primary, fontSize: 14)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.3), size: 20),
          ]),
        ),
      ),
      if (!last) Divider(height: 1, color: cs.onSurface.withOpacity(0.05), indent: 56),
    ]);
  }
}
