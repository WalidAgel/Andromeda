// File: lib/pages/soal_user.dart
import 'package:flutter/material.dart';
import 'package:haloo/widget/sidebar_user.dart';
import 'package:haloo/services/api_services.dart';

class SoalUser extends StatefulWidget {
  const SoalUser({super.key});

  @override
  State<SoalUser> createState() => _SoalUserState();
}

class _SoalUserState extends State<SoalUser> {
  List<Map<String, dynamic>> soalList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSoal();
  }

  Future<void> _loadSoal() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getSoal();
      
      if (response.success && response.data != null) {
        final List<dynamic> soalData = response.data['data'] ?? [];
        
        setState(() {
          soalList = soalData.map((item) => {
            'id': item['id'].toString(),
            'title': item['judul'] ?? '',
            'description': _generateDescription(item['pertanyaan']),
            'category': _getCategoryFromTitle(item['judul']),
            'date': _formatDate(item['created_at']),
            'icon': _getIconForSoal(item['judul']),
            'backgroundColor': _getColorForSoal(item['judul']),
            'jumlahSoal': 1,
            'durasi': '5 menit',
            'tingkatKesulitan': _getDifficultyFromQuestion(item['pertanyaan']),
            'passingScore': 70,
            'pertanyaan': item['pertanyaan'],
            'pilihan_a': item['pilihan_a'],
            'pilihan_b': item['pilihan_b'],
            'pilihan_c': item['pilihan_c'],
            'pilihan_d': item['pilihan_d'],
            'jawaban_benar': item['jawaban_benar'],
          }).toList().cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.message;
          isLoading = false;
          _loadDummyData();
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
        _loadDummyData();
      });
    }
  }

  void _loadDummyData() {
    soalList = [
      {
        'id': '1',
        'title': 'Sample komprehensional',
        'description': 'Soal latihan untuk mengukur kemampuan pemahaman komprehensif tentang berpikir komputasional dan sistem komputer.',
        'category': 'Berpikir Komputasional',
        'date': '2025-06-08',
        'icon': Icons.assignment,
        'backgroundColor': Colors.purple.shade300,
        'jumlahSoal': 10,
        'durasi': '15 menit',
        'tingkatKesulitan': 'Mudah',
        'passingScore': 70,
      },
      {
        'id': '2',
        'title': 'Algoritma dan Struktur Data',
        'description': 'Ujian komprehensif tentang algoritma sorting, searching, dan struktur data dasar seperti array, linked list, dan tree.',
        'category': 'Algoritma',
        'date': '2025-06-07',
        'icon': Icons.memory,
        'backgroundColor': Colors.blue.shade300,
        'jumlahSoal': 15,
        'durasi': '25 menit',
        'tingkatKesulitan': 'Sedang',
        'passingScore': 75,
      },
      {
        'id': '3',
        'title': 'Database Management',
        'description': 'Soal advanced tentang normalisasi database, query optimization, dan database design patterns.',
        'category': 'Database',
        'date': '2025-06-06',
        'icon': Icons.storage,
        'backgroundColor': Colors.orange.shade300,
        'jumlahSoal': 20,
        'durasi': '30 menit',
        'tingkatKesulitan': 'Sulit',
        'passingScore': 80,
      },
    ];
  }

  String _generateDescription(String? pertanyaan) {
    if (pertanyaan == null || pertanyaan.isEmpty) {
      return 'Soal latihan untuk mengukur pemahaman materi.';
    }
    if (pertanyaan.length > 100) {
      return '${pertanyaan.substring(0, 100)}...';
    }
    return pertanyaan;
  }

  String _getCategoryFromTitle(String? title) {
    if (title == null) return 'Umum';
    
    if (title.toLowerCase().contains('komputasional') || title.toLowerCase().contains('berpikir')) {
      return 'Berpikir Komputasional';
    } else if (title.toLowerCase().contains('algoritma')) {
      return 'Algoritma';
    } else if (title.toLowerCase().contains('sistem') || title.toLowerCase().contains('komputer')) {
      return 'Sistem Komputer';
    } else if (title.toLowerCase().contains('database') || title.toLowerCase().contains('data')) {
      return 'Database';
    } else if (title.toLowerCase().contains('cpu') || title.toLowerCase().contains('processor')) {
      return 'Hardware';
    } else {
      return 'Umum';
    }
  }

  IconData _getIconForSoal(String? title) {
    if (title == null) return Icons.assignment;
    
    if (title.toLowerCase().contains('komputasional') || title.toLowerCase().contains('berpikir')) {
      return Icons.psychology;
    } else if (title.toLowerCase().contains('algoritma')) {
      return Icons.memory;
    } else if (title.toLowerCase().contains('sistem') || title.toLowerCase().contains('komputer')) {
      return Icons.computer;
    } else if (title.toLowerCase().contains('database') || title.toLowerCase().contains('data')) {
      return Icons.storage;
    } else if (title.toLowerCase().contains('cpu') || title.toLowerCase().contains('processor')) {
      return Icons.memory;
    } else {
      return Icons.assignment;
    }
  }

  Color _getColorForSoal(String? title) {
    if (title == null) return Colors.grey.shade300;
    
    if (title.toLowerCase().contains('komputasional') || title.toLowerCase().contains('berpikir')) {
      return Colors.purple.shade300;
    } else if (title.toLowerCase().contains('algoritma')) {
      return Colors.blue.shade300;
    } else if (title.toLowerCase().contains('sistem') || title.toLowerCase().contains('komputer')) {
      return Colors.green.shade300;
    } else if (title.toLowerCase().contains('database') || title.toLowerCase().contains('data')) {
      return Colors.orange.shade300;
    } else if (title.toLowerCase().contains('cpu') || title.toLowerCase().contains('processor')) {
      return Colors.red.shade300;
    } else {
      return Colors.teal.shade300;
    }
  }

  String _getDifficultyFromQuestion(String? question) {
    if (question == null) return 'Mudah';
    
    final lowerQuestion = question.toLowerCase();
    
    if (lowerQuestion.contains('advanced') || 
        lowerQuestion.contains('kompleks') ||
        lowerQuestion.contains('optimization')) {
      return 'Sulit';
    } else if (lowerQuestion.contains('cara') ||
               lowerQuestion.contains('metode') ||
               lowerQuestion.contains('proses')) {
      return 'Sedang';
    } else {
      return 'Mudah';
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

  Future<void> _refreshSoal() async {
    await _loadSoal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const SidebarUser(),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("Daftar Soal"),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshSoal,
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
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
              'Memuat data soal...',
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
              onPressed: _refreshSoal,
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

    if (soalList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshSoal,
      color: const Color(0xFF664f9f),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: soalList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildSoalCard(context, soalList[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada soal tersedia',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Soal akan ditambahkan segera',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshSoal,
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

  Widget _buildSoalCard(BuildContext context, Map<String, dynamic> soal) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(soal),
            const SizedBox(height: 12),
            _buildDescription(soal),
            const SizedBox(height: 12),
            _buildSoalInfo(soal),
            const SizedBox(height: 8),
            _buildDate(soal),
            const SizedBox(height: 16),
            _buildActionButton(context, soal),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(Map<String, dynamic> soal) {
    return Row(
      children: [
        _buildIconContainer(soal),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                soal['title'] ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              _buildBadges(soal),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconContainer(Map<String, dynamic> soal) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: soal['backgroundColor'],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        soal['icon'],
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildBadges(Map<String, dynamic> soal) {
    return Row(
      children: [
        _buildCategoryBadge(soal),
        const SizedBox(width: 8),
        if (soal['tingkatKesulitan'] != null)
          _buildDifficultyBadge(soal['tingkatKesulitan'].toString()),
      ],
    );
  }

  Widget _buildCategoryBadge(Map<String, dynamic> soal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (soal['backgroundColor'] as Color).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        soal['category'] ?? '',
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getDifficultyColor(difficulty),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDescription(Map<String, dynamic> soal) {
    return Text(
      soal['description'] ?? '',
      style: TextStyle(
        fontSize: 14, 
        color: Colors.grey[800],
        height: 1.4,
      ),
    );
  }

  Widget _buildSoalInfo(Map<String, dynamic> soal) {
    return Row(
      children: [
        _buildInfoItem(
          Icons.assignment_outlined,
          '${soal['jumlahSoal'] ?? 0} Soal',
        ),
        const SizedBox(width: 16),
        _buildInfoItem(
          Icons.timer_outlined,
          soal['durasi'] ?? 'N/A',
        ),
        const SizedBox(width: 16),
        _buildInfoItem(
          Icons.grade_outlined,
          'Min ${soal['passingScore'] ?? 0}%',
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDate(Map<String, dynamic> soal) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          soal['date'] ?? '',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: (soal['backgroundColor'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'ID: ${soal['id']}',
            style: TextStyle(
              fontSize: 10,
              color: soal['backgroundColor'],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, Map<String, dynamic> soal) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToDetail(context, soal),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF664f9f),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: const Icon(
          Icons.visibility_outlined,
          color: Colors.white,
          size: 18,
        ),
        label: const Text(
          "Lihat Detail Soal",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'mudah':
        return Colors.green;
      case 'sedang':
        return Colors.orange;
      case 'sulit':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> soal) {
    // TODO: Navigate to detail soal user page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detail soal: ${soal['title']}'),
        backgroundColor: const Color(0xFF664f9f),
      ),
    );
  }
}