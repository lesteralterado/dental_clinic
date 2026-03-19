/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Dental Clinic';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userData = 'user_data';
  static const String themeMode = 'theme_mode';
  static const String lastSyncTime = 'last_sync_time';
  static const String deviceId = 'device_id';

  // Cache Duration
  static const int patientCacheDuration = 30; // days
  static const int appointmentCacheDuration = 1; // days
  static const int treatmentCacheDuration = 7; // days

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Face Recognition
  static const double faceRecognitionConfidence = 0.7;
  static const int faceDetectionTimeout = 5000; // milliseconds

  // QR Code
  static const String qrCodePrefix = 'dental_clinic_patient_';

  // Animation
  static const int defaultAnimationDuration = 300;
  static const int shortAnimationDuration = 150;
  static const int longAnimationDuration = 500;

  // Appointment
  static const int defaultAppointmentDuration = 30; // minutes
  static const List<String> appointmentStatuses = [
    'scheduled',
    'confirmed',
    'in_progress',
    'completed',
    'cancelled',
    'no_show',
  ];

  // Patient Status Options
  static const List<String> maritalStatuses = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
    'Separated',
  ];

  // Gender Options
  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
  ];
}
