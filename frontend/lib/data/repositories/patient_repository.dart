import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/patient_model.dart';
import 'mock_data_repository.dart';

/// Patient repository - handles patient CRUD operations via Supabase
class PatientRepository {
  final ApiClient _apiClient;
  final MockDataRepository _mockDataRepo = MockDataRepository();

  PatientRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Check if running in mock mode
  Future<bool> _isMockMode() async {
    final token = await _apiClient.getAccessToken();
    if (token == null) return false;
    return _mockDataRepo.isMockToken(token);
  }

  /// Get all patients with optional pagination and search
  Future<PaginatedPatients> getPatients({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    // Check if in mock mode - return mock patients
    if (await _isMockMode()) {
      return _getMockPatients(page, limit, search);
    }

    try {
      final queryParams = <String, dynamic>{
        'select': '*',
        'order': 'created_at.desc',
        'limit': limit,
        'offset': (page - 1) * limit,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['or'] = '(name.ilike.*$search*,telephone.ilike.*$search*)';
      }

      final response = await _apiClient.get(
        ApiConstants.patients,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Supabase returns array directly
        final patients = (response.data as List)
            .map((json) => _parsePatientFromSupabase(json))
            .toList();

        return PaginatedPatients(
          patients: patients,
          total: patients.length,
          page: page,
          totalPages: (patients.length / limit).ceil(),
        );
      }
      return PaginatedPatients(patients: [], total: 0, page: 1, totalPages: 1);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get mock patients with pagination
  PaginatedPatients _getMockPatients(int page, int limit, String? search) {
    var patients = _mockDataRepo.getAllPatients();

    if (search != null && search.isNotEmpty) {
      final lowerSearch = search.toLowerCase();
      patients = patients
          .where((p) =>
              p.name.toLowerCase().contains(lowerSearch) ||
              p.telephone.contains(search))
          .toList();
    }

    // Sort by created date descending
    patients.sort((a, b) => (b.createdAt).compareTo(a.createdAt));

    final total = patients.length;
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    final paginatedPatients = patients.length > startIndex
        ? patients.sublist(
            startIndex, endIndex > patients.length ? patients.length : endIndex)
        : <PatientModel>[];

    return PaginatedPatients(
      patients: paginatedPatients,
      total: total,
      page: page,
      totalPages: (total / limit).ceil(),
    );
  }

  /// Search patients by name or telephone
  Future<List<PatientModel>> searchPatients(String query) async {
    // Check if in mock mode - return mock search results
    if (await _isMockMode()) {
      return _mockDataRepo.searchPatients(query);
    }

    try {
      final response = await _apiClient.get(
        ApiConstants.patientSearch,
        queryParameters: {
          'or':
              '(name.ilike.*$query*,telephone.ilike.*$query*,qr_code.ilike.*$query*)',
          'limit': 10,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => _parsePatientFromSupabase(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get patient by QR code
  Future<PatientModel?> getPatientByQrCode(String qrCode) async {
    // Check if in mock mode - return mock patient
    if (await _isMockMode()) {
      final patients = _mockDataRepo.getAllPatients();
      try {
        return patients.firstWhere((p) => p.qrCode == qrCode);
      } catch (_) {
        return null;
      }
    }

    try {
      final response = await _apiClient.get(
        '${ApiConstants.patients}?qr_code=eq.$qrCode',
      );

      if (response.statusCode == 200 && (response.data as List).isNotEmpty) {
        return _parsePatientFromSupabase(response.data[0]);
      }
      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get recent patients
  Future<List<PatientModel>> getRecentPatients({int limit = 5}) async {
    // Check if in mock mode - return mock patients
    if (await _isMockMode()) {
      final patients = _mockDataRepo.getAllPatients();
      patients.sort((a, b) =>
          (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt));
      return patients.take(limit).toList();
    }

    try {
      final response = await _apiClient.get(
        ApiConstants.patientRecent,
        queryParameters: {
          'order': 'updated_at.desc',
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => _parsePatientFromSupabase(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get frequent patients
  Future<List<PatientModel>> getFrequentPatients() async {
    // Check if in mock mode - return mock patients
    if (await _isMockMode()) {
      return _mockDataRepo.getFrequentPatients();
    }

    try {
      final response = await _apiClient.get(
        ApiConstants.patientFrequent,
        queryParameters: {
          'is_frequent': 'eq.true',
          'order': 'name.asc',
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => _parsePatientFromSupabase(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get patient by ID
  Future<PatientModel?> getPatientById(String id) async {
    // Check if in mock mode - return mock patient
    if (await _isMockMode()) {
      return _mockDataRepo.getPatientById(id);
    }

    try {
      final response = await _apiClient.get(
        '${ApiConstants.patients}?id=eq.$id',
      );

      if (response.statusCode == 200 && (response.data as List).isNotEmpty) {
        return _parsePatientFromSupabase(response.data[0]);
      }
      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new patient
  Future<PatientModel> createPatient({
    required String name,
    required String address,
    required String telephone,
    required int age,
    String? occupation,
    String? status,
    String? complaint,
    String? gender,
    String? email,
    String? emergencyContact,
    String? emergencyPhone,
    String? medicalNotes,
    String? allergies,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.patients,
        data: {
          'qr_code': 'DC-${DateTime.now().millisecondsSinceEpoch}',
          'name': name,
          'address': address,
          'telephone': telephone,
          'age': age,
          'occupation': occupation,
          'status': status ?? 'Active',
          'complaint': complaint,
          'gender': gender,
          'email': email,
          'emergency_contact': emergencyContact,
          'emergency_phone': emergencyPhone,
          'medical_notes': medicalNotes,
          'allergies': allergies,
          'is_frequent': false,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _parsePatientFromSupabase(response.data);
      }
      throw Exception('Failed to create patient');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update a patient
  Future<PatientModel> updatePatient(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.patients}?id=eq.$id',
        data: data,
      );

      if (response.statusCode == 200 && (response.data as List).isNotEmpty) {
        return _parsePatientFromSupabase(response.data[0]);
      }
      throw Exception('Failed to update patient');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a patient
  Future<void> deletePatient(String id) async {
    try {
      await _apiClient.delete('${ApiConstants.patients}?id=eq.$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Parse patient from Supabase response (handles snake_case)
  PatientModel _parsePatientFromSupabase(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String? ?? '',
      qrCode: json['qr_code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      occupation: json['occupation'] as String?,
      status: json['status'] as String?,
      complaint: json['complaint'] as String?,
      gender: json['gender'] as String?,
      email: json['email'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      emergencyPhone: json['emergency_phone'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      allergies: json['allergies'] as String?,
      isFrequent: json['is_frequent'] as bool? ?? false,
      lastVisit: json['last_visit'] != null
          ? DateTime.tryParse(json['last_visit'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  String _handleError(DioException e) {
    // Handle specific Supabase error messages
    final errorData = e.response?.data;

    if (errorData != null) {
      // Check for JWT-related errors
      final errorMsg =
          errorData['msg'] ?? errorData['message'] ?? errorData['error'] ?? '';
      if (errorMsg.toString().contains('JWT') ||
          errorMsg.toString().contains('cryptography')) {
        return 'Session expired. Please login again.';
      }
      if (errorMsg.toString().contains('refresh_token') ||
          errorMsg.toString().contains('invalid_grant')) {
        return 'Session expired. Please login again.';
      }

      return errorMsg.toString();
    }

    // Handle Dio-specific errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    }

    return 'An error occurred. Please try again.';
  }
}

/// Paginated patients result
class PaginatedPatients {
  final List<PatientModel> patients;
  final int total;
  final int page;
  final int totalPages;

  PaginatedPatients({
    required this.patients,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}
