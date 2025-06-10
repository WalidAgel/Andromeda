// File: lib/utils/quiz_helper.dart
// Helper class untuk navigasi dan utility quiz

import 'package:flutter/material.dart';

class QuizHelper {
  // Navigate to detail kuis
  static void navigateToDetailKuis(
    BuildContext context,
    Map<String, dynamic> kuisData,
  ) {
    Navigator.pushNamed(
      context,
      '/detail-kuis-user/${kuisData['id']}',
      arguments: kuisData,
    );
  }

  // Navigate to mengerjakan kuis
  static void navigateToMengerjakanKuis(
    BuildContext context,
    Map<String, dynamic> kuisData,
  ) {
    Navigator.pushNamed(
      context,
      '/mengerjakan-kuis/${kuisData['id']}',
      arguments: kuisData,
    );
  }

  // Format waktu dari detik ke MM:SS
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Format tanggal untuk tampilan
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Tidak ada deadline';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Cek apakah kuis sudah expired
  static bool isExpired(String? deadline) {
    if (deadline == null || deadline.isEmpty) return false;
    
    try {
      final deadlineDate = DateTime.parse(deadline);
      return DateTime.now().isAfter(deadlineDate);
    } catch (e) {
      return false;
    }
  }

  // Get warna status kuis
  static Color getStatusColor(String? status) {
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

  // Get text status kuis
  static String getStatusText(String? status) {
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

  // Validasi apakah kuis bisa dikerjakan
  static bool canTakeQuiz(Map<String, dynamic> kuis) {
    // Cek status published
    if (kuis['status'] != 'published') return false;
    
    // Cek expired
    if (isExpired(kuis['deadline'])) return false;
    
    // Cek ada soal
    final soalCount = getSoalCount(kuis);
    if (soalCount == 0) return false;
    
    return true;
  }

  // Get jumlah soal dalam kuis
  static int getSoalCount(Map<String, dynamic> kuis) {
    if (kuis['soal'] != null && kuis['soal'] is List) {
      return (kuis['soal'] as List).length;
    }
    return 0;
  }

  // Show konfirmasi dialog
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText ?? 'Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? const Color(0xFF664f9f),
            ),
            child: Text(
              confirmText ?? 'Ya',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Calculate percentage
  static double calculatePercentage(int correct, int total) {
    if (total == 0) return 0.0;
    return (correct / total) * 100;
  }

  // Get grade text based on score
  static String getGradeText(double score) {
    if (score >= 90) return 'Sangat Baik';
    if (score >= 80) return 'Baik';
    if (score >= 70) return 'Cukup';
    if (score >= 60) return 'Kurang';
    return 'Sangat Kurang';
  }

  // Get grade color based on score
  static Color getGradeColor(double score) {
    if (score >= 90) return Colors.green[700]!;
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.orange[700]!;
    return Colors.red;
  }
}