import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'dart:io';
import '../../models/kuis_model.dart'; // Import model yang sudah ada

class TambahKuisPage extends StatefulWidget {
  final bool isEdit;
  final KuisModel? existingKuis;
  
  const TambahKuisPage({
    Key? key,
    this.isEdit = false,
    this.existingKuis,
  }) : super(key: key);

  @override
  State<TambahKuisPage> createState() => _TambahKuisPageState();
}

class _TambahKuisPageState extends State<TambahKuisPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  
  File? _selectedImage;
  DateTime? _selectedDate;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Jika mode edit, isi form dengan data yang ada
    if (widget.isEdit && widget.existingKuis != null) {
      _judulController.text = widget.existingKuis!.title;
      // Parse tanggal deadline jika ada
      try {
        _selectedDate = DateTime.parse(widget.existingKuis!.tanggalDeadline);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
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
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
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
          content: Text('Error mengambil foto: $e'),
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

  Future<void> _showDatePicker() async {
    final results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        selectedDayHighlightColor: const Color(0xFF664f9f),
        closeDialogOnCancelTapped: true,
        firstDayOfWeek: 1,
        selectedDayTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        dayTextStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w400,
        ),
        disabledDayTextStyle: const TextStyle(
          color: Colors.grey,
        ),
        selectableDayPredicate: (day) => day.isAfter(DateTime.now().subtract(Duration(days: 1))),
      ),
      dialogSize: const Size(325, 400),
      value: _selectedDate != null ? [_selectedDate!] : [],
      dialogBackgroundColor: Colors.white,
    );

    if (results != null && results.isNotEmpty) {
      setState(() {
        _selectedDate = results.first;
      });
    }
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Fungsi untuk mengkonversi DateTime ke format YYYY-MM-DD
  String _formatDateForDeadline(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi tanggal deadline
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal deadline terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulasi proses penyimpanan
    await Future.delayed(const Duration(seconds: 1));

    // Membuat objek kuis baru dengan format yang sesuai
    final kuisData = {
      'judul': _judulController.text.trim(),
      'gambar': _selectedImage?.path,
      'tanggalDeadline': _formatDateForDeadline(_selectedDate!), // Format YYYY-MM-DD
      'createdAt': DateTime.now().toString().split(' ')[0],
    };

    // Debug print
    print('Data kuis yang akan dikirim: $kuisData');

    setState(() {
      _isLoading = false;
    });

    // Tampilkan pesan sukses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isEdit 
          ? 'Kuis berhasil diperbarui!' 
          : 'Kuis berhasil ditambahkan!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Kembali ke halaman sebelumnya dengan hasil
    Navigator.pop(context, kuisData);
  }

  Future<bool> _onWillPop() async {
    if (_judulController.text.isNotEmpty || 
        _selectedImage != null ||
        _selectedDate != null) {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            widget.isEdit ? 'Edit Kuis' : 'Tambah Kuis',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field Judul
                const Text(
                  'Judul',
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
                    border: UnderlineInputBorder(),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    if (value.trim().length < 3) {
                      return 'Judul minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 25),
                
                // Field Tanggal Deadline
                const Text(
                  'Tanggal Deadline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showDatePicker,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: _selectedDate != null ? const Color(0xFF664f9f) : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate != null
                              ? _formatDate(_selectedDate!)
                              : 'Pilih tanggal deadline',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Section Upload Gambar
                const Text(
                  'Gambar Kuis ',
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
                        foregroundColor: Color(0xFF664f9f),
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
                            style: _selectedImage != null ? BorderStyle.solid : BorderStyle.values[1],
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
                
                // Tombol Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color(0xFF664f9f),
                      padding: const EdgeInsets.symmetric(vertical: 15),
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
                            widget.isEdit ? 'Update' : 'Tambah',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}