// lib/data/models/user_model.dart

enum UserRole { candidate, recruiter, admin }

enum UserStatus { active, inactive }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? avatarUrl;
  final String? phone;
  final String? company;
  final String? gender;
  final DateTime? birthday;
  final UserStatus status;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.avatarUrl,
    this.phone,
    this.company,
    this.gender,
    this.birthday,
    this.status = UserStatus.active,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole = UserRole.candidate;
    if (json['role'] != null) {
      final roleName = json['role']['name']?.toString().toLowerCase() ?? '';
      if (roleName.contains('admin')) parsedRole = UserRole.admin;
      else if (roleName.contains('recruiter') || roleName.contains('employer') || roleName.contains('ntd')) parsedRole = UserRole.recruiter;
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      password: '', // do not store password from backend
      role: parsedRole,
      avatarUrl: null,
      phone: json['sdt'],
      company: null, // company is mapped differently in backend maybe
      gender: json['gender'],
      birthday: json['birthday'] != null ? DateTime.tryParse(json['birthday']) : null,
      status: (json['status'] == 'active' || json['status'] == 'ACTIVE') ? UserStatus.active : UserStatus.inactive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'sdt': phone,
      'gender': gender,
      'birthday': birthday?.toIso8601String(),
    };
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.candidate:
        return 'Ứng viên';
      case UserRole.recruiter:
        return 'Nhà tuyển dụng';
      case UserRole.admin:
        return 'Quản trị viên';
    }
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? avatarUrl,
    String? phone,
    String? company,
    String? gender,
    DateTime? birthday,
    UserStatus? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      status: status ?? this.status,
    );
  }
}
