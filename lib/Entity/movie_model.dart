class MovieModel {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final String category;
  final List<String> genres;
  final bool isFavorite;
  final String year;
  final Map<String, dynamic>? extraInfo;

  MovieModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.genres,
    this.isFavorite = false,
    this.year = '',
    this.extraInfo,
  });

  // Factory constructor để tạo MovieModel từ Map (Firebase)
  factory MovieModel.fromMap(Map<String, dynamic> map, String id) {
    return MovieModel(
      id: id,
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      genres: List<String>.from(map['genres'] ?? []),
      isFavorite: map['isFavorite'] ?? false,
      year: map['year'] ?? '',
      extraInfo: map['extraInfo'],
    );
  }

  // Phương thức chuyển đổi MovieModel thành Map (để lưu vào Firebase)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'genres': genres,
      'isFavorite': isFavorite,
      'year': year,
      'extraInfo': extraInfo,
    };
  }

  // Phương thức tạo bản sao với isFavorite được cập nhật
  MovieModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? description,
    String? category,
    List<String>? genres,
    bool? isFavorite,
    String? year,
    Map<String, dynamic>? extraInfo,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      genres: genres ?? this.genres,
      isFavorite: isFavorite ?? this.isFavorite,
      year: year ?? this.year,
      extraInfo: extraInfo ?? this.extraInfo,
    );
  }

  // Thêm phương thức fromJson để sử dụng trong Favoritemovieservice
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
      isFavorite: json['isFavorite'] ?? false,
      year: json['year'] ?? '',
      extraInfo: json['extraInfo'],
    );
  }

  // Thêm phương thức toJson để sử dụng trong Favoritemovieservice
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'genres': genres,
      'isFavorite': isFavorite,
      'year': year,
      'extraInfo': extraInfo,
    };
  }
}
