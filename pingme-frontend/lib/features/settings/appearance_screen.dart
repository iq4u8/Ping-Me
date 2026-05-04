import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/custom_media_picker.dart';
import '../../presentation/viewmodels/theme_viewmodel.dart';
import '../../theme.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeVM = Provider.of<ThemeViewModel>(context);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Appearance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 16),
            
            // App Theme
            Text(
              'App Theme',
              style: TextStyle(color: colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  _ThemeButton(
                    label: 'Default',
                    isSelected: themeVM.currentMode == AppThemeMode.defaultTheme,
                    onTap: () => themeVM.setTheme(AppThemeMode.defaultTheme),
                    colorScheme: colorScheme,
                  ),
                  _ThemeButton(
                    label: 'Light',
                    isSelected: themeVM.currentMode == AppThemeMode.light,
                    onTap: () => themeVM.setTheme(AppThemeMode.light),
                    colorScheme: colorScheme,
                  ),
                  _ThemeButton(
                    label: 'Dark',
                    isSelected: themeVM.currentMode == AppThemeMode.dark,
                    onTap: () => themeVM.setTheme(AppThemeMode.dark),
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App Icon
            Text(
              'App Icon',
              style: TextStyle(color: colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                title: Text('Use Dark Icon', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500)),
                trailing: Switch(
                  value: themeVM.isDarkIcon,
                  onChanged: (val) {
                    themeVM.changeAppIcon(val);
                  },
                  activeColor: colorScheme.primary,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Wallpapers
            Text(
              'Wallpapers',
              style: TextStyle(color: colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    title: Text('Chat Wallpaper', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500)),
                    trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.3), size: 22),
                    onTap: () {
                      Navigator.pushNamed(context, '/chat_wallpapers');
                    },
                  ),
                  Divider(height: 1, thickness: 1, color: colorScheme.onSurface.withOpacity(0.05), indent: 16),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    title: Text('Dashboard Wallpaper', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500)),
                    trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.3), size: 22),
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      final result = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => SizedBox(
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: const CustomMediaPickerBottomSheet(showOnlyGallery: true),
                        ),
                      );
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: const Text('Dashboard wallpaper updated!'), backgroundColor: colorScheme.primary),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _ThemeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
