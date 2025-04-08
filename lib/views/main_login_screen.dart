import 'package:flutter/material.dart';
import 'package:movieom_app/widgets/movieom_logo.dart';

class MainLoginScreen extends StatefulWidget {
  const MainLoginScreen({super.key});

  @override
  State<MainLoginScreen> createState() => _MainLoginScreenState();
}

class _MainLoginScreenState extends State<MainLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const MovieomLogo(),
        
              // Logo
              Transform.translate(
                offset: const Offset(0, -100),
                child: Image.asset('assets/images/logo.png', height: 400),
              ),
        
              // Register Button
              Transform.translate(
                offset: const Offset(0, -150),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Handle register
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F54D1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20), // tăng kích thước
                    ),
                    child: const Text(
                      "Đăng ký tài khoản",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        fontFamily: 'Roboto', // dùng Roboto
                      ),
                    ),
                  ),
                ),
              ),
        
              const SizedBox(height: 16),
        
              // Facebook Button
              Transform.translate(
                offset: const Offset(0, -150),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Facebook login
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20), // tăng kích thước
                    ),
                    child: const Text(
                      "Đăng nhập bằng Facebook",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ),
        
              const SizedBox(height: 24),
        
              // Text Link to Login
              Transform.translate(
                offset: const Offset(0, -150),
                child: GestureDetector(
                  onTap: () {
                    // TODO: navigate to login screen
                  },
                  child: const Text(
                    "Đăng nhập",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
