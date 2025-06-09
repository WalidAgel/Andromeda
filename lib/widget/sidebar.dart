// File: lib/widget/sidebar.dart
import 'package:flutter/material.dart';
import 'package:haloo/services/api_services.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.purple[700],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Name : Admin User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Username : admin',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Role : admin',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                // Simpan context reference sebelum async operations
                final navigator = Navigator.of(context);
                
                navigator.pop(); // Tutup dialog konfirmasi
                
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                try {
                  await ApiService.logout();
                } catch (e) {
                  print('Logout error: $e');
                }
                
                // Tutup loading dialog
                navigator.pop();
                
                try {
                  // Navigate to login dan clear semua stack
                  navigator.pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                    arguments: 'logout_success',
                  );
                } catch (e) {
                  print('Navigation error: $e');
                  // Jika gagal navigasi normal, coba dengan pushReplacementNamed
                  try {
                    navigator.pushReplacementNamed('/login', arguments: 'logout_success');
                  } catch (e2) {
                    print('Fallback navigation error: $e2');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

// File: lib/widget/soal_user.dart
