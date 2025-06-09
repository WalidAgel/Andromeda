import 'package:flutter/material.dart';
import 'package:haloo/pages/materi/detail_user.dart';
import 'package:haloo/models/materi_model.dart';
import 'package:haloo/widget/sidebar_user.dart';
import 'package:haloo/services/api_services.dart';

class MateriUser extends StatefulWidget {
  const MateriUser({super.key});

  @override
  State<MateriUser> createState() => _MateriUserState();
}

class _MateriUserState extends State<MateriUser> {
  List<MateriModel> materiList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMateri();
  }

  Future<void> _loadMateri() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getMateri();
      
      if (response.success && response.data != null) {
        final List<dynamic> materiData = response.data['data'] ?? [];
        
        setState(() {
          materiList = materiData.map((item) => MateriModel(
            id: item['id'].toString(),
            title: item['judul'] ?? '',
            description: item['konten_materi'] ?? '',
            date: _formatDate(item['created_at']),
            icon: _getIconForMateri(item['judul']),
            backgroundColor: _getColorForMateri(item['judul']),
            iconColor: Colors.white,
          )).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.message;
          isLoading = false;
          // Fallback ke data dummy jika API gagal
          _loadDummyData();
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
        // Fallback ke data dummy jika error
        _loadDummyData();
      });
    }
  }

  void _loadDummyData() {
    materiList = [
      MateriModel(
        id: "1",
        title: "Berpikir Komputasional",
        date: "2025-05-25",
        description:
            "Berpikir komputasional merupakan metode pemecahan masalah dengan menerapkan teknologi ilmu komputer atau informatika. Berpikir komputasional juga dapat diartikan sebagai konsep tentang cara menemukan masalah yang ada di sekitar, dengan mengambil ide lalu mengembangkan solusi pemecahan masalah. Mungkin tidak sedikit orang mengira jika berpikir komputasional haruslah menggunakan aplikasi yang terdapat pada komputer.",
        icon: Icons.psychology,
        backgroundColor: Colors.blue[300],
        iconColor: Colors.white,
      ),
      MateriModel(
        id: "2",
        title: "Sistem komputer",
        date: "2025-05-23",
        description:
            "Sistem komputer adalah gabungan dari hardware (perangkat keras), software (perangkat lunak), dan brainware (manusia yang mengoperasikan) yang bekerja bersama-sama untuk memproses data dan menghasilkan informasi. Sistem ini merupakan dasar dari teknologi informasi dan memungkinkan kita untuk melakukan berbagai tugas, mulai dari pekerjaan kantor hingga hiburan digital.",
        icon: Icons.computer,
        backgroundColor: Colors.green[300],
        iconColor: Colors.white,
      ),
      MateriModel(
        id: "3",
        title: "CPU",
        date: "2025-05-23",
        description:
            "CPU, atau Central Processing Unit, adalah otak dari komputer yang bertugas memproses semua instruksi dan data. Ia berfungsi sebagai pusat kontrol utama, mengarahkan operasi komputer, mulai dari menjalankan aplikasi hingga melakukan perhitungan matematis.",
        icon: Icons.memory,
        backgroundColor: Colors.orange[300],
        iconColor: Colors.white,
      ),
    ];
  }

  IconData _getIconForMateri(String title) {
    if (title.toLowerCase().contains('komputasional') || title.toLowerCase().contains('berpikir')) {
      return Icons.psychology;
    } else if (title.toLowerCase().contains('sistem') || title.toLowerCase().contains('komputer')) {
      return Icons.computer;
    } else if (title.toLowerCase().contains('cpu') || title.toLowerCase().contains('processor')) {
      return Icons.memory;
    } else if (title.toLowerCase().contains('network') || title.toLowerCase().contains('jaringan')) {
      return Icons.network_check;
    } else if (title.toLowerCase().contains('database') || title.toLowerCase().contains('data')) {
      return Icons.storage;
    } else {
      return Icons.book;
    }
  }

  Color? _getColorForMateri(String title) {
    if (title.toLowerCase().contains('komputasional') || title.toLowerCase().contains('berpikir')) {
      return Colors.blue[300];
    } else if (title.toLowerCase().contains('sistem') || title.toLowerCase().contains('komputer')) {
      return Colors.green[300];
    } else if (title.toLowerCase().contains('cpu') || title.toLowerCase().contains('processor')) {
      return Colors.orange[300];
    } else if (title.toLowerCase().contains('network') || title.toLowerCase().contains('jaringan')) {
      return Colors.purple[300];
    } else if (title.toLowerCase().contains('database') || title.toLowerCase().contains('data')) {
      return Colors.red[300];
    } else {
      return Colors.teal[300];
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _refreshMateri() async {
    await _loadMateri();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Materi"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMateri,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      drawer: const SidebarUser(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF664f9f)),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat data materi...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshMateri,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF664f9f),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Menampilkan data offline',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (materiList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada materi tersedia',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Materi akan ditambahkan segera',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshMateri,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF664f9f),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMateri,
      color: const Color(0xFF664f9f),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: materiList.length,
        itemBuilder: (context, index) {
          final materi = materiList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: materi.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          materi.icon,
                          color: materi.iconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          materi.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    materi.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        materi.date,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: materi.backgroundColor?.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ID: ${materi.id}',
                          style: TextStyle(
                            fontSize: 10,
                            color: materi.backgroundColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigasi ke halaman DetailUser dengan MateriModel
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailUser(materi: materi), // Pass materi parameter
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF664f9f),
                      ),
                      icon: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        "Lihat Detail",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}