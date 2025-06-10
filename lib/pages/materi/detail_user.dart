import 'package:flutter/material.dart';
import 'package:haloo/services/api_services.dart';

class DetailUser extends StatefulWidget {
  final dynamic materiId; // id materi

  const DetailUser({
    super.key,
    required this.materiId,
  });

  @override
  State<DetailUser> createState() => _DetailUserState();
}

class _DetailUserState extends State<DetailUser> {
  Map<String, dynamic>? materi;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMateri();
  }

  Future<void> fetchMateri() async {
    setState(() {
      isLoading = true;
    });
    final response = await ApiService.getMateriById(int.parse(widget.materiId.toString()));
    if (response.success && response.data != null) {
      setState(() {
        materi = response.data['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Tampilkan error jika perlu
    }
  }

  String _timeAgo(String dateString) {
    if (dateString.isEmpty) return '';
    final date = DateTime.tryParse(dateString);
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 30) return '${diff.inDays} hari yang lalu';
    if (diff.inDays < 365)
      return '${(diff.inDays / 30).floor()} bulan yang lalu';
    return '${(diff.inDays / 365).floor()} tahun yang lalu';
  }

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
          'Detail Materi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : materi == null
              ? const Center(child: Text('Materi tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              Text(
                                materi!['judul'] ?? materi!['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // FOTO MATERI ATAU DEFAULT
                              if (materi!['gambar'] != null &&
                                  materi!['gambar'].toString().isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    materi!['gambar'],
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => _defaultImage(),
                                  ),
                                )
                              else
                                _defaultImage(),
                              const SizedBox(height: 20),
                              Text(
                                materi!['konten_materi'] ??
                                    materi!['deskripsi'] ??
                                    materi!['description'] ??
                                    '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.6,
                                  letterSpacing: 0.2,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Dibuat: ${_timeAgo(materi!['created_at'] ?? materi!['tanggal_dibuat'] ?? materi!['date'] ?? '')}',
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

  Widget _defaultImage() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.purple[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.white,
        size: 60,
      ),
    );
  }
}
