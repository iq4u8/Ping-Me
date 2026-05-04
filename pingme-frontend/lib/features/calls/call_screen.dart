import 'package:flutter/material.dart';
import '../../theme.dart';

class CallScreen extends StatelessWidget {
  final String nodeName;
  const CallScreen({super.key, required this.nodeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              nodeName,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, letterSpacing: 4),
            ),
            Text(
              'ESTABLISHING_TUNNEL...',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontSize: 12),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CallAction(icon: Icons.mic_off, onClick: () {}),
                const SizedBox(width: 40),
                _CallAction(icon: Icons.call_end, color: Colors.red, onClick: () => Navigator.pop(context)),
                const SizedBox(width: 40),
                _CallAction(icon: Icons.videocam_off, onClick: () {}),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _CallAction extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onClick;

  const _CallAction({required this.icon, this.color, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? Theme.of(context).colorScheme.surface,
          border: Border.all(color: color ?? Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
