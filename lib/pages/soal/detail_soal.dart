import 'package:flutter/material.dart';
import 'dart:io';

class DetailSoalPage extends StatelessWidget {
  final Map<String, dynamic> soal;
  
  const DetailSoalPage({
    super.key,
    required this.soal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card utama dengan konten soal
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar dan judul
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
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.orange[300]!,
                                  Colors.orange[400]!,
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Jika ada gambar custom
                                if (soal['imagePath'] != null && soal['imagePath'].isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(soal['imagePath']),
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                    ),
                                  )
                                else
                                  // Ilustrasi default yang sama seperti sebelumnya (versi kecil)
                                  _buildDefaultIllustration(true),
                                
                                // Icon untuk menunjukkan gambar bisa diklik
                                Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.zoom_in,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Kategori sebagai "judul"
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                soal['kategori'] ?? 'Komputer Komprehensif',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Jenis Kuis',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    const SizedBox(height: 8),
                    Text(
                      soal['pertanyaan'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    if (soal['opsiA'] != null) ...[
                      _buildOpsiJawaban('A', soal['opsiA']),
                      _buildOpsiJawaban('B', soal['opsiB']),
                      _buildOpsiJawaban('C', soal['opsiC']),
                      _buildOpsiJawaban('D', soal['opsiD']),
                    ],
                  
                    const SizedBox(height: 24),
                    
                    // Tanggal pembuatan
                    Text(
                      'Created At: ${_formatDate(DateTime.now())}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOpsiJawaban(String opsi, String? jawaban) {
    if (jawaban == null || jawaban.isEmpty) return const SizedBox();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'Opsi $opsi: $jawaban',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }
  
  Widget _buildDefaultIllustration(bool isSmall) {
    double scale = isSmall ? 0.7 : 1.0;
    
    return Stack(
      children: [
        // Awan putih di kiri atas
        Positioned(
          top: 15 * scale,
          left: 15 * scale,
          child: Container(
            width: 20 * scale,
            height: 10 * scale,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        // Awan putih di kanan atas
        Positioned(
          top: 20 * scale,
          right: 20 * scale,
          child: Container(
            width: 25 * scale,
            height: 12 * scale,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        // Karakter utama
        Positioned(
          bottom: 20 * scale,
          right: 30 * scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kepala
              Container(
                width: 16 * scale,
                height: 16 * scale,
                decoration: BoxDecoration(
                  color: Colors.brown[300],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: 2 * scale),
              // Badan
              Container(
                width: 20 * scale,
                height: 25 * scale,
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              SizedBox(height: 2 * scale),
              // Kaki
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6 * scale,
                    height: 12 * scale,
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(width: 2 * scale),
                  Container(
                    width: 6 * scale,
                    height: 12 * scale,
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Tumpukan buku
        Positioned(
          bottom: 15 * scale,
          left: 15 * scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Buku 1
              Container(
                width: 25 * scale,
                height: 6 * scale,
                decoration: BoxDecoration(
                  color: Colors.red[400],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              SizedBox(height: 1 * scale),
              // Buku 2
              Container(
                width: 30 * scale,
                height: 6 * scale,
                decoration: BoxDecoration(
                  color: Colors.green[400],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              SizedBox(height: 1 * scale),
              // Buku 3
              Container(
                width: 20 * scale,
                height: 6 * scale,
                decoration: BoxDecoration(
                  color: Colors.purple[400],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Method untuk menampilkan dialog gambar
  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange[300]!,
                          Colors.orange[400]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: soal['imagePath'] != null && soal['imagePath'].isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(soal['imagePath']),
                              fit: BoxFit.contain,
                            ),
                          )
                        : _buildDefaultIllustration(false), // Ilustrasi default ukuran besar
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}