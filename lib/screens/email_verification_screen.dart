import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerified();
    });
  }

  Future<void> _checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user?.emailVerified ?? false) {
      _timer?.cancel();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      }
    }
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isResending = true;
    });
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
    setState(() {
      _isResending = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pichli screen ka keyboard automatically band karne ke liye
    FocusManager.instance.primaryFocus?.unfocus();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        // Center aur SingleChildScrollView lagane se overflow issue khtam ho jayega
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 100,
                    color: AppTheme.primaryBlue
                ),
                const SizedBox(height: 32),
                Text(
                  'Verify Your Email',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You have received a mail. If you cannot see the mail in your inbox, please check your spam or junk folder.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[400],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(color: AppTheme.primaryPurple),
                const SizedBox(height: 24),
                Text(
                  'Waiting for verification...',
                  style: GoogleFonts.poppins(color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 48),
                CustomButton(
                  text: 'Resend Email',
                  isLoading: _isResending,
                  onPressed: _resendEmail,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}