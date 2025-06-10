import 'package:flutter/material.dart';
import 'package:haloo/services/api_services.dart';

class SidebarUser extends StatefulWidget {
  const SidebarUser({super.key});

  @override
  State<SidebarUser> createState() => _SidebarUserState();
}

class _SidebarUserState extends State<SidebarUser> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Coba ambil dari local storage dulu
      final localData = await ApiService.getUserData();
      if (localData != null) {
        setState(() {
          userData = localData;
          isLoading = false;
        });
        return;
      }

      // Jika tidak ada di local, ambil dari API
      final response = await ApiService.getProfile();
      if (response.success && response.data != null) {
        final profileData = response.data['data'];
        setState(() {
          userData = profileData;
          isLoading = false;
        });
        // Save ke local storage
        await ApiService.saveUserData(profileData);
      } else {
        setState(() {
          isLoading = false;
          // Fallback ke data default
          userData = {
            'nama_lengkap': 'User',
            'username': 'user',
          };
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        // Fallback ke data default
        userData = {
          'nama_lengkap': 'User',
          'username': 'user',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: const BoxDecoration(
              color: Color(0xFF664f9f),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF664f9f),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isLoading ? 'Loading...' : 'Name : ${userData?['nama_lengkap'] ?? 'User'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isLoading ? '' : 'Username : ${userData?['username'] ?? 'user'}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'Role : user',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Materi'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/user-dashboard',
                (route) => false,
                arguments: {'selectedTab': 0}, // Tab materi
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_turned_in),
            title: const Text('Daftar Kuis'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/user-dashboard',
                (route) => false,
                arguments: {'selectedTab': 1}, // Tab kuis
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/user-profile');
            },
          ),
          const Divider(),
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