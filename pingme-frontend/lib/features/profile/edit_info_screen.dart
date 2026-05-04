import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditInfoScreen extends StatefulWidget {
  const EditInfoScreen({super.key});

  @override
  State<EditInfoScreen> createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  final _firstNameCtrl = TextEditingController(text: 'Ping Me');
  final _lastNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String _username = '';
  String _birthday = '';
  int _bioRemaining = 70;

  @override
  void initState() {
    super.initState();
    _bioCtrl.addListener(() {
      setState(() => _bioRemaining = 70 - _bioCtrl.text.length);
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _bioCtrl.dispose();
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
        title: Text(
          'Account',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Profile saved!'), backgroundColor: colorScheme.primary),
              );
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
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
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showChangePhoneDialog(context, colorScheme);
                  },
                ),
                Divider(height: 1, indent: 56, color: colorScheme.onSurface.withOpacity(0.1)),
                ListTile(
                  leading: Icon(Icons.alternate_email, color: colorScheme.primary),
                  title: Text(_username.isEmpty ? 'Add Username' : '@$_username', style: TextStyle(color: colorScheme.primary)),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showUsernameDialog(context, colorScheme);
                  },
                ),
                Divider(height: 1, indent: 56, color: colorScheme.onSurface.withOpacity(0.1)),
                ListTile(
                  leading: Icon(Icons.cake_outlined, color: colorScheme.primary),
                  title: Text(_birthday.isEmpty ? 'Add Birthday' : _birthday, style: TextStyle(color: colorScheme.primary)),
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000, 1, 1),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: colorScheme,
                          dialogBackgroundColor: colorScheme.surface,
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) {
                      setState(() => _birthday = '${date.day}/${date.month}/${date.year}');
                    }
                  },
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
                    controller: _firstNameCtrl,
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
                    controller: _lastNameCtrl,
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
                    controller: _bioCtrl,
                    maxLength: 70,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Write about yourself...',
                      hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                      counterText: '',
                    ),
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                  ),
                ),
                Text('$_bioRemaining', style: TextStyle(color: _bioRemaining < 10 ? Colors.redAccent : colorScheme.onSurface.withOpacity(0.4), fontSize: 12)),
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
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pushNamed(context, '/create_channel');
              },
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
              onTap: () {
                HapticFeedback.heavyImpact();
                _showLogoutDialog(context, colorScheme);
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showChangePhoneDialog(BuildContext context, ColorScheme cs) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Change Phone', style: TextStyle(color: cs.onSurface)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'New phone number',
            hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.4)),
            prefixText: '+91 ',
            prefixStyle: TextStyle(color: cs.onSurface),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: cs.onSurface.withOpacity(0.5)))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Verification code sent!'), backgroundColor: cs.primary));
            },
            child: Text('Send Code', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showUsernameDialog(BuildContext context, ColorScheme cs) {
    final ctrl = TextEditingController(text: _username);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Set Username', style: TextStyle(color: cs.onSurface)),
        content: TextField(
          controller: ctrl,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'username',
            prefixText: '@',
            prefixStyle: TextStyle(color: cs.primary),
            hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.4)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: cs.onSurface.withOpacity(0.5)))),
          TextButton(
            onPressed: () {
              setState(() => _username = ctrl.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Username set to @${ctrl.text.trim()}'), backgroundColor: cs.primary));
            },
            child: Text('Save', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ColorScheme cs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Out', style: TextStyle(color: cs.onSurface)),
        content: Text('Are you sure you want to log out?', style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: cs.onSurface.withOpacity(0.5)))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
