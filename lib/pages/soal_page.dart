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
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSoalList();
  }

  Future<void> fetchSoalList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getSoal();
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        setState(() {
          soalList = data.cast<Map<String, dynamic>>();
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
    await fetchSoalList();
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
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddSoal(context),
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
            CircularProgressIndicator(),
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
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (soalList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada soal',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap tombol + untuk menambah soal',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddSoal(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Soal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
    } else if (result == 'refresh') {
      _refreshData();
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
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await ApiService.addSoal(soalData);
      
      Navigator.pop(context); // Close loading

      if (response.success) {
        await fetchSoalList();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Soal berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambah soal: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      
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

  void _navigateToEditSoal(BuildContext context, Map<String, dynamic> soal) async {
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
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await ApiService.updateSoal(id, updatedData);
      
      Navigator.pop(context); // Close loading

      if (response.success) {
        await fetchSoalList();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Soal berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui soal: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      
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

  void _editSoal(BuildContext context, Map<String, dynamic> soal) {
    _navigateToEditSoal(context, soal);
  }

  void _deleteSoalFromDetail(Map<String, dynamic> soal) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await ApiService.deleteSoal(soal['id'].toString());
      
      Navigator.pop(context); // Close loading

      if (response.success) {
        await fetchSoalList();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Soal berhasil dihapus!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus soal: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      
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
                Navigator.of(dialogContext).pop();
                _deleteSoalFromDetail(soal);
              },
            ),
          ],
        );
      },
    );
  }
}