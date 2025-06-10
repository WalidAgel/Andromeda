// File: lib/pages/kuis_page.dart - Improved CRUD Operations
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
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    fetchKuisList();
  }

  Future<void> fetchKuisList() async {
    if (!isRefreshing) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final response = await ApiService.getKuis();
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        setState(() {
          kuisList = data.cast<Map<String, dynamic>>();
          isLoading = false;
          isRefreshing = false;
        });
      } else {
        setState(() {
          errorMessage = response.message;
          isLoading = false;
          isRefreshing = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
        isRefreshing = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isRefreshing = true;
    });
    await fetchKuisList();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Processing...'),
          ],
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manajemen Kuis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isRefreshing ? Icons.hourglass_empty : Icons.refresh,
              color: isRefreshing ? Colors.grey : Colors.black,
            ),
            onPressed: isRefreshing ? null : _refreshData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddKuis(context),
            tooltip: 'Tambah Kuis',
          ),
        ],
      ),
      drawer: const Sidebar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddKuis(context),
        backgroundColor: const Color(0xFF664f9f),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
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
              'Mulai dengan membuat kuis pertama Anda',
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF664f9f),
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

    if (result == true) {
      await fetchKuisList();
    }
  }

  // Metode untuk navigasi ke form edit kuis
  void _navigateToEditKuis(BuildContext context, Map<String, dynamic> kuis) async {
    // Load detail kuis terlebih dahulu untuk mendapatkan data lengkap
    _showLoadingDialog();
    
    try {
      final response = await ApiService.getKuisById(kuis['id']);
      _hideLoadingDialog();
      
      if (response.success && response.data != null) {
        final detailKuis = response.data['data'];
        
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TambahKuisPage(
              isEdit: true,
              existingKuis: detailKuis,
            ),
          ),
        );

        if (result == true) {
          await fetchKuisList();
        }
      } else {
        _showMessage('Gagal memuat detail kuis: ${response.message}', isError: true);
      }
    } catch (e) {
      _hideLoadingDialog();
      _showMessage('Error: $e', isError: true);
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
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus Kuis'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apakah Anda yakin ingin menghapus kuis ini?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Kuis:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      kuis['nama_kuis'] ?? 'Tanpa Nama',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jumlah Soal: ${_getJumlahSoal(kuis)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tindakan ini tidak dapat dibatalkan!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  int _getJumlahSoal(Map<String, dynamic> kuis) {
    if (kuis['soal'] != null && kuis['soal'] is List) {
      return (kuis['soal'] as List).length;
    }
    return 0;
  }

  Future<void> _deleteKuisFromApi(Map<String, dynamic> kuis) async {
    _showLoadingDialog();

    try {
      final response = await ApiService.hapusKuis(int.parse(kuis['id'].toString()));
      _hideLoadingDialog();

      if (response.success) {
        await fetchKuisList();
        
        if (mounted) {
          _showMessage('Kuis "${kuis['nama_kuis'] ?? 'Tanpa Nama'}" berhasil dihapus!');
        }
      } else {
        if (mounted) {
          _showMessage('Gagal menghapus kuis: ${response.message}', isError: true);
        }
      }
    } catch (e) {
      _hideLoadingDialog();
      
      if (mounted) {
        _showMessage('Error: $e', isError: true);
      }
    }
  }

  // Method untuk menampilkan statistik kuis (opsional)
  Widget _buildKuisStats() {
    final totalKuis = kuisList.length;
    final publishedKuis = kuisList.where((k) => k['status'] == 'published').length;
    final draftKuis = kuisList.where((k) => k['status'] == 'draft').length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('Total', totalKuis.toString(), Colors.blue),
          _buildStatItem('Published', publishedKuis.toString(), Colors.green),
          _buildStatItem('Draft', draftKuis.toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}