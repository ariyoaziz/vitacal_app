import 'package:vitacal_app/models/user_model.dart'; // Sesuaikan dengan nama proyek Anda

class OtpResponse {
  final String message;
  final User user;
  final String otp; // Kode OTP yang dikirim dari backend

  OtpResponse({
    required this.message,
    required this.user,
    required this.otp,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      otp: json['user']['otp']
          as String, // OTP ada di dalam objek user di respons Anda
    );
  }
}
