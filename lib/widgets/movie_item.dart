import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/Entity/movie_model.dart';

class MovieItem extends StatelessWidget {
  final MovieModel movie;
  final double width;
  final VoidCallback? onTap;

  const MovieItem({
    super.key,
    required this.movie,
    this.width = 120.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tính toán chiều cao tối đa cho mỗi component
    final double imageHeight = width * 1.3; // Giảm chiều cao poster
    final double titleHeight = 14.0;
    final double descHeight =
        movie.year.isNotEmpty || movie.description.isNotEmpty ? 10.0 : 0.0;
    final double totalTextHeight =
        titleHeight + descHeight + 8.0; // 8.0 cho padding

    return GestureDetector(
      onTap: onTap ??
          () {
            // Điều hướng đến trang chi tiết phim
            Navigator.pushNamed(
              context,
              '/movie_detail',
              arguments: movie,
            );
          },
      child: Container(
        width: width,
        height: imageHeight + totalTextHeight,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster phim - Sử dụng chiều cao cố định thay vì Expanded
            SizedBox(
              width: width,
              height: imageHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: _buildImage(movie.imageUrl, width, imageHeight),
              ),
            ),
            const SizedBox(height: 4.0),
            // Tiêu đề phim - Giới hạn chiều cao
            SizedBox(
              height: titleHeight,
              child: Text(
                movie.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Năm sản xuất và mô tả ngắn - Giới hạn chiều cao
            if (movie.year.isNotEmpty || movie.description.isNotEmpty)
              SizedBox(
                height: descHeight,
                child: Row(
                  children: [
                    if (movie.year.isNotEmpty)
                      Text(
                        movie.year,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (movie.year.isNotEmpty && movie.description.isNotEmpty)
                      Text(
                        ' • ',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 8,
                        ),
                      ),
                    if (movie.description.isNotEmpty)
                      Expanded(
                        child: Text(
                          movie.description,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl, double width, double height) {
    // Kiểm tra nếu imageUrl là URL thực tế (bắt đầu bằng http hoặc https)
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[800],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[800],
            child: const Icon(
              Icons.broken_image,
              color: Colors.white,
            ),
          );
        },
      );
    } else {
      // Xử lý hình ảnh cục bộ (từ assets)
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[800],
            child: const Icon(
              Icons.broken_image,
              color: Colors.white,
            ),
          );
        },
      );
    }
  }
}
