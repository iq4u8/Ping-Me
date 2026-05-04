import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/wire_components.dart';
import '../../theme.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';

class IdentifyScreen extends StatefulWidget {
  final String method;
  const IdentifyScreen({super.key, required this.method});

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final isPhone = widget.method == 'phone';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Title - centered
                      Text(
                        isPhone ? 'Your Phone' : 'Your Email',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isPhone
                            ? 'Please confirm your country code\nand enter your phone number.'
                            : 'Please enter your email address.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),
                      if (isPhone) ...[
                        // Country code
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: colorScheme.onSurface.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text('+91', style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
                              const SizedBox(width: 4),
                              Icon(Icons.expand_more, color: colorScheme.onSurface.withOpacity(0.4), size: 18),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Input
                      SizedBox(
                        height: 48,
                        child: TextField(
                          controller: _controller,
                          keyboardType: isPhone ? TextInputType.phone : TextInputType.emailAddress,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: isPhone ? 'Phone number' : 'Email address',
                            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.25), fontSize: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.15)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isPhone
                            ? 'We will send an SMS with a verification code.'
                            : 'We will send a code to this email.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.3),
                          fontSize: 12,
                        ),
                      ),
                      if (!isPhone) ...[
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              HapticFeedback.selectionClick();
                              // Show spinner
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                barrierColor: Colors.black54,
                                builder: (ctx) => Center(
                                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                                    SizedBox(width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 3, color: colorScheme.primary)),
                                    const SizedBox(height: 16),
                                    const Text('Signing in with Google...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, decoration: TextDecoration.none)),
                                  ]),
                                ),
                              );
                              await Future.delayed(const Duration(milliseconds: 1200));
                              if (!mounted) return;
                              Navigator.pop(context); // close spinner
                              Navigator.pushNamed(context, '/username');
                            },
                            icon: SizedBox(
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
                            label: Text('Continue with Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Bottom button
              if (authVM.isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/otp',
                          arguments: {
                            'identifier': _controller.text.isEmpty
                                ? (isPhone ? '+91 1234567890' : 'test@example.com')
                                : _controller.text,
                            'method': widget.method,
                          },
                        );
                      },
                      child: const Text('Continue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
