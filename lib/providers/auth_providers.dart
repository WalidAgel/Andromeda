// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// // Import your API service
// import 'package:haloo/services/api_services.dart';

// enum AuthState {
//   initial,
//   loading,
//   authenticated,
//   unauthenticated,
//   error,
// }

// class AuthProvider extends ChangeNotifier {
//   AuthState _state = AuthState.initial;
//   String? _userType;
//   Map<String, dynamic>? _userData;
//   String? _token;
//   String? _errorMessage;

//   // Getters
//   AuthState get state => _state;
//   String? get userType => _userType;
//   Map<String, dynamic>? get userData => _userData;
//   String? get token => _token;
//   String? get errorMessage => _errorMessage;
  
//   bool get isAuthenticated => _state == AuthState.authenticated;
//   bool get isLoading => _state == AuthState.loading;
//   bool get isAdmin => _userType == 'admin';
//   bool get isUser => _userType == 'user';

//   // Initialize auth state
//   Future<void> initializeAuth() async {
//     _setState(AuthState.loading);
    
//     try {
//       // Check if user is already logged in
//       final isLoggedIn = await ApiService.isLoggedIn();
      
//       if (isLoggedIn) {
//         _token = await ApiService.getToken();
//         _userType = await ApiService.getUserType();
//         _userData = await ApiService.getUserData();
        
//         // Verify token with backend
//         final response = await ApiService.getProfile();
        
//         if (response.success) {
//           _userData = response.data['data'];
//           _setState(AuthState.authenticated);
//         } else {
//           // Token might be expired, logout
//           await logout();
//         }
//       } else {
//         _setState(AuthState.unauthenticated);
//       }
//     } catch (e) {
//       _setError('Failed to initialize authentication: $e');
//     }
//   }

//   // Login methods
//   Future<bool> loginAdmin({
//     required String username,
//     required String password,
//   }) async {
//     _setState(AuthState.loading);
    
//     try {
//       final response = await ApiService.loginAdmin(
//         username: username,
//         password: password,
//       );

//       if (response.success) {
//         final data = response.data as Map<String, dynamic>;
//         _token = data['token'];
//         _userType = 'admin';
//         _userData = data['user'];
        
//         _setState(AuthState.authenticated);
//         return true;
//       } else {
//         _setError(response.message);
//         return false;
//       }
//     } catch (e) {
//       _setError('Login failed: $e');
//       return false;
//     }
//   }

//   Future<bool> loginUser({
//     required String username,
//     required String password,
//   }) async {
//     _setState(AuthState.loading);
    
//     try {
//       final response = await ApiService.loginUser(
//         username: username,
//         password: password,
//       );

//       if (response.success) {
//         final data = response.data as Map<String, dynamic>;
//         _token = data['token'];
//         _userType = 'user';
//         _userData = data['user'];
        
//         _setState(AuthState.authenticated);
//         return true;
//       } else {
//         _setError(response.message);
//         return false;
//       }
//     } catch (e) {
//       _setError('Login failed: $e');
//       return false;
//     }
//   }

//   // Register method
//   Future<bool> register({
//     required String username,
//     required String password,
//     required String namaLengkap,
//     String? email,
//   }) async {
//     _setState(AuthState.loading);
    
//     try {
//       final response = await ApiService.registerUser(
//         username: username,
//         password: password,
//         namaLengkap: namaLengkap,
//         email: email,
//       );

//       if (response.success) {
//         _setState(AuthState.unauthenticated);
//         return true;
//       } else {
//         _setError(response.message);
//         return false;
//       }
//     } catch (e) {
//       _setError('Registration failed: $e');
//       return false;
//     }
//   }

//   // Logout method
//   Future<void> logout() async {
//     _setState(AuthState.loading);
    
//     try {
//       await ApiService.logout();
//     } catch (e) {
//       if (kDebugMode) print('Logout error: $e');
//     } finally {
//       _clearUserData();
//       _setState(AuthState.unauthenticated);
//     }
//   }

//   // Update profile
//   Future<bool> updateProfile({
//     String? email,
//     String? namaLengkap,
//     String? password,
//   }) async {
//     try {
//       final response = await ApiService.updateProfile(
//         email: email,
//         namaLengkap: namaLengkap,
//         password: password,
//       );

//       if (response.success) {
//         // Update local user data
//         if (response.data != null && response.data['data'] != null) {
//           _userData = response.data['data'];
//           await ApiService.saveUserData(_userData!);
//           notifyListeners();
//         }
//         return true;
//       } else {
//         _setError(response.message);
//         return false;
//       }
//     } catch (e) {
//       _setError('Profile update failed: $e');
//       return false;
//     }
//   }

//   // Refresh user data
//   Future<void> refreshUserData() async {
//     if (!isAuthenticated) return;
    
//     try {
//       final response = await ApiService.getProfile();
      
//       if (response.success) {
//         _userData = response.data['data'];
//         await ApiService.saveUserData(_userData!);
//         notifyListeners();
//       }
//     } catch (e) {
//       if (kDebugMode) print('Failed to refresh user data: $e');
//     }
//   }

//   // Clear error
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }

//   // Private methods
//   void _setState(AuthState newState) {
//     _state = newState;
//     _errorMessage = null;
//     notifyListeners();
//   }

//   void _setError(String error) {
//     _state = AuthState.error;
//     _errorMessage = error;
//     notifyListeners();
//   }

//   void _clearUserData() {
//     _token = null;
//     _userType = null;
//     _userData = null;
//     _errorMessage = null;
//   }

//   // Helper getters for user data
//   String get userName => _userData?['nama_lengkap'] ?? _userData?['username'] ?? '';
//   String get userEmail => _userData?['email'] ?? '';
//   String get userUsername => _userData?['username'] ?? '';
//   String? get userPhotoUrl => _userData?['foto_profile'];
// }

// // Auth Guard Widget
// class AuthGuard extends StatelessWidget {
//   final Widget child;
//   final Widget? loadingWidget;
//   final Widget? unauthenticatedWidget;
//   final bool requireAdmin;

//   const AuthGuard({
//     Key? key,
//     required this.child,
//     this.loadingWidget,
//     this.unauthenticatedWidget,
//     this.requireAdmin = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, _) {
//         switch (authProvider.state) {
//           case AuthState.initial:
//           case AuthState.loading:
//             return loadingWidget ?? const LoadingScreen();
            
//           case AuthState.unauthenticated:
//           case AuthState.error:
//             return unauthenticatedWidget ?? const LoginRedirectScreen();
            
//           case AuthState.authenticated:
//             if (requireAdmin && !authProvider.isAdmin) {
//               return const UnauthorizedScreen();
//             }
//             return child;
//         }
//       },
//     );
//   }
// }

// // Loading Screen
// class LoadingScreen extends StatelessWidget {
//   const LoadingScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF3a4b82),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.flight,
//                   color: Colors.white,
//                   size: 32,
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'Andromeda',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 40),
//             const CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Loading...',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Login Redirect Screen
// class LoginRedirectScreen extends StatelessWidget {
//   const LoginRedirectScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Automatically navigate to login after a short delay
//     Future.delayed(const Duration(milliseconds: 100), () {
//       Navigator.pushNamedAndRemoveUntil(
//         context,
//         '/login',
//         (route) => false,
//       );
//     });

//     return const LoadingScreen();
//   }
// }

// // Unauthorized Screen
// class UnauthorizedScreen extends StatelessWidget {
//   const UnauthorizedScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Unauthorized'),
//         backgroundColor: Colors.red,
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.lock_outline,
//               size: 100,
//               color: Colors.red[300],
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Access Denied',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red,
//               ),
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               'You do not have permission to access this page.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: () {
//                 final authProvider = Provider.of<AuthProvider>(context, listen: false);
//                 authProvider.logout();
//               },
//               icon: const Icon(Icons.logout),
//               label: const Text('Logout'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }