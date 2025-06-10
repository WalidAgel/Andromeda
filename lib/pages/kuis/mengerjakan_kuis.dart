// File: lib/pages/kuis/mengerjakan_kuis.dart
import 'package:flutter/material.dart';
import 'package:haloo/services/api_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MengerjakanKuisPage extends StatefulWidget {
  final Map<String, dynamic> kuisData;

  const MengerjakanKuisPage({super.key, required this.kuisData});

  @override
  State<MengerjakanKuisPage> createState() => _MengerjakanKuisPageState();
}

class _MengerjakanKuisPageState extends State<MengerjakanKuisPage> {
  List<Map<String, dynamic>> soalList = [];
  Map<int, String> jawabanUser = {}; // soal_id -> jawaban
  int currentSoalIndex = 0;
  bool isLoading = true;
  bool isSubmitting = false;
  
  // Timer untuk durasi kuis
  Timer? _timer;
  int remainingSeconds = 0;
  bool hasStartedQuiz = false;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeQuiz() async {
    setState(() => isLoading = true);
    
    try {
      // Start quiz via API menggunakan HTTP langsung
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/user/kuis/${widget.kuisData['id']}/start'),
        headers: await ApiService.headersWithAuth,
      );

      final responseData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      if (!isSuccess) {
        _showMessage(responseData['message'] ?? 'Gagal memulai kuis', isError: true);
        Navigator.pop(context);
        return;
      }

      // Load soal dari kuisData yang sudah ada
      if (widget.kuisData['soal'] != null) {
        setState(() {
          soalList = List<Map<String, dynamic>>.from(widget.kuisData['soal']);
          isLoading = false;
          hasStartedQuiz = true;
        });
        
        _startTimer();
      } else {
        _showMessage('Tidak ada soal dalam kuis ini', isError: true);
        Navigator.pop(context);
      }
      
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage('Error: $e', isError: true);
      Navigator.pop(context);
    }
  }

  void _startTimer() {
    final durasi = widget.kuisData['durasi_menit'] as int? ?? 0;
    if (durasi > 0) {
      remainingSeconds = durasi * 60;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          remainingSeconds--;
        });
        
        if (remainingSeconds <= 0) {
          _timer?.cancel();
          _submitQuiz(isTimeout: true);
        }
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _submitJawaban(String jawaban) async {
    final currentSoal = soalList[currentSoalIndex];
    
    try {
      // Menggunakan HTTP langsung karena method tidak tersedia
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/user/kuis/${widget.kuisData['id']}/submit'),
        headers: await ApiService.headersWithAuth,
        body: jsonEncode({
          'soal_id': currentSoal['id'],
          'jawaban_user': jawaban,
        }),
      );

      final responseData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      if (isSuccess) {
        setState(() {
          jawabanUser[currentSoal['id']] = jawaban;
        });
        
        // Auto move to next question after 1 second
        await Future.delayed(const Duration(seconds: 1));
        _nextSoal();
      } else {
        _showMessage(responseData['message'] ?? 'Gagal submit jawaban', isError: true);
      }
    } catch (e) {
      _showMessage('Error submit jawaban: $e', isError: true);
    }
  }

  void _nextSoal() {
    if (currentSoalIndex < soalList.length - 1) {
      setState(() {
        currentSoalIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  void _previousSoal() {
    if (currentSoalIndex > 0) {
      setState(() {
        currentSoalIndex--;
      });
    }
  }

  Future<void> _submitQuiz({bool isTimeout = false}) async {
    if (isSubmitting) return;
    
    setState(() => isSubmitting = true);
    _timer?.cancel();

    try {
      // Get quiz result menggunakan HTTP langsung
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/user/kuis/${widget.kuisData['id']}/result'),
        headers: await ApiService.headersWithAuth,
      );

      final responseData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      setState(() => isSubmitting = false);

      if (isSuccess) {
        // Show result dialog
        _showResultDialog(responseData, isTimeout);
      } else {
        _showMessage('Error mengambil hasil kuis', isError: true);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      _showMessage('Error: $e', isError: true);
      Navigator.pop(context);
    }
  }

  void _showResultDialog(Map<String, dynamic> result, bool isTimeout) {
    final hasilKuis = result['hasil_kuis'];
    final skor = hasilKuis['skor'] ?? 0;
    final jawabanBenar = hasilKuis['jawaban_benar'] ?? 0;
    final totalSoal = hasilKuis['total_soal'] ?? soalList.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              skor >= 70 ? Icons.celebration : Icons.info_outline,
              color: skor >= 70 ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(isTimeout ? 'Waktu Habis!' : 'Kuis Selesai!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isTimeout) ...[
              const Text(
                'Waktu kuis telah habis. Berikut adalah hasil Anda:',
                style: TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildResultRow('Skor Anda', '$skor%', 
                    color: skor >= 70 ? Colors.green : Colors.red),
                  const Divider(),
                  _buildResultRow('Jawaban Benar', '$jawabanBenar'),
                  _buildResultRow('Total Soal', '$totalSoal'),
                  _buildResultRow('Jawaban Salah', '${totalSoal - jawabanBenar}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              skor >= 70 
                ? 'Selamat! Anda lulus kuis ini.' 
                : 'Anda belum lulus. Tetap semangat belajar!',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: skor >= 70 ? Colors.green : Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to detail
              Navigator.pop(context); // Back to kuis list
            },
            child: const Text('Kembali ke Daftar Kuis'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Kuis?'),
        content: const Text(
          'Jika Anda keluar, progress kuis akan hilang dan tidak dapat dilanjutkan. Yakin ingin keluar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Memulai kuis...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isSubmitting) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Menyelesaikan kuis...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentSoal = soalList[currentSoalIndex];
    final isAnswered = jawabanUser.containsKey(currentSoal['id']);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF664f9f),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            'Soal ${currentSoalIndex + 1} dari ${soalList.length}',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            if (remainingSeconds > 0)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: remainingSeconds <= 300 ? Colors.red : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: remainingSeconds <= 300 ? Colors.white : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(remainingSeconds),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: remainingSeconds <= 300 ? Colors.white : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF664f9f).withOpacity(0.1),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.kuisData['nama_kuis'] ?? 'Kuis',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${jawabanUser.length}/${soalList.length} dijawab',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (currentSoalIndex + 1) / soalList.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF664f9f)),
                  ),
                ],
              ),
            ),
            
            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question number and title
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF664f9f),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Soal ${currentSoalIndex + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Question text
                    Text(
                      currentSoal['pertanyaan'] ?? currentSoal['judul'] ?? 'Pertanyaan tidak tersedia',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    
                    // Question image if exists
                    if (currentSoal['gambar'] != null && currentSoal['gambar'].toString().isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            currentSoal['gambar'],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 30),
                    
                    // Answer options
                    const Text(
                      'Pilih jawaban yang benar:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Option A
                    if (currentSoal['pilihan_a'] != null) 
                      _buildOptionButton('A', currentSoal['pilihan_a'], isAnswered),
                    
                    // Option B
                    if (currentSoal['pilihan_b'] != null) 
                      _buildOptionButton('B', currentSoal['pilihan_b'], isAnswered),
                    
                    // Option C
                    if (currentSoal['pilihan_c'] != null) 
                      _buildOptionButton('C', currentSoal['pilihan_c'], isAnswered),
                    
                    // Option D
                    if (currentSoal['pilihan_d'] != null) 
                      _buildOptionButton('D', currentSoal['pilihan_d'], isAnswered),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Previous button
                  if (currentSoalIndex > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousSoal,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF664f9f)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, size: 18),
                            SizedBox(width: 8),
                            Text('Sebelumnya'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  
                  // Next/Finish button
                  Expanded(
                    flex: currentSoalIndex == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: isAnswered 
                        ? (currentSoalIndex == soalList.length - 1 ? _submitQuiz : _nextSoal)
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF664f9f),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentSoalIndex == soalList.length - 1 
                              ? 'Selesai' 
                              : 'Selanjutnya'
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            currentSoalIndex == soalList.length - 1 
                              ? Icons.check 
                              : Icons.arrow_forward,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option, String text, bool isAnswered) {
    final isSelected = jawabanUser[soalList[currentSoalIndex]['id']] == option;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAnswered ? null : () => _submitJawaban(option),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                ? const Color(0xFF664f9f).withOpacity(0.1)
                : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                  ? const Color(0xFF664f9f)
                  : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Option letter
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? const Color(0xFF664f9f)
                      : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Option text
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? const Color(0xFF664f9f) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                ),
                
                // Selected indicator
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF664f9f),
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}