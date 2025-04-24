// movie_model.dart
import 'package:movieom_app/Entity/api_movie.dart';

// MovieModel class
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
}

// Extension để chuyển đổi từ ApiMovie sang MovieModel
extension ApiMovieExtension on ApiMovie {
  MovieModel toMovieModel() {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    return MovieModel(
      id: tempId,
      title: title,
      imageUrl: poster,
      description: description,
      category: category,
      genres: genres,
      isFavorite: false,
      year: year,
      extraInfo: {
        'source': 'phimapi.com',
        'fetchedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}