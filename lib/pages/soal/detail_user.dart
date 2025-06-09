// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../models/materi_model.dart';
// import '../../models/soal_model.dart';

// class DetailUser extends StatefulWidget {
//   final MateriModel? materi;
//   final SoalModel? soal;
//   final String? materiId;
//   final String? soalId;

//   const DetailUser({
//     super.key,
//     this.materi,
//     this.soal,
//     this.materiId,
//     this.soalId,
//   });

//   @override
//   State<DetailUser> createState() => _DetailUserState();
// }

// class _DetailUserState extends State<DetailUser> {
//   bool _isLoading = false;
//   Map<String, dynamic>? _detailData;
//   String? _error;
  
//   // Base URL untuk API
//   static const String baseUrl = 'http://localhost:8000/api';

//   @override
//   void initState() {
//     super.initState();
//     if (widget.materiId != null || widget.soalId != null) {
//       _loadDetailFromApi();
//     } else {
//       _loadDetailFromModel();
//     }
//   }

//   void _loadDetailFromModel() {
//     if (widget.materi != null) {
//       setState(() {
//         _detailData = {
//           'type': 'materi',
//           'id': widget.materi!.id,
//           'title': widget.materi!.title,
//           'description': widget.materi!.description,
//           'date': widget.materi!.date,
//           'icon': widget.materi!.icon,
//           'iconColor': widget.materi!.iconColor,
//           'backgroundColor': widget.materi!.backgroundColor,
//         };
//       });
//     } else if (widget.soal != null) {
//       setState(() {
//         _detailData = {
//           'type': 'soal',
//           'id': widget.soal!.id,
//           'title': widget.soal!.title,
//           'description': widget.soal!.description,
//           'category': widget.soal!.category,
//           'date': widget.soal!.date,
//           'icon': widget.soal!.icon,
//           'iconColor': widget.soal!.iconColor,
//           'backgroundColor': widget.soal!.backgroundColor,
//           'questionData': widget.soal!.questionData,
//         };
//       });
//     }
//   }

//   Future<void> _loadDetailFromApi() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       String url;
//       if (widget.materiId != null) {
//         url = '$baseUrl/user/materi/${widget.materiId}';
//       } else {
//         url = '$baseUrl/user/soal/${widget.soalId}';
//       }

//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           // Add authorization header if needed
//           // 'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         setState(() {
//           _detailData = jsonData['data'];
//           _detailData!['type'] = widget.materiId != null ? 'materi' : 'soal';
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _error = 'Gagal memuat data: ${response.statusCode}';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = 'Error: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           _detailData?['type'] == 'materi' ? 'Detail Materi' : 'Detail Soal',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         centerTitle: false,
//       ),
//       body: _buildBody(),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF664f9f)),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Memuat data...',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: 64,
//               color: Colors.red[300],
//             ),
//             SizedBox(height: 16),
//             Text(
//               _error!,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.red[600],
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 if (widget.materiId != null || widget.soalId != null) {
//                   _loadDetailFromApi();
//                 } else {
//                   _loadDetailFromModel();
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFF664f9f),
//               ),
//               child: Text(
//                 'Coba Lagi',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_detailData == null) {
//       return Center(
//         child: Text(
//           'Data tidak tersedia',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey[600],
//           ),
//         ),
//       );
//     }

//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Card utama dengan konten
//           Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header dengan icon dan title
//                   _buildHeader(),
//                   SizedBox(height: 20),
                  
//                   // Content berdasarkan tipe
//                   if (_detailData!['type'] == 'materi') 
//                     _buildMateriContent()
//                   else 
//                     _buildSoalContent(),
                  
//                   SizedBox(height: 24),
                  
//                   // Footer info
//                   _buildFooterInfo(),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     final iconData = _detailData!['icon'] ?? Icons.book;
//     final iconColor = _detailData!['iconColor'] ?? Colors.white;
//     final backgroundColor = _detailData!['backgroundColor'] ?? Color(0xFF664f9f);

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         GestureDetector(
//           onTap: () => _showImageDialog(context),
//           child: Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: backgroundColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Icon(
//                   iconData,
//                   color: iconColor,
//                   size: 40,
//                 ),
//                 Positioned(
//                   bottom: 5,
//                   right: 5,
//                   child: Container(
//                     width: 16,
//                     height: 16,
//                     decoration: BoxDecoration(
//                       color: Colors.black54,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.zoom_in,
//                       size: 10,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 _detailData!['judul'] ?? _detailData!['title'] ?? 'Tidak Ada Judul',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               SizedBox(height: 8),
//               if (_detailData!['type'] == 'soal') ...[
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: backgroundColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Text(
//                     _detailData!['category'] ?? 'Umum',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: backgroundColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMateriContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           _detailData!['konten_materi'] ?? _detailData!['description'] ?? 'Tidak ada deskripsi',
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.black87,
//             height: 1.5,
//             letterSpacing: 0.1,
//           ),
//           textAlign: TextAlign.justify,
//         ),
        
//         // Tampilkan gambar jika ada
//         if (_detailData!['gambar'] != null) ...[
//           SizedBox(height: 20),
//           Container(
//             width: double.infinity,
//             height: 200,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey[300]!),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 '$baseUrl/storage/${_detailData!['gambar']}',
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     color: Colors.grey[200],
//                     child: Icon(
//                       Icons.image_not_supported,
//                       size: 50,
//                       color: Colors.grey[400],
//                     ),
//                   );
//                 },
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Center(
//                     child: CircularProgressIndicator(
//                       value: loadingProgress.expectedTotalBytes != null
//                           ? loadingProgress.cumulativeBytesLoaded /
//                               loadingProgress.expectedTotalBytes!
//                           : null,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
        
//         // Tampilkan video jika ada
//         if (_detailData!['video'] != null) ...[
//           SizedBox(height: 20),
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.blue[200]!),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.video_library, color: Colors.blue[600]),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Video Pembelajaran',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.blue[800],
//                         ),
//                       ),
//                       Text(
//                         'Tap untuk memutar video',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.blue[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Icon(Icons.play_circle, color: Colors.blue[600], size: 32),
//               ],
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildSoalContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           _detailData!['description'] ?? 'Tidak ada deskripsi',
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.black87,
//             height: 1.5,
//             letterSpacing: 0.1,
//           ),
//           textAlign: TextAlign.justify,
//         ),
        
//         SizedBox(height: 20),
        
//         // Informasi soal dari questionData
//         if (_detailData!['questionData'] != null)
//           _buildSoalInfo(_detailData!['questionData']),
        
//         // Detail pertanyaan jika ada
//         if (_detailData!['pertanyaan'] != null) ...[
//           SizedBox(height: 20),
//           _buildQuestionDetail(),
//         ],
//       ],
//     );
//   }

//   Widget _buildSoalInfo(Map<String, dynamic> questionData) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Informasi Soal:',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           SizedBox(height: 12),
//           _buildInfoRow('Jumlah Soal', '${questionData['jumlahSoal'] ?? 1}'),
//           _buildInfoRow('Durasi', questionData['durasi'] ?? '5 menit'),
//           _buildInfoRow('Tingkat Kesulitan', questionData['tingkatKesulitan'] ?? 'Mudah'),
//           _buildInfoRow('Passing Score', '${questionData['passingScore'] ?? 70}%'),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuestionDetail() {
//     final backgroundColor = _detailData!['backgroundColor'] ?? Color(0xFF664f9f);
    
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: backgroundColor.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: backgroundColor.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Contoh Pertanyaan:',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: backgroundColor,
//             ),
//           ),
//           SizedBox(height: 12),
//           Text(
//             _detailData!['pertanyaan'] ?? '',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.black87,
//               height: 1.4,
//             ),
//           ),
//           if (_detailData!['pilihan_a'] != null) ...[
//             SizedBox(height: 12),
//             _buildOption('A', _detailData!['pilihan_a']),
//             _buildOption('B', _detailData!['pilihan_b']),
//             _buildOption('C', _detailData!['pilihan_c']),
//             _buildOption('D', _detailData!['pilihan_d']),
//             SizedBox(height: 12),
//             Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: Colors.green.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.check_circle, color: Colors.green, size: 16),
//                   SizedBox(width: 8),
//                   Text(
//                     'Jawaban Benar: ${_detailData!['jawaban_benar'] ?? 'A'}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.green[700],
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ),
//           Text(
//             ': ',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[700],
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOption(String option, String? text) {
//     if (text == null || text.isEmpty) return SizedBox();
    
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 24,
//             height: 24,
//             margin: EdgeInsets.only(right: 12),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey[400]!),
//             ),
//             child: Center(
//               child: Text(
//                 option,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.black87,
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFooterInfo() {
//     return Row(
//       children: [
//         Icon(
//           Icons.calendar_today,
//           size: 16,
//           color: Colors.grey[600],
//         ),
//         SizedBox(width: 4),
//         Text(
//           'Created At: ${_detailData!['created_at']?.split('T')[0] ?? _detailData!['date'] ?? ''}',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[500],
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         Spacer(),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//           decoration: BoxDecoration(
//             color: Color(0xFF664f9f).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             'ID: ${_detailData!['id']}',
//             style: TextStyle(
//               fontSize: 10,
//               color: Color(0xFF664f9f),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _showImageDialog(BuildContext context) {
//     final iconData = _detailData!['icon'] ?? Icons.book;
//     final iconColor = _detailData!['iconColor'] ?? Colors.white;
//     final backgroundColor = _detailData!['backgroundColor'] ?? Color(0xFF664f9f);

//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           child: Container(
//             width: MediaQuery.of(context).size.width * 0.9,
//             height: MediaQuery.of(context).size.height * 0.6,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(16),
//                       topRight: Radius.circular(16),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         _detailData!['type'] == 'materi' ? 'Preview Materi' : 'Preview Soal',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () => Navigator.pop(context),
//                         icon: Icon(Icons.close),
//                         constraints: BoxConstraints(),
//                         padding: EdgeInsets.zero,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     margin: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: backgroundColor,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Center(
//                       child: Icon(
//                         iconData,
//                         color: iconColor,
//                         size: 120,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }