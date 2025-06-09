// File: pages/kuis_page.dart
import 'package:flutter/material.dart';
import 'package:haloo/pages/kuis/form_kuis.dart';
import 'package:haloo/pages/kuis/detail_kuis.dart';
import 'package:haloo/widget/kuis_card.dart';
import 'package:haloo/widget/sidebar.dart';
import 'package:haloo/services/api_services.dart';

class KuisPage extends StatefulWidget {
  const KuisPage({super.key});

  @override
  State<KuisPage> createState() => _KuisPageState();
}

class _KuisPageState extends State<KuisPage> {
  List<Map<String, dynamic>> kuisList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchKuisList();
  }

  Future<void> fetchKuisList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getKuis();
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        setState(() {
          kuisList = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.message;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await fetchKuisList();
  }

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
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddKuis(context),
          ),
        ],
      ),
      drawer: const Sidebar(),
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
              'Memuat data kuis...',
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
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF664f9f),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (kuisList.isEmpty) {
      return Center(
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddKuis(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Kuis'),
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
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kuisList.length,
        itemBuilder: (context, index) {
          final kuis = kuisList[index];
          return KuisCard(
            kuis: kuis,
            onEdit: () => _editKuis(context, kuis),
            onDelete: () => _deleteKuis(context, kuis),
            onDetail: () => _viewDetail(context, kuis),
          );
        },
      ),
    );
  }

  // Metode untuk navigasi ke halaman detail kuis
  void _viewDetail(BuildContext context, Map<String, dynamic> kuis) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailKuisPage(kuisData: kuis),
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

    if (result != null) {
      _addNewKuis(result);
    }
  }

  // Metode untuk menambah kuis baru via API
  void _addNewKuis(Map<String, dynamic> kuisData) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await ApiService.tambahKuis(kuisData);
      
      Navigator.pop(context); // Close loading

      if (response.success) {
        await fetchKuisList();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kuis berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambah kuis: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Metode untuk navigasi ke form edit kuis
  void _navigateToEditKuis(BuildContext context, Map<String, dynamic> kuis) async {
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
      _updateKuis(kuis['id'], result);
    }
  }

  // Metode untuk update kuis via API
  void _updateKuis(dynamic id, Map<String, dynamic> updatedData) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await ApiService.updateKuis(int.parse(id.toString()), updatedData);
      
      Navigator.pop(context);

      if (response.success) {
        await fetchKuisList();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kuis berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui kuis: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editKuis(BuildContext context, Map<String, dynamic> kuis) {
    _navigateToEditKuis(context, kuis);
  }

  void _deleteKuis(BuildContext context, Map<String, dynamic> kuis) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Kuis'),
          content: Text('Apakah Anda yakin ingin menghapus kuis "${kuis['nama_kuis'] ?? 'Tanpa Nama'}"?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteKuisFromApi(kuis);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteKuisFromApi(Map<String, dynamic> kuis) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await ApiService.hapusKuis(int.parse(kuis['id'].toString()));
      
      Navigator.pop(context);

      if (response.success) {
        await fetchKuisList();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kuis "${kuis['nama_kuis'] ?? 'Tanpa Nama'}" berhasil dihapus!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus kuis: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}