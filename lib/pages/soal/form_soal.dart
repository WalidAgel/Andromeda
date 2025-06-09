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
  _TambahSoalPageState createState() => _TambahSoalPageState();
}

class _TambahSoalPageState extends State<TambahSoalPage> {
  final TextEditingController _pertanyaanController = TextEditingController();
  final TextEditingController _opsiAController = TextEditingController();
  final TextEditingController _opsiBController = TextEditingController();
  final TextEditingController _opsiCController = TextEditingController();
  final TextEditingController _opsiDController = TextEditingController();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingSoal != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final data = widget.existingSoal!;
    _judulController.text = data['judul'] ?? '';
    _deskripsiController.text = data['deskripsi'] ?? '';
    _kategoriController.text = data['kategori'] ?? '';
    _pertanyaanController.text = data['pertanyaan'] ?? '';
    _opsiAController.text = data['opsiA'] ?? '';
    _opsiBController.text = data['opsiB'] ?? '';
    _opsiCController.text = data['opsiC'] ?? '';
    _opsiDController.text = data['opsiD'] ?? '';
    
    if (data['imagePath'] != null) {
      _selectedImage = File(data['imagePath']);
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memilih gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _simpanSoal() {
    if (_pertanyaanController.text.isEmpty ||
        _opsiAController.text.isEmpty ||
        _opsiBController.text.isEmpty ||
        _opsiCController.text.isEmpty ||
        _opsiDController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua field'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Return data to parent page
    final soalData = {
      'judul': _judulController.text.isEmpty ? 'Soal Baru' : _judulController.text,
      'deskripsi': _deskripsiController.text,
      'kategori': _kategoriController.text.isEmpty ? 'Umum' : _kategoriController.text,
      'pertanyaan': _pertanyaanController.text,
      'opsiA': _opsiAController.text,
      'opsiB': _opsiBController.text,
      'opsiC': _opsiCController.text,
      'opsiD': _opsiDController.text,
      'imagePath': _selectedImage?.path,
    };

    Navigator.pop(context, soalData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Soal',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field Pertanyaan
            _buildSimpleTextField('Pertanyaan', _pertanyaanController),
            
            const SizedBox(height: 20),

            // Field Opsi A
            _buildSimpleTextField('Opsi A', _opsiAController),
            
            const SizedBox(height: 20),

            // Field Opsi B
            _buildSimpleTextField('Opsi B', _opsiBController),
            
            const SizedBox(height: 20),

            // Field Opsi C
            _buildSimpleTextField('Opsi C', _opsiCController),
            
            const SizedBox(height: 20),

            // Field Opsi D
            _buildSimpleTextField('Opsi D', _opsiDController),

            const SizedBox(height: 30),

            // Section Gambar Kuis
            const Text(
              'Gambar Kuis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                // Tombol Pilih Gambar
                ElevatedButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.image, size: 18),
                  label: const Text('Pilih Gambar'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF664f9f),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                const SizedBox(width: 15),
                
                // Preview Gambar
                GestureDetector(
                  onTap: _selectedImage != null ? _removeImage : _showImageSourceDialog,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(
                        color: _selectedImage != null ? Colors.indigo : Colors.grey[300]!,
                        width: _selectedImage != null ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  _selectedImage!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Icon(
                            Icons.image,
                            size: 32,
                            color: Colors.grey,
                          ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),

            // Tombol Tambah
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _simpanSoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tambah',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pertanyaanController.dispose();
    _opsiAController.dispose();
    _opsiBController.dispose();
    _opsiCController.dispose();
    _opsiDController.dispose();
    _judulController.dispose();
    _deskripsiController.dispose();
    _kategoriController.dispose();
    super.dispose();
  }
}