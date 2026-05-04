import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserProfileScreen extends StatelessWidget {
  final String userName;
  const UserProfileScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: cs.background,
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(icon: Icon(Icons.arrow_back, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
            actions: [
              IconButton(icon: Icon(Icons.more_vert, color: cs.onSurface), onPressed: () => _showProfileMenu(context, cs)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: cs.primary.withOpacity(0.15),
                      child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?', style: TextStyle(color: cs.primary, fontSize: 36, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    Text(userName, style: TextStyle(color: cs.onSurface, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('last seen recently', style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Action buttons
                Row(children: [
                  _actionBtn(Icons.chat_bubble_outline, 'Message', cs, () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  _actionBtn(Icons.call_outlined, 'Voice', cs, () {}),
                  const SizedBox(width: 12),
                  _actionBtn(Icons.videocam_outlined, 'Video', cs, () {}),
                ]),
                const SizedBox(height: 20),
                // Bio
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Bio', style: TextStyle(color: cs.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('Silence is my signature.', style: TextStyle(color: cs.onSurface, fontSize: 15, height: 1.4)),
                  ]),
                ),
                const SizedBox(height: 12),
                // Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.alternate_email, color: cs.onSurface.withOpacity(0.6), size: 22),
                      title: Text('@${userName.toLowerCase().replaceAll(' ', '')}', style: TextStyle(color: cs.onSurface, fontSize: 15)),
                      subtitle: Text('Username', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
                    ),
                    Divider(height: 1, color: cs.onSurface.withOpacity(0.05), indent: 56),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.notifications_outlined, color: cs.onSurface.withOpacity(0.6), size: 22),
                      title: Text('Notifications', style: TextStyle(color: cs.onSurface, fontSize: 15)),
                      trailing: Text('On', style: TextStyle(color: cs.primary, fontSize: 14)),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: cs.surface,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                          builder: (ctx) => Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Mute Notifications', style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              ...['1 hour', '8 hours', '1 day', '3 days', 'Forever'].map((option) => ListTile(
                                title: Text(option, style: TextStyle(color: cs.onSurface)),
                                leading: Icon(Icons.timer_outlined, color: cs.onSurface.withOpacity(0.5)),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('Muted for $option'),
                                    backgroundColor: cs.primary,
                                  ));
                                },
                              )),
                            ]),
                          ),
                        );
                      },
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                // Shared media placeholder
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Shared Media', style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('0', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 14)),
                    ]),
                    const SizedBox(height: 12),
                    Center(child: Text('No shared media yet', style: TextStyle(color: cs.onSurface.withOpacity(0.3), fontSize: 14))),
                  ]),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, ColorScheme cs, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Icon(icon, color: cs.primary, size: 24),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(color: cs.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: Icon(Icons.volume_off_outlined, color: cs.onSurface), title: Text('Mute', style: TextStyle(color: cs.onSurface)), onTap: () => Navigator.pop(ctx)),
          ListTile(leading: Icon(Icons.search, color: cs.onSurface), title: Text('Search', style: TextStyle(color: cs.onSurface)), onTap: () => Navigator.pop(ctx)),
          ListTile(leading: Icon(Icons.share_outlined, color: cs.onSurface), title: Text('Share Contact', style: TextStyle(color: cs.onSurface)), onTap: () => Navigator.pop(ctx)),
          Divider(color: cs.onSurface.withOpacity(0.1)),
          ListTile(leading: Icon(Icons.block, color: Colors.red.shade400), title: Text('Block User', style: TextStyle(color: Colors.red.shade400)), onTap: () => Navigator.pop(ctx)),
          ListTile(leading: Icon(Icons.flag_outlined, color: Colors.red.shade400), title: Text('Report', style: TextStyle(color: Colors.red.shade400)), onTap: () => Navigator.pop(ctx)),
        ]),
      ),
    );
  }
}
