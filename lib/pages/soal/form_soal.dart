import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TambahSoalPage extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? existingSoal;
  
  const TambahSoalPage({
    super.key,
    this.isEdit = false,
    this.existingSoal,
  });

  @override
  State<TambahSoalPage> createState() => _TambahSoalPageState();
}

class _TambahSoalPageState extends State<TambahSoalPage> {
  final _judulController = TextEditingController();
  final _pertanyaanController = TextEditingController();
  final _opsiAController = TextEditingController();
  final _opsiBController = TextEditingController();
  final _opsiCController = TextEditingController();
  final _opsiDController = TextEditingController();
  
  String _jawabanBenar = 'A';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingSoal != null) {
      _loadData();
    }
  }

  void _loadData() {
    final data = widget.existingSoal!;
    _judulController.text = data['judul'] ?? '';
    _pertanyaanController.text = data['pertanyaan'] ?? '';
    _opsiAController.text = data['pilihan_a'] ?? '';
    _opsiBController.text = data['pilihan_b'] ?? '';
    _opsiCController.text = data['pilihan_c'] ?? '';
    _opsiDController.text = data['pilihan_d'] ?? '';
    _jawabanBenar = data['jawaban_benar'] ?? 'A';
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _submit() {
    if (_judulController.text.isEmpty || _pertanyaanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi data soal')),
      );
      return;
    }

    final data = {
      'judul': _judulController.text.trim(),
      'pertanyaan': _pertanyaanController.text.trim(),
      'pilihan_a': _opsiAController.text.trim(),
      'pilihan_b': _opsiBController.text.trim(),
      'pilihan_c': _opsiCController.text.trim(),
      'pilihan_d': _opsiDController.text.trim(),
      'jawaban_benar': _jawabanBenar,
      if (_selectedImage != null) 'imagePath': _selectedImage!.path,
    };

    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Soal' : 'Tambah Soal'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Judul
            _buildTextField('Judul', _judulController),
            const SizedBox(height: 16),
            
            // Pertanyaan
            _buildTextField('Pertanyaan', _pertanyaanController, maxLines: 3),
            const SizedBox(height: 16),
            
            // Pilihan A-D
            _buildTextField('Opsi A', _opsiAController),
            const SizedBox(height: 12),
            _buildTextField('Opsi B', _opsiBController),
            const SizedBox(height: 12),
            _buildTextField('Opsi C', _opsiCController),
            const SizedBox(height: 12),
            _buildTextField('Opsi D', _opsiDController),
            const SizedBox(height: 16),
            
            // Jawaban Benar
            Row(
              children: [
                const Text('Jawaban Benar: '),
                DropdownButton<String>(
                  value: _jawabanBenar,
                  items: ['A', 'B', 'C', 'D'].map((e) => 
                    DropdownMenuItem(value: e, child: Text('Opsi $e'))
                  ).toList(),
                  onChanged: (v) => setState(() => _jawabanBenar = v!),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Gambar
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Pilih Gambar'),
                ),
                const SizedBox(width: 16),
                if (_selectedImage != null) ...[
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _selectedImage = null),
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.isEdit ? 'Update' : 'Tambah',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _pertanyaanController.dispose();
    _opsiAController.dispose();
    _opsiBController.dispose();
    _opsiCController.dispose();
    _opsiDController.dispose();
    super.dispose();
  }
}