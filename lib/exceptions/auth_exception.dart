// lib/exceptions/auth_exception.dart

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() {
    return message; // Hanya mengembalikan pesan, tanpa prefiks "Exception: "
  }
}
