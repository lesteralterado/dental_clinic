import 'package:equatable/equatable.dart';

/// User role enum - matches backend (ADMIN, DOCTOR, RECEPTIONIST)
enum UserRole {
  admin,
  doctor,
  receptionist;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.receptionist:
        return 'Receptionist';
    }
  }

  /// Convert from backend string (e.g., 'ADMIN' -> admin)
  static UserRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'DOCTOR':
        return UserRole.doctor;
      case 'RECEPTIONIST':
        return UserRole.receptionist;
      default:
        return UserRole.receptionist;
    }
  }

  /// Convert to backend string (e.g., admin -> 'ADMIN')
  String toBackendString() {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.doctor:
        return 'DOCTOR';
      case UserRole.receptionist:
        return 'RECEPTIONIST';
    }
  }
}

/// User data model
class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  List<Object?> get props =>
      [id, email, name, role, isActive, createdAt, updatedAt];
}

/// Authentication response model
class AuthResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
