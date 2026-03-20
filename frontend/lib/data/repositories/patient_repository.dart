import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/patient_model.dart';

/// Patient repository - handles patient CRUD operations via Supabase
class PatientRepository {
  final ApiClient _apiClient;

  PatientRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all patients with optional pagination and search
  Future<PaginatedPatients> getPatients({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
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

  /// Search patients by name or telephone
  Future<List<PatientModel>> searchPatients(String query) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.patientSearch,
        queryParameters: {
          'or': '(name.ilike.*$query*,telephone.ilike.*$query*)',
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

  /// Get recent patients
  Future<List<PatientModel>> getRecentPatients({int limit = 5}) async {
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
    return e.response?.data?['message'] ??
        e.response?.data?['error'] ??
        'An error occurred';
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
