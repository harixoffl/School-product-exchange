// lib/services/auth_service.dart
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storageService = StorageService();
  User? _currentUser; // Track the currently logged-in user

  Future<bool> register(User user) async {
    try {
      final existingUser = await _storageService.getUser(user.email);
      if (existingUser != null) {
        return false; // User already exists
      }
      await _storageService.addUser(user);
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final user = await _storageService.getUser(email);
      if (user != null && user.password == password) {
        _currentUser = user; // Set the current user upon successful login
        return user;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final user = await _storageService.getUser(email);
      if (user != null) {
        // In a real app, we would update the user's password
        // For this demo, we'll just return true
        return true;
      }
      return false;
    } catch (e) {
      print('Password reset error: $e');
      return false;
    }
  }

  // Add this method to get the current user
  User? getCurrentUser() {
    return _currentUser;
  }

  // Add this method to logout
  void logout() {
    _currentUser = null;
  }
}
