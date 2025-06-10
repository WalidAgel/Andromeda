// File: lib/main.dart (Updated with TabBar User)
import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/login.dart';
import 'pages/register_page.dart';
import 'pages/user_choice_page.dart';
import 'pages/materi_user.dart';
import 'pages/soal_user.dart';
import 'pages/user_profile.dart';
import 'widget/tabBar.dart';
import 'widget/tabbar_user.dart';
import 'pages/kuis_user.dart';
import 'pages/kuis/detail_kuis_user.dart';
import 'pages/kuis/mengerjakan_kuis.dart';

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
        '/user-dashboard': (context) => const MainScreenUser(),
        // '/user-profile': (context) => const UserProfilePage(),
        '/materi-user': (context) => const MateriUser(),
        '/kuis-user': (context) => const KuisUser(),
      },
      // Handle dynamic routes for quiz detail and quiz taking
      onGenerateRoute: (settings) {
        // Handle quiz detail route
        if (settings.name?.startsWith('/detail-kuis-user/') == true) {
          final kuisData = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => DetailKuisUser(kuisData: kuisData),
          );
        }
        
        // Handle quiz taking route
        if (settings.name?.startsWith('/mengerjakan-kuis/') == true) {
          final kuisData = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => MengerjakanKuisPage(kuisData: kuisData),
          );
        }
        
        // Default fallback
        return MaterialPageRoute(
          builder: (context) => const SplashPage(),
        );
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