import 'package:flutter/material.dart';
import 'package:haloo/pages/soal/detail_soal.dart';
import 'package:haloo/pages/soal/form_soal.dart';
import 'package:haloo/services/api_services.dart';
import '../widget/sidebar.dart';

class SoalPage extends StatefulWidget {
  const SoalPage({super.key});

  @override
  State<SoalPage> createState() => _SoalPageState();
}

class _SoalPageState extends State<SoalPage> {
  List<Map<String, dynamic>> soalList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSoal();
  }

  Future<void> _loadSoal() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService.getSoal();
      if (response.success && response.data != null) {
        setState(() {
          soalList =
              List<Map<String, dynamic>>.from(response.data['data'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showMessage(response.message, isError: true);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage('Error: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _tambahSoal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahSoalPage()),
    );

    if (result != null) {
      _showLoading();
      try {
        final response = await ApiService.addSoal(result);
        Navigator.pop(context);

        if (response.success) {
          _loadSoal();
          _showMessage('Soal berhasil ditambahkan!');
        } else {
          _showMessage(response.message, isError: true);
        }
      } catch (e) {
        Navigator.pop(context);
        _showMessage('Error: $e', isError: true);
      }
    }
  }

  Future<void> _editSoal(Map<String, dynamic> soal) async {
    _showLoading();
    try {
      final response = await ApiService.getSoalById(soal['id']);
      Navigator.pop(context);

      if (response.success) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                TambahSoalPage(isEdit: true, existingSoal: response.data),
          ),
        );

        if (result != null) {
          _showLoading();
          final updateResponse =
              await ApiService.updateSoal(soal['id'].toString(), result);
          Navigator.pop(context);

          if (updateResponse.success) {
            _loadSoal();
            _showMessage('Soal berhasil diperbarui!');
          } else {
            _showMessage(updateResponse.message, isError: true);
          }
        }
      } else {
        _showMessage(response.message, isError: true);
      }
    } catch (e) {
      Navigator.pop(context);
      _showMessage('Error: $e', isError: true);
    }
  }

  Future<void> _hapusSoal(Map<String, dynamic> soal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Soal'),
        content: Text('Yakin ingin menghapus soal "${soal['judul']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _showLoading();
      try {
        final response = await ApiService.deleteSoal(soal['id'].toString());
        Navigator.pop(context);

        if (response.success) {
          _loadSoal();
          _showMessage('Soal berhasil dihapus!');
        } else {
          _showMessage(response.message, isError: true);
        }
      } catch (e) {
        Navigator.pop(context);
        _showMessage('Error: $e', isError: true);
      }
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soal Admin'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSoal,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _tambahSoal,
          ),
        ],
      ),
      drawer: const Sidebar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : soalList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Belum ada soal'),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _tambahSoal,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Soal'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSoal,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: soalList.length,
                    itemBuilder: (context, index) {
                      final soal = soalList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            soal['judul'] ?? 'Soal ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            soal['pertanyaan'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'detail':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailSoalPage(soal: soal),
                                    ),
                                  );
                                  break;
                                case 'edit':
                                  _editSoal(soal);
                                  break;
                                case 'delete':
                                  _hapusSoal(soal);
                                  break;
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'detail',
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Detail'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined,
                                        color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Hapus'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
