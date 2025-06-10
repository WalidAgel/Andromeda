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
    return RefreshIndicator(
      onRefresh: _refreshMateri,
      child: Scaffold(
        appBar: AppBar(title: const Text('Soal User')),
        body: const Center(child: Text('Halaman Soal User')),
      ),
    );
  }

  Future<void> _refreshMateri() async {
    // Implementasi untuk refresh materi
  }
}

class SoalUser extends StatelessWidget {
  const SoalUser({super.key});

  @override
  Widget build(BuildContext context) {
    // ... UI Soal User ...
    return Scaffold(
      appBar: AppBar(title: const Text('Soal User')),
      body: const Center(child: Text('Halaman Soal User')),
    );
  }
}
