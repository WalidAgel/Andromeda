// File: pages/materi_page.dart
import 'package:flutter/material.dart';
import 'package:haloo/pages/materi/form_materi.dart';
import 'package:haloo/pages/materi/detail_materi.dart';
import 'package:haloo/widget/sidebar.dart';
import 'package:haloo/services/api_services.dart';
import 'package:haloo/widget/materi_card.dart';

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  List<dynamic> materiList = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchMateri();
  }

  Future<void> fetchMateri() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final response = await ApiService.getMateri();
      if (response.success && response.data != null) {
        setState(() {
          materiList = response.data['data'] ?? [];
        });
      } else {
        setState(() {
          errorMsg = response.message;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Contoh hapus materi via API (jika endpoint tersedia)
  Future<void> _deleteMateri(dynamic materi) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Materi'),
        content:
            Text('Yakin ingin menghapus materi "${materi['title'] ?? ''}"?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // Contoh: jika ada endpoint deleteMateri
      // await ApiService.deleteMateri(materi['id']);
      setState(() {
        materiList.removeWhere((item) => item['id'] == materi['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Materi berhasil dihapus!')),
      );
    }
  }

  // Navigasi ke detail materi (jika ingin)
  void _viewDetail(BuildContext context, dynamic materi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailMateriPage(materiId: materi['id']),
      ),
    );
  }

  // Navigasi ke tambah materi (jika ingin)
  void _navigateToAddMateri(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahMateriPage(),
      ),
    );
    if (result != null) {
      fetchMateri(); // Refresh dari API setelah tambah
    }
  }

  // Navigasi ke edit materi (jika ingin)
  void _editMateri(BuildContext context, dynamic materi) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahMateriPage(
          isEdit: true,
          existingMateri: materi,
        ),
      ),
    );
    if (result != null) {
      fetchMateri(); // Refresh dari API setelah edit
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Materi',
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
            onPressed: () => _navigateToAddMateri(context),
          ),
        ],
      ),
      drawer: const Sidebar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
              ? Center(child: Text(errorMsg!))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: materiList.length,
                  itemBuilder: (context, index) {
                    final materi = materiList[index];
                    return MateriCard(
                      materi: materi, // materi adalah Map<String, dynamic>
                      onTap: () => _viewDetail(context, materi),
                      onEdit: () => _editMateri(context, materi),
                      onDelete: () => _deleteMateri(materi),
                    );
                  },
                ),
    );
  }
}
