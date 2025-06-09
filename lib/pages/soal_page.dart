import 'package:flutter/material.dart';
import 'package:haloo/pages/soal/detail_soal.dart';
import 'package:haloo/pages/soal/form_soal.dart';
import 'package:haloo/services/api_services.dart';
import '../widget/soal_card.dart';
import '../widget/sidebar.dart';

class SoalPage extends StatefulWidget {
  const SoalPage({super.key});

  @override
  SoalPageState createState() => SoalPageState();
}

class SoalPageState extends State<SoalPage> {
  List<Map<String, dynamic>> soalList = [];

  @override
  void initState() {
    super.initState();
    fetchSoalList();
  }

  Future<void> fetchSoalList() async {
    final data = await ApiService.getSoalList();
    if (mounted) {
      setState(() {
        soalList = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soal Admin',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                  Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada soal',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk menambah soal',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: soalList.length,
              itemBuilder: (context, index) {
                final soal = soalList[index];
                return SoalCard(
                  idSoal: soal['id'],
                  data: soal,
                  onEdit: () => _navigateToEditSoal(context, soal),
                  onDelete: () => _deleteSoal(context, soal),
                  onDetail: () => _viewDetail(context, soal),
                );
              },
            ),
    );
  }

  void _viewDetail(BuildContext context, Map<String, dynamic> soal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailSoalPage(soal: soal),
      ),
    );

    if (result == 'edit') {
      if (!mounted) return;
      _editSoal(context, soal);
    } else if (result == 'delete') {
      _deleteSoalFromDetail(soal);
    }
  }

  void _navigateToAddSoal(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahSoalPage(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      _addNewSoal(result);
    }
  }

  void _addNewSoal(Map<String, dynamic> soalData) async {
    await ApiService.addSoal(soalData);
    await fetchSoalList();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Soal berhasil ditambahkan!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToEditSoal(
      BuildContext context, Map<String, dynamic> soal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahSoalPage(
          isEdit: true,
          existingSoal: soal,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      _updateSoal(soal['id'].toString(), result);
    }
  }

  void _updateSoal(String id, Map<String, dynamic> updatedData) async {
    await ApiService.updateSoal(id, updatedData);
    await fetchSoalList();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Soal berhasil diperbarui!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editSoal(BuildContext context, Map<String, dynamic> soal) {
    _navigateToEditSoal(context, soal);
  }

  void _deleteSoalFromDetail(Map<String, dynamic> soal) async {
    await ApiService.deleteSoal(soal['id'].toString());
    await fetchSoalList();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Soal berhasil dihapus!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _deleteSoal(BuildContext context, Map<String, dynamic> soal) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Soal'),
          content: Text(
              'Apakah Anda yakin ingin menghapus soal "${soal['judul'] ?? soal['title'] ?? ''}"?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
              onPressed: () async {
                await ApiService.deleteSoal(soal['id'].toString());
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                  await fetchSoalList();
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
