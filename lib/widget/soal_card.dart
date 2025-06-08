import 'package:flutter/material.dart';
import '../models/soal_model.dart';

class SoalCard extends StatelessWidget {
  final SoalModel soal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDetail;

  const SoalCard({
    Key? key,
    required this.soal,
    required this.onEdit,
    required this.onDelete,
    required this.onDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon container dengan design yang lebih menarik
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.blue[100]!,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.quiz_outlined,
                color: Colors.blue[600],
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul pertanyaan
                  Text(
                    soal.title.isNotEmpty ? soal.title : 'Soal Baru',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  // Jenis soal dengan styling yang lebih baik
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Jenis Soal: ${soal.category.isNotEmpty ? soal.category : "Umum"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  // Tanggal dengan format yang lebih baik
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4),
                      Text(
                        soal.date.isNotEmpty ? soal.date : _getCurrentDate(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Menu button dengan styling yang lebih baik
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              child: PopupMenuButton<String>(
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
                        Icon(Icons.visibility_outlined, size: 18, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('Lihat Detail'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: Colors.orange),
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
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}