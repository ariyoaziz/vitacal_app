class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

class AuthException implements Exception {
  final String message;
  final int? userId;
  final String? phoneNumber;

  // Pastikan HANYA constructor ini yang ada:
  const AuthException(this.message, {this.userId, this.phoneNumber});

  @override
  String toString() {
    String details = '';
    if (userId != null) {
      details += ' (User ID: $userId)';
    }
    if (phoneNumber != null) {
      details += ' (Phone: $phoneNumber)';
    }
    return 'AuthException: $message$details'; // Output toString() akan seperti ini
  }
}
