// lib/data/repositories/auth_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';

class AuthRepository {
  UserModel? _currentUser;
  String? _token;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;

  /// Đăng nhập
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'username': email,
          'passHash': password,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded);
        
        // Data có dạng { "success": true, "data": { "token": "..." } } 
        // Hoặc trả thẳng AuthResponse tuỳ backend, nhưng UserController dùng ApiResponse.success(authResponse)
        if (data['success'] == true && data['data'] != null) {
          _token = data['data']['token'];
          
          // Lấy danh sách users để tìm user vừa đăng nhập
          return await _fetchCurrentUser(email);
        }
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<UserModel?> _fetchCurrentUser(String username) async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.users));
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded);
        if (data['success'] == true && data['data'] != null) {
          final List usersList = data['data'];
          for (var u in usersList) {
            if (u['username'] == username || u['email'] == username) {
              final userModel = UserModel.fromJson(u);
              _currentUser = userModel;
              return userModel;
            }
          }
        }
      }
      return null;
    } catch (e) {
      print('Fetch current user error: $e');
      return null;
    }
  }

  /// Đăng ký
  Future<UserModel?> register(UserModel user) async {
    try {
      Map<String, dynamic> roleMap;
      if (user.role == UserRole.admin) {
        roleMap = {'id': 1, 'name': 'ADMIN'};
      } else if (user.role == UserRole.recruiter) {
        roleMap = {'id': 2, 'name': 'EMPLOYER'};
      } else {
        roleMap = {'id': 3, 'name': 'CANDIDATE'};
      }

      String? birthdayStr;
      if (user.birthday != null) {
        final b = user.birthday!;
        birthdayStr = '${b.year.toString().padLeft(4, '0')}-${b.month.toString().padLeft(2, '0')}-${b.day.toString().padLeft(2, '0')}';
      }

      final response = await http.post(
        Uri.parse(ApiConstants.users),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'username': user.email,
          'name': user.name,
          'email': user.email,
          'passHash': user.password,
          'sdt': user.phone,
          'gender': user.gender,
          'birthday': birthdayStr,
          'role': roleMap,
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded);
        if (data['success'] == true && data['data'] != null) {
          _currentUser = UserModel.fromJson(data['data']);
          return _currentUser;
        }
      }
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  /// Reset password (giả lập vì backend không có)
  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }

  /// Logout
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
  }

  /// Lấy current user
  UserModel? getCurrentUser() => _currentUser;

  /// Kiểm tra quyền truy cập
  bool hasAccess(UserRole requiredRole) {
    if (_currentUser == null) return false;
    if (_currentUser!.role == UserRole.admin) return true;
    return _currentUser!.role == requiredRole;
  }

  /// Quick login để test (lấy bừa một user theo role)
  Future<UserModel?> quickLogin(UserRole role) async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.users));
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded);
        if (data['success'] == true && data['data'] != null) {
          final List usersList = data['data'];
          for (var u in usersList) {
            final userModel = UserModel.fromJson(u);
            if (userModel.role == role) {
              _currentUser = userModel;
              return userModel;
            }
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
