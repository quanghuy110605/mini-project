// lib/data/models/cv_model.dart

class EducationEntry {
  final String id;
  final String school;
  final String degree;
  final String major;
  final String startYear;
  final String endYear;
  final String? gpa;

  const EducationEntry({
    required this.id,
    required this.school,
    required this.degree,
    required this.major,
    required this.startYear,
    required this.endYear,
    this.gpa,
  });

  EducationEntry copyWith({
    String? id,
    String? school,
    String? degree,
    String? major,
    String? startYear,
    String? endYear,
    String? gpa,
  }) {
    return EducationEntry(
      id: id ?? this.id,
      school: school ?? this.school,
      degree: degree ?? this.degree,
      major: major ?? this.major,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      gpa: gpa ?? this.gpa,
    );
  }
}

class ExperienceEntry {
  final String id;
  final String company;
  final String position;
  final String startDate;
  final String endDate;
  final String description;
  final bool isCurrent;

  const ExperienceEntry({
    required this.id,
    required this.company,
    required this.position,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.isCurrent = false,
  });

  ExperienceEntry copyWith({
    String? id,
    String? company,
    String? position,
    String? startDate,
    String? endDate,
    String? description,
    bool? isCurrent,
  }) {
    return ExperienceEntry(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}

enum SkillLevel { beginner, intermediate, advanced, expert }

extension SkillLevelExtension on SkillLevel {
  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Cơ bản';
      case SkillLevel.intermediate:
        return 'Trung cấp';
      case SkillLevel.advanced:
        return 'Nâng cao';
      case SkillLevel.expert:
        return 'Chuyên gia';
    }
  }
}

class SkillEntry {
  final String id;
  final String name;
  final SkillLevel level;

  const SkillEntry({
    required this.id,
    required this.name,
    required this.level,
  });

  SkillEntry copyWith({String? id, String? name, SkillLevel? level}) {
    return SkillEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
    );
  }
}

class ProjectEntry {
  final String id;
  final String name;
  final String role;
  final String description;

  const ProjectEntry({
    required this.id,
    required this.name,
    required this.role,
    required this.description,
  });

  ProjectEntry copyWith({
    String? id,
    String? name,
    String? role,
    String? description,
  }) {
    return ProjectEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      description: description ?? this.description,
    );
  }
}

class CertificateEntry {
  final String id;
  final String name;
  final String issuedBy;
  final String issuedDate;

  const CertificateEntry({
    required this.id,
    required this.name,
    required this.issuedBy,
    required this.issuedDate,
  });

  CertificateEntry copyWith({
    String? id,
    String? name,
    String? issuedBy,
    String? issuedDate,
  }) {
    return CertificateEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      issuedBy: issuedBy ?? this.issuedBy,
      issuedDate: issuedDate ?? this.issuedDate,
    );
  }
}

class CvModel {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String? address;
  final String? birthday;
  final String? gender;
  final String? position;
  final String? careerObjective;
  final String? summary;
  final List<EducationEntry> education;
  final List<ExperienceEntry> experience;
  final List<SkillEntry> skills;
  final List<ProjectEntry> projects;
  final List<CertificateEntry> certificates;
  final DateTime updatedAt;

  const CvModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.address,
    this.birthday,
    this.gender,
    this.position,
    this.careerObjective,
    this.summary,
    required this.education,
    required this.experience,
    required this.skills,
    this.projects = const [],
    this.certificates = const [],
    required this.updatedAt,
  });

  factory CvModel.fromJson(Map<String, dynamic> json) {
    return CvModel(
      id: json['id']?.toString() ?? '',
      userId: json['user']?['id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      birthday: json['birthday'],
      gender: json['gender'],
      position: json['position'],
      careerObjective: json['careerObjective'],
      summary: null,
      education: [],
      experience: [],
      skills: [],
      projects: [],
      certificates: [],
      updatedAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {'id': int.tryParse(userId)},
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'birthday': birthday,
      'gender': gender,
      'position': position,
      'careerObjective': careerObjective,
    };
  }

  CvModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? birthday,
    String? gender,
    String? position,
    String? careerObjective,
    String? summary,
    List<EducationEntry>? education,
    List<ExperienceEntry>? experience,
    List<SkillEntry>? skills,
    List<ProjectEntry>? projects,
    List<CertificateEntry>? certificates,
    DateTime? updatedAt,
  }) {
    return CvModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      position: position ?? this.position,
      careerObjective: careerObjective ?? this.careerObjective,
      summary: summary ?? this.summary,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      certificates: certificates ?? this.certificates,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
