// File: detail_kuis.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/kuis_model.dart'; // import model KuisModel

class DetailKuisPage extends StatelessWidget {
  final KuisModel kuis; // Terima parameter kuis

  const DetailKuisPage({super.key, required this.kuis});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kuis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(
                kuis.icon,
                size: 80,
                color: kuis.iconColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kuis.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tanggal Deadline: ${kuis.tanggalDeadline}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                    Text(
                      'Created at: ${kuis.createdAt}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Daftar Soal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Soal 1 (contoh)
          _buildQuestionCard(
            question:
                'Berpikir komputasi memiliki empat pondasi sebagai berikut, kecuali...',
            options: ['Abstraksi', 'Pola', 'Kritis', 'Dekomposisi'],
            createdAt: kuis.createdAt,
          ),
          const SizedBox(height: 16),
          // Soal 2 (contoh)
          _buildQuestionCard(
            question: 'Contoh soal kedua di sini...',
            options: ['Opsi 1', 'Opsi 2', 'Opsi 3', 'Opsi 4'],
            createdAt: kuis.createdAt,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required String question,
    required List<String> options,
    required String createdAt,
  }) {
    return Card(
      color: const Color(0xFFF5F0FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  kuis.icon,
                  size: 50,
                  color: kuis.iconColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < options.length; i++)
              Text('Opsi ${String.fromCharCode(65 + i)}: ${options[i]}'),
            const SizedBox(height: 12),
            Text(
              'Created At: $createdAt',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
