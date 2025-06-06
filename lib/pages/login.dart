import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Judul Login
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 200),

              // Username TextField
              const Text('Username', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold
              ),),
              TextField(
                controller: _usernameController,
              ),

              const SizedBox(height: 20),

              // Password TextField
              const Text('Password', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold
              ),),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Login
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Aksi login
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    backgroundColor: Color(0xFFf5f2fd),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFF664f9f),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Link Daftar
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman daftar
                  },
                  child: const Text(
                    'Belum Punya Akun? Daftar Sekarang!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Notifikasi "Success logout" di bawah
      bottomNavigationBar: Container(
        color: const Color(0xFF97c15d), // warna hijau terang
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'success logout',
              style: TextStyle(color: Colors.white),
            ),
            Icon(Icons.info, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
