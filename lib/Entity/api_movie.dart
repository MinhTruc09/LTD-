// lib/Entity/api_movie.dart

class ApiMovie {
  final String title;
  final String poster;
  final String description;
  final String category;
  final List<String> genres;
  final String year;
  final String slug;
  final String id;
  final String quality;
  final String lang;
  final String episodeCurrent;
  final String type;
  final String originName;
  final String time;

  ApiMovie({
    required this.title,
    required this.poster,
    required this.description,
    required this.category,
    required this.genres,
    required this.year,
    required this.slug,
    required this.id,
    this.quality = '',
    this.lang = '',
    this.episodeCurrent = '',
    this.type = '',
    this.originName = '',
    this.time = '',
  });

  factory ApiMovie.fromJson(Map<String, dynamic> json) {
    // Extract genres from categories if available
    List<String> extractGenres() {
      if (json['category'] != null && json['category'] is List) {
        return List<String>.from(
          (json['category'] as List).map((category) {
            if (category is Map) {
              return category['name']?.toString() ?? '';
            }
            return category.toString();
          }).where((name) => name.isNotEmpty),
        );
      }
      return List<String>.from(json['genres'] ?? []);
    }

    return ApiMovie(
      // Dùng 'name' nếu không có 'title'
      title: json['name']?.toString() ??
          json['title']?.toString() ??
          'Không có tiêu đề',
      poster:
          json['poster_url']?.toString() ?? json['poster']?.toString() ?? '',
      description: json['content']?.toString() ??
          json['description']?.toString() ??
          json['origin_name']?.toString() ??
          '',
      // Dùng 'status' làm category nếu có
      category: json['status']?.toString() ??
          json['slug']?.toString() ??
          json['category']?.toString() ??
          '',
      genres: extractGenres(),
      year: json['year']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      id: json['_id']?.toString() ?? '',
      quality: json['quality']?.toString() ?? '',
      lang: json['lang']?.toString() ?? '',
      episodeCurrent: json['episode_current']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      originName: json['origin_name']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
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
    // Handle the structure shown in the example
    List<dynamic> items = [];
    String title = '';

    if (json['data'] != null) {
      if (json['data']['items'] is List) {
        items = json['data']['items'];
      }

      title = json['data']['titlePage']?.toString() ?? '';
    }

    return ApiSearchResponse(
      status: json['status']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      movies: items
          .map((item) => ApiMovie.fromJson(item as Map<String, dynamic>))
          .toList(),
      titlePage: title,
    );
  }
}
