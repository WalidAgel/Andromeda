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
            decoration: BoxDecoration(
              color: Colors.purple[700],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: userData?['foto_profile'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            userData!['foto_profile'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.blue,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.blue,
                        ),
                ),
                const SizedBox(height: 10),
                if (isLoading)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name : ${userData?['nama_lengkap'] ?? 'User'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Username : ${userData?['username'] ?? 'user'}',
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
              ],
            ),
          ),

          // Menu items
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // Navigate ke profile page jika ada
              // Navigator.pushNamed(context, '/profile');
            },
          ),

          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Materi'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/materi-user');
            },
          ),

          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Soal'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/soal-user');
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
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
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      await ApiService.logout();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
      arguments: 'logout_success',
    );
  }
}
