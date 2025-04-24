import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/Entity/movie_detail_model.dart';
import 'package:flutter/services.dart';

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
              extraInfo: {
                'slug': item['slug'] ?? '',
              },
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

            // Trong phần xử lý từng item trong getMoviesByGenre
            movies.add(MovieModel(
              id: item['_id'] ?? '',
              title: item['name'] ?? '',
              imageUrl: imageUrl,
              description: item['origin_name'] ?? '',
              category: 'Thể loại',
              genres: genreNames,
              year: item['year'] != null ? item['year'].toString() : '',
              isFavorite: false,
              extraInfo: {
                'slug': item['slug'] ?? '', // Thêm slug vào extraInfo
              },
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

  // Phương thức mới để lấy chi tiết phim bằng slug
  Future<MovieModel?> getMovieDetailBySlug(String slug) async {
    try {
      print('Đang tải chi tiết phim với slug: $slug');
      final response = await http.get(
        Uri.parse('$baseUrl/phim/$slug'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Đã nhận response: ${response.statusCode}');
        print(
            'Content response: ${response.body.substring(0, min(500, response.body.length))}...');

        // Kiểm tra cấu trúc dữ liệu
        print('Status trong response: ${data['status']}');
        if (data['data'] != null) {
          print('Data có tồn tại');
          if (data['data']['item'] != null) {
            print('Item có tồn tại');
          } else {
            print('Item không tồn tại trong data');
            // Kiểm tra xem có cấu trúc khác không
            print('Các key trong data: ${data['data'].keys.toList()}');
          }
        } else {
          print('Data không tồn tại trong response');
          print('Các key trong response: ${data.keys.toList()}');
        }

        if (data['status'] == "success" &&
            data['data'] != null &&
            data['data']['item'] != null) {
          final item = data['data']['item'];
          print('Đã phân tích dữ liệu phim: ${item['name']}');

          // Danh sách thể loại
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

          // Thêm xử lý URL hình ảnh poster
          String thumbUrl = '';
          if (item['thumb_url'] != null && item['thumb_url'].isNotEmpty) {
            if (item['thumb_url'].startsWith('http')) {
              thumbUrl = item['thumb_url'];
            } else {
              String cdnUrl =
                  data['data']['APP_DOMAIN_CDN_IMAGE'] ?? 'https://phimimg.com';
              thumbUrl = '$cdnUrl/${item['thumb_url']}';
            }
          }

          // Xử lý danh sách quốc gia
          List<String> countries = [];
          if (item['country'] != null) {
            for (var country in item['country']) {
              countries.add(country['name'] ?? '');
            }
          }

          return MovieModel(
              id: item['_id'] ?? '',
              title: item['name'] ?? '',
              imageUrl: imageUrl,
              description: item['content'] ?? item['origin_name'] ?? '',
              category: item['status'] ?? 'Hoàn thành',
              genres: genreNames,
              year: item['year'] != null ? item['year'].toString() : '',
              isFavorite: false,
              // Thêm thông tin chi tiết hơn vào model
              extraInfo: {
                'origin_name': item['origin_name'] ?? '',
                'thumb_url': thumbUrl,
                'countries': countries,
                'episode_current': item['episode_current'] ?? 'Full',
                'quality': item['quality'] ?? 'HD',
                'lang': item['lang'] ?? 'Vietsub',
                'time': item['time'] ?? '',
                'slug': item['slug'] ?? '',
                'view': item['view']?.toString() ?? '0',
              });
        } else {
          print('Không tìm thấy dữ liệu phim hoặc format không đúng');

          // Thử phương án dự phòng với định dạng API khác
          try {
            // API có thể sử dụng cấu trúc khác như API chi tiết phim bằng ID
            if (data['items'] != null &&
                data['items'] is List &&
                data['items'].isNotEmpty) {
              final item = data['items'][0];
              print(
                  'Tìm thấy dữ liệu thay thế trong items[0]: ${item['name'] ?? 'không có tên'}');

              List<String> genreNames = [];
              String imageUrl = item['poster_url'] ?? '';

              return MovieModel(
                  id: item['_id'] ?? slug,
                  title: item['name'] ?? 'Không có tên',
                  imageUrl: imageUrl,
                  description: item['origin_name'] ?? '',
                  category: 'Phim lẻ',
                  genres: genreNames,
                  year: item['year'] != null ? item['year'].toString() : '',
                  isFavorite: false,
                  extraInfo: {
                    'origin_name': item['origin_name'] ?? '',
                    'quality': item['quality'] ?? 'HD',
                    'lang': 'Vietsub',
                  });
            }
          } catch (e) {
            print('Lỗi khi thử phân tích dữ liệu thay thế: $e');
          }
        }
      } else {
        print('Lỗi khi gọi API: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      print('Lỗi khi tải chi tiết phim: $e');
      return null;
    }
  }

  // Phương thức với URL tường minh
  Future<MovieModel?> getMovieDetailBySlugV2(String slug) async {
    try {
      // Sử dụng GET https://phimapi.com/phim/${slug}
      final url = '$baseUrl/phim/$slug';
      print('Gọi API mới: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Đã nhận response từ API mới: ${response.statusCode}');

        // Xác nhận cấu trúc response phù hợp - kiểm tra status có thể là true hoặc "true"
        if ((data['status'] == true || data['status'] == "true") &&
            data['movie'] != null) {
          print('Tìm thấy dữ liệu phim từ API');
          final movieData = data['movie'];

          try {
            // Xử lý thông tin thể loại
            List<String> genres = [];
            if (movieData['category'] != null &&
                movieData['category'] is List) {
              for (var category in movieData['category']) {
                if (category is Map && category['name'] != null) {
                  genres.add(category['name'].toString());
                }
              }
            }

            // Xử lý thông tin quốc gia
            List<String> countries = [];
            if (movieData['country'] != null && movieData['country'] is List) {
              for (var country in movieData['country']) {
                if (country is Map && country['name'] != null) {
                  countries.add(country['name'].toString());
                }
              }
            }

            // Xử lý thông tin diễn viên
            List<String> actors = [];
            if (movieData['actor'] != null && movieData['actor'] is List) {
              for (var actor in movieData['actor']) {
                if (actor != null) {
                  actors.add(actor.toString());
                }
              }
            }

            // Xử lý danh sách tập phim
            List<Map<String, dynamic>> episodes = [];
            if (data['episodes'] != null && data['episodes'] is List) {
              for (var server in data['episodes']) {
                if (server is Map &&
                    server['server_data'] != null &&
                    server['server_data'] is List) {
                  final serverName =
                      server['server_name']?.toString() ?? 'Server';

                  for (var episode in server['server_data']) {
                    if (episode is Map) {
                      episodes.add({
                        'server_name': serverName,
                        'name': episode['name']?.toString() ?? '',
                        'slug': episode['slug']?.toString() ?? '',
                        'link_embed': episode['link_embed']?.toString() ?? '',
                        'link_m3u8': episode['link_m3u8']?.toString() ?? '',
                      });
                    }
                  }
                }
              }
            }

            String imageUrl = '';
            if (movieData['poster_url'] != null) {
              imageUrl = movieData['poster_url'].toString();
            }

            String thumbUrl = '';
            if (movieData['thumb_url'] != null) {
              thumbUrl = movieData['thumb_url'].toString();
            }

            // Xử lý đạo diễn
            List<String> directors = [];
            if (movieData['director'] != null &&
                movieData['director'] is List) {
              for (var director in movieData['director']) {
                if (director != null) {
                  directors.add(director.toString());
                }
              }
            }

            return MovieModel(
                id: movieData['_id']?.toString() ?? '',
                title: movieData['name']?.toString() ?? '',
                imageUrl: imageUrl,
                description: movieData['content']?.toString() ?? '',
                category: movieData['status']?.toString() ?? 'Đang cập nhật',
                genres: genres,
                year: movieData['year'] != null
                    ? movieData['year'].toString()
                    : '',
                isFavorite: false,
                extraInfo: {
                  'origin_name': movieData['origin_name']?.toString() ?? '',
                  'thumb_url': thumbUrl,
                  'trailer_url': movieData['trailer_url']?.toString() ?? '',
                  'time': movieData['time']?.toString() ?? '',
                  'episode_current':
                      movieData['episode_current']?.toString() ?? '',
                  'episode_total': movieData['episode_total']?.toString() ?? '',
                  'quality': movieData['quality']?.toString() ?? '',
                  'lang': movieData['lang']?.toString() ?? '',
                  'type': movieData['type']?.toString() ?? '',
                  'view': movieData['view'] != null
                      ? movieData['view'].toString()
                      : '0',
                  'slug': movieData['slug']?.toString() ?? '',
                  'countries': countries,
                  'actors': actors,
                  'directors': directors,
                  'episodes': episodes,
                });
          } catch (e) {
            print('Lỗi khi xử lý dữ liệu phim: $e');
            // Xử lý lỗi và trả về model cơ bản
            return MovieModel(
                id: movieData['_id']?.toString() ?? slug,
                title: movieData['name']?.toString() ?? 'Phim không xác định',
                imageUrl: movieData['poster_url']?.toString() ?? '',
                description: movieData['content']?.toString() ?? '',
                category: 'Phim',
                genres: [],
                year: '',
                isFavorite: false,
                extraInfo: {
                  'origin_name': movieData['origin_name']?.toString() ?? '',
                });
          }
        } else {
          print('Cấu trúc dữ liệu không phù hợp: ${data.keys.toList()}');

          // Thử trực tiếp với dữ liệu movie
          if (data['movie'] != null) {
            final movieData = data['movie'];
            print('Thử phân tích trực tiếp từ movie');

            try {
              // Tạo model phim với dữ liệu tối thiểu
              List<String> genres = [];

              if (movieData['category'] != null &&
                  movieData['category'] is List) {
                for (var cat in movieData['category']) {
                  if (cat is Map && cat['name'] != null) {
                    genres.add(cat['name'].toString());
                  }
                }
              }

              return MovieModel(
                  id: movieData['_id']?.toString() ?? slug,
                  title: movieData['name']?.toString() ?? 'Phim không xác định',
                  imageUrl: movieData['poster_url']?.toString() ?? '',
                  description: movieData['content']?.toString() ?? '',
                  category: movieData['status']?.toString() ?? 'Phim',
                  genres: genres,
                  year: movieData['year'] != null
                      ? movieData['year'].toString()
                      : '',
                  isFavorite: false,
                  extraInfo: {
                    'origin_name': movieData['origin_name']?.toString() ?? '',
                    'quality': movieData['quality']?.toString() ?? 'HD',
                    'lang': movieData['lang']?.toString() ?? 'Vietsub',
                    'time': movieData['time']?.toString() ?? '',
                    'episode_current':
                        movieData['episode_current']?.toString() ?? '',
                  });
            } catch (e) {
              print('Lỗi khi phân tích trực tiếp từ movie: $e');
            }
          }
        }
      } else {
        print('Lỗi khi gọi API: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      print('Lỗi khi tải chi tiết phim: $e');
      return null;
    }
  }

  /// Fetches detailed movie information based on slug/id
  Future<MovieDetailModel?> getMovieDetailV3(String slugOrId,
      {MovieModel? fallbackModel}) async {
    try {
      print('Fetching movie details for: $slugOrId');

      // Sử dụng slug từ extraInfo nếu có
      String finalSlug = slugOrId;
      if (fallbackModel != null && fallbackModel.extraInfo?['slug'] != null) {
        finalSlug = fallbackModel.extraInfo!['slug'];
      }

      var response = await http.get(Uri.parse('$baseUrl/phim/$finalSlug'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('API Response Status: ${jsonData['status']}');

        // Ghi log toàn bộ response để debug
        print(
            'API Response: ${jsonData.toString().substring(0, min(100, jsonData.toString().length))}...');

        // Trường hợp API trả về status = true và có dữ liệu phim
        if (jsonData['status'] == true && jsonData['movie'] != null) {
          print('API trả về thành công, đang xử lý dữ liệu phim');

          // Debug dữ liệu phim
          final movieData = jsonData['movie'];
          if (movieData is Map) {
            print('Movie title: ${movieData['name']}');
            print(
                'Movie content available: ${movieData.containsKey('content')}');
            if (movieData.containsKey('content')) {
              print(
                  'Content sample: ${movieData['content'].toString().substring(0, min(50, movieData['content'].toString().length))}...');
            }

            print('Actor data available: ${movieData.containsKey('actor')}');
            if (movieData.containsKey('actor')) {
              if (movieData['actor'] is List) {
                print('Actor count: ${(movieData['actor'] as List).length}');
                if ((movieData['actor'] as List).isNotEmpty) {
                  print('First actor: ${(movieData['actor'] as List)[0]}');
                }
              } else {
                print('Actor is not a List: ${movieData['actor'].runtimeType}');
              }
            }

            // Tạo MovieDetailModel trực tiếp từ dữ liệu JSON
            try {
              final detailModel = MovieDetailModel.fromJson({
                'status': jsonData['status'],
                'msg': jsonData['msg'] ?? '',
                'movie': movieData,
                'episodes': jsonData['episodes'] ?? []
              });

              // Debug thông tin model sau khi tạo
              print('Đã tạo MovieDetailModel thành công');
              print(
                  'Nội dung phim: ${detailModel.movie.content.substring(0, min(50, detailModel.movie.content.length))}...');
              print('Số lượng diễn viên: ${detailModel.movie.actor.length}');
              if (detailModel.movie.actor.isNotEmpty) {
                print('Diễn viên đầu tiên: ${detailModel.movie.actor[0]}');
              }

              return detailModel;
            } catch (e) {
              print('Lỗi khi tạo MovieDetailModel từ JSON: $e');
            }
          } else {
            print('Movie data không phải là Map: ${movieData.runtimeType}');
          }
        } else {
          print(
              'API trả về không thành công: status=${jsonData['status']}, có movie=${jsonData['movie'] != null}');
        }

        // Nếu tất cả các cách xử lý đều thất bại và có model dự phòng
        if (fallbackModel != null) {
          print('Sử dụng dữ liệu dự phòng để tạo MovieDetailModel');
          final defaultData = {
            'status': true,
            'msg': 'Fallback data',
            'movie': {
              'name': fallbackModel.title,
              'origin_name': fallbackModel.extraInfo?['origin_name'] ?? '',
              'content': fallbackModel
                  .description, // Sử dụng description nếu không có content
              'poster_url': fallbackModel.imageUrl,
              'thumb_url': fallbackModel.extraInfo?['thumb_url'] ??
                  fallbackModel.imageUrl,
              'type': fallbackModel.extraInfo?['type'] ?? 'movie',
              'status': 'ongoing',
              'episode_current':
                  fallbackModel.extraInfo?['episode_current'] ?? '',
              'episode_total': '',
              'time': fallbackModel.extraInfo?['time'] ?? '',
              'quality': fallbackModel.extraInfo?['quality'] ?? 'HD',
              'lang': fallbackModel.extraInfo?['lang'] ?? 'Vietsub',
              'year': fallbackModel.year,
              'actor': fallbackModel.extraInfo?['actors'] is List
                  ? fallbackModel.extraInfo!['actors']
                  : [],
              'director': fallbackModel.extraInfo?['directors'] is List
                  ? fallbackModel.extraInfo!['directors']
                  : [],
              'category': fallbackModel.genres
                  .map((g) => {
                        'id': '',
                        'name': g,
                        'slug': g.toLowerCase().replaceAll(' ', '-')
                      })
                  .toList(),
              'country': fallbackModel.extraInfo?['countries'] is List
                  ? (fallbackModel.extraInfo!['countries'] as List)
                      .map((c) => {'id': '', 'name': c, 'slug': ''})
                      .toList()
                  : [],
              'trailer_url': fallbackModel.extraInfo?['trailer_url'] ?? '',
            },
            'episodes': []
          };

          return MovieDetailModel.fromJson(defaultData);
        }
      } else {
        print('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching movie details: $e');
    }

    return null;
  }
}
