/// API Constants for the Dental Clinic application
class ApiConstants {
  ApiConstants._();

  // Base URL - Change this to your server URL
  static const String baseUrl = 'http://localhost:3000/api';

  // Endpoints
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String refresh = '$auth/refresh';
  static const String me = '$auth/me';

  static const String patients = '/patients';
  static const String patientSearch = '$patients/search';
  static const String patientRecent = '$patients/recent';
  static const String patientFrequent = '$patients/frequent';
  static const String patientIdentify = '/face/identify';
  static const String patientEnroll = '/face/enroll';

  static const String appointments = '/appointments';
  static const String appointmentsToday = '$appointments/today';
  static const String appointmentsWeek = '$appointments/week';

  static const String dashboard = '/dashboard';
  static const String dashboardStats = '$dashboard/stats';
  static const String dashboardRecent = '$dashboard/recent';

  static const String treatments = '/treatments';
  static const String payments = '/payments';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
