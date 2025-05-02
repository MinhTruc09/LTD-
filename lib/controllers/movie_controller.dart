import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/services/movie_api_service.dart';

class MovieController {
  final CollectionReference _moviesCollection =
      FirebaseFirestore.instance.collection('movies');
  final MovieApiService _apiService = MovieApiService();

  // Lấy tất cả phim từ API
  Future<List<MovieModel>> getAllMoviesFromApi({int page = 1}) async {
    return await _apiService.getRecentMovies(page: page);
  }

  // Lấy danh sách thể loại từ API
  Future<List<Map<String, dynamic>>> getAllGenres() async {
    return await _apiService.getGenres();
  }

  // Lấy danh sách quốc gia từ API
  Future<List<Map<String, dynamic>>> getAllCountries() async {
    return await _apiService.getAllCountries();
  }

  // Lấy phim theo thể loại từ API
  Future<List<MovieModel>> getMoviesByGenreFromApi(String slug,
      {int page = 1}) async {
    return await _apiService.getMoviesByGenre(slug, page: page);
  }

  // Lấy phim theo quốc gia từ API
  Future<List<MovieModel>> getMoviesByCountryFromApi(String slug,
      {int page = 1}) async {
    return await _apiService.getMoviesByCountryFromApi(slug, page: page);
  }

  // Lấy tất cả phim từ Firebase
  Future<List<MovieModel>> getAllMovies() async {
    final querySnapshot = await _moviesCollection.get();
    return querySnapshot.docs.map((doc) {
      return MovieModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // Lấy phim theo thể loại từ Firebase
  Future<List<MovieModel>> getMoviesByCategory(String category) async {
    final querySnapshot =
        await _moviesCollection.where('category', isEqualTo: category).get();
    return querySnapshot.docs.map((doc) {
      return MovieModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // Lấy phim theo quốc gia từ Firebase
  Future<List<MovieModel>> getMoviesByCountry(String country) async {
    final querySnapshot = await _moviesCollection
        .where('extraInfo.countries', arrayContains: country)
        .get();
    return querySnapshot.docs.map((doc) {
      return MovieModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // Lấy phim theo id
  Future<MovieModel?> getMovieById(String id) async {
    final docSnapshot = await _moviesCollection.doc(id).get();
    if (docSnapshot.exists) {
      return MovieModel.fromMap(
          docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
    }
    return null;
  }

  // Thêm phim mới
  Future<void> addMovie(MovieModel movie) async {
    await _moviesCollection.add(movie.toMap());
  }

  // Cập nhật phim
  Future<void> updateMovie(MovieModel movie) async {
    await _moviesCollection.doc(movie.id).update(movie.toMap());
  }

  // Xóa phim
  Future<void> deleteMovie(String id) async {
    await _moviesCollection.doc(id).delete();
  }

  // Tìm kiếm phim theo tên
  Future<List<MovieModel>> searchMovies(String query) async {
    final querySnapshot = await _moviesCollection.get();
    final allMovies = querySnapshot.docs.map((doc) {
      return MovieModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    return allMovies.where((movie) {
      return movie.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Dữ liệu mẫu
  List<MovieModel> getMockMovies() {
    return [
      MovieModel(
        id: '1',
        title: 'Fast & Furious 8',
        imageUrl: 'https://phimimg.com/fast8.jpg',
        description: 'Phim hành động về đua xe',
        category: 'Hành Động & Phiêu Lưu',
        genres: ['Hành động', 'Phiêu lưu'],
        year: '2017',
      ),
      MovieModel(
        id: '2',
        title: 'Sniper',
        imageUrl: 'https://phimimg.com/sniper.jpg',
        description: 'Diệt súng mù',
        category: 'Hành Động & Phiêu Lưu',
        genres: ['Hành động'],
        year: '2020',
      ),
      MovieModel(
        id: '3',
        title: 'Mission: Impossible - Dead Reckoning',
        imageUrl: 'https://phimimg.com/mission_impossible.jpg',
        description:
            'Đặc vụ IMF Ethan Hunt phải hoàn thành nhiệm vụ bất khả thi',
        category: 'Hành Động & Phiêu Lưu',
        genres: ['Hành động', 'Phiêu lưu', 'Gián điệp'],
        year: '2023',
      ),
      MovieModel(
        id: '4',
        title: 'The Instigators',
        imageUrl: 'https://phimimg.com/instigators.jpg',
        description: 'Hai kẻ xúi giục',
        category: 'Hành Động & Phiêu Lưu',
        genres: ['Hài hước', 'Hành động'],
        year: '2023',
      ),
      MovieModel(
        id: '5',
        title: 'Doraemon: Nobita\'s Sky Utopia',
        imageUrl: 'https://phimimg.com/doraemon.jpg',
        description: 'Phim hoạt họa về Doraemon và Nobita',
        category: 'Hoạt Hình',
        genres: ['Hoạt hình', 'Phiêu lưu'],
        year: '2023',
      ),
      MovieModel(
        id: '6',
        title: 'Minions',
        imageUrl: 'https://phimimg.com/minions.jpg',
        description: 'Bộ phim hoạt hình về những sinh vật nhỏ màu vàng',
        category: 'Hoạt Hình',
        genres: ['Hoạt hình', 'Hài hước'],
        year: '2022',
      ),
      MovieModel(
        id: '7',
        title: 'Super Mario Bros',
        imageUrl: 'https://phimimg.com/mario.jpg',
        description: 'Vị qua cứu Ngôi sao',
        category: 'Hoạt Hình',
        genres: ['Hoạt hình', 'Phiêu lưu'],
        year: '2023',
      ),
    ];
  }
}
