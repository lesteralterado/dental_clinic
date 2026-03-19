import 'package:equatable/equatable.dart';
import 'patient_model.dart';

/// Appointment status enum
enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow;

  String get displayName {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  static AppointmentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'scheduled':
        return AppointmentStatus.scheduled;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'in_progress':
      case 'inprogress':
        return AppointmentStatus.inProgress;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'no_show':
      case 'noshow':
        return AppointmentStatus.noShow;
      default:
        return AppointmentStatus.scheduled;
    }
  }
}

/// Appointment data model
class AppointmentModel extends Equatable {
  final String id;
  final String patientId;
  final String? dentistId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final int duration;
  final AppointmentStatus status;
  final String? reason;
  final String? notes;
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PatientModel? patient;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    this.dentistId,
    required this.appointmentDate,
    required this.appointmentTime,
    this.duration = 30,
    this.status = AppointmentStatus.scheduled,
    this.reason,
    this.notes,
    this.isCheckedIn = false,
    this.checkedInAt,
    required this.createdAt,
    required this.updatedAt,
    this.patient,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      dentistId: json['dentistId'] as String?,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      appointmentTime: json['appointmentTime'] as String,
      duration: json['duration'] as int? ?? 30,
      status: AppointmentStatus.fromString(
          json['status'] as String? ?? 'scheduled'),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      isCheckedIn: json['isCheckedIn'] as bool? ?? false,
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      patient: json['patient'] != null
          ? PatientModel.fromJson(json['patient'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'dentistId': dentistId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'appointmentTime': appointmentTime,
      'duration': duration,
      'status': status.name,
      'reason': reason,
      'notes': notes,
      'isCheckedIn': isCheckedIn,
      'checkedInAt': checkedInAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? dentistId,
    DateTime? appointmentDate,
    String? appointmentTime,
    int? duration,
    AppointmentStatus? status,
    String? reason,
    String? notes,
    bool? isCheckedIn,
    DateTime? checkedInAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    PatientModel? patient,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      dentistId: dentistId ?? this.dentistId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      patient: patient ?? this.patient,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        dentistId,
        appointmentDate,
        appointmentTime,
        duration,
        status,
        reason,
        notes,
        isCheckedIn,
        checkedInAt,
        createdAt,
        updatedAt,
        patient,
      ];
}
