// lib/models/user_model.dart

// Pastikan tidak ada import lain yang tidak diperlukan di sini
// (misal: otp_response_model.dart jika tidak digunakan langsung di User).

class User {
  final int userId; // <--- PASTIKAN TIPE INI ADALAH 'int'
  final String username;
  final String email;
  final String phone;
  final bool? verified; // Tetap nullable karena di login awal mungkin tidak ada
  final String createdAt;
  final String updatedAt;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.phone,
    this.verified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int, // <--- PASTIKAN INI 'as int'
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      verified: json['verified'] as bool?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'phone': phone,
      'verified': verified,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
