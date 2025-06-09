import 'package:flutter/material.dart';
import 'package:haloo/models/soal_model.dart';
import 'package:haloo/pages/materi/detail_user.dart';
import 'package:haloo/pages/soal/detail_soal.dart';
import 'package:haloo/widget/sidebar_user.dart';

class SoalUser extends StatelessWidget {
  SoalUser({super.key});

  // Sample data dengan SoalModel yang sesuai
  List<SoalModel> get soalList => [
    SoalModel(
      id: "1",
      title: "Sample komprehensional",
      description: "Soal latihan untuk mengukur kemampuan pemahaman komprehensif tentang berpikir komputasional dan sistem komputer.",
      category: "Berpikir Komputasional",
      date: "2025-06-08",
      icon: Icons.assignment,
      iconColor: Colors.white,
      backgroundColor: Colors.purple.shade300,
      questionData: {
        'jumlahSoal': 10,
        'durasi': '15 menit',
        'tingkatKesulitan': 'Mudah',
        'waktuPengerjaan': 900,
        'passingScore': 70,
      },
    ),
    SoalModel(
      id: "2",
      title: "Algoritma dan Struktur Data",
      description: "Ujian komprehensif tentang algoritma sorting, searching, dan struktur data dasar seperti array, linked list, dan tree.",
      category: "Algoritma",
      date: "2025-06-07",
      icon: Icons.memory,
      iconColor: Colors.white,
      backgroundColor: Colors.blue.shade300,
      questionData: {
        'jumlahSoal': 15,
        'durasi': '25 menit',
        'tingkatKesulitan': 'Sedang',
        'waktuPengerjaan': 1500,
        'passingScore': 75,
      },
    ),
    SoalModel(
      id: "3",
      title: "Database Management",
      description: "Soal advanced tentang normalisasi database, query optimization, dan database design patterns.",
      category: "Database",
      date: "2025-06-06",
      icon: Icons.storage,
      iconColor: Colors.white,
      backgroundColor: Colors.orange.shade300,
      questionData: {
        'jumlahSoal': 20,
        'durasi': '30 menit',
        'tingkatKesulitan': 'Sulit',
        'waktuPengerjaan': 1800,
        'passingScore': 80,
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: SidebarUser(),
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
    );
  }

  Widget _buildBody(BuildContext context) {
    if (soalList.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: soalList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildSoalCard(context, soalList[index]),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada soal tersedia',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Soal akan ditambahkan segera',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoalCard(BuildContext context, SoalModel soal) {
    final Map<String, dynamic> questionData = soal.questionData ?? <String, dynamic>{};

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
            _buildCardHeader(soal, questionData),
            const SizedBox(height: 12),
            _buildDescription(soal),
            const SizedBox(height: 12),
            _buildSoalInfo(questionData),
            const SizedBox(height: 8),
            _buildDate(soal),
            const SizedBox(height: 16),
            _buildActionButton(context, soal),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(SoalModel soal, Map<String, dynamic> questionData) {
    return Row(
      children: [
        _buildIconContainer(soal),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                soal.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              _buildBadges(soal, questionData),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconContainer(SoalModel soal) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: soal.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        soal.icon,
        color: soal.iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildBadges(SoalModel soal, Map<String, dynamic> questionData) {
    return Row(
      children: [
        _buildCategoryBadge(soal),
        const SizedBox(width: 8),
        if (questionData['tingkatKesulitan'] != null)
          _buildDifficultyBadge(questionData['tingkatKesulitan'].toString()),
      ],
    );
  }

  Widget _buildCategoryBadge(SoalModel soal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: soal.backgroundColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        soal.category,
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

  Widget _buildDescription(SoalModel soal) {
    return Text(
      soal.description,
      style: TextStyle(
        fontSize: 14, 
        color: Colors.grey[800],
        height: 1.4,
      ),
    );
  }

  Widget _buildSoalInfo(Map<String, dynamic> questionData) {
    return Row(
      children: [
        _buildInfoItem(
          Icons.assignment_outlined,
          '${questionData['jumlahSoal']?.toString() ?? '0'} Soal',
        ),
        const SizedBox(width: 16),
        _buildInfoItem(
          Icons.timer_outlined,
          questionData['durasi']?.toString() ?? 'N/A',
        ),
        const SizedBox(width: 16),
        _buildInfoItem(
          Icons.grade_outlined,
          'Min ${questionData['passingScore']?.toString() ?? '0'}%',
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

  Widget _buildDate(SoalModel soal) {
    return Text(
      soal.date,
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  Widget _buildActionButton(BuildContext context, SoalModel soal) {
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

  void _navigateToDetail(BuildContext context, SoalModel soal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailUser(soal: soal),
      ),
    );
  }
}