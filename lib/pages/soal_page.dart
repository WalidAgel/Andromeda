import 'package:flutter/material.dart';
import 'package:haloo/pages/soal/detail_soal.dart';
import 'package:haloo/pages/soal/form_soal.dart';
import '../models/soal_model.dart';
import '../widget/soal_card.dart';
import '../widget/sidebar.dart';

class SoalPage extends StatefulWidget {
  const SoalPage({super.key});

  @override
  _SoalPageState createState() => _SoalPageState();
}

class _SoalPageState extends State<SoalPage> {
  List<SoalModel> soalList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Soal Admin', 
          style: TextStyle(fontWeight: FontWeight.bold)
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
            onPressed: () => _navigateToAddSoal(context),
          ),
        ],
      ),
      drawer: const Sidebar(),
      body: soalList.isEmpty 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Belum ada soal',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap tombol + untuk menambah soal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: soalList.length,
            itemBuilder: (context, index) {
              return SoalCard(
                soal: soalList[index],
                onEdit: () => _editSoal(context, soalList[index]),
                onDelete: () => _deleteSoal(context, soalList[index]),
                onDetail: () => _viewDetail(context, soalList[index]),
              );
            },
          ),
    );
  }

  // Metode untuk navigasi ke halaman detail soal
  void _viewDetail(BuildContext context, SoalModel soal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailSoalPage(soal: soal.questionData ?? {}),
      ),
    );

    // Handle actions from detail page
    if (result == 'edit') {
      _editSoal(context, soal);
    } else if (result == 'delete') {
      _deleteSoalFromDetail(soal);
    }
  }

  // Metode untuk navigasi ke form tambah soal
  void _navigateToAddSoal(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahSoalPage(),
      ),
    );

    // Jika ada data yang dikembalikan dari form
    if (result != null && result is Map<String, dynamic>) {
      _addNewSoal(result);
    }
  }

  // Metode untuk menambah soal baru ke list
  void _addNewSoal(Map<String, dynamic> soalData) {
    if (!mounted) return;
    
    setState(() {
      soalList.add(
        SoalModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: soalData['judul'] ?? 'Soal Baru',
          description: soalData['deskripsi'] ?? '',
          category: soalData['kategori'] ?? 'Umum',
          date: DateTime.now().toString().split(' ')[0],
          icon: Icons.quiz,
          iconColor: Colors.blue,
          backgroundColor: Colors.blue.shade100,
          // Store additional question data
          questionData: soalData,
        ),
      );
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soal berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Metode untuk navigasi ke form edit soal
  void _navigateToEditSoal(BuildContext context, SoalModel soal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahSoalPage(
          isEdit: true,
          existingSoal: soal.questionData, // Pass the complete question data
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      _updateSoal(soal.id, result);
    }
  }

  // Metode untuk update soal
  void _updateSoal(String id, Map<String, dynamic> updatedData) {
    if (!mounted) return;
    
    setState(() {
      final index = soalList.indexWhere((soal) => soal.id == id);
      if (index != -1) {
        soalList[index] = SoalModel(
          id: id,
          title: updatedData['judul'] ?? soalList[index].title,
          description: updatedData['deskripsi'] ?? soalList[index].description,
          category: updatedData['kategori'] ?? soalList[index].category,
          date: soalList[index].date,
          icon: soalList[index].icon,
          iconColor: soalList[index].iconColor,
          backgroundColor: soalList[index].backgroundColor,
          questionData: updatedData, // Store updated question data
        );
      }
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soal berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _editSoal(BuildContext context, SoalModel soal) {
    _navigateToEditSoal(context, soal);
  }

  // Method untuk hapus dari detail page
  void _deleteSoalFromDetail(SoalModel soal) {
    if (!mounted) return;
    
    setState(() {
      soalList.removeWhere((item) => item.id == soal.id);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soal berhasil dihapus!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteSoal(BuildContext context, SoalModel soal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Soal'),
          content: Text('Apakah Anda yakin ingin menghapus soal "${soal.title}"?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    soalList.removeWhere((item) => item.id == soal.id);
                  });
                }
                Navigator.of(context).pop();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Soal berhasil dihapus!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}