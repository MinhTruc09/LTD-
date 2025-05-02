class MovieDetailModel {
  final bool status;
  final String msg;
  final MovieData movie;
  final List<EpisodeServer> episodes;

  MovieDetailModel({
    required this.status,
    required this.msg,
    required this.movie,
    required this.episodes,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailModel(
      status: json['status'] == true || json['status'] == "true",
      msg: json['msg']?.toString() ?? "",
      movie: MovieData.fromJson(json['movie']),
      episodes: json['episodes'] != null
          ? (json['episodes'] as List)
              .map((e) => EpisodeServer.fromJson(e))
              .toList()
          : [],
    );
  }

  // Attempt to create MovieDetail from alternative API response format
  static MovieDetailModel? fromApiResponse(Map<String, dynamic> response) {
    try {
      if (response['status'] == true || response['status'] == "true") {
        if (response['movie'] != null) {
          return MovieDetailModel.fromJson(response);
        }
      } else if (response['items'] != null &&
          response['items'] is List &&
          response['items'].isNotEmpty) {
        // Alternative API format with items array
        final item = response['items'][0];

        // Create a compatible response format
        final modifiedJson = {
          'status': true,
          'msg': 'Success',
          'movie': item,
          'episodes': item['episodes'] ?? [],
        };

        return MovieDetailModel.fromJson(modifiedJson);
      }
    } catch (e) {
      print('Error parsing API response: $e');
    }
    return null;
  }

  // Helper getters for UI
  bool get isSeriesMovie => movie.type == 'series';
  bool get isCompletedStatus => movie.status == 'completed';
  bool get hasTrailer => movie.trailerUrl.isNotEmpty;
  bool get hasActors => movie.actor.isNotEmpty;
  bool get hasDirectors => movie.director.isNotEmpty;
  bool get hasGenres => movie.category.isNotEmpty;
  bool get hasCountries => movie.country.isNotEmpty;
  bool get hasEpisodes => episodes.isNotEmpty;

  String get displayStatus => isCompletedStatus ? 'Hoàn thành' : 'Đang chiếu';
  String get displayType => isSeriesMovie ? 'Phim bộ' : 'Phim lẻ';
}

class MovieData {
  final String name;
  final String originName;
  final String content;
  late final String posterUrl;
  late final String thumbUrl;
  final String type;
  final String status;
  final String episodeCurrent;
  final String episodeTotal;
  final String time;
  final String quality;
  final String lang;
  final int year;
  final List<String> actor;
  final List<String> director;
  final List<Category> category;
  final List<Country> country;
  final Tmdb tmdb;
  final String trailerUrl;
  final List<String>? productionCompanies;
  final List<String>? spokenLanguages;

  MovieData({
    required this.name,
    required this.originName,
    required this.content,
    required this.posterUrl,
    required this.thumbUrl,
    required this.type,
    this.status = '',
    required this.episodeCurrent,
    required this.episodeTotal,
    required this.time,
    required this.quality,
    required this.lang,
    required this.year,
    required this.actor,
    required this.director,
    required this.category,
    required this.country,
    required this.tmdb,
    this.trailerUrl = '',
    this.productionCompanies,
    this.spokenLanguages,
  });

  factory MovieData.fromJson(Map<String, dynamic> json) {
    try {
      // Xử lý danh sách công ty sản xuất
      List<String> extractProductionCompanies() {
        if (json['production_companies'] != null &&
            json['production_companies'] is List) {
          return List<String>.from(json['production_companies'].map((company) =>
              company is Map ? (company['name'] ?? '') : company.toString()));
        }
        return [];
      }

      // Xử lý danh sách ngôn ngữ phim
      List<String> extractSpokenLanguages() {
        if (json['spoken_languages'] != null &&
            json['spoken_languages'] is List) {
          return List<String>.from(json['spoken_languages'].map((lang) =>
              lang is Map
                  ? (lang['name'] ?? lang['english_name'] ?? '')
                  : lang.toString()));
        }
        return [];
      }

      // Debug dữ liệu nội dung và diễn viên
      print(
          'MovieData.fromJson - content type: ${json['content'].runtimeType}');
      print('MovieData.fromJson - actor type: ${json['actor'].runtimeType}');
      if (json['actor'] is List) {
        print(
            'MovieData.fromJson - actor count: ${(json['actor'] as List).length}');
      }

      return MovieData(
        name: json['name'] ?? '',
        originName: json['origin_name'] ?? '',
        content: json['content']?.toString() ??
            json['description']?.toString() ??
            '',
        posterUrl: json['poster_url'] ?? '',
        thumbUrl: json['thumb_url'] ?? '',
        type: json['type'] ?? '',
        status: json['status'] ?? '',
        episodeCurrent: json['episode_current']?.toString() ?? '',
        episodeTotal: json['episode_total']?.toString() ?? '',
        time: json['time'] ?? json['runtime']?.toString() ?? '',
        quality: json['quality'] ?? 'HD',
        lang: json['lang'] ?? 'Vietsub',
        year: json['year'] is int
            ? json['year']
            : (int.tryParse(json['year']?.toString() ?? '0') ?? 0),
        trailerUrl: json['trailer_url'] ?? '',
        actor: json['actor'] != null
            ? (json['actor'] is List
                ? List<String>.from(
                    (json['actor'] as List).map((a) => a.toString()))
                : [])
            : [],
        director: json['director'] != null
            ? (json['director'] is List
                ? List<String>.from(
                    (json['director'] as List).map((d) => d.toString()))
                : [])
            : [],
        category: json['category'] != null && json['category'] is List
            ? (json['category'] as List)
                .map((e) => Category.fromJson(e))
                .toList()
            : [],
        country: json['country'] != null && json['country'] is List
            ? (json['country'] as List).map((e) => Country.fromJson(e)).toList()
            : [],
        tmdb: json['tmdb'] != null
            ? Tmdb.fromJson(json['tmdb'])
            : Tmdb(
                type: '',
                id: '',
                voteAverage: 0.0,
                voteCount: 0,
              ),
        productionCompanies: extractProductionCompanies(),
        spokenLanguages: extractSpokenLanguages(),
      );
    } catch (e) {
      print('Error parsing MovieData: $e');
      // Return minimal MovieData on error
      return MovieData(
        name: json['name'] ?? '',
        originName: json['origin_name'] ?? '',
        content: json['content']?.toString() ??
            json['description']?.toString() ??
            '',
        posterUrl: json['poster_url'] ?? '',
        thumbUrl: json['thumb_url'] ?? '',
        type: json['type'] ?? '',
        episodeCurrent: '',
        episodeTotal: '',
        time: '',
        quality: 'HD',
        lang: 'Vietsub',
        year: 0,
        actor: [],
        director: [],
        category: [],
        country: [],
        tmdb: Tmdb(type: '', id: '', voteAverage: 0.0, voteCount: 0),
        productionCompanies: [],
        spokenLanguages: [],
      );
    }
  }
}

class Tmdb {
  final String type;
  final String id;
  final double voteAverage;
  final int voteCount;

  Tmdb({
    required this.type,
    required this.id,
    required this.voteAverage,
    required this.voteCount,
  });

  factory Tmdb.fromJson(Map<String, dynamic> json) {
    try {
      return Tmdb(
        type: json['type'] ?? '',
        id: json['id']?.toString() ?? '',
        voteAverage: json['vote_average'] is num
            ? (json['vote_average'] as num).toDouble()
            : 0.0,
        voteCount: json['vote_count'] is int
            ? json['vote_count']
            : (int.tryParse(json['vote_count']?.toString() ?? '0') ?? 0),
      );
    } catch (e) {
      print('Error parsing Tmdb: $e');
      return Tmdb(type: '', id: '', voteAverage: 0.0, voteCount: 0);
    }
  }
}

class Category {
  final String id;
  final String name;
  final String slug;

  Category({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      return Category(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing Category: $e');
      return Category(id: '', name: '', slug: '');
    }
  }
}

class Country {
  final String id;
  final String name;
  final String slug;

  Country({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    try {
      return Country(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing Country: $e');
      return Country(id: '', name: '', slug: '');
    }
  }
}

class EpisodeServer {
  final String serverName;
  final List<EpisodeData> serverData;

  EpisodeServer({
    required this.serverName,
    required this.serverData,
  });

  factory EpisodeServer.fromJson(Map<String, dynamic> json) {
    try {
      return EpisodeServer(
        serverName: json['server_name']?.toString() ?? '',
        serverData: json['server_data'] != null && json['server_data'] is List
            ? (json['server_data'] as List)
                .map((e) => EpisodeData.fromJson(e))
                .toList()
            : [],
      );
    } catch (e) {
      print('Error parsing EpisodeServer: $e');
      return EpisodeServer(serverName: '', serverData: []);
    }
  }
}

class EpisodeData {
  final String name;
  final String slug;
  final String filename;
  final String linkEmbed;
  final String linkM3u8;

  EpisodeData({
    required this.name,
    required this.slug,
    required this.filename,
    required this.linkEmbed,
    required this.linkM3u8,
  });

  factory EpisodeData.fromJson(Map<String, dynamic> json) {
    try {
      return EpisodeData(
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        filename: json['filename']?.toString() ?? '',
        linkEmbed: json['link_embed']?.toString() ?? '',
        linkM3u8: json['link_m3u8']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing EpisodeData: $e');
      return EpisodeData(
          name: '', slug: '', filename: '', linkEmbed: '', linkM3u8: '');
    }
  }
}
