// File: lib/pages/soal/detail_soal.dart - Improved Detail View
import 'package:flutter/material.dart';
import 'package:haloo/services/api_services.dart';

class DetailSoalPage extends StatefulWidget {
  final Map<String, dynamic> soal;

  const DetailSoalPage({
    super.key,
    required this.soal,
  });

  @override
  State<DetailSoalPage> createState() => _DetailSoalPageState();
}

class _DetailSoalPageState extends State<DetailSoalPage> {
  Map<String, dynamic>? soalDetail;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSoalDetail();
  }

  Future<void> _loadSoalDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getSoalById(widget.soal['id']);
      if (response.success && response.data != null) {
        setState(() {
          soalDetail = response.data['data'] ?? response.data;
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
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getAnswerColor(String? answer) {
    switch (answer) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showImageDialog(BuildContext context) {
    if (soalDetail?['gambar'] == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Header dialog
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          soalDetail?['judul'] ?? 'Preview Gambar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                // Gambar besar
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        soalDetail!['gambar'],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultImage();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[300]!,
            Colors.blue[400]!,
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 8),
            Text(
              'Tidak ada gambar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpsiJawaban(String opsi, String? jawaban, String? jawabanBenar) {
    if (jawaban == null || jawaban.isEmpty) return const SizedBox();
    
    final bool isCorrect = opsi == jawabanBenar;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green[300]! : Colors.grey[300]!,
          width: isCorrect ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 16, top: 2),
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green[600] : _getAnswerColor(opsi).withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                opsi,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jawaban,
                  style: TextStyle(
                    fontSize: 15,
                    color: isCorrect ? Colors.green[800] : Colors.black87,
                    fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                    height: 1.4,
                  ),
                ),
                if (isCorrect) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Jawaban Benar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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
          'Detail Soal',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          if (!isLoading && soalDetail != null) ...[
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _loadSoalDetail,
              tooltip: 'Refresh',
            ),
          ],
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
              'Memuat detail soal...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat detail',
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
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSoalDetail,
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

    if (soalDetail == null) {
      return const Center(
        child: Text(
          'Detail soal tidak ditemukan',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan gambar dan kategori
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container untuk gambar dengan GestureDetector
                      GestureDetector(
                        onTap: () => _showImageDialog(context),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Jika ada gambar custom
                              if (soalDetail!['gambar'] != null && soalDetail!['gambar'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    soalDetail!['gambar'],
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultImage();
                                    },
                                  ),
                                )
                              else
                                // Ilustrasi default
                                _buildDefaultImage(),
                              
                              // Icon untuk menunjukkan gambar bisa diklik
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.zoom_in,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Judul dan kategori
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              soalDetail!['judul'] ?? 'Soal Tanpa Judul',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getAnswerColor(soalDetail!['jawaban_benar']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Jawaban Benar: ${soalDetail!['jawaban_benar'] ?? 'A'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _getAnswerColor(soalDetail!['jawaban_benar']),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Media indicators
                            Row(
                              children: [
                                if (soalDetail!['gambar'] != null && soalDetail!['gambar'].toString().isNotEmpty) ...[
                                  Icon(Icons.image, size: 16, color: Colors.blue[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Gambar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                if (soalDetail!['video'] != null && soalDetail!['video'].toString().isNotEmpty) ...[
                                  Icon(Icons.video_library, size: 16, color: Colors.purple[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Video',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pertanyaan
                  const Text(
                    'Pertanyaan:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Text(
                      soalDetail!['pertanyaan'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pilihan Jawaban
                  const Text(
                    'Pilihan Jawaban:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildOpsiJawaban('A', soalDetail!['pilihan_a'], soalDetail!['jawaban_benar']),
                  _buildOpsiJawaban('B', soalDetail!['pilihan_b'], soalDetail!['jawaban_benar']),
                  _buildOpsiJawaban('C', soalDetail!['pilihan_c'], soalDetail!['jawaban_benar']),
                  _buildOpsiJawaban('D', soalDetail!['pilihan_d'], soalDetail!['jawaban_benar']),
                  
                  const SizedBox(height: 20),
                  
                  // Info tambahan
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Info grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                Icons.calendar_today,
                                'Dibuat',
                                _formatDate(soalDetail!['created_at']),
                                Colors.blue,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                Icons.update,
                                'Diperbarui',
                                _formatDate(soalDetail!['updated_at']),
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        if (soalDetail!['admin'] != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  Icons.person,
                                  'Admin',
                                  soalDetail!['admin']['nama_lengkap'] ?? 
                                  soalDetail!['admin']['username'] ?? 
                                  'Unknown',
                                  Colors.purple,
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  Icons.quiz,
                                  'ID Soal',
                                  '#${soalDetail!['id']}',
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}