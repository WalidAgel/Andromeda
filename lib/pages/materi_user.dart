import 'package:flutter/material.dart';
import 'package:haloo/pages/materi/detail_user.dart';
import 'package:haloo/models/materi_model.dart';
import 'package:haloo/widget/sidebar_user.dart';

class MateriUser extends StatelessWidget {
  final List<MateriModel> materiList = [
    MateriModel(
      id: "1",
      title: "Berpikir Komputasional",
      date: "2025-05-25",
      description:
          "Berpikir komputasional merupakan metode pemecahan masalah dengan menerapkan teknologi ilmu komputer atau informatika. Berpikir komputasional juga dapat diartikan sebagai konsep tentang cara menemukan masalah yang ada di sekitar, dengan mengambil ide lalu mengembangkan solusi pemecahan masalah. Mungkin tidak sedikit orang mengira jika berpikir komputasional haruslah menggunakan aplikasi yang terdapat pada komputer.",
      icon: Icons.psychology,
      backgroundColor: Colors.blue[300],
      iconColor: Colors.white,
    ),
    MateriModel(
      id: "2",
      title: "Sistem komputer",
      date: "2025-05-23",
      description:
          "Sistem komputer adalah gabungan dari hardware (perangkat keras), software (perangkat lunak), dan brainware (manusia yang mengoperasikan) yang bekerja bersama-sama untuk memproses data dan menghasilkan informasi. Sistem ini merupakan dasar dari teknologi informasi dan memungkinkan kita untuk melakukan berbagai tugas, mulai dari pekerjaan kantor hingga hiburan digital.",
      icon: Icons.computer,
      backgroundColor: Colors.green[300],
      iconColor: Colors.white,
    ),
    MateriModel(
      id: "3",
      title: "CPU",
      date: "2025-05-23",
      description:
          "CPU, atau Central Processing Unit, adalah otak dari komputer yang bertugas memproses semua instruksi dan data. Ia berfungsi sebagai pusat kontrol utama, mengarahkan operasi komputer, mulai dari menjalankan aplikasi hingga melakukan perhitungan matematis.",
      icon: Icons.memory,
      backgroundColor: Colors.orange[300],
      iconColor: Colors.white,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Materi"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      drawer: SidebarUser(),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: materiList.length,
        itemBuilder: (context, index) {
          final materi = materiList[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    materi.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    materi.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 12),
                  Text(
                    materi.date,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigasi ke halaman DetailUser langsung dengan MateriModel
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailUser(materi: materi),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF664f9f),
                      ),
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        "Lihat Detail",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}