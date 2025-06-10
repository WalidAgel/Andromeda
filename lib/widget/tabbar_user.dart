import 'package:flutter/material.dart';
import 'package:haloo/pages/materi_user.dart';
import 'package:haloo/pages/kuis_user.dart'; // Ganti ke halaman kuis user

class MainScreenUser extends StatefulWidget {
  const MainScreenUser({super.key});

  @override
  _MainScreenUserState createState() => _MainScreenUserState();
}

class _MainScreenUserState extends State<MainScreenUser> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    MateriUser(),
    KuisUser(), // Halaman daftar kuis user
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF664f9f),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Kuis',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}