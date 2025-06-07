// lib/exceptions/api_exception.dart

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
