// File: lib/widget/kuis_card.dart - Improved with better UI
import 'package:flutter/material.dart';

class KuisCard extends StatelessWidget {
  final Map<String, dynamic> kuis;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDetail;

  const KuisCard({
    super.key,
    required this.kuis,
    required this.onEdit,
    required this.onDelete,
    required this.onDetail,
  });

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString.split(' ')[0];
    }
  }

  String _formatDateWithTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return _formatDate(dateString);
    }
  }

  int _getJumlahSoal() {
    if (kuis['soal'] != null && kuis['soal'] is List) {
      return (kuis['soal'] as List).length;
    }
    return 0;
  }

  Color _getStatusColor() {
    switch (kuis['status']) {
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

  String _getStatusText() {
    switch (kuis['status']) {
      case 'published':
        return 'PUBLISHED';
      case 'draft':
        return 'DRAFT';
      case 'closed':
        return 'CLOSED';
      default:
        return 'UNKNOWN';
    }
  }

  bool _isExpired() {
    if (kuis['deadline'] == null || kuis['deadline'].toString().isEmpty) {
      return false;
    }
    
    try {
      final deadline = DateTime.parse(kuis['deadline']);
      return DateTime.now().isAfter(deadline);
    } catch (e) {
      return false;
    }
  }

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
                      Expanded(
                        child: Text(
                          kuis['nama_kuis'] ?? 'Preview Kuis',
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
                // Gambar atau default illustration
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: kuis['gambar'] != null && kuis['gambar'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              kuis['gambar'],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultImagePlaceholder();
                              },
                            ),
                          )
                        : _buildDefaultImagePlaceholder(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF664f9f).withOpacity(0.7),
            const Color(0xFF664f9f),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 60,
              color: Colors.white,
            ),
            SizedBox(height: 8),
            Text(
              'Kuis Image',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jumlahSoal = _getJumlahSoal();
    final isExpired = _isExpired();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onDetail,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kuis['nama_kuis'] ?? 'Kuis Tanpa Nama',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dibuat ${_formatDateWithTime(kuis['created_at'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor().withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Deskripsi (jika ada)
              if (kuis['deskripsi'] != null && kuis['deskripsi'].toString().isNotEmpty) ...[
                Text(
                  kuis['deskripsi'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              
              // Info Section
              Row(
                children: [
                  // Image Section
                  GestureDetector(
                    onTap: () => _showImageDialog(context),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: kuis['gambar'] != null && kuis['gambar'].toString().isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.network(
                                kuis['gambar'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildSmallImagePlaceholder();
                                },
                              ),
                            )
                          : _buildSmallImagePlaceholder(),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Jumlah Soal
                        _buildInfoRow(
                          Icons.quiz,
                          'Soal',
                          '$jumlahSoal soal',
                          color: jumlahSoal > 0 ? Colors.blue : Colors.red,
                        ),
                        const SizedBox(height: 6),
                        
                        // Durasi
                        _buildInfoRow(
                          Icons.schedule,
                          'Durasi',
                          kuis['durasi_menit'] != null 
                            ? '${kuis['durasi_menit']} menit'
                            : 'Tanpa batas',
                        ),
                        const SizedBox(height: 6),
                        
                        // Deadline
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Deadline',
                          kuis['deadline'] != null 
                            ? _formatDate(kuis['deadline'])
                            : 'Tanpa deadline',
                          color: isExpired ? Colors.red : null,
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions Menu
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      switch (result) {
                        case 'detail':
                          onDetail();
                          break;
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 20, color: Colors.blue),
                            SizedBox(width: 12),
                            Text('Lihat Detail'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20, color: Colors.orange),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Warning jika expired atau tidak ada soal
              if (isExpired || jumlahSoal == 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isExpired ? Colors.red : Colors.orange)[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (isExpired ? Colors.red : Colors.orange)[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isExpired ? Icons.schedule : Icons.warning_outlined,
                        size: 16,
                        color: (isExpired ? Colors.red : Colors.orange)[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isExpired 
                            ? 'Kuis telah melewati deadline'
                            : 'Kuis belum memiliki soal',
                          style: TextStyle(
                            fontSize: 12,
                            color: (isExpired ? Colors.red : Colors.orange)[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color ?? Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF664f9f).withOpacity(0.7),
            const Color(0xFF664f9f),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.quiz_outlined,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}