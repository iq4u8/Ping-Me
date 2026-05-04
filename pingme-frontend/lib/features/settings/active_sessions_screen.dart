import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActiveSessionsScreen extends StatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  State<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> {
  final List<Map<String, String>> _otherSessions = [
    {'device': 'Windows PC (Chrome)', 'ip': '192.168.1.4', 'location': 'Mumbai, India'},
    {'device': 'MacBook Pro', 'ip': '192.168.1.10', 'location': 'Pune, India'},
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Active Sessions', style: TextStyle(color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current session
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: cs.primary.withOpacity(0.3))),
            child: Row(children: [
              Icon(Icons.phone_android, color: cs.primary, size: 36),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('This Device', style: TextStyle(color: cs.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Ping Me Android • Online now', style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 13)),
                Text('IP: 192.168.x.x', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
              ])),
              Icon(Icons.check_circle, color: cs.primary, size: 24),
            ]),
          ),
          const SizedBox(height: 24),
          Text('Other Sessions', style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          if (_otherSessions.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(children: [
                Icon(Icons.devices_other, size: 60, color: cs.onSurface.withOpacity(0.2)),
                const SizedBox(height: 12),
                Text('No other sessions', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 15)),
              ]),
            ))
          else
            Container(
              decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: List.generate(_otherSessions.length, (index) {
                  final session = _otherSessions[index];
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Icon(
                          session['device']!.contains('Windows') || session['device']!.contains('Mac') 
                              ? Icons.laptop_mac 
                              : Icons.phone_android, 
                          color: cs.onSurface.withOpacity(0.8), size: 32
                        ),
                        title: Text(session['device']!, style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
                        subtitle: Text('${session['location']} • ${session['ip']}', style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 12)),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _otherSessions.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Session terminated'), backgroundColor: cs.primary));
                          },
                        ),
                      ),
                      if (index < _otherSessions.length - 1)
                        Divider(height: 1, indent: 64, color: cs.onSurface.withOpacity(0.1)),
                    ],
                  );
                }),
              ),
            ),
          const SizedBox(height: 16),
          if (_otherSessions.isNotEmpty)
            Container(
              decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(Icons.logout, color: Colors.red.shade400, size: 24),
                title: Text('Terminate All Other Sessions', style: TextStyle(color: Colors.red.shade400, fontSize: 15, fontWeight: FontWeight.w500)),
                onTap: () {
                  HapticFeedback.heavyImpact();
                  setState(() {
                    _otherSessions.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('All other sessions terminated'), backgroundColor: cs.primary));
                },
              ),
            ),
        ],
      ),
    );
  }
}
