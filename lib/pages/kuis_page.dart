// File: pages/kuis_page.dart
import 'package:flutter/material.dart';
import 'package:haloo/pages/kuis/form_kuis.dart';
import 'package:haloo/pages/kuis/detail_kuis.dart';
import 'package:haloo/widget/kuis_card.dart';
import 'package:haloo/widget/sidebar.dart';
import '../models/kuis_model.dart';

class KuisPage extends StatefulWidget {
  const KuisPage({super.key});

  @override
  State<KuisPage> createState() => _KuisPageState();
}

class _KuisPageState extends State<KuisPage> {
  List<KuisModel> kuisList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kuis Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddKuis(context),
          ),
        ],
      ),
      drawer: const Sidebar(),
      body: kuisList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada kuis',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk menambah kuis',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kuisList.length,
              itemBuilder: (context, index) {
                return KuisCard(
                  kuis: kuisList[index],
                  onEdit: () => _editKuis(context, kuisList[index]),
                  onDelete: () => _deleteKuis(context, kuisList[index]),
                  onDetail: () => _viewDetail(context, kuisList[index]),
                );
              },
            ),
    );
  }

  // Metode untuk navigasi ke halaman detail kuis
  void _viewDetail(BuildContext context, KuisModel kuis) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailKuisPage(kuis: kuis),
      ),
    );
  }

  // Metode untuk navigasi ke form tambah kuis
  void _navigateToAddKuis(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahKuisPage(),
      ),
    );

    // Jika ada data yang dikembalikan dari form
    if (result != null) {
      _addNewKuis(result);
    }
  }

  // Metode untuk menambah kuis baru ke list
  void _addNewKuis(Map<String, dynamic> kuisData) {
    setState(() {
      kuisList.add(
        KuisModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: kuisData['judul'],
          jumlahSoal: 0, // Default 0 karena baru dibuat
          tanggalDeadline: kuisData['tanggalDeadline'], // Menggunakan format yang benar
          createdAt: DateTime.now().toString().split(' ')[0],
          icon: Icons.quiz,
          iconColor: Colors.purple,
          backgroundColor: Colors.purple[100],
        ),
      );
    });
  }

  // Metode untuk navigasi ke form edit kuis
  void _navigateToEditKuis(BuildContext context, KuisModel kuis) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahKuisPage(
          isEdit: true,
          existingKuis: kuis,
        ),
      ),
    );

    if (result != null) {
      _updateKuis(kuis.id, result);
    }
  }

  // Metode untuk update kuis
  void _updateKuis(String id, Map<String, dynamic> updatedData) {
    setState(() {
      final index = kuisList.indexWhere((kuis) => kuis.id == id);
      if (index != -1) {
        kuisList[index] = KuisModel(
          id: id,
          title: updatedData['judul'],
          jumlahSoal: kuisList[index].jumlahSoal, // Tetap gunakan jumlah soal yang ada
          tanggalDeadline: updatedData['tanggalDeadline'],
          createdAt: kuisList[index].createdAt,
          icon: kuisList[index].icon,
          iconColor: kuisList[index].iconColor,
          backgroundColor: kuisList[index].backgroundColor,
        );
      }
    });
  }

  void _editKuis(BuildContext context, KuisModel kuis) {
    _navigateToEditKuis(context, kuis);
  }

  void _deleteKuis(BuildContext context, KuisModel kuis) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Kuis'),
          content: Text('Apakah Anda yakin ingin menghapus kuis "${kuis.title}"?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () {
                setState(() {
                  kuisList.removeWhere((item) => item.id == kuis.id);
                });
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kuis "${kuis.title}" berhasil dihapus!')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}