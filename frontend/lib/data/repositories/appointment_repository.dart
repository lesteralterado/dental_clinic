import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/appointment_model.dart';

/// Appointment repository - handles appointment CRUD operations via API
class AppointmentRepository {
  final ApiClient _apiClient;

  AppointmentRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Get all appointments with optional filters
  Future<List<AppointmentModel>> getAppointments({
    String? date,
    String? dentistId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date;
      if (dentistId != null) queryParams['dentistId'] = dentistId;
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.get(
        ApiConstants.appointments,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get today's appointments
  Future<List<AppointmentModel>> getTodayAppointments() async {
    try {
      final response = await _apiClient.get(ApiConstants.appointmentsToday);

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get weekly appointments
  Future<List<AppointmentModel>> getWeekAppointments(
      {String? startDate}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start'] = startDate;

      final response = await _apiClient.get(
        ApiConstants.appointmentsWeek,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get appointments by date
  Future<List<AppointmentModel>> getAppointmentsByDate(DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return getAppointments(date: dateStr);
  }

  /// Get appointment by ID
  Future<AppointmentModel?> getAppointmentById(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.appointments}/$id');

      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get appointments by patient ID
  Future<List<AppointmentModel>> getAppointmentsByPatientId(
      String patientId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.appointments,
        queryParameters: {'patientId': patientId},
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new appointment
  Future<AppointmentModel> createAppointment({
    required String patientId,
    String? dentistId,
    required DateTime appointmentDate,
    required String appointmentTime,
    int duration = 30,
    String? reason,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.appointments,
        data: {
          'patientId': patientId,
          'dentistId': dentistId,
          'appointmentDate': appointmentDate.toIso8601String().split('T')[0],
          'appointmentTime': appointmentTime,
          'duration': duration,
          'reason': reason,
          'notes': notes,
        },
      );

      if (response.statusCode == 201) {
        return AppointmentModel.fromJson(response.data);
      }
      throw Exception('Failed to create appointment');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an appointment
  Future<AppointmentModel> updateAppointment(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.appointments}/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(response.data);
      }
      throw Exception('Failed to update appointment');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel an appointment
  Future<void> cancelAppointment(String id) async {
    try {
      await _apiClient.delete('${ApiConstants.appointments}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Check-in patient for appointment
  Future<AppointmentModel> checkIn(String id) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.appointments}/$id/checkin',
      );

      if (response.statusCode == 200) {
        return AppointmentModel.fromJson(response.data);
      }
      throw Exception('Failed to check in');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    return e.response?.data['message'] ?? 'An error occurred';
  }
}
