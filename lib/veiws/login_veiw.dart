import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_chat/viewmodels/auth_veiwmodel.dart';


class PhoneLoginView extends StatelessWidget {
  final AuthViewModel controller = Get.put(AuthViewModel());

  PhoneLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌈 App Title
              Text(
                "ChatApp",
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Connect instantly with people you care about 💬",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: size.height * 0.08),

              // 📞 Label
              Text(
                "Enter your phone number",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // 📱 Text Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 15),
                    const Text(
                      "+91",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.poppins(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: "Enter phone number",
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.05),

              // 🚀 Send OTP button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                    // ignore: deprecated_member_use
                    shadowColor: Colors.blueAccent.withOpacity(0.3),
                  ),
                  onPressed: () {
                    controller.verifyPhoneNumber();
                  },
                  child: Text(
                    "Send OTP",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.06),

              // 🛡 Info text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 20, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    "Your number is safe with us",
                    style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}