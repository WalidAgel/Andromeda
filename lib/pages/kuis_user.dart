// File: lib/pages/kuis_user.dart (Updated)
import 'package:flutter/material.dart';
import 'package:haloo/services/api_services.dart';
import 'package:haloo/pages/kuis/detail_kuis_user.dart';

class KuisUser extends StatefulWidget {
  const KuisUser({super.key});

  @override
  State<KuisUser> createState() => _KuisUserState();
}

class _KuisUserState extends State<KuisUser> {
  List<Map<String, dynamic>> kuisList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadKuis();
  }

  Future<void> _loadKuis() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getKuisUser();
      if (response.success && response.data != null) {
        setState(() {
          kuisList = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Tidak ada deadline';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  bool _isExpired(String? deadline) {
    if (deadline == null || deadline.isEmpty) return false;
    
    try {
      final deadlineDate = DateTime.parse(deadline);
      return DateTime.now().isAfter(deadlineDate);
    } catch (e) {
      return false;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'published':
        return 'Tersedia';
      case 'draft':
        return 'Draft';
      case 'closed':
        return 'Ditutup';
      default:
        return 'Tidak diketahui';
    }
  }

  int _getJumlahSoal(Map<String, dynamic> kuis) {
    if (kuis['soal'] != null && kuis['soal'] is List) {
      return (kuis['soal'] as List).length;
    }
    return 0;
  }

  void _viewDetailKuis(Map<String, dynamic> kuis) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailKuisUser(kuisData: kuis),
      ),
    );
  }

  Future<void> _refreshKuis() async {
    await _loadKuis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Kuis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshKuis,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
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
              'Memuat daftar kuis...',
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
              onPressed: _refreshKuis,
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
              'Belum ada kuis tersedia',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kuis akan muncul di sini setelah dipublikasikan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshKuis,
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
      onRefresh: _refreshKuis,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kuisList.length,
        itemBuilder: (context, index) {
          final kuis = kuisList[index];
          final isExpired = _isExpired(kuis['deadline']);
          final jumlahSoal = _getJumlahSoal(kuis);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _viewDetailKuis(kuis),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with status badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            kuis['nama_kuis'] ?? 'Kuis Tanpa Nama',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(kuis['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getStatusColor(kuis['status']).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _getStatusText(kuis['status']),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(kuis['status']),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Description
                    if (kuis['deskripsi'] != null && kuis['deskripsi'].toString().isNotEmpty) ...[
                      Text(
                        kuis['deskripsi'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Quiz info
                    Row(
                      children: [
                        Icon(
                          Icons.quiz,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$jumlahSoal soal',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          kuis['durasi_menit'] != null 
                            ? '${kuis['durasi_menit']} menit'
                            : 'Tanpa batas',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Deadline info
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: isExpired ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Deadline: ${_formatDate(kuis['deadline'])}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isExpired ? Colors.red : Colors.grey[600],
                            fontWeight: isExpired ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                        if (isExpired) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Text(
                              'EXPIRED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[600],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (kuis['status'] == 'published' && !isExpired && jumlahSoal > 0)
                          ? () => _viewDetailKuis(kuis)
                          : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF664f9f),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isExpired 
                                ? Icons.lock_outline
                                : jumlahSoal == 0
                                  ? Icons.warning_outlined
                                  : Icons.play_arrow,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isExpired 
                                ? 'Kuis Berakhir'
                                : jumlahSoal == 0
                                  ? 'Belum Ada Soal'
                                  : kuis['status'] != 'published'
                                    ? 'Belum Tersedia'
                                    : 'Lihat Detail',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}