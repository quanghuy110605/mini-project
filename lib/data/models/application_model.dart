// lib/data/models/application_model.dart

enum ApplicationStatus { pending, reviewed, accepted, rejected, cancelled }

extension ApplicationStatusExtension on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Chờ duyệt';
      case ApplicationStatus.reviewed:
        return 'Đang xem xét';
      case ApplicationStatus.accepted:
        return 'Đã chấp nhận';
      case ApplicationStatus.rejected:
        return 'Đã từ chối';
      case ApplicationStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

class ApplicationModel {
  final String id;
  final String jobId;
  final String candidateId;
  final String candidateName;
  final String candidateEmail;
  final String cvId;
  final String jobTitle;
  final String companyName;
  final String coverLetter;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final String? recruiterNote;

  const ApplicationModel({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.candidateName,
    required this.candidateEmail,
    required this.cvId,
    required this.jobTitle,
    required this.companyName,
    required this.coverLetter,
    required this.status,
    required this.appliedAt,
    this.recruiterNote,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    ApplicationStatus parsedStatus = ApplicationStatus.pending;
    if (json['status'] == 'APPROVED' || json['status'] == 'ACCEPTED') {
      parsedStatus = ApplicationStatus.accepted;
    } else if (json['status'] == 'REJECTED') {
      parsedStatus = ApplicationStatus.rejected;
    } else if (json['status'] == 'REVIEWED') {
      parsedStatus = ApplicationStatus.reviewed;
    } else if (json['status'] == 'CANCELLED') {
      parsedStatus = ApplicationStatus.cancelled;
    }

    return ApplicationModel(
      id: json['id']?.toString() ?? '',
      jobId: json['job']?['id']?.toString() ?? '',
      candidateId: json['user']?['id']?.toString() ?? '',
      candidateName: json['user']?['name'] ?? json['user']?['username'] ?? 'Không rõ',
      candidateEmail: json['user']?['email'] ?? '',
      cvId: '', 
      jobTitle: json['job']?['title'] ?? '',
      companyName: json['job']?['company'] ?? '',
      coverLetter: json['coverLetter'] ?? '',
      status: parsedStatus,
      appliedAt: json['appliedAt'] != null ? DateTime.parse(json['appliedAt']) : DateTime.now(),
      recruiterNote: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job': {'id': int.tryParse(jobId)},
      'user': {'id': int.tryParse(candidateId)},
      'coverLetter': coverLetter,
      'status': status.name.toUpperCase(),
    };
  }

  ApplicationModel copyWith({
    String? id,
    String? jobId,
    String? candidateId,
    String? candidateName,
    String? candidateEmail,
    String? cvId,
    String? jobTitle,
    String? companyName,
    String? coverLetter,
    ApplicationStatus? status,
    DateTime? appliedAt,
    String? recruiterNote,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      candidateEmail: candidateEmail ?? this.candidateEmail,
      cvId: cvId ?? this.cvId,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      recruiterNote: recruiterNote ?? this.recruiterNote,
    );
  }
}
