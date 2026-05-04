import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme.dart';
import '../../../../presentation/viewmodels/auth_viewmodel.dart';
import '../../../../presentation/viewmodels/theme_viewmodel.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  // Data for each theme slide
  static const List<AppThemeMode> _themeModes = [
    AppThemeMode.defaultTheme,
    AppThemeMode.light,
    AppThemeMode.dark,
  ];

  static const List<String> _subtitles = [
    'Where every conversation feels like home.',
    'Simple. Clean. Beautifully connected.',
    'Privacy-first messaging, redefined.',
  ];

  static const List<String> _quotes = [
    '"Connection is the energy that is created\nbetween people when they feel heard."',
    '"The most important thing in communication\nis hearing what isn\'t said."',
    '"In a world full of noise,\nbe someone\'s signal."',
  ];

  static const List<String> _themeLabels = [
    'Warm',
    'Light',
    'Dark',
  ];

  @override
  void initState() {
    super.initState();
    final themeVM = Provider.of<ThemeViewModel>(context, listen: false);
    _currentPage = _themeModes.indexOf(themeVM.currentMode);
    if (_currentPage < 0) _currentPage = 0;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    final themeVM = Provider.of<ThemeViewModel>(context, listen: false);
    themeVM.setTheme(_themeModes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeVM = Provider.of<ThemeViewModel>(context);

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: 3,
          itemBuilder: (context, index) {
            return _WelcomeSlide(
              subtitle: _subtitles[index],
              quote: _quotes[index],
              themeLabel: _themeLabels[index],
              currentPage: _currentPage,
              pageCount: 3,
              onStart: () => _showAuthSheet(context),
            );
          },
        ),
      ),
    );
  }

  void _showAuthSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (ctx) => const _AuthBottomSheet(),
    );
  }
}

class _WelcomeSlide extends StatelessWidget {
  final String subtitle;
  final String quote;
  final String themeLabel;
  final int currentPage;
  final int pageCount;
  final VoidCallback onStart;

  const _WelcomeSlide({
    required this.subtitle,
    required this.quote,
    required this.themeLabel,
    required this.currentPage,
    required this.pageCount,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeVM = Provider.of<ThemeViewModel>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Logo
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                  themeVM.currentMode == AppThemeMode.light
                      ? 'assets/images/logo_light.png'
                      : 'assets/images/logo_dark.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack).fadeIn(duration: 500.ms),
          const SizedBox(height: 20),
          // App name
          Text(
            'Ping Me',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 150.ms),
          const SizedBox(height: 10),
          // Unique subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: 14,
              height: 1.5,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 250.ms),
          const SizedBox(height: 8),
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentPage == i ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: currentPage == i
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
              );
            }),
          ),
          const Spacer(flex: 1),
          // Quote
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              quote,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                color: colorScheme.onSurface.withOpacity(0.35),
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Theme label chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
            ),
            child: Text(
              themeLabel,
              style: TextStyle(color: colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5),
            ),
          ),
          const Spacer(flex: 2),
          // Start button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                elevation: 0,
              ),
              onPressed: onStart,
              child: const Text('Start Messaging', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ).animate().slideY(begin: 0.5, end: 0, duration: 500.ms, curve: Curves.easeOutQuad, delay: 350.ms).fadeIn(duration: 500.ms, delay: 350.ms),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ─── Auth Bottom Sheet ──────────────────────────────────────────────────────

class _AuthBottomSheet extends StatefulWidget {
  const _AuthBottomSheet();
  @override
  State<_AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<_AuthBottomSheet> {
  int _step = 0; // 0=email, 1=otp
  final _emailCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpNodes = List.generate(6, (_) => FocusNode());
  int _countdown = 60;
  Timer? _timer;
  String _email = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    for (var c in _otpCtrls) c.dispose();
    for (var f in _otpNodes) f.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 0) { if (mounted) setState(() => _countdown--); }
      else t.cancel();
    });
  }

  void _submitEmail() {
    _email = _emailCtrl.text.trim();
    if (_email.isEmpty || !_email.contains('@')) return;
    _startTimer();
    setState(() => _step = 1);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_otpNodes.isNotEmpty && mounted) _otpNodes[0].requestFocus();
    });
  }

  void _onDigit(int i, String v) {
    if (v.isNotEmpty && i < 5) _otpNodes[i + 1].requestFocus();
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length == 6) _verify(otp);
  }

  void _onBackspace(int i, KeyEvent e) {
    if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.backspace && _otpCtrls[i].text.isEmpty && i > 0) {
      _otpNodes[i - 1].requestFocus();
    }
  }

  Future<void> _verify(String otp) async {
    final cs = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 3, color: cs.primary)),
            const SizedBox(height: 16),
            const Text('Verifying...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final ok = await authVM.verify(_email, otp);
    
    if (!mounted) return;
    Navigator.pop(context); // Close spinner dialog

    if (ok) {
      Navigator.pop(context); // Close bottom sheet
      Navigator.pushNamed(context, '/username');
    } else {
      for (var c in _otpCtrls) c.clear();
      _otpNodes[0].requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Invalid code. Try 000000'),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _googleLogin() async {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 3, color: cs.primary)),
            const SizedBox(height: 16),
            const Text('Signing in...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    
    Navigator.pop(context); // Close spinner
    Navigator.pop(context); // Close bottom sheet
    Navigator.pushNamed(context, '/username');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: _step == 0 ? _emailView(cs) : _otpView(cs),
          ),
        ),
      ),
    );
  }

  // ── Email Step ──
  Widget _emailView(ColorScheme cs) {
    return Padding(
      key: const ValueKey(0),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 48, height: 5, decoration: BoxDecoration(color: cs.onSurface.withOpacity(0.12), borderRadius: BorderRadius.circular(2.5))),
        const SizedBox(height: 32),
        Text('Welcome to Ping Me', style: TextStyle(color: cs.onSurface, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Log in or sign up to continue', style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 14)),
        const SizedBox(height: 32),
        // Google button with perfect SVG icon
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _googleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.background, foregroundColor: cs.onSurface, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cs.onSurface.withOpacity(0.12))),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: 22, height: 22,
                child: SvgPicture.string('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.7 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.2-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>
'''),
              ),
              const SizedBox(width: 14),
              Text('Continue with Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: Divider(color: cs.onSurface.withOpacity(0.08), thickness: 1)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('or continue with email', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 13, fontWeight: FontWeight.w500))),
          Expanded(child: Divider(color: cs.onSurface.withOpacity(0.08), thickness: 1)),
        ]),
        const SizedBox(height: 24),

        SizedBox(
          height: 52,
          child: TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: cs.onSurface, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.25), fontSize: 14),
              prefixIcon: Padding(padding: const EdgeInsets.only(left: 14, right: 10), child: Icon(Icons.mail_outline_rounded, color: cs.onSurface.withOpacity(0.35), size: 19)),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              filled: true, fillColor: cs.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
            onSubmitted: (_) => _submitEmail(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _submitEmail,
            style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Continue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
      ]),
    );
  }

  // ── OTP Step ──
  Widget _otpView(ColorScheme cs) {
    return Padding(
      key: const ValueKey(1),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 48, height: 5, decoration: BoxDecoration(color: cs.onSurface.withOpacity(0.12), borderRadius: BorderRadius.circular(2.5))),
        const SizedBox(height: 32),
        Text('Verify Email', style: TextStyle(color: cs.onSurface, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Enter the code sent to', style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 14)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_email, style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _step = 0),
              child: Text('Change', style: TextStyle(color: cs.primary, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => SizedBox(
            width: 46, height: 54,
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (e) => _onBackspace(i, e),
              child: TextField(
                controller: _otpCtrls[i],
                focusNode: _otpNodes[i],
                maxLength: 1,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '', filled: true, fillColor: cs.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: cs.onSurface.withOpacity(0.08))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: cs.primary, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (v) => _onDigit(i, v),
              ),
            ),
          )),
        ),
        const SizedBox(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.timer_outlined, size: 16, color: cs.onSurface.withOpacity(0.4)),
          const SizedBox(width: 6),
          Text('00:${_countdown.toString().padLeft(2, '0')}', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: cs.onSurface.withOpacity(0.2))),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _countdown == 0 ? () => _startTimer() : null,
            child: Text('Resend Code', style: TextStyle(color: _countdown == 0 ? cs.primary : cs.onSurface.withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),
      ]),
    );
  }
}


