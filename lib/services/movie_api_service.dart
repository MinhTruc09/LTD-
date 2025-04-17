import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movieom_app/Entity/movie_model.dart';

class MovieApiService {
  final String baseUrl = 'https://phimapi.com';

  Future<List<MovieModel>> getRecentMovies({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/danh-sach/phim-moi-cap-nhat?page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['items'] != null) {
          List<MovieModel> movies = [];
          for (var item in data['items']) {
            movies.add(MovieModel(
              id: item['_id'] ?? '',
              title: item['name'] ?? '',
              imageUrl: item['poster_url'] ?? '',
              description: item['origin_name'] ?? '',
              category: 'Phim mới',
              genres: [],
              year: item['year'] != null ? item['year'].toString() : '',
              isFavorite: false,
            ));
          }
          return movies;
        }
      }
      return [];
    } catch (e) {
      print('Lỗi khi tải danh sách phim: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getGenres() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/the-loai'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> genres = [];

        print('Đã tải ${data.length} thể loại từ API');

        for (var item in data) {
          genres.add({
            'id': item['_id'],
            'name': item['name'],
            'slug': item['slug'],
          });
        }

        return genres;
      }

      // Fallback nếu không lấy được dữ liệu từ API
      return _getComprehensiveGenreList();
    } catch (e) {
      print('Lỗi khi tải danh sách thể loại: $e');
      return _getComprehensiveGenreList();
    }
  }

  // Danh sách đầy đủ thể loại dựa trên API thực tế
  List<Map<String, dynamic>> _getComprehensiveGenreList() {
    return [
      {
        "id": "9822be111d2ccc29c7172c78b8af8ff5",
        "name": "Hành Động",
        "slug": "hanh-dong"
      },
      {
        "id": "d111447ee87ec1a46a31182ce4623662",
        "name": "Miền Tây",
        "slug": "mien-tay"
      },
      {
        "id": "0c853f6238e0997ee318b646bb1978bc",
        "name": "Trẻ Em",
        "slug": "tre-em"
      },
      {
        "id": "f8ec3e9b77c509fdf64f0c387119b916",
        "name": "Lịch Sử",
        "slug": "lich-su"
      },
      {
        "id": "3a17c7283b71fa84e5a8d76fb790ed3e",
        "name": "Cổ Trang",
        "slug": "co-trang"
      },
      {
        "id": "1bae5183d681b7649f9bf349177f7123",
        "name": "Chiến Tranh",
        "slug": "chien-tranh"
      },
      {
        "id": "68564911f00849030f9c9c144ea1b931",
        "name": "Viễn Tưởng",
        "slug": "vien-tuong"
      },
      {
        "id": "4db8d7d4b9873981e3eeb76d02997d58",
        "name": "Kinh Dị",
        "slug": "kinh-di"
      },
      {
        "id": "1645fa23fa33651cef84428b0dcc2130",
        "name": "Tài Liệu",
        "slug": "tai-lieu"
      },
      {
        "id": "2fb53017b3be83cd754a08adab3e916c",
        "name": "Bí Ẩn",
        "slug": "bi-an"
      },
      {
        "id": "4b4457a1af8554c282dc8ac41fd7b4a1",
        "name": "Phim 18+",
        "slug": "phim-18"
      },
      {
        "id": "bb2b4b030608ca5984c8dd0770f5b40b",
        "name": "Tình Cảm",
        "slug": "tinh-cam"
      },
      {
        "id": "a7b065b92ad356387ef2e075dee66529",
        "name": "Tâm Lý",
        "slug": "tam-ly"
      },
      {
        "id": "591bbb2abfe03f5aa13c08f16dfb69a2",
        "name": "Thể Thao",
        "slug": "the-thao"
      },
      {
        "id": "66c78b23908113d478d8d85390a244b4",
        "name": "Phiêu Lưu",
        "slug": "phieu-luu"
      },
      {
        "id": "252e74b4c832ddb4233d7499f5ed122e",
        "name": "Âm Nhạc",
        "slug": "am-nhac"
      },
      {
        "id": "a2492d6cbc4d58f115406ca14e5ec7b6",
        "name": "Gia Đình",
        "slug": "gia-dinh"
      },
      {
        "id": "01c8abbb7796a1cf1989616ca5c175e6",
        "name": "Học Đường",
        "slug": "hoc-duong"
      },
      {
        "id": "ba6fd52e5a3aca80eaaf1a3b50a182db",
        "name": "Hài Hước",
        "slug": "hai-huoc"
      },
      {
        "id": "7a035ac0b37f5854f0f6979260899c90",
        "name": "Hình Sự",
        "slug": "hinh-su"
      },
      {
        "id": "578f80eb493b08d175c7a0c29687cbdf",
        "name": "Võ Thuật",
        "slug": "vo-thuat"
      },
      {
        "id": "0bcf4077916678de9b48c89221fcf8ae",
        "name": "Khoa Học",
        "slug": "khoa-hoc"
      },
      {
        "id": "2276b29204c46f75064735477890afd6",
        "name": "Thần Thoại",
        "slug": "than-thoai"
      },
      {
        "id": "37a7b38b6184a5ebd3c43015aa20709d",
        "name": "Chính Kịch",
        "slug": "chinh-kich"
      },
      {
        "id": "268385d0de78827ff7bb25c35036ee2a",
        "name": "Kinh Điển",
        "slug": "kinh-dien"
      }
    ];
  }

  Future<List<MovieModel>> getMoviesByGenre(String slug, {int page = 1}) async {
    try {
      // Sử dụng URL /v1/api/the-loai/{slug} theo đúng định dạng API
      final response = await http.get(
        Uri.parse('$baseUrl/v1/api/the-loai/$slug?page=$page'),
      );

      print('URL đang gọi: $baseUrl/v1/api/the-loai/$slug?page=$page');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == "success" &&
            data['data'] != null &&
            data['data']['items'] != null) {
          List<MovieModel> movies = [];
          for (var item in data['data']['items']) {
            List<String> genreNames = [];
            if (item['category'] != null) {
              for (var genre in item['category']) {
                genreNames.add(genre['name'] ?? '');
              }
            }

            // Sử dụng đường dẫn hình ảnh từ CDN
            String imageUrl = '';
            if (item['poster_url'] != null && item['poster_url'].isNotEmpty) {
              // Nếu poster_url đã có http, không cần thêm domain
              if (item['poster_url'].startsWith('http')) {
                imageUrl = item['poster_url'];
              } else {
                // Sử dụng APP_DOMAIN_CDN_IMAGE từ API response nếu có
                String cdnUrl = data['data']['APP_DOMAIN_CDN_IMAGE'] ??
                    'https://phimimg.com';
                imageUrl = '$cdnUrl/${item['poster_url']}';
              }
            }

            movies.add(MovieModel(
              id: item['_id'] ?? '',
              title: item['name'] ?? '',
              imageUrl: imageUrl,
              description: item['origin_name'] ?? '',
              category: 'Thể loại',
              genres: genreNames,
              year: item['year'] != null ? item['year'].toString() : '',
              isFavorite: false,
            ));
          }
          return movies;
        } else {
          // Nếu API không trả về đúng format
          print(
              'API trả về không thành công: ${data['msg'] ?? "Không có dữ liệu"}');
          return [];
        }
      } else {
        // Nếu mã status code không phải 200
        print(
            'Lỗi khi gọi API thể loại: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Lỗi khi tải phim theo thể loại: $e');
      return [];
    }
  }

  Future<MovieModel?> getMovieDetail(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/phim/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == "success" &&
            data['data'] != null &&
            data['data']['item'] != null) {
          final item = data['data']['item'];

          List<String> genreNames = [];
          if (item['category'] != null) {
            for (var genre in item['category']) {
              genreNames.add(genre['name'] ?? '');
            }
          }

          // Xử lý URL hình ảnh
          String imageUrl = '';
          if (item['poster_url'] != null && item['poster_url'].isNotEmpty) {
            if (item['poster_url'].startsWith('http')) {
              imageUrl = item['poster_url'];
            } else {
              String cdnUrl =
                  data['data']['APP_DOMAIN_CDN_IMAGE'] ?? 'https://phimimg.com';
              imageUrl = '$cdnUrl/${item['poster_url']}';
            }
          }

          return MovieModel(
            id: item['_id'] ?? '',
            title: item['name'] ?? '',
            imageUrl: imageUrl,
            description: item['content'] ?? item['origin_name'] ?? '',
            category: 'Chi tiết',
            genres: genreNames,
            year: item['year'] != null ? item['year'].toString() : '',
            isFavorite: false,
          );
        }
      }
      return null;
    } catch (e) {
      print('Lỗi khi tải chi tiết phim: $e');
      return null;
    }
  }
}
