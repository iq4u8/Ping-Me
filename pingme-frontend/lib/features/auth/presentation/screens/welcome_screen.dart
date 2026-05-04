import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../theme.dart';
import '../../../../shared/widgets/wire_components.dart';
import '../../../../presentation/viewmodels/theme_viewmodel.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVM = Provider.of<ThemeViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // Logo image
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          themeVM.currentMode == AppThemeMode.dark
                              ? 'assets/images/logo_dark.png'
                              : 'assets/images/logo_light.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(duration: 600.ms),
                  const SizedBox(height: 24),
                  Text(
                    'Ping Me',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().slideY(begin: 0.5, end: 0, duration: 500.ms, curve: Curves.easeOutQuad, delay: 200.ms).fadeIn(duration: 500.ms, delay: 200.ms),
                  const SizedBox(height: 12),
                  Text(
                    'The world\'s fastest messaging app.\nIt is free and secure.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ).animate().slideY(begin: 0.5, end: 0, duration: 500.ms, curve: Curves.easeOutQuad, delay: 300.ms).fadeIn(duration: 500.ms, delay: 300.ms),
                  const Spacer(flex: 4),
                  // Single button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/identify', arguments: 'email');
                      },
                      child: const Text(
                        'Start Messaging',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ).animate().slideY(begin: 0.5, end: 0, duration: 500.ms, curve: Curves.easeOutQuad, delay: 400.ms).fadeIn(duration: 500.ms, delay: 400.ms),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            // Theme toggle
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  themeVM.currentMode == AppThemeMode.defaultTheme
                      ? Icons.brightness_auto
                      : (themeVM.currentMode == AppThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode),
                  color: colorScheme.onSurface.withOpacity(0.6),
                  size: 22,
                ),
                onPressed: () => themeVM.cycleTheme(),
              ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
            ),
          ],
        ),
      ),
    );
  }
}
