import 'package:flutter/material.dart';
import '../../shared/widgets/wire_components.dart';
import '../../theme.dart';

class UsernameScreen extends StatelessWidget {
  const UsernameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IDENTITY',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
              Text(
                'ASSIGNMENT',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      color: Theme.of(context).dividerColor,
                    ),
              ),
              const SizedBox(height: 40),
              Text(
                'Select a unique identifier. This cannot be modified once the transmission tunnel is established.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              const WireInputField(label: 'UNIQUE ID', value: '@'),
              const Spacer(),
              WireButton(
                text: 'FINALIZE CONFIG',
                icon: Icons.check,
                onClick: () => Navigator.pushReplacementNamed(context, '/chats'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
