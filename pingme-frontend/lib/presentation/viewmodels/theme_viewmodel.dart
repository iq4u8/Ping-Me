import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme.dart';

class ThemeViewModel extends ChangeNotifier {
  AppThemeMode _currentMode = AppThemeMode.defaultTheme;
  
  AppThemeMode get currentMode => _currentMode;

  bool get isDarkMode => _currentMode == AppThemeMode.dark;

  void cycleTheme() {
    if (_currentMode == AppThemeMode.defaultTheme) {
      _currentMode = AppThemeMode.light;
    } else if (_currentMode == AppThemeMode.light) {
      _currentMode = AppThemeMode.dark;
    } else {
      _currentMode = AppThemeMode.defaultTheme;
    }
    notifyListeners();
  }

  void setTheme(AppThemeMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  bool _isDarkIcon = false;
  bool get isDarkIcon => _isDarkIcon;

  static const platform = MethodChannel('com.pingme.app/icon');

  Future<void> changeAppIcon(bool isDark) async {
    try {
      await platform.invokeMethod('changeIcon', {'iconName': isDark ? 'dark' : 'light'});
      _isDarkIcon = isDark;
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint("Failed to change icon: '${e.message}'.");
    }
  }
}
