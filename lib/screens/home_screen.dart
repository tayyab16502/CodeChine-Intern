import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoggingOut = false;

  // Actual logout logic
  void _handleLogout() async {
    setState(() => _isLoggingOut = true);
    await AuthService().logoutUser();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  // Logout confirmation dialog
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkBg, // Theming ke hisaab se dark background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          title: Text(
            "Logout",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.poppins(
              color: Colors.grey[300],
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel karne pe dialog close
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog close karein
                _handleLogout(); // Asal logout function call karein
              },
              child: Text(
                "Logout",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _forceLogout() async {
    await AuthService().logoutUser();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out: Session active on another device')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightBg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Scaffold();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          Positioned(
            top: -150,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.primaryPurple.withOpacity(0.25), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
                }

                if (snapshot.hasData && snapshot.data!.exists) {
                  Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

                  if (userData['sessionId'] != AuthService.currentSessionId) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _forceLogout());
                    return const Center(child: CircularProgressIndicator(color: Colors.red));
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Profile',
                              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.5)),
                              ),
                              child: Text(
                                'Active',
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.lightBg,
                            child: Icon(Icons.person_outline, size: 50, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          userData['name'] ?? 'No Name',
                          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Verified Member',
                          style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.primaryBlue, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 32),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildInfoTile(Icons.email_outlined, 'Email Address', userData['email'] ?? ''),
                                _buildInfoTile(Icons.fingerprint, 'User ID', userData['uid'] ?? currentUser!.uid),
                                _buildInfoTile(
                                  Icons.access_time_outlined,
                                  'Account Created',
                                  _formatDate(userData['createdAt']),
                                ),
                              ],
                            ),
                          ),
                        ),
                        CustomButton(
                          text: 'Logout',
                          isLoading: _isLoggingOut,
                          // Yahan _handleLogout ki jagah naya dialog wala function pass kiya hai
                          onPressed: _showLogoutConfirmation,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                }
                return const Center(child: Text("Error loading data", style: TextStyle(color: Colors.white)));
              },
            ),
          ),
        ],
      ),
    );
  }
}