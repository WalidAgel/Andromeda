// File: lib/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // Check login status dan navigate setelah 3 detik
    _checkLogin();
  }

// Updated _checkLogin method in SplashPage
  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    try {
      final isLoggedIn = await ApiService.isLoggedIn();

      if (isLoggedIn) {
        final userType = await ApiService.getUserType();

        if (userType == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else if (userType == 'user') {
          Navigator.pushReplacementNamed(context, '/user-choice');
        } else {
          // Invalid user type, clear data and go to login
          await ApiService.clearAllData();
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // Not logged in, clear any stale data and go to login
        await ApiService.clearAllData();
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Auth check error: $e');
      // On error, clear data and go to login
      await ApiService.clearAllData();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');

    if (token != null && token.isNotEmpty) {
      if (role == 'admin') {
        Navigator.of(context).pushReplacementNamed('/admin/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/user/home');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    // Hanya navigate jika user tap, tidak otomatis
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _onTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // Warna biru yang sama persis dengan gambar
          color: const Color(0xFF4A5C96),
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon pesawat yang di-rotate ke kanan (90 derajat = pi/2)
                  Transform.rotate(
                    angle: 1.5708, // pi/2 radian = 90 derajat ke kanan
                    child: Icon(
                      Icons.flight,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Andromeda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
