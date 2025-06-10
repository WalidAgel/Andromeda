// File: lib/pages/kuis/form_kuis.dart - Improved CRUD
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:haloo/services/api_services.dart';
import 'dart:io';

class TambahKuisPage extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? existingKuis;
  
  const TambahKuisPage({
    super.key,
    this.isEdit = false,
    this.existingKuis,
  });

  @override
  State<TambahKuisPage> createState() => _TambahKuisPageState();
}

class _TambahKuisPageState extends State<TambahKuisPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _durasiController = TextEditingController();
  
  File? _selectedImage;
  DateTime? _selectedDate;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _selectedStatus = 'draft';
  
  // Available questions
  List<Map<String, dynamic>> availableQuestions = [];
  List<int> selectedQuestionIds = [];
  bool _loadingQuestions = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableQuestions();
    if (widget.isEdit && widget.existingKuis != null) {
      _loadExistingData();
    }
  }

  Future<void> _loadAvailableQuestions() async {
    setState(() => _loadingQuestions = true);
    
    try {
      final response = await ApiService.getSoal();
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        setState(() {
          availableQuestions = data.cast<Map<String, dynamic>>();
          _loadingQuestions = false;
        });
      } else {
        setState(() {
          availableQuestions = [];
          _loadingQuestions = false;
        });
      }
    } catch (e) {
      setState(() {
        availableQuestions = [];
        _loadingQuestions = false;
      });
    }
  }

  void _loadExistingData() {
    final data = widget.existingKuis!;
    _judulController.text = data['nama_kuis'] ?? '';
    _deskripsiController.text = data['deskripsi'] ?? '';
    _durasiController.text = data['durasi_menit']?.toString() ?? '';
    _selectedStatus = data['status'] ?? 'draft';
    
    if (data['deadline'] != null) {
      try {
        _selectedDate = DateTime.parse(data['deadline']);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    // Load selected questions if editing
    if (data['soal'] != null && data['soal'] is List) {
      selectedQuestionIds = (data['soal'] as List)
          .map((soal) => soal['id'] as int)
          .toList();
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _durasiController.dispose();
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
        selectableDayPredicate: (day) => day.isAfter(DateTime.now().subtract(const Duration(days: 1))),
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

  String _formatDateForDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} 23:59:59';
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_judulController.text.isNotEmpty ||
        _deskripsiController.text.isNotEmpty ||
        _selectedImage != null ||
        selectedQuestionIds.isNotEmpty) {
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

    // Validate at least one question selected
    if (selectedQuestionIds.isEmpty) {
      _showMessage('Pilih minimal satu soal untuk kuis ini', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final kuisData = {
        'nama_kuis': _judulController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'deadline': _selectedDate != null ? _formatDateForApi(_selectedDate!) : null,
        'durasi_menit': _durasiController.text.isNotEmpty ? int.parse(_durasiController.text) : null,
        'status': _selectedStatus,
      };

      // Submit kuis data
      ApiResponse response;
      if (widget.isEdit) {
        response = await ApiService.updateKuis(widget.existingKuis!['id'], kuisData);
      } else {
        response = await ApiService.tambahKuis(kuisData);
      }

      if (response.success && response.data != null) {
        final kuisId = widget.isEdit 
            ? widget.existingKuis!['id']
            : response.data['data']['id'];

        // Add selected questions to quiz if not editing or if questions changed
        if (!widget.isEdit || _questionsChanged()) {
          await _updateKuisQuestions(kuisId);
        }

        _showMessage(widget.isEdit 
            ? 'Kuis berhasil diperbarui!' 
            : 'Kuis berhasil ditambahkan!');
        
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

  bool _questionsChanged() {
    if (widget.existingKuis == null) return true;
    
    final existingSoal = widget.existingKuis!['soal'] as List? ?? [];
    final existingIds = existingSoal.map((soal) => soal['id'] as int).toSet();
    final newIds = selectedQuestionIds.toSet();
    
    return !existingIds.isEqual(newIds);
  }

  Future<void> _updateKuisQuestions(int kuisId) async {
    if (selectedQuestionIds.isNotEmpty) {
      final questionResponse = await ApiService.makeRequest(
        method: 'POST',
        url: '/admin/kuis/$kuisId/soal',
        body: {'soal_ids': selectedQuestionIds},
        requiresAuth: true,
      );
      
      if (!questionResponse.success) {
        _showMessage('Berhasil menyimpan kuis, tapi gagal menambah soal: ${questionResponse.message}', isError: true);
      }
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Icon(Icons.landscape_outlined, size: 20, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
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
                        'Judul Kuis',
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
                            borderSide: BorderSide(color: Color(0xFF664f9f), width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          hintText: 'Masukkan judul kuis',
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
                      
                      const SizedBox(height: 24),
                      
                      // Deskripsi Field
                      const Text(
                        'Deskripsi Kuis (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _deskripsiController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF664f9f), width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          hintText: 'Masukkan deskripsi kuis (opsional)',
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Durasi Field
                      const Text(
                        'Durasi (Menit)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _durasiController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF664f9f), width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          hintText: 'Contoh: 30 (kosongkan jika tanpa batas)',
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final duration = int.tryParse(value);
                            if (duration == null || duration <= 0) {
                              return 'Durasi harus berupa angka positif';
                            }
                            if (duration > 1440) { // 24 jam
                              return 'Durasi maksimal 1440 menit (24 jam)';
                            }
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Status Field
                      const Text(
                        'Status Kuis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF664f9f), width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'draft', child: Text('Draft')),
                          DropdownMenuItem(value: 'published', child: Text('Published')),
                          DropdownMenuItem(value: 'closed', child: Text('Closed')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Tanggal Deadline Field
                      const Text(
                        'Tanggal Deadline (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _showDatePicker,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey, width: 1),
                                  ),
                                ),
                                child: Text(
                                  _selectedDate != null
                                      ? _formatDateForDisplay(_selectedDate!)
                                      : 'Pilih tanggal deadline (opsional)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_selectedDate != null) ...[
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _selectedDate = null;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Gambar Kuis Section
                      const Text(
                        'Gambar Kuis (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
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
                              backgroundColor: const Color(0xFF664f9f),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Image Preview
                          GestureDetector(
                            onTap: _selectedImage != null ? _removeImage : _showImageSourceDialog,
                            child: _selectedImage != null
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
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
                                : _buildImagePlaceholder(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Pilih Soal Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Pilih Soal untuk Kuis',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${selectedQuestionIds.length} dipilih)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Questions List
                      if (_loadingQuestions) ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ] else if (availableQuestions.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: const Center(
                            child: Text(
                              'Belum ada soal tersedia.\nSilakan tambah soal terlebih dahulu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Select All / Deselect All buttons
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  selectedQuestionIds = availableQuestions
                                      .map((q) => q['id'] as int)
                                      .toList();
                                });
                              },
                              child: const Text('Pilih Semua'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  selectedQuestionIds.clear();
                                });
                              },
                              child: const Text('Hapus Semua'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Questions List
                        Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: SingleChildScrollView(
                            child: Column(
                              children: availableQuestions.map((question) {
                                final questionId = question['id'] as int;
                                final isSelected = selectedQuestionIds.contains(questionId);
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected 
                                          ? const Color(0xFF664f9f) 
                                          : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected 
                                        ? const Color(0xFF664f9f).withOpacity(0.05)
                                        : Colors.white,
                                  ),
                                  child: CheckboxListTile(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedQuestionIds.add(questionId);
                                        } else {
                                          selectedQuestionIds.remove(questionId);
                                        }
                                      });
                                    },
                                    title: Text(
                                      question['judul'] ?? 'Soal ${question['id']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected 
                                            ? const Color(0xFF664f9f)
                                            : Colors.black87,
                                      ),
                                    ),
                                    subtitle: question['pertanyaan'] != null 
                                        ? Text(
                                            question['pertanyaan'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          )
                                        : null,
                                    activeColor: const Color(0xFF664f9f),
                                    checkColor: Colors.white,
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
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
                              widget.isEdit ? 'Update Kuis' : 'Tambah Kuis',
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
}

// Extension untuk Set comparison
extension SetEquality<T> on Set<T> {
  bool isEqual(Set<T> other) {
    if (length != other.length) return false;
    for (final element in this) {
      if (!other.contains(element)) return false;
    }
    return true;
  }
}