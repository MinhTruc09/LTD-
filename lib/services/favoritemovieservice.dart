import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movieom_app/Entity/movie_model.dart';

class Favoritemovieservice {
  final String _userId;
  final CollectionReference<Map<String, dynamic>> _favoritesCollection =
      FirebaseFirestore.instance.collection('favorites');

  Favoritemovieservice(this._userId) {
    if (_userId.isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }
  }

  // Thêm phim vào danh sách yêu thích
  Future<void> addFavorite(MovieModel movie) async {
    try {
      DocumentReference<Map<String, dynamic>> docRef =
          _favoritesCollection.doc(_userId);
      DocumentSnapshot<Map<String, dynamic>> doc = await docRef.get();

      List<dynamic> favoriteList = [];
      if (doc.exists) {
        favoriteList = List.from(doc.data()!['movies'] ?? []);
      }

      final movieJson = movie.toJson();
      if (!favoriteList.any((item) => item['id'] == movieJson['id'])) {
        favoriteList.add(movieJson);
        await docRef.set({
          'movies': favoriteList,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error adding favorite: $e');
      throw Exception('Failed to add favorite: $e');
    }
  }

  // Lấy danh sách phim yêu thích
  Future<List<MovieModel>> getFavorites() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _favoritesCollection.doc(_userId).get();
      if (!doc.exists) {
        return [];
      }

      List<dynamic> favoriteList = doc.data()!['movies'] ?? [];
      return favoriteList
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } catch (e) {
      print('Error getting favorites: $e');
      throw Exception('Failed to get favorites: $e');
    }
  }

  // Xóa phim khỏi danh sách yêu thích
  Future<void> removeFavorite(MovieModel movie) async {
    try {
      DocumentReference<Map<String, dynamic>> docRef =
          _favoritesCollection.doc(_userId);
      DocumentSnapshot<Map<String, dynamic>> doc = await docRef.get();

      if (!doc.exists) {
        return;
      }

      List<dynamic> favoriteList = List.from(doc.data()!['movies'] ?? []);
      favoriteList.removeWhere((item) => item['id'] == movie.id);

      await docRef.set({
        'movies': favoriteList,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error removing favorite: $e');
      throw Exception('Failed to remove favorite: $e');
    }
  }

  // Kiểm tra xem phim có trong danh sách yêu thích không
  Future<bool> isFavorite(MovieModel movie) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _favoritesCollection.doc(_userId).get();
      if (!doc.exists) {
        return false;
      }

      List<dynamic> favoriteList = doc.data()!['movies'] ?? [];
      return favoriteList.any((item) => item['id'] == movie.id);
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  // Xóa toàn bộ danh sách yêu thích
  Future<void> clearFavorites() async {
    try {
      await _favoritesCollection.doc(_userId).set({
        'movies': [],
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error clearing favorites: $e');
      throw Exception('Failed to clear favorites: $e');
    }
  }
}
