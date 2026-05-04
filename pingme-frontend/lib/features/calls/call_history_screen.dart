import 'package:flutter/material.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

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
          'Calls',
          style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: 4,
        padding: const EdgeInsets.only(bottom: 80),
        itemBuilder: (context, index) {
          final mockCalls = [
            {'name': 'Alice Smith', 'type': 'Incoming', 'time': 'Yesterday, 14:32', 'missed': false},
            {'name': 'Bob Jones', 'type': 'Outgoing', 'time': 'Yesterday, 09:15', 'missed': false},
            {'name': 'Charlie Brown', 'type': 'Incoming', 'time': 'Sunday, 18:40', 'missed': true},
            {'name': 'Diana Prince', 'type': 'Outgoing', 'time': 'Saturday, 11:20', 'missed': false},
          ];
          final call = mockCalls[index];
          final bool missed = call['missed'] as bool;
          final String type = call['type'] as String;
          
          IconData icon;
          Color iconColor;
          if (missed) {
            icon = Icons.call_missed;
            iconColor = Colors.red;
          } else if (type == 'Incoming') {
            icon = Icons.call_received;
            iconColor = colorScheme.primary;
          } else {
            icon = Icons.call_made;
            iconColor = Colors.green;
          }

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary.withOpacity(0.2),
              child: Text(call['name'].toString()[0], style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
            title: Text(call['name'].toString(), style: TextStyle(color: missed ? Colors.red : colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500)),
            subtitle: Row(
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 4),
                Text(call['time'].toString(), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.call, color: colorScheme.primary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling ${call['name']}...'), backgroundColor: colorScheme.primary));
              },
            ),
            onTap: () {
              Navigator.pushNamed(context, '/conversation', arguments: {'name': call['name'], 'isGroup': false});
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Select a contact to call'), backgroundColor: colorScheme.primary));
        },
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add_call, color: colorScheme.onPrimary),
      ),
    );
  }
}
