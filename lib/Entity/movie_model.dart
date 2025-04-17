class MovieModel {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final String category;
  final List<String> genres;
  final bool isFavorite;
  final String year;

  MovieModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.genres,
    this.isFavorite = false,
    this.year = '',
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
    );
  }
}
