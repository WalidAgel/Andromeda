// File: lib/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      // Clear any existing tokens/session first for fresh start
      await ApiService.removeToken();
      
      // Always navigate to login on fresh app start
      Navigator.pushReplacementNamed(context, '/login');
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon pesawat
                  Icon(
                    Icons.flight,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  // Text Andromeda
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