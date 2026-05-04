import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/viewmodels/theme_viewmodel.dart';
import '../../theme.dart';
import '../../shared/widgets/custom_media_picker.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onNavigateToSettings;

  const ProfileScreen({super.key, this.onNavigateToSettings});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Header Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.qr_code_2, color: colorScheme.onSurface),
                              onPressed: () => Navigator.pushNamed(context, '/qr_code'),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
                              color: colorScheme.surface,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'color',
                                  child: Row(
                                    children: [
                                      Icon(Icons.palette_outlined, color: colorScheme.onSurface, size: 20),
                                      const SizedBox(width: 12),
                                      Text('Change profile color', style: TextStyle(color: colorScheme.onSurface)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'username',
                                  child: Row(
                                    children: [
                                      Icon(Icons.alternate_email, color: colorScheme.onSurface, size: 20),
                                      const SizedBox(width: 12),
                                      Text('Set username', style: TextStyle(color: colorScheme.onSurface)),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem(
                                  value: 'theme_toggle',
                                  enabled: false,
                                  child: Consumer<ThemeViewModel>(
                                    builder: (context, themeVM, child) {
                                      String themeLabel = 'Default';
                                      IconData themeIcon = Icons.brightness_auto;
                                      if (themeVM.currentMode == AppThemeMode.light) {
                                        themeLabel = 'Light mode';
                                        themeIcon = Icons.light_mode;
                                      } else if (themeVM.currentMode == AppThemeMode.dark) {
                                        themeLabel = 'Night';
                                        themeIcon = Icons.dark_mode;
                                      }
                                      return InkWell(
                                        onTap: () {
                                          themeVM.cycleTheme();
                                          Navigator.pop(context);
                                        },
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Row(
                                            children: [
                                              Icon(themeIcon, color: colorScheme.onSurface, size: 20),
                                              const SizedBox(width: 12),
                                              Text(themeLabel, style: TextStyle(color: colorScheme.onSurface)),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Profile Info
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundColor: colorScheme.surface,
                              backgroundImage: const AssetImage('assets/images/logo_dark.png'), // placeholder
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ping Me',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'online',
                              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'id: 8399194134',
                              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ActionButton(
                              icon: Icons.camera_alt, 
                              label: 'Set Photo', 
                              colorScheme: colorScheme,
                              onTap: () => _showSetPhotoBottomSheet(context),
                            ),
                            const SizedBox(width: 12),
                            _ActionButton(
                              icon: Icons.edit, 
                              label: 'Edit Info', 
                              colorScheme: colorScheme,
                              onTap: () => Navigator.pushNamed(context, '/edit_info'),
                            ),
                            const SizedBox(width: 12),
                            _ActionButton(
                              icon: Icons.settings, 
                              label: 'Settings', 
                              colorScheme: colorScheme,
                              onTap: onNavigateToSettings ?? () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone Number Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: PopupMenuButton<String>(
                          color: colorScheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          offset: const Offset(0, 40),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'copy',
                              child: Row(
                                children: [
                                  Icon(Icons.copy, color: colorScheme.onSurface, size: 20),
                                  const SizedBox(width: 12),
                                  Text('Copy', style: TextStyle(color: colorScheme.onSurface)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'replace',
                              child: Row(
                                children: [
                                  Icon(Icons.sim_card_alert_outlined, color: colorScheme.onSurface, size: 20),
                                  const SizedBox(width: 12),
                                  Text('Replace number', style: TextStyle(color: colorScheme.onSurface)),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '+91 xxxxxx',
                                  style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Mobile',
                                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // TabBar
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: TabBar(
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                          indicator: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: colorScheme.primary,
                          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                          tabs: const [
                            Tab(text: 'Posts', height: 36),
                            Tab(text: 'Archived Posts', height: 36),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                // Posts Tab
                _EmptyStateView(
                  title: 'No posts yet...',
                  subtitle: 'Publish photos and videos to display on\nyour profile page',
                  buttonLabel: 'Add a post',
                  buttonIcon: Icons.camera_alt,
                  colorScheme: colorScheme,
                  onTapButton: () => _showSetPhotoBottomSheet(context),
                ),
                // Archived Posts Tab
                _EmptyStateView(
                  title: 'No stories yet...',
                  subtitle: 'Upload a new story to view it here.\nAfter 24 hours, stories will be automatically archived here.',
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSetPhotoBottomSheet(BuildContext context) async {
    final selectedAsset = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: const CustomMediaPickerBottomSheet(showOnlyGallery: true),
      ),
    );
    if (selectedAsset != null) {
      // Handle the selected asset (e.g., update profile photo)
    }
  }
}



class _EmptyStateView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final IconData? buttonIcon;
  final ColorScheme colorScheme;
  final VoidCallback? onTapButton;

  const _EmptyStateView({
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.buttonIcon,
    required this.colorScheme,
    this.onTapButton,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 14, height: 1.4),
              ),
              if (buttonLabel != null && buttonIcon != null && onTapButton != null) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onTapButton,
                    icon: Icon(buttonIcon, size: 20),
                    label: Text(buttonLabel!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 96), // Clears the glassy nav bar!
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.colorScheme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(icon, color: colorScheme.onSurface, size: 24),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
