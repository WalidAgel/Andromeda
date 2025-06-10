// File: lib/pages/soal/form_soal.dart - Improved CRUD
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:haloo/services/api_services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _pertanyaanController = TextEditingController();
  final _opsiAController = TextEditingController();
  final _opsiBController = TextEditingController();
  final _opsiCController = TextEditingController();
  final _opsiDController = TextEditingController();
  
  String _jawabanBenar = 'A';
  File? _selectedImage;
  File? _selectedVideo;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingSoal != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final data = widget.existingSoal!['data'] ?? widget.existingSoal!;
    _judulController.text = data['judul'] ?? '';
    _pertanyaanController.text = data['pertanyaan'] ?? '';
    _opsiAController.text = data['pilihan_a'] ?? '';
    _opsiBController.text = data['pilihan_b'] ?? '';
    _opsiCController.text = data['pilihan_c'] ?? '';
    _opsiDController.text = data['pilihan_d'] ?? '';
    _jawabanBenar = data['jawaban_benar'] ?? 'A';
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

  Future<void> _showImageSourceDialog() async {
    return showDialog(
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
      _showMessage('Error memilih gambar: $e', isError: true);
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (video != null) {
        setState(() {
          _selectedVideo = File(video.path);
        });
      }
    } catch (e) {
      _showMessage('Error memilih video: $e', isError: true);
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _removeVideo() {
    setState(() {
      _selectedVideo = null;
    });
  }

  Future<String?> _saveImageToLocal(File imageFile) async {
  try {
    // Dapatkan direktori aplikasi
    final appDir = await getApplicationDocumentsDirectory();
    
    // Buat direktori images jika belum ada
    final imagesDir = Directory('${appDir.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    // Generate nama file unik
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(imageFile.path);
    final fileName = 'soal_${timestamp}$extension';
    
    // Path file tujuan
    final savedImagePath = '${imagesDir.path}/$fileName';
    
    // Copy file ke direktori images
    await imageFile.copy(savedImagePath);
    
    // Return URL relatif
    return './images/$fileName';
  } catch (e) {
    print('Error saving image: $e');
    return null;
  }
}

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_judulController.text.isNotEmpty ||
        _pertanyaanController.text.isNotEmpty ||
        _opsiAController.text.isNotEmpty ||
        _opsiBController.text.isNotEmpty ||
        _opsiCController.text.isNotEmpty ||
        _opsiDController.text.isNotEmpty ||
        _selectedImage != null ||
        _selectedVideo != null) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Konfirmasi'),
              content: const Text('Data yang belum disimpan akan hilang. Yakin ingin keluar?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Ya, Keluar'),
                ),
              ],
            ),
          ) ?? false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final soalData = {
        'judul': _judulController.text.trim(),
        'pertanyaan': _pertanyaanController.text.trim(),
        'pilihan_a': _opsiAController.text.trim(),
        'pilihan_b': _opsiBController.text.trim(),
        'pilihan_c': _opsiCController.text.trim(),
        'pilihan_d': _opsiDController.text.trim(),
        'jawaban_benar': _jawabanBenar,
      };

          // Handle image upload
      if (_selectedImage != null) {
        final savedImageUrl = await _saveImageToLocal(_selectedImage!);
        if (savedImageUrl != null) {
          soalData['gambar'] = savedImageUrl;
        } else {
          _showMessage('Gagal menyimpan gambar', isError: true);
          setState(() => _isLoading = false);
          return;
        }
}

      if (_selectedVideo != null) {
        // TODO: Upload video and get URL 
        // soalData['video'] = uploadedVideoUrl;
      }

      // Submit soal data
      ApiResponse response;
      if (widget.isEdit) {
        final soalId = widget.existingSoal!['data']?['id']?.toString() ?? 
                      widget.existingSoal!['id']?.toString();
        response = await ApiService.updateSoal(soalId!, soalData);
      } else {
        response = await ApiService.addSoal(soalData);
      }

      if (response.success) {
        _showMessage(widget.isEdit 
            ? 'Soal berhasil diperbarui!' 
            : 'Soal berhasil ditambahkan!');
        
        Navigator.pop(context, true);
      } else {
        _showMessage(response.message, isError: true);
      }
    } catch (e) {
      _showMessage('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            widget.isEdit ? 'Edit Soal' : 'Tambah Soal',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Form Fields Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Field
                      const Text(
                        'Judul Soal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _judulController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan judul soal',
                          contentPadding: EdgeInsets.all(12),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul soal tidak boleh kosong';
                          }
                          if (value.trim().length < 3) {
                            return 'Judul soal minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Pertanyaan Field
                      const Text(
                        'Pertanyaan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pertanyaanController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan pertanyaan soal',
                          contentPadding: EdgeInsets.all(12),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Pertanyaan tidak boleh kosong';
                          }
                          if (value.trim().length < 10) {
                            return 'Pertanyaan minimal 10 karakter';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Pilihan Jawaban Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilihan Jawaban',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Opsi A
                      _buildOptionField('A', _opsiAController),
                      const SizedBox(height: 12),
                      
                      // Opsi B
                      _buildOptionField('B', _opsiBController),
                      const SizedBox(height: 12),
                      
                      // Opsi C
                      _buildOptionField('C', _opsiCController),
                      const SizedBox(height: 12),
                      
                      // Opsi D
                      _buildOptionField('D', _opsiDController),
                      
                      const SizedBox(height: 20),
                      
                      // Jawaban Benar
                      const Text(
                        'Jawaban Benar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _jawabanBenar,
                            isExpanded: true,
                            items: ['A', 'B', 'C', 'D'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  'Opsi $value',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _jawabanBenar = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Media Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Media Pendukung (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Gambar Section
                      Row(
                        children: [
                          // Pilih Gambar Button
                          ElevatedButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: const Icon(Icons.image, size: 18, color: Colors.white),
                            label: const Text(
                              'Pilih Gambar',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Image Preview
                          if (_selectedImage != null) ...[
                            Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
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
                            ),
                          ] else ...[
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Icon(
                                Icons.image_outlined,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Video Section
                      Row(
                        children: [
                          // Pilih Video Button
                          ElevatedButton.icon(
                            onPressed: _pickVideo,
                            icon: const Icon(Icons.video_library, size: 18, color: Colors.white),
                            label: const Text(
                              'Pilih Video',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Video Preview
                          if (_selectedVideo != null) ...[
                            Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: const Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: _removeVideo,
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
                            ),
                          ] else ...[
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Icon(
                                Icons.video_library_outlined,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Submit Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF664f9f),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Menyimpan...'),
                              ],
                            )
                          : Text(
                              widget.isEdit ? 'Update Soal' : 'Tambah Soal',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionField(String option, TextEditingController controller) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _jawabanBenar == option ? Colors.green : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              option,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _jawabanBenar == option ? Colors.white : Colors.black54,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Masukkan pilihan $option',
              contentPadding: const EdgeInsets.all(12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Pilihan $option tidak boleh kosong';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}