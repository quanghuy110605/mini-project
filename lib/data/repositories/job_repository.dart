// lib/data/repositories/job_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';
import '../../core/constants/api_constants.dart';

class JobRepository {
  /// Lấy toàn bộ danh sách jobs
  Future<List<JobModel>> getJobs() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.jobs));
      if (response.statusCode == 200) {
        // UTF-8 decode body
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => JobModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      print('Error fetching jobs: $e');
      return [];
    }
  }

  /// Tìm kiếm theo keyword và filter theo location (Client-side vì backend chưa hỗ trợ search endpoint)
  Future<List<JobModel>> searchJobs({
    String? keyword,
    String? location,
    JobStatus? status,
  }) async {
    final jobs = await getJobs();

    return jobs.where((job) {
      final matchKeyword = keyword == null ||
          keyword.isEmpty ||
          job.title.toLowerCase().contains(keyword.toLowerCase()) ||
          job.company.toLowerCase().contains(keyword.toLowerCase());

      final matchLocation = location == null ||
          location.isEmpty ||
          location == 'all' ||
          job.location == location;

      final matchStatus = status == null || job.status == status;

      return matchKeyword && matchLocation && matchStatus;
    }).toList();
  }

  /// Lấy danh sách địa điểm duy nhất (Client-side)
  Future<List<String>> getLocations() async {
    final jobs = await getJobs();
    final locations = jobs.map((j) => j.location).toSet().toList();
    locations.sort();
    return locations;
  }

  /// Lấy job theo id
  Future<JobModel?> getJobById(String id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.jobs}/$id'));
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);
        return JobModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching job by id: $e');
      return null;
    }
  }

  /// Lấy jobs của recruiter (Async)
  Future<List<JobModel>> getJobsByRecruiter(String recruiterId) async {
    final jobs = await getJobs();
    return jobs.where((j) => j.recruiterId == recruiterId).toList();
  }

  /// Lưu hoặc cập nhật job
  Future<bool> saveJob(JobModel job) async {
    try {
      final isUpdate = job.id.isNotEmpty;
      final uri = isUpdate 
          ? Uri.parse('${ApiConstants.jobs}/${job.id}')
          : Uri.parse(ApiConstants.jobs);

      final response = isUpdate 
          ? await http.put(
              uri,
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: json.encode(job.toJson()),
            )
          : await http.post(
              uri,
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: json.encode(job.toJson()),
            );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saving job: $e');
      return false;
    }
  }

  /// Xóa job
  Future<bool> deleteJob(String jobId) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConstants.jobs}/$jobId'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting job: $e');
      return false;
    }
  }
}
