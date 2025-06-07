// lib/exceptions/auth_exception.dart

class AuthException implements Exception {
  final String message;
  final int? userId; // <--- TAMBAHKAN INI
  final String? phoneNumber; // <--- TAMBAHKAN INI

  AuthException(this.message,
      {this.userId, this.phoneNumber}); // <--- SESUAIKAN CONSTRUCTOR

  @override
  String toString() =>
      'AuthException: $message' + (userId != null ? ' (User ID: $userId)' : '');
}
