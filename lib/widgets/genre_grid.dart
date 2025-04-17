import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GenreGrid extends StatefulWidget {
  final List<Map<String, dynamic>> genres;
  final Function(String, String) onGenreSelected;

  const GenreGrid({
    super.key,
    required this.genres,
    required this.onGenreSelected,
  });

  @override
  State<GenreGrid> createState() => _GenreGridState();
}

class _GenreGridState extends State<GenreGrid> {
  // Ban đầu hiển thị tất cả thể loại, nhưng chia thành nhiều trang
  int _currentPage = 0;
  // Số lượng thể loại trên mỗi trang
  final int _itemsPerPage = 12;

  // Lấy danh sách thể loại cho trang hiện tại
  List<Map<String, dynamic>> get _currentPageGenres {
    final start = _currentPage * _itemsPerPage;
    final end = start + _itemsPerPage;

    if (start >= widget.genres.length) {
      return [];
    }

    if (end > widget.genres.length) {
      return widget.genres.sublist(start);
    }

    return widget.genres.sublist(start, end);
  }

  // Kiểm tra xem có trang tiếp theo không
  bool get _hasNextPage {
    return (_currentPage + 1) * _itemsPerPage < widget.genres.length;
  }

  // Số trang tổng cộng
  int get _totalPages {
    return (widget.genres.length / _itemsPerPage).ceil();
  }

  // Chuyển đến trang tiếp theo
  void _loadNextPage() {
    if (_hasNextPage) {
      setState(() {
        _currentPage++;
      });
    }
  }

  // Hiển thị tất cả thể loại
  void _loadAllGenres() {
    setState(() {
      _currentPage = _totalPages - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán tổng số thể loại đã hiển thị
    final totalDisplayed =
        (_currentPage + 1) * _itemsPerPage > widget.genres.length
            ? widget.genres.length
            : (_currentPage + 1) * _itemsPerPage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 12.0, bottom: 8.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thể loại (${totalDisplayed}/${widget.genres.length})',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_currentPage > 0)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentPage = 0;
                    });
                  },
                  child: Text(
                    'Trang đầu',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF3F54D1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Hiển thị các thể loại cho trang hiện tại
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: _currentPageGenres.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final genre = _currentPageGenres[index];
            return _buildGenreItem(genre);
          },
        ),

        // Hiển thị điều hướng trang
        if (widget.genres.length > _itemsPerPage)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nút xem trang trước
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentPage--;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.chevron_left),
                  ),

                // Hiển thị số trang
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Trang ${_currentPage + 1}/$_totalPages',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Nút xem trang tiếp theo
                if (_hasNextPage)
                  ElevatedButton(
                    onPressed: _loadNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.chevron_right),
                  ),
              ],
            ),
          ),

        // Nút "Hiển thị tất cả" chỉ xuất hiện khi chưa hiển thị hết
        if (totalDisplayed < widget.genres.length)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: _loadAllGenres,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F54D1),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Hiển thị tất cả thể loại',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGenreItem(Map<String, dynamic> genre) {
    final colors = [
      const Color(0xFF3F54D1), // Xanh dương
      const Color(0xFF8C52FF), // Tím
      const Color(0xFF007BFF), // Xanh dương nhạt
      const Color(0xFF00C2A8), // Xanh ngọc
      const Color(0xFFE91E63), // Hồng
      const Color(0xFFFF5722), // Cam
      const Color(0xFF673AB7), // Tím đậm
      const Color(0xFF2196F3), // Xanh dương nhạt
      const Color(0xFF4CAF50), // Xanh lá
      const Color(0xFFFF9800), // Cam nhạt
      const Color(0xFF795548), // Nâu
      const Color(0xFF607D8B), // Xanh đen
    ];

    // Đảm bảo mỗi thể loại có một màu ổn định
    final colorIndex = genre['name'].hashCode.abs() % colors.length;
    final color = colors[colorIndex];

    return InkWell(
      onTap: () => widget.onGenreSelected(genre['slug'], genre['name']),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          genre['name'],
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
