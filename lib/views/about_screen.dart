import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/widgets/support_page_layout.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SupportPageLayout(
      title: 'Về Movieom',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App logo and name
          Center(
            child: Column(
              children: [
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
                      'assets/images/app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'MOVIEOM',
                  style: GoogleFonts.rubikDoodleShadow(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Phiên bản 1.0.0',
                  style: GoogleFonts.aBeeZee(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // About the app
          const SectionTitle('Giới thiệu'),
          const Paragraph(
            'Movieom là ứng dụng xem phim trực tuyến được phát triển với cảm hứng từ Netflix. Ứng dụng được tạo ra bởi nhóm sinh viên năm 3 với mục đích hiểu sâu về cách thức hoạt động của một ứng dụng di động và áp dụng kiến thức từ môn học Lập Trình Thiết Bị Di Động.'
          ),
          const Paragraph(
            'Ứng dụng cung cấp trải nghiệm xem phim mượt mà với giao diện thân thiện, cho phép người dùng dễ dàng tìm kiếm và thưởng thức các bộ phim yêu thích.'
          ),
          
          const SectionTitle('Thông tin học phần'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3F54D1).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.book, color: Color(0xFF3F54D1)),
                    const SizedBox(width: 8),
                    Text(
                      'Mã học phần: 010112103403',
                      style: GoogleFonts.aBeeZee(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Lập Trình Thiết Bị Di Động',
                  style: GoogleFonts.aBeeZee(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Lớp: CN22D',
                  style: GoogleFonts.aBeeZee(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SectionTitle('Nhóm phát triển'),
          const DeveloperCard(
            name: 'Nguyễn Minh Trực',
            studentId: '2251120392',
            role: 'Trưởng nhóm & Phát triển Backend',
            githubUrl: 'https://github.com/MinhTruc09',
          ),
          const DeveloperCard(
            name: 'Nguyễn Thanh Khang',
            studentId: '2251120355',
            role: 'UI/UX Designer & Frontend Developer',
            githubUrl: 'https://github.com/tkhan2004',
          ),
          const DeveloperCard(
            name: 'Trần Minh Hoàng',
            studentId: '2251120351',
            role: 'Database Engineer & Tester',
            githubUrl: 'https://github.com/TranMinhHoang267',
          ),
          
          const SectionTitle('Công nghệ sử dụng'),
          _buildTechItem('Flutter & Dart', 'Framework và ngôn ngữ chính'),
          _buildTechItem('Firebase', 'Xác thực và cơ sở dữ liệu'),
          _buildTechItem('RESTful API', 'Kết nối dữ liệu phim'),
          _buildTechItem('Video Player & Chewie', 'Trình phát video tích hợp'),
          
          const SizedBox(height: 24),
          InkWell(
            onTap: () => _launchURL('https://github.com/MinhTruc09/LTD-.git'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3F54D1).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.code, color: Color(0xFF3F54D1)),
                  const SizedBox(width: 8),
                  Text(
                    'Xem mã nguồn trên GitHub',
                    style: GoogleFonts.aBeeZee(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          Center(
            child: Text(
              '© 2024 Movieom. Đây là dự án học tập.',
              style: GoogleFonts.aBeeZee(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTechItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3F54D1).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Color(0xFF3F54D1),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.aBeeZee(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.aBeeZee(
                    fontSize: 14,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 