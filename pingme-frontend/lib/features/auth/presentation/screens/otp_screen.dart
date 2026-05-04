import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme.dart';
import '../../../../shared/widgets/wire_components.dart';
import '../../../../presentation/viewmodels/auth_viewmodel.dart';

class OtpScreen extends StatefulWidget {
  final String identifier;
  final String method;

  const OtpScreen({super.key, required this.identifier, required this.method});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  int _secondsRemaining = 60;
  Timer? _timer;
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Title - centered
                Text(
                  widget.identifier,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'We\'ve sent the code to the email\naddress you provided.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Try another email?',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // OTP Input
                SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 14,
                      fontSize: 22,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '••••••',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.15),
                        letterSpacing: 14,
                        fontSize: 22,
                      ),
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
                    onChanged: (val) async {
                      if (val.length == 6) {
                        final success = await authVM.verify(widget.identifier, val);
                        if (success && mounted) {
                          Navigator.pushReplacementNamed(context, '/username');
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid code. Try 000000')),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Timer
                Text(
                  '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: _secondsRemaining > 0
                        ? colorScheme.onSurface.withOpacity(0.4)
                        : colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                // Resend
                TextButton(
                  onPressed: _secondsRemaining == 0
                      ? () {
                          authVM.login(widget.identifier);
                          _startTimer();
                        }
                      : null,
                  child: Text(
                    'Resend Code',
                    style: TextStyle(
                      color: _secondsRemaining == 0
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.25),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (authVM.isLoading)
                  Center(child: CircularProgressIndicator(color: colorScheme.primary)),
                  
              ],
            ),
          ),
        ),
      ),
    );
  }
}
