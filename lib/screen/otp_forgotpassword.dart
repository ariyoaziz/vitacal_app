import 'package:flutter/material.dart';
import 'package:vitacal_app/screen/reset_password.dart';
import 'package:vitacal_app/themes/colors.dart';

class OtpForgotpassword extends StatefulWidget {
  const OtpForgotpassword({super.key});

  @override
  State<OtpForgotpassword> createState() => _OtpForgotpasswordState();
}

class _OtpForgotpasswordState extends State<OtpForgotpassword> {
  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  final TextEditingController controller4 = TextEditingController();

  // Fungsi untuk membuat TextField OTP
  Widget _otpTextField(BuildContext context, TextEditingController controller) {
    return SizedBox(
      width: 50, // Lebar input
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1, // Hanya 1 karakter
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Radius border
            borderSide: BorderSide(color: AppColors.primary, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary, width: 1),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: screenHeight * 0.08,
              bottom: screenHeight * 0.05,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Verivikasi OTP Kamu",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05), // Spasi antar elemen

                // Logo Image
                SizedBox(
                  child: Image.asset(
                    'assets/images/otp.png',
                  ),
                ),
                const SizedBox(height: 50),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Masukan kode 4 digit yang kami kirim ke nomor\n",
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: "whatsapp kamu, untuk verivikasi akun\n",
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.08),
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _otpTextField(context, controller1),
                    const SizedBox(width: 11),
                    _otpTextField(context, controller2),
                    const SizedBox(width: 11),
                    _otpTextField(context, controller3),
                    const SizedBox(width: 11),
                    _otpTextField(context, controller4),
                  ],
                ),
                SizedBox(height: screenHeight * 0.08),
                // Verify Button
                SizedBox(
                  width: screenWidth * 0.8,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppColors.greenGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // // Gabungkan semua input OTP
                        // String otp = controller1.text +
                        //     controller2.text +
                        //     controller3.text +
                        //     controller4.text;

                        // // Validasi OTP
                        // if (otp.length == 4) {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(content: Text('OTP: $otp')),
                        //   );
                        // } else {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(
                        //       content: Text('Please enter the complete OTP!'),
                        //     ),
                        //   );
                        // }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ResetPassword()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Konfirmasi",
                        style: TextStyle(
                          color: Colors
                              .white, // Warna teks agar tetap terlihat jelas
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
