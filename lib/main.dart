// File: lib/main.dart
import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/login.dart';
import 'pages/register_page.dart';
import 'pages/user_choice_page.dart';
import 'pages/materi_user.dart';
import 'pages/soal_user.dart';
import 'widget/tabBar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Andromeda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A5C96)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // Pastikan initial route adalah splash page
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/user-choice': (context) => const UserChoicePage(),
        '/admin-dashboard': (context) => const MainScreen(),
        '/materi-user': (context) => const MateriUser(),
        '/soal-user': (context) => const SoalUser(),
      },
      // Tambahkan ini untuk handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const SplashPage(),
        );
      },
    );
  }
}