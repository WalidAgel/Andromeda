// File: lib/pages/kuis/detail_kuis_user.dart
import 'package:flutter/material.dart';
import 'package:haloo/services/api_services.dart';
import 'package:haloo/pages/kuis/mengerjakan_kuis.dart';

class DetailKuisUser extends StatefulWidget {
  final Map<String, dynamic> kuisData;

  const DetailKuisUser({super.key, required this.kuisData});

  @override
  State<DetailKuisUser> createState() => _DetailKuisUserState();
}

class _DetailKuisUserState extends State<DetailKuisUser> {
  Map<String, dynamic>? detailKuis;
  bool isLoading = true;
  bool hasStarted = false;

  @override
  void initState() {
    super.initState();
    _loadDetailKuis();
  }

  Future<void> _loadDetailKuis() async {
    setState(() => isLoading = true);
    
    try {
      final response = await ApiService.getKuisById(widget.kuisData['id']);
      if (response.success && response.data != null) {
        setState(() {
          detailKuis = response.data['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showMessage(response.message, isError: true);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage('Error: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
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

  bool _isExpired() {
    if (detailKuis?['deadline'] == null) return false;
    
    try {
      final deadline = DateTime.parse(detailKuis!['deadline']);
      return DateTime.now().isAfter(deadline);
    } catch (e) {
      return false;
    }
  }

  int _getJumlahSoal() {
    if (detailKuis?['soal'] != null && detailKuis!['soal'] is List) {
      return (detailKuis!['soal'] as List).length;
    }
    return 0;
  }

  Future<void> _mulaiKuis() async {
    if (_isExpired()) {
      _showMessage('Kuis sudah melewati deadline', isError: true);
      return;
    }

    if (_getJumlahSoal() == 0) {
      _showMessage('Kuis belum memiliki soal', isError: true);
      return;
    }

    // Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mulai Kuis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Anda akan memulai kuis: ${detailKuis!['nama_kuis']}'),
            const SizedBox(height: 8),
            Text('Jumlah soal: ${_getJumlahSoal()}'),
            if (detailKuis!['durasi_menit'] != null)
              Text('Durasi: ${detailKuis!['durasi_menit']} menit'),
            const SizedBox(height: 8),
            const Text(
              'Pastikan koneksi internet stabil. Kuis tidak dapat diulang setelah dimulai.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF664f9f),
            ),
            child: const Text('Mulai', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Navigasi ke halaman mengerjakan kuis
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MengerjakanKuisPage(kuisData: detailKuis!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Kuis',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : detailKuis == null
              ? const Center(child: Text('Kuis tidak ditemukan'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              detailKuis!['nama_kuis'] ?? 'Kuis Tanpa Nama',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Description
                            if (detailKuis!['deskripsi'] != null) ...[
                              Text(
                                detailKuis!['deskripsi'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Quiz Info
                            _buildInfoCard(),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Soal Preview Section
                      if (_getJumlahSoal() > 0) ...[
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Preview Soal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Show first 3 questions as preview
                              ..._buildSoalPreview(),
                              
                              if (_getJumlahSoal() > 3) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(top: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Dan ${_getJumlahSoal() - 3} soal lainnya...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                      
                      // Start Quiz Button
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (_isExpired()) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.schedule, color: Colors.red[600]),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Kuis telah melewati deadline',
                                        style: TextStyle(
                                          color: Colors.red[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (_getJumlahSoal() == 0) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.orange[600]),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Kuis belum memiliki soal',
                                        style: TextStyle(
                                          color: Colors.orange[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _mulaiKuis,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF664f9f),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.play_arrow, size: 24),
                                      SizedBox(width: 8),
                                      Text(
                                        'Mulai Kuis',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF664f9f).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF664f9f).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.quiz,
            'Jumlah Soal',
            '${_getJumlahSoal()} soal',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.schedule,
            'Durasi',
            detailKuis!['durasi_menit'] != null 
                ? '${detailKuis!['durasi_menit']} menit'
                : 'Tidak terbatas',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Deadline',
            _formatDate(detailKuis!['deadline']),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.info_outline,
            'Status',
            detailKuis!['status'] ?? 'draft',
            statusColor: _getStatusColor(detailKuis!['status']),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? statusColor}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF664f9f),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: statusColor ?? Colors.black87,
          ),
        ),
      ],
    );
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
        return Colors.black87;
    }
  }

  List<Widget> _buildSoalPreview() {
    final soalList = detailKuis!['soal'] as List? ?? [];
    final previewCount = soalList.length > 3 ? 3 : soalList.length;
    
    return List.generate(previewCount, (index) {
      final soal = soalList[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soal ${index + 1}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF664f9f),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              soal['pertanyaan'] ?? soal['judul'] ?? 'Pertanyaan tidak tersedia',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            if (soal['pilihan_a'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'A. ${soal['pilihan_a']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'B. ${soal['pilihan_b'] ?? '...'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'C. ${soal['pilihan_c'] ?? '...'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'D. ${soal['pilihan_d'] ?? '...'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}