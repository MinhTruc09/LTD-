import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/controllers/auth_controller.dart';
import 'package:movieom_app/views/main_login_screen.dart';
import 'package:movieom_app/widgets/profile_containers.dart'; // Import ProfileContainers

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _authController = AuthController();
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = _authController.getCurrentUser();
    setState(() {
      _userName = user?.email;
    });
  }

  Future<void> _signOut() async {
    setState(() {
    });

    try {
      await _authController.signOut();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainLoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi khi đăng xuất: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text(
          'Thông tin cá nhân',
          style: GoogleFonts.aBeeZee(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Ảnh đại diện
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3F54D1),
                    width: 2.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/userlogo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Email người dùng
              Text(
                _userName ?? 'Chưa đăng nhập',
                style: GoogleFonts.aBeeZee(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F54D1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF3F54D1),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Thành viên',
                  style: GoogleFonts.aBeeZee(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Các container
              ProfileContainers(
                onSignOut: _signOut, // Truyền hàm đăng xuất
              ),
            ],
          ),
        ),
      ),
    );
  }
}
