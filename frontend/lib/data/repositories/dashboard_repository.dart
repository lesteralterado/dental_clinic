import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/patient_model.dart';

/// Dashboard repository - handles dashboard statistics via API
class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get dashboard statistics
  Future<DashboardStats> getStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.dashboardStats);

      if (response.statusCode == 200) {
        return DashboardStats.fromJson(response.data);
      }
      return DashboardStats.empty();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get recent patients for dashboard
  Future<List<PatientModel>> getRecentPatients({int limit = 5}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.dashboardRecent,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => PatientModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    return e.response?.data['message'] ?? 'An error occurred';
  }
}

/// Dashboard statistics model
class DashboardStats {
  final int totalPatients;
  final int todayAppointments;
  final int completedToday;
  final int pendingPayments;
  final DateTime? date;

  DashboardStats({
    required this.totalPatients,
    required this.todayAppointments,
    required this.completedToday,
    required this.pendingPayments,
    this.date,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalPatients: json['totalPatients'] ?? 0,
      todayAppointments: json['todayAppointments'] ?? 0,
      completedToday: json['completedToday'] ?? 0,
      pendingPayments: json['pendingPayments'] ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  factory DashboardStats.empty() {
    return DashboardStats(
      totalPatients: 0,
      todayAppointments: 0,
      completedToday: 0,
      pendingPayments: 0,
    );
  }

  Map<String, int> toMap() {
    return {
      'totalPatients': totalPatients,
      'todayAppointments': todayAppointments,
      'frequentPatients': 0, // Not provided by backend
      'completedAppointments': completedToday,
    };
  }
}
