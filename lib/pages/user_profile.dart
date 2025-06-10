// // File: lib/pages/user_profile.dart
// import 'package:flutter/material.dart';
// import 'package:haloo/services/api_services.dart';

// class UserProfilePage extends StatefulWidget {
//   const UserProfilePage({super.key});

//   @override
//   State<UserProfilePage> createState() => _UserProfilePageState();
// }

// class _UserProfilePageState extends State<UserProfilePage> {
//   Map<String, dynamic>? userData;
//   bool isLoading = true;
//   bool isEditing = false;

//   final _formKey = GlobalKey<FormState>();
//   final _namaController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _usernameController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   @override
//   void dispose() {
//     _namaController.dispose();
//     _emailController.dispose();
//     _usernameController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserProfile() async {
//     setState(() => isLoading = true);

//     try {
//       // Coba ambil dari local storage dulu
//       final localData = await ApiService.getUserData();
//       if (localData != null) {
//         _setUserData(localData);
//         setState(() => isLoading = false);
//       }

//       // Ambil data terbaru dari API
//       final response = await ApiService.getProfile();
//       if (response.success && response.data != null) {
//         final profileData = response.data['data'];
//         _setUserData(profileData);
//         await ApiService.saveUserData(profileData);
//       }
      
//       setState(() => isLoading = false);
//     } catch (e) {
//       setState(() => isLoading = false);
//       _showMessage('Error loading profile: $e', isError: true);
//     }
//   }

//   void _setUserData(Map<String, dynamic> data) {
//     setState(() {
//       userData = data;
//       _namaController.text = data['nama_lengkap'] ?? '';
//       _emailController.text = data['email'] ?? '';
//       _usernameController.text = data['username'] ?? '';
//     });
//   }

//   void _showMessage(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }

//   String _formatDate(String? dateString) {
//     if (dateString == null || dateString.isEmpty) return '-';
//     try {
//       final date = DateTime.parse(dateString);
//       return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//     } catch (e) {
//       return dateString;
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       final updateData = {
//         'nama_lengkap': _namaController.text.trim(),
//         'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
//       };

//       final response = await ApiService.makeRequest(
//         method: 'PUT',
//         url: '/user/profile',
//         body: updateData,
//         requiresAuth: true,
//       );

//       if (response.success) {
//         await _loadUserProfile();
//         setState(() => isEditing = false);
//         _showMessage('Profile berhasil diperbarui!');
//       } else {
//         _showMessage(response.message, isError: true);
//       }
//     } catch (e) {
//       _showMessage('Error: $e', isError: true);
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Profile Saya',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: const Color(0xFF664f9f),
//         foregroundColor: Colors.white,
//         elevation: 1,
//         actions: [
//           if (!isEditing && !isLoading)
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () => setState(() => isEditing = true),
//               tooltip: 'Edit Profile',
//             ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   // Profile Header
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         // Avatar
//                         Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF664f9f).withOpacity(0.1),
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: const Color(0xFF664f9f),
//                               width: 3,
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.person,
//                             size: 50,
//                             color: Color(0xFF664f9f),
//                           ),
//                         ),
                        
//                         const SizedBox(height: 16),
                        
//                         // Name
//                         Text(
//                           userData?['nama_lengkap'] ?? 'User',
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
                        
//                         const SizedBox(height: 4),
                        
//                         // Username
//                         Text(
//                           '@${userData?['username'] ?? 'username'}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
                        
//                         const SizedBox(height: 8),
                        
//                         // Status
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.green.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(color: Colors.green.withOpacity(0.3)),
//                           ),
//                           child: Text(
//                             userData?['status'] == 'active' ? 'AKTIF' : 'TIDAK AKTIF',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: userData?['status'] == 'active' ? Colors.green[700] : Colors.red[700],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   const SizedBox(height: 20),
                  
//                   // Profile Info/Edit Form
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: isEditing ? _buildEditForm() : _buildInfoView(),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildInfoView() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Informasi Profile',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
        
//         const SizedBox(height: 20),
        
//         _buildInfoRow('Nama Lengkap', userData?['nama_lengkap'] ?? '-'),
//         _buildInfoRow('Username', userData?['username'] ?? '-'),
//         _buildInfoRow('Email', userData?['email'] ?? '-'),
//         _buildInfoRow('Status', userData?['status'] ?? '-'),
//         _buildInfoRow('Bergabung', _formatDate(userData?['created_at'])),
//         _buildInfoRow('Update Terakhir', _formatDate(userData?['updated_at'])),
//       ],
//     );
//   }

//   Widget _buildEditForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Edit Profile',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
          
//           const SizedBox(height: 20),
          
//           // Nama Lengkap
//           TextFormField(
//             controller: _namaController,
//             decoration: const InputDecoration(
//               labelText: 'Nama Lengkap',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.person),
//             ),
//             validator: (value) {
//               if (value == null || value.trim().isEmpty) {
//                 return 'Nama lengkap tidak boleh kosong';
//               }
//               return null;
//             },
//           ),
          
//           const SizedBox(height: 16),
          
//           // Email
//           TextFormField(
//             controller: _emailController,
//             decoration: const InputDecoration(
//               labelText: 'Email (Opsional)',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.email),
//             ),
//             keyboardType: TextInputType.emailAddress,
//             validator: (value) {
//               if (value != null && value.trim().isNotEmpty) {
//                 if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value.trim())) {
//                   return 'Format email tidak valid';
//                 }
//               }
//               return null;
//             },
//           ),
          
//           const SizedBox(height: 16),
          
//           // Username (Read only)
//           TextFormField(
//             controller: _usernameController,
//             decoration: const InputDecoration(
//               labelText: 'Username',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.alternate_email),
//               suffixIcon: Icon(Icons.lock, color: Colors.grey),
//             ),
//             enabled: false,
//           ),
          
//           const SizedBox(height: 24),
          
//           // Action Buttons
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: isLoading ? null : () {
//                     setState(() => isEditing = false);
//                     _setUserData(userData!);
//                   },
//                   child: const Text('Batal'),
//                 ),
//               ),
              
//               const SizedBox(width: 16),
              
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : _updateProfile,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF664f9f),
//                     foregroundColor: Colors.white,
//                   ),
//                   child: isLoading 
//                     ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                     : const Text('Simpan'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           const Text(': '),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }