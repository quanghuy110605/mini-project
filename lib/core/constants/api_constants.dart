// lib/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8080/api';

  // Auth endpoints
  static const String login = '$baseUrl/users/login';
  static const String register = '$baseUrl/users';

  // Users endpoints
  static const String users = '$baseUrl/users';

  // Job endpoints
  static const String jobs = '$baseUrl/job';

  // Application endpoints
  static const String applications = '$baseUrl/applications';

  // CV endpoints
  static const String cvs = '$baseUrl/cv';
}
