// File: pages/materi_page.dart
import 'package:flutter/material.dart';
import 'package:haloo/pages/form_materi.dart';
import 'package:haloo/widget/materi_card.dart';
import 'package:haloo/widget/sidebar.dart';
import '../models/materi_model.dart';

class MateriPage extends StatefulWidget {
  @override
  _MateriPageState createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  // Data dummy untuk materi (menggunakan List yang bisa dimodifikasi)
  List<MateriModel> materiList = [
    MateriModel(
      id: '1',
      title: 'CPU',
      description: 'CPU, atau Central Processing Unit, adalah otak dari komputer yang bertugas memproses semua instruksi dan data. Ia bertugas sebagai pusat kontrol utama, mengarahkan operasi komputer, mulai dari menjalankan aplikasi hingga melakukan perhitungan matematis. CPU terdiri dari berbagai komponen internal, seperti unit kontrol, ALU (Arithmetical Logical Unit), dan register, yang bekerja sama untuk memproses informasi.',
      date: '2025-04-23',
      icon: Icons.memory,
      iconColor: Colors.blue,
      backgroundColor: Colors.blue[100],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materi Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToAddMateri(context), 
          ),
        ],
      ),
      drawer: Sidebar(),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: materiList.length,
        itemBuilder: (context, index) {
          return MateriCard(
            materi: materiList[index],
            onEdit: () => _editMateri(context, materiList[index]),
            onDelete: () => _deleteMateri(context, materiList[index]),
          );
        },
      ),
    );
  }

  // Metode untuk navigasi ke form tambah materi
  void _navigateToAddMateri(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahMateriPage(),
      ),
    );

    // Jika ada data yang dikembalikan dari form
    if (result != null) {
      _addNewMateri(result);
    }
  }

  // Metode untuk menambah materi baru ke list
  void _addNewMateri(Map<String, dynamic> materiData) {
    setState(() {
      materiList.add(
        MateriModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate ID sederhana
          title: materiData['judul'],
          description: materiData['deskripsi'],
          date: DateTime.now().toString().split(' ')[0], // Format YYYY-MM-DD
          icon: Icons.article, // Icon default
          iconColor: Colors.green,
          backgroundColor: Colors.green[100],
        ),
      );
    });
  }

  // Metode untuk navigasi ke form edit materi
  void _navigateToEditMateri(BuildContext context, MateriModel materi) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahMateriPage(
          // Jika Anda ingin mengedit, Anda perlu menambahkan parameter di TambahMateriPage
          isEdit: true,
          existingMateri: materi,
        ),
      ),
    );

    if (result != null) {
      _updateMateri(materi.id, result);
    }
  }

  // Metode untuk update materi
  void _updateMateri(String id, Map<String, dynamic> updatedData) {
    setState(() {
      final index = materiList.indexWhere((materi) => materi.id == id);
      if (index != -1) {
        materiList[index] = MateriModel(
          id: id,
          title: updatedData['judul'],
          description: updatedData['deskripsi'],
          date: materiList[index].date, // Tetap gunakan tanggal asli
          icon: materiList[index].icon,
          iconColor: materiList[index].iconColor,
          backgroundColor: materiList[index].backgroundColor,
        );
      }
    });
  }

  void _editMateri(BuildContext context, MateriModel materi) {
    // Opsi 1: Gunakan form page untuk edit
    _navigateToEditMateri(context, materi);
    
    // Opsi 2: Tetap gunakan dialog (kode lama)
    // _showEditDialog(context, materi);
  }

  // Metode dialog edit alternatif (jika Anda masih ingin menggunakan dialog)
  void _showEditDialog(BuildContext context, MateriModel materi) {
    final TextEditingController titleController = TextEditingController(text: materi.title);
    final TextEditingController descriptionController = TextEditingController(text: materi.description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Materi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul Materi',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () {
                if (titleController.text.isNotEmpty && 
                    descriptionController.text.isNotEmpty) {
                  _updateMateri(materi.id, {
                    'judul': titleController.text,
                    'deskripsi': descriptionController.text,
                  });
                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Materi berhasil diupdate!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteMateri(BuildContext context, MateriModel materi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Materi'),
          content: Text('Apakah Anda yakin ingin menghapus materi "${materi.title}"?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Hapus'),
              onPressed: () {
                setState(() {
                  materiList.removeWhere((item) => item.id == materi.id);
                });
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Materi berhasil dihapus!')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}