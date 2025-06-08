// lib/exceptions/api_exception.dart

// ignore_for_file: prefer_interpolation_to_compose_strings

class ApiException implements Exception {
  final String message;
  final int? statusCode; // Optional: to store HTTP status code

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'ApiException: $message' +
        (statusCode != null ? ' (Status: $statusCode)' : '');
  }
}
