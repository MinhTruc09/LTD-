// lib/Entity/api_movie.dart
class ApiMovie {
  final String title;
  final String poster;
  final String description;
  final String category;
  final List<String> genres;
  final String year;

  ApiMovie({
    required this.title,
    required this.poster,
    required this.description,
    required this.category,
    required this.genres,
    required this.year,
  });

  factory ApiMovie.fromJson(Map<String, dynamic> json) {
    return ApiMovie(
      // Dùng 'name' nếu không có 'title'
      title: json['name']?.toString() ?? json['title']?.toString() ?? 'Không có tiêu đề',
      poster: json['poster']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      // Dùng 'slug' làm category nếu không có 'category'
      category: json['slug']?.toString() ?? json['category']?.toString() ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      year: json['year']?.toString() ?? '',
    );
  }
}

class ApiSearchResponse {
  final String status;
  final String msg;
  final List<ApiMovie> movies;
  final String titlePage;

  ApiSearchResponse({
    required this.status,
    required this.msg,
    required this.movies,
    required this.titlePage,
  });

  factory ApiSearchResponse.fromJson(Map<String, dynamic> json) {
    var items = json['data']['items'] as List<dynamic>? ?? [];
    return ApiSearchResponse(
      status: json['status']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      movies: items.map((item) => ApiMovie.fromJson(item as Map<String, dynamic>)).toList(),
      titlePage: json['data']['titlePage']?.toString() ?? '',
    );
  }
}