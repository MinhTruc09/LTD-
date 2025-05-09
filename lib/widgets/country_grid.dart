// lib/widgets/country_grid.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Danh sách màu sắc đa dạng cho các nút quốc gia
const List<Color> _countryColors = [
  Color(0xFF3F54D1), // Xanh dương
  Color(0xFF8C52FF), // Tím
  Color(0xFF007BFF), // Xanh dương nhạt
  Color(0xFF00C2A8), // Xanh ngọc
  Color(0xFFE91E63), // Hồng
  Color(0xFFFF5722), // Cam
  Color(0xFF673AB7), // Tím đậm
  Color(0xFF2196F3), // Xanh dương nhạt
  Color(0xFF4CAF50), // Xanh lá
  Color(0xFFFF9800), // Cam nhạt
  Color(0xFF795548), // Nâu
  Color(0xFF607D8B), // Xanh đen
];

class CountryGrid extends StatefulWidget {
  final List<Map<String, dynamic>> countries;
  final Function(String, String) onCountrySelected;

  const CountryGrid({
    super.key,
    required this.countries,
    required this.onCountrySelected,
  });

  @override
  State<CountryGrid> createState() => _CountryGridState();
}

class _CountryGridState extends State<CountryGrid> {
  // Ban đầu hiển thị trang đầu tiên
  int _currentPage = 0;
  // Số lượng quốc gia trên mỗi trang
  final int _itemsPerPage = 12;

  // Lấy danh sách quốc gia cho trang hiện tại
  List<Map<String, dynamic>> get _currentPageCountries {
    final start = _currentPage * _itemsPerPage;
    final end = start + _itemsPerPage;

    if (start >= widget.countries.length) {
      return [];
    }

    if (end > widget.countries.length) {
      return widget.countries.sublist(start);
    }

    return widget.countries.sublist(start, end);
  }

  // Kiểm tra xem có trang tiếp theo không
  bool get _hasNextPage {
    return (_currentPage + 1) * _itemsPerPage < widget.countries.length;
  }

  // Số trang tổng cộng
  int get _totalPages {
    return (widget.countries.length / _itemsPerPage).ceil();
  }

  // Chuyển đến trang tiếp theo
  void _loadNextPage() {
    if (_hasNextPage) {
      setState(() {
        _currentPage++;
      });
    }
  }

  // Chuyển đến trang trước
  void _loadPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  // Chuyển về trang đầu
  void _goToFirstPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage = 0;
      });
    }
  }

  // Hiển thị tất cả quốc gia
  void _loadAllCountries() {
    setState(() {
      _currentPage = _totalPages - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán tổng số quốc gia đã hiển thị
    final totalDisplayed =
        (_currentPage + 1) * _itemsPerPage > widget.countries.length
            ? widget.countries.length
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
                'QUỐC GIA (${totalDisplayed}/${widget.countries.length})',
                style: GoogleFonts.aBeeZee(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_currentPage > 0)
                TextButton(
                  onPressed: _goToFirstPage,
                  child: Text(
                    'Trang đầu',
                    style: GoogleFonts.aBeeZee(
                      color: const Color(0xFF3F54D1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Hiển thị các quốc gia cho trang hiện tại
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: _currentPageCountries.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final country = _currentPageCountries[index];
            return _buildCountryItem(country);
          },
        ),

        // Hiển thị điều hướng trang
        if (widget.countries.length > _itemsPerPage)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nút xem trang trước
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: _loadPreviousPage,
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
                    style: GoogleFonts.aBeeZee(
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
        if (totalDisplayed < widget.countries.length)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: _loadAllCountries,
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
                  'Hiển thị tất cả quốc gia',
                  style: GoogleFonts.aBeeZee(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCountryItem(Map<String, dynamic> country) {
    // Sử dụng hash code của tên quốc gia để chọn màu ổn định
    final colorIndex = country['name'].hashCode.abs() % _countryColors.length;
    final color = _countryColors[colorIndex];

    return InkWell(
      onTap: () => widget.onCountrySelected(country['slug'], country['name']),
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
          country['name'],
          style: GoogleFonts.aBeeZee(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
