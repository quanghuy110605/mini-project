// lib/data/models/job_model.dart

enum JobStatus { open, closed }

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final int salaryMin;
  final int salaryMax;
  final JobStatus status;
  final String description;
  final String requirement;
  final String benefit;
  final String experience;
  final String employmentType; // Full-time, Part-time, Intern
  final int quantity;
  final DateTime deadline;
  final List<String> tags;
  final String recruiterId;
  final DateTime postedAt;
  final String? logoUrl;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salaryMin,
    required this.salaryMax,
    required this.status,
    required this.description,
    required this.requirement,
    required this.benefit,
    required this.experience,
    required this.employmentType,
    required this.quantity,
    required this.deadline,
    required this.tags,
    required this.recruiterId,
    required this.postedAt,
    this.logoUrl,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      company: json['company'] != null ? (json['company']['name'] ?? '') : '',
      location: json['location'] ?? '',
      salaryMin: json['salaryMin'] ?? 0,
      salaryMax: json['salaryMax'] ?? 0,
      status: (json['status'] == 'active' || json['status'] == 'ACTIVE') ? JobStatus.open : JobStatus.closed,
      description: json['description'] ?? '',
      requirement: json['requirement'] ?? '',
      benefit: json['benefit'] ?? '',
      experience: json['experience'] ?? '',
      employmentType: json['employmentType'] ?? '',
      quantity: json['quantity'] ?? 0,
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline']) ?? DateTime.now() : DateTime.now(),
      tags: [], // Tags aren't in the Job entity currently
      recruiterId: json['recruiter'] != null ? (json['recruiter']['id']?.toString() ?? '') : '',
      postedAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      logoUrl: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': {'name': company},
      'location': location,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'status': status == JobStatus.open ? 'active' : 'inactive',
      'description': description,
      'requirement': requirement,
      'benefit': benefit,
      'experience': experience,
      'employmentType': employmentType,
      'quantity': quantity,
      'deadline': deadline.toIso8601String(),
    };
  }

  String get salaryDisplay {
    final min = (salaryMin / 1000000).toStringAsFixed(0);
    final max = (salaryMax / 1000000).toStringAsFixed(0);
    return '$min - ${max}M VNĐ';
  }

  bool get isOpen => status == JobStatus.open;

  JobModel copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    int? salaryMin,
    int? salaryMax,
    JobStatus? status,
    String? description,
    String? requirement,
    String? benefit,
    String? experience,
    String? employmentType,
    int? quantity,
    DateTime? deadline,
    List<String>? tags,
    String? recruiterId,
    DateTime? postedAt,
    String? logoUrl,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      status: status ?? this.status,
      description: description ?? this.description,
      requirement: requirement ?? this.requirement,
      benefit: benefit ?? this.benefit,
      experience: experience ?? this.experience,
      employmentType: employmentType ?? this.employmentType,
      quantity: quantity ?? this.quantity,
      deadline: deadline ?? this.deadline,
      tags: tags ?? this.tags,
      recruiterId: recruiterId ?? this.recruiterId,
      postedAt: postedAt ?? this.postedAt,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
