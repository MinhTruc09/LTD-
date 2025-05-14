import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/widgets/support_page_layout.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Làm thế nào để đăng ký tài khoản?',
      answer: 'Để đăng ký tài khoản, bạn cần vào màn hình đăng nhập và nhấn vào nút "Đăng ký". Sau đó, nhập email và mật khẩu của bạn để tạo tài khoản mới.',
    ),
    FAQItem(
      question: 'Làm thế nào để tìm kiếm phim?',
      answer: 'Bạn có thể tìm kiếm phim bằng cách nhấn vào biểu tượng tìm kiếm ở thanh điều hướng phía dưới. Sau đó, nhập tên phim bạn muốn tìm vào ô tìm kiếm.',
    ),
    FAQItem(
      question: 'Làm thế nào để thêm phim vào danh sách yêu thích?',
      answer: 'Để thêm phim vào danh sách yêu thích, bạn cần đăng nhập vào tài khoản của mình. Sau đó, mở chi tiết phim và nhấn vào biểu tượng trái tim ở góc phải trên cùng hoặc nút "Yêu thích" ở dưới cùng.',
    ),
    FAQItem(
      question: 'Làm thế nào để xem phim?',
      answer: 'Để xem phim, bạn cần mở chi tiết phim và nhấn vào nút "Xem phim". Nếu phim có nhiều tập, bạn có thể chọn tập bạn muốn xem từ danh sách các tập.',
    ),
    FAQItem(
      question: 'Tại sao tôi không thể xem phim?',
      answer: 'Có thể có một số lý do khiến bạn không thể xem phim, như kết nối internet không ổn định, phim đang được bảo trì, hoặc phim không có sẵn trong khu vực của bạn. Hãy thử làm mới ứng dụng hoặc kiểm tra kết nối internet của bạn.',
    ),
    FAQItem(
      question: 'Làm thế nào để đăng xuất?',
      answer: 'Để đăng xuất, bạn cần vào trang "Thông tin cá nhân" bằng cách nhấn vào biểu tượng người dùng ở thanh điều hướng phía dưới. Sau đó, cuộn xuống dưới và nhấn vào nút "Đăng xuất".',
    ),
    FAQItem(
      question: 'Làm thế nào để thay đổi mật khẩu?',
      answer: 'Nếu bạn quên mật khẩu, bạn có thể sử dụng chức năng "Quên mật khẩu" trên màn hình đăng nhập. Nếu bạn muốn thay đổi mật khẩu hiện tại, bạn có thể làm điều đó trong phần "Thông tin cá nhân".',
    ),
    FAQItem(
      question: 'Ứng dụng có tính phí không?',
      answer: 'Không, Movieom là một ứng dụng miễn phí được phát triển với mục đích học tập. Chúng tôi không thu phí người dùng cho việc sử dụng ứng dụng.',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  List<FAQItem> _filteredFaqItems = [];
  
  @override
  void initState() {
    super.initState();
    _filteredFaqItems = _faqItems;
  }
  
  void _filterFAQs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFaqItems = _faqItems;
      } else {
        _filteredFaqItems = _faqItems
            .where((item) =>
                item.question.toLowerCase().contains(query.toLowerCase()) ||
                item.answer.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SupportPageLayout(
      title: 'Trung tâm hỗ trợ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header image
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF3F54D1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline,
                size: 50,
                color: Color(0xFF3F54D1),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Center(
            child: Text(
              'Chúng tôi có thể giúp gì cho bạn?',
              style: GoogleFonts.aBeeZee(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: _filterFAQs,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm câu hỏi...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _filterFAQs('');
                      },
                    )
                  : null,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // FAQ Categories
          _buildCategoryButtons(),
          
          const SizedBox(height: 24),
          
          // FAQ Items
          Text(
            'Câu hỏi thường gặp',
            style: GoogleFonts.aBeeZee(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _filteredFaqItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off,
                          color: Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy câu hỏi phù hợp',
                          style: GoogleFonts.aBeeZee(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredFaqItems.length,
                  itemBuilder: (context, index) {
                    return _buildFAQItem(_filteredFaqItems[index]);
                  },
                ),
          
          const SizedBox(height: 32),
          
          // Additional help
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
                Text(
                  'Vẫn cần trợ giúp?',
                  style: GoogleFonts.aBeeZee(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nếu bạn không tìm thấy câu trả lời cho câu hỏi của mình, vui lòng liên hệ với chúng tôi qua:',
                  style: GoogleFonts.aBeeZee(
                    fontSize: 14,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildContactButton(
                      icon: Icons.email,
                      label: 'Email',
                      onTap: () {
                        Navigator.pushNamed(context, '/contact');
                      },
                    ),
                    _buildContactButton(
                      icon: Icons.phone,
                      label: 'Điện thoại',
                      onTap: () {
                        Navigator.pushNamed(context, '/contact');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Cảm ơn bạn đã sử dụng Movieom!',
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
  
  Widget _buildCategoryButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryButton(
            icon: Icons.account_circle,
            label: 'Tài khoản',
            onTap: () {
              _searchController.text = 'tài khoản';
              _filterFAQs('tài khoản');
            },
          ),
          _buildCategoryButton(
            icon: Icons.movie,
            label: 'Xem phim',
            onTap: () {
              _searchController.text = 'xem phim';
              _filterFAQs('xem phim');
            },
          ),
          _buildCategoryButton(
            icon: Icons.favorite,
            label: 'Yêu thích',
            onTap: () {
              _searchController.text = 'yêu thích';
              _filterFAQs('yêu thích');
            },
          ),
          _buildCategoryButton(
            icon: Icons.search,
            label: 'Tìm kiếm',
            onTap: () {
              _searchController.text = 'tìm kiếm';
              _filterFAQs('tìm kiếm');
            },
          ),
          _buildCategoryButton(
            icon: Icons.settings,
            label: 'Cài đặt',
            onTap: () {
              _searchController.text = 'cài đặt';
              _filterFAQs('cài đặt');
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF3F54D1).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF3F54D1), size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.aBeeZee(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFAQItem(FAQItem item) {
    return ExpansionTile(
      title: Text(
        item.question,
        style: GoogleFonts.aBeeZee(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      iconColor: const Color(0xFF3F54D1),
      collapsedIconColor: Colors.grey,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            item.answer,
            style: GoogleFonts.aBeeZee(
              fontSize: 14,
              color: Colors.grey[300],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF3F54D1).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF3F54D1), size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.aBeeZee(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  
  FAQItem({required this.question, required this.answer});
} 