import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../chat/chat_list_screen.dart';
import '../contacts/contacts_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isNavBarHidden = false;

  List<Widget> get _pages => [
    ChatListScreen(onTabSwitch: (index) => setState(() => _currentIndex = index)),
    const ContactsScreen(),
    const SettingsScreen(),
    ProfileScreen(
      onNavigateToSettings: () => setState(() => _currentIndex = 2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      extendBody: true, // Allows the body to scroll behind the nav bar smoothly
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (!_isNavBarHidden) setState(() => _isNavBarHidden = true);
          } else if (notification.direction == ScrollDirection.forward || notification.direction == ScrollDirection.idle) {
            if (_isNavBarHidden) setState(() => _isNavBarHidden = false);
          }
          return false;
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        offset: _isNavBarHidden ? const Offset(0, 2.0) : Offset.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.3),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      activeIcon: Icons.chat_bubble_rounded,
                      label: 'Chats',
                      isActive: _currentIndex == 0,
                      colorScheme: colorScheme,
                      onTap: () => setState(() => _currentIndex = 0),
                    ),
                    _NavItem(
                      icon: Icons.people_outline_rounded,
                      activeIcon: Icons.people_rounded,
                      label: 'Contacts',
                      isActive: _currentIndex == 1,
                      colorScheme: colorScheme,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                    _NavItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings_rounded,
                      label: 'Settings',
                      isActive: _currentIndex == 2,
                      colorScheme: colorScheme,
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                    _NavItem(
                      customIcon: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _currentIndex == 3 ? colorScheme.primary : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: colorScheme.primary.withOpacity(0.2),
                          child: Icon(Icons.person, size: 16, color: colorScheme.primary),
                        ),
                      ),
                      icon: Icons.account_circle,
                      activeIcon: Icons.account_circle,
                      label: 'Profile',
                      isActive: _currentIndex == 3,
                      colorScheme: colorScheme,
                      onTap: () => setState(() => _currentIndex = 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final Widget? customIcon;
  final String label;
  final bool isActive;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    this.customIcon,
    required this.label,
    required this.isActive,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            customIcon ?? Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.45),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
