/// Custom exceptions for the application
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Network exceptions
class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

/// Cache exceptions
class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Authentication exceptions
class AuthException implements Exception {
  final String message;

  AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}

/// Validation exceptions
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;

  ValidationException({required this.message, this.fieldErrors});

  @override
  String toString() => 'ValidationException: $message';
}

/// Face recognition exceptions
class FaceRecognitionException implements Exception {
  final String message;

  FaceRecognitionException({required this.message});

  @override
  String toString() => 'FaceRecognitionException: $message';
}

/// QR code exceptions
class QRCodeException implements Exception {
  final String message;

  QRCodeException({required this.message});

  @override
  String toString() => 'QRCodeException: $message';
}

/// Permission exceptions
class PermissionException implements Exception {
  final String message;

  PermissionException({required this.message});

  @override
  String toString() => 'PermissionException: $message';
}
