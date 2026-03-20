import 'package:equatable/equatable.dart';

/// Patient data model - compatible with backend API
class PatientModel extends Equatable {
  final String id;
  final String qrCode;
  final String? qrCodeData; // Generated QR code image (base64)
  final String name;
  final String address;
  final String telephone;
  final int age;
  final String? occupation;
  final String? status;
  final String? complaint;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? email;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? medicalNotes;
  final String? allergies;
  final bool isFrequent;
  final DateTime? lastVisit;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PatientModel({
    required this.id,
    required this.qrCode,
    this.qrCodeData,
    required this.name,
    required this.address,
    required this.telephone,
    required this.age,
    this.occupation,
    this.status,
    this.complaint,
    this.gender,
    this.dateOfBirth,
    this.email,
    this.emergencyContact,
    this.emergencyPhone,
    this.medicalNotes,
    this.allergies,
    this.isFrequent = false,
    this.lastVisit,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      qrCode: json['qrCode'] as String? ?? json['qr_code'] as String? ?? '',
      qrCodeData:
          json['qrCodeData'] as String? ?? json['qr_code_data'] as String?,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      occupation: json['occupation'] as String?,
      status: json['status'] as String?,
      complaint: json['complaint'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : (json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'] as String)
              : null),
      email: json['email'] as String?,
      emergencyContact: json['emergencyContact'] as String? ??
          json['emergency_contact'] as String?,
      emergencyPhone: json['emergencyPhone'] as String? ??
          json['emergency_phone'] as String?,
      medicalNotes:
          json['medicalNotes'] as String? ?? json['medical_notes'] as String?,
      allergies: json['allergies'] as String?,
      isFrequent:
          json['isFrequent'] as bool? ?? json['is_frequent'] as bool? ?? false,
      lastVisit: json['lastVisit'] != null
          ? DateTime.parse(json['lastVisit'] as String)
          : (json['last_visit'] != null
              ? DateTime.parse(json['last_visit'] as String)
              : null),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : (json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : DateTime.now()),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qrCode': qrCode,
      'qrCodeData': qrCodeData,
      'name': name,
      'address': address,
      'telephone': telephone,
      'age': age,
      'occupation': occupation,
      'status': status,
      'complaint': complaint,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'email': email,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'medicalNotes': medicalNotes,
      'allergies': allergies,
      'isFrequent': isFrequent,
      'lastVisit': lastVisit?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  PatientModel copyWith({
    String? id,
    String? qrCode,
    String? qrCodeData,
    String? name,
    String? address,
    String? telephone,
    int? age,
    String? occupation,
    String? status,
    String? complaint,
    String? gender,
    DateTime? dateOfBirth,
    String? email,
    String? emergencyContact,
    String? emergencyPhone,
    String? medicalNotes,
    String? allergies,
    bool? isFrequent,
    DateTime? lastVisit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      qrCode: qrCode ?? this.qrCode,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      name: name ?? this.name,
      address: address ?? this.address,
      telephone: telephone ?? this.telephone,
      age: age ?? this.age,
      occupation: occupation ?? this.occupation,
      status: status ?? this.status,
      complaint: complaint ?? this.complaint,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      allergies: allergies ?? this.allergies,
      isFrequent: isFrequent ?? this.isFrequent,
      lastVisit: lastVisit ?? this.lastVisit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get initials from name
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        qrCode,
        qrCodeData,
        name,
        address,
        telephone,
        age,
        occupation,
        status,
        complaint,
        gender,
        dateOfBirth,
        email,
        emergencyContact,
        emergencyPhone,
        medicalNotes,
        allergies,
        isFrequent,
        lastVisit,
        createdAt,
        updatedAt,
      ];
}
