import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/patient_model.dart';
import '../models/appointment_model.dart';
import 'mock_data_repository.dart';

/// Dashboard repository - handles dashboard statistics via API
class DashboardRepository {
  final ApiClient _apiClient;
  final MockDataRepository _mockDataRepo = MockDataRepository();

  DashboardRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Check if running in mock mode
  Future<bool> _isMockMode() async {
    final token = await _apiClient.getAccessToken();
    if (token == null) return false;
    return _mockDataRepo.isMockToken(token);
  }

  /// Get dashboard statistics
  Future<DashboardStats> getStats() async {
    // Check if in mock mode - return mock stats
    if (await _isMockMode()) {
      return _getMockStats();
    }

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

  /// Get mock statistics from mock data
  DashboardStats _getMockStats() {
    final patients = _mockDataRepo.getAllPatients();
    final appointments = _mockDataRepo.getAllAppointments();
    final now = DateTime.now();

    // Filter today's appointments
    final todayAppointments = appointments.where((a) {
      final apptDate = a.appointmentDate;
      return apptDate.year == now.year &&
          apptDate.month == now.month &&
          apptDate.day == now.day;
    }).toList();

    final completedToday = todayAppointments
        .where((a) => a.status == AppointmentStatus.completed)
        .length;

    return DashboardStats(
      totalPatients: patients.length,
      todayAppointments: todayAppointments.length,
      completedToday: completedToday,
      pendingPayments: 0,
      date: now,
    );
  }

  /// Get recent patients for dashboard
  Future<List<PatientModel>> getRecentPatients({int limit = 5}) async {
    // Check if in mock mode - return mock patients
    if (await _isMockMode()) {
      final patients = _mockDataRepo.getAllPatients();
      // Sort by updated date descending
      patients.sort((a, b) =>
          (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt));
      return patients.take(limit).toList();
    }

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
