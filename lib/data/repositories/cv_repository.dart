// lib/data/repositories/cv_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cv_model.dart';
import '../../core/constants/api_constants.dart';

class CvRepository {
  /// Lấy danh sách toàn bộ CV
  Future<List<CvModel>> _getAllCvs() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.cvs));
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded);
        if (data is List) {
          return data.map((j) => CvModel.fromJson(j)).toList();
        } else if (data['data'] is List) {
          final List list = data['data'];
          return list.map((j) => CvModel.fromJson(j)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting cvs: $e');
      return [];
    }
  }

  /// Lấy CV của user (Backend Java có lấy cv qua api/cv/user/{userId} hoặc tìm trong toàn bộ)
  Future<CvModel?> getCvByUserId(String userId) async {
    try {
      final cvs = await _getAllCvs();
      return cvs.firstWhere((cv) => cv.userId == userId);
    } catch (_) {
      return null;
    }
  }

  /// Lấy CV theo id
  Future<CvModel?> getCvById(String cvId) async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.cvs}/$cvId'));
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded);
        if (data['data'] != null) {
          return CvModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Lưu / cập nhật CV
  Future<CvModel> saveCV(CvModel cv) async {
    try {
      final isUpdate = cv.id.isNotEmpty;
      final uri = isUpdate 
          ? Uri.parse('${ApiConstants.cvs}/${cv.id}')
          : Uri.parse(ApiConstants.cvs);

      final response = isUpdate
          ? await http.put(
              uri,
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: json.encode(cv.toJson()),
            )
          : await http.post(
              uri,
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: json.encode(cv.toJson()),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded);
        if (data['data'] != null) {
          return CvModel.fromJson(data['data']);
        }
      }
      return cv.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      print('Error saving CV: $e');
      return cv; // Return as-is on error to avoid breaking UI entirely during mockup phase
    }
  }
}
