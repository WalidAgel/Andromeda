import 'package:flutter/material.dart';
import 'package:haloo/pages/materi_user.dart';
import 'package:haloo/pages/soal_user.dart';


class MainScreenUser extends StatefulWidget {
  const MainScreenUser({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenUser> {
  int _selectedIndex = 0;

  // List halaman yang akan ditampilkan
  final List<Widget> _pages = [
    // MateriUser(),
    // SoalUser(),
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
        backgroundColor: Color(0xFF664f9f), // Warna latar BottomNavigationBar
        selectedItemColor: Colors.white, // Warna ikon dan label saat aktif
        unselectedItemColor: Colors.white70, // Warna ikon dan label saat tidak aktif
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Soal',
          ),
        ],
        currentIndex: _selectedIndex, // Gunakan _selectedIndex, bukan hardcode 0
        onTap: _onItemTapped, // Panggil fungsi _onItemTapped
      ),
    );
  }
}