import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'email_verification_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 3));
    User? user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      await AuthService().updateSessionForAutoLogin();
      await user.reload();
      if (user.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EmailVerificationScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.darkBg, AppTheme.lightBg, AppTheme.darkBg],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 160, height: 160, child: CustomPaint(painter: NodeLogoPainter())),
              const SizedBox(height: 32),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.blueAccent, AppTheme.primaryPurple, Colors.blueAccent],
                ).createShader(bounds),
                child: Text(
                  'TechIntern',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.primaryBlue,
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NodeLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint gradientPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    final Paint linePaint = Paint()
      ..shader = gradientPaint.shader
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final Paint whitePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawLine(const Offset(80, 52), const Offset(80, 64), linePaint);
    canvas.drawLine(const Offset(92, 80), const Offset(104, 80), linePaint);
    canvas.drawLine(const Offset(80, 96), const Offset(80, 108), linePaint);
    canvas.drawLine(const Offset(68, 80), const Offset(56, 80), linePaint);
    canvas.drawCircle(const Offset(80, 40), 12, gradientPaint);
    canvas.drawCircle(const Offset(120, 80), 12, gradientPaint);
    canvas.drawCircle(const Offset(80, 120), 12, gradientPaint);
    canvas.drawCircle(const Offset(40, 80), 12, gradientPaint);
    canvas.drawCircle(const Offset(80, 80), 16, gradientPaint);
    canvas.drawCircle(const Offset(80, 40), 5, whitePaint);
    canvas.drawCircle(const Offset(120, 80), 5, whitePaint);
    canvas.drawCircle(const Offset(80, 120), 5, whitePaint);
    canvas.drawCircle(const Offset(40, 80), 5, whitePaint);
    canvas.drawCircle(const Offset(80, 80), 7, whitePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}