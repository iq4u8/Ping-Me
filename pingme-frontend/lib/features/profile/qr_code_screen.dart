import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../presentation/viewmodels/theme_viewmodel.dart';
import '../../theme.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  int _secondsLeft = 4 * 60 + 58; // 04:58
  Timer? _timer;
  int _currentQrIndex = 0;
  
  final List<Color> _qrColors = [
    Colors.blue.shade600,
    Colors.green.shade600,
    Colors.purple.shade600,
    Colors.orange.shade600,
    Colors.teal.shade600,
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _secondsLeft = 4 * 60 + 58; // Restart time
          _currentQrIndex = (_currentQrIndex + 1) % _qrColors.length; // Change QR
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _secondsLeft ~/ 60;
    int seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  IconData _getThemeIcon(AppThemeMode mode) {
    if (mode == AppThemeMode.light) return Icons.light_mode;
    if (mode == AppThemeMode.dark) return Icons.dark_mode;
    return Icons.brightness_auto;
  }

  @override
  Widget build(BuildContext context) {
    final themeVM = Provider.of<ThemeViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // QR Code Card
                      Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 36, left: 40, right: 40),
                            padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.qr_code_2, size: 180, color: _qrColors[_currentQrIndex]),
                                const SizedBox(height: 16),
                                Text(
                                  _formattedTime,
                                  style: TextStyle(
                                    color: _qrColors[_currentQrIndex],
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Avatar overlapping
                          Positioned(
                            top: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: colorScheme.background, width: 4),
                              ),
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: colorScheme.surface,
                                backgroundImage: const AssetImage('assets/images/logo_dark.png'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Sheet Area
            Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Fixes overflow
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'QR Code',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_getThemeIcon(themeVM.currentMode), color: colorScheme.primary),
                        onPressed: () {
                          themeVM.cycleTheme();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // QR Themes List
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _qrColors.length,
                      itemBuilder: (context, index) {
                        final isSelected = _currentQrIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentQrIndex = index;
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.background,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: colorScheme.primary, width: 2) : null,
                            ),
                            child: Center(
                              child: Icon(Icons.qr_code, color: _qrColors[index], size: 30),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('QR Code copied to clipboard!'),
                          backgroundColor: colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: const Text('Share QR Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Scan Button
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: colorScheme.surface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Text('Scan QR Code', style: TextStyle(color: colorScheme.onSurface)),
                            content: Column(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                width: 200, height: 200,
                                decoration: BoxDecoration(
                                  color: colorScheme.background,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 2),
                                ),
                                child: Center(
                                  child: Icon(Icons.qr_code_scanner, size: 80, color: colorScheme.primary.withOpacity(0.4)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text('Point your camera at a QR code', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 14)),
                            ]),
                            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: TextStyle(color: colorScheme.primary)))],
                          ),
                        );
                      },
                      icon: Icon(Icons.qr_code_scanner, color: colorScheme.primary),
                      label: Text('Scan QR Code', style: TextStyle(color: colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
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
