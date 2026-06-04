// lib/data/repositories/application_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/application_model.dart';
import '../../core/constants/api_constants.dart';

class ApplicationRepository {
  /// Lấy toàn bộ applications
  Future<List<ApplicationModel>> getApplications() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.applications));
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded);
        if (data is List) {
          return data.map((j) => ApplicationModel.fromJson(j)).toList();
        } else if (data['data'] is List) {
          final List list = data['data'];
          return list.map((j) => ApplicationModel.fromJson(j)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting applications: $e');
      return [];
    }
  }

  /// Lấy applications theo recruiter (qua jobId)
  Future<List<ApplicationModel>> getApplicationsByJobIds(
      List<String> jobIds) async {
    final allApps = await getApplications();
    return allApps.where((a) => jobIds.contains(a.jobId)).toList();
  }

  /// Lấy applications của candidate
  Future<List<ApplicationModel>> getApplicationsByCandidate(
      String candidateId) async {
    final allApps = await getApplications();
    return allApps.where((a) => a.candidateId == candidateId).toList();
  }

  /// Cập nhật trạng thái application
  Future<bool> updateStatus(
      String applicationId, ApplicationStatus status) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.applications}/$applicationId/status'), // Giả sử có endpoint này
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'status': status.name.toUpperCase(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Nộp đơn ứng tuyển
  Future<ApplicationModel> apply({
    required String jobId,
    required String candidateId,
    required String cvId,
    required String jobTitle,
    required String companyName,
    required String coverLetter,
  }) async {
    try {
      final app = ApplicationModel(
        id: '',
        jobId: jobId,
        candidateId: candidateId,
        candidateName: '',
        candidateEmail: '',
        cvId: cvId,
        jobTitle: jobTitle,
        companyName: companyName,
        coverLetter: coverLetter,
        status: ApplicationStatus.pending,
        appliedAt: DateTime.now(),
      );

      final response = await http.post(
        Uri.parse(ApiConstants.applications),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(app.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded);
        if (data['data'] != null) {
          return ApplicationModel.fromJson(data['data']);
        }
        return app.copyWith(id: 'app_${DateTime.now().millisecondsSinceEpoch}'); // fallback
      }
      throw Exception('Failed to apply');
    } catch (e) {
      print('Apply error: $e');
      throw Exception('Error applying: $e');
    }
  }
}
