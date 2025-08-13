// lib/models/login_respon_model.dart

import 'package:equatable/equatable.dart'; // Digunakan untuk membandingkan objek model
import 'package:vitacal_app/models/user_model.dart'; // Pastikan path model User sudah benar

/// Merepresentasikan struktur respons dari API login yang berhasil.
/// Mengandung token akses, pesan, dan data detail pengguna.
class LoginResponseModel extends Equatable {
  // Token akses JWT yang diterima setelah login berhasil
  final String accessToken;
  // Pesan status dari server (misalnya "Login berhasil. Selamat datang!")
  final String message;
  // Objek User yang berisi detail pengguna yang login
  final User user;

  /// Konstruktor konstan untuk [LoginResponseModel].
  const LoginResponseModel({
    required this.accessToken,
    required this.message,
    required this.user,
  });

  /// Factory constructor untuk membuat instance [LoginResponseModel] dari Map JSON.
  /// Digunakan saat menerima respons data dari API.
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      // Mengambil 'access_token' dari JSON dan memastikan tipenya String
      accessToken: json['access_token'] as String,
      // Mengambil 'message' dari JSON dan memastikan tipenya String
      message: json['message'] as String,
      // Mengambil objek 'user' dari JSON dan mengonversinya ke model User
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Mengonversi instance [LoginResponseModel] ini kembali ke Map JSON.
  /// Berguna saat Anda perlu mengirim ulang data ini atau menyimpannya.
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'message': message,
      'user': user.toJson(), // Mengonversi objek User kembali ke JSON
    };
  }

  @override
  List<Object?> get props => [accessToken, message, user];
}
