import 'package:flutter/material.dart';
import '../../shared/widgets/wire_components.dart';
import '../../theme.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onEnter;
  const OnboardingScreen({super.key, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              Text(
                'WIRE',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const Spacer(),
              // Visual Canvas
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Opacity(
                    opacity: 0.8,
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBE0YsD6EUkaz8v5ouEGuTMpvApb3uPri2em9Yki1R1Lgslu5VyhS2KMSZUymVHKnxNkC7-GZttEa6sN7k3PShxpQ-knLi2kGwiCoQaUv5JkwhlbDEYRJGWbuP3xLNxPZn25MG2HcS3Jj2c204zrg221cUlfoEAIh3Afi9lbec8TR-NQBMpTREIdjt62ZlmQBxGvzKlfmU3z0AJG51ulzDTfMjjGnt4FZteVCwq44U-dM4X3Z2dH01LEwPtsseOpUb-FtXn-o4-_taU',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        const Center(child: Icon(Icons.signal_cellular_alt, size: 64)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Headline
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SECURE DIRECT LINE',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Establish an encrypted, objective connection. No algorithmic interference. Pure signal. Configure your transmission parameters directly.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              const Spacer(),
              // Progress indicator placeholder
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 1, color: Theme.of(context).dividerColor)),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 1, color: Theme.of(context).dividerColor)),
                ],
              ),
              const SizedBox(height: 24),
              WireButton(
                text: 'ENTER',
                icon: Icons.arrow_forward,
                onClick: onEnter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
