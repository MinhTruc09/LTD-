import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movieom_app/Entity/movie_model.dart';

class Favoritemovieservice {
  final String _userId;
  final FirebaseFirestore _firestore;
  // Tên document đặc biệt để lưu danh sách ID phim yêu thích
  static const String FAVORITE_IDS_DOC = 'favorite_ids_list';

  Favoritemovieservice(this._userId, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<MovieModel> _getFavoritesCollection() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .withConverter<MovieModel>(
          fromFirestore: (snapshot, _) => MovieModel.fromJson(snapshot.data()!),
          toFirestore: (movie, _) => movie.toJson(),
        );
  }

  // Truy cập document đặc biệt chứa danh sách ID yêu thích
  DocumentReference _getFavoriteIdsDocument() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(FAVORITE_IDS_DOC);
  }

  // Hàm để lấy slug từ phim (nếu có)
  String? _getMovieSlug(MovieModel movie) {
    if (movie.extraInfo != null && movie.extraInfo!.containsKey('slug')) {
      final slug = movie.extraInfo!['slug'];
      if (slug != null && slug is String && slug.isNotEmpty) {
        return slug;
      }
    }
    return null;
  }

  // Tạo document ID thống nhất
  String _getDocumentId(MovieModel movie) {
    // Ưu tiên sử dụng ID của phim
    if (movie.id.isNotEmpty) {
      return movie.id;
    }

    // Nếu không có ID, thử dùng slug
    final slug = _getMovieSlug(movie);
    if (slug != null) {
      return slug;
    }

    // Trường hợp không có ID và slug, dùng title với timestamp
    return '${movie.title}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Thêm ID phim vào danh sách IDs yêu thích
  Future<void> _addToFavoriteIds(String movieId, String? slug) async {
    try {
      final docRef = _getFavoriteIdsDocument();
      final doc = await docRef.get();

      // Tập hợp các ID cần lưu
      Set<String> idsToStore = <String>{movieId};
      if (slug != null && slug.isNotEmpty && slug != movieId) {
        idsToStore.add(slug);
      }

      if (doc.exists) {
        // Nếu document đã tồn tại, cập nhật nó với ID mới
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> existingIds = List<String>.from(data['ids'] ?? []);

        // Thêm tất cả các ID mới vào danh sách
        existingIds.addAll(idsToStore);

        // Loại bỏ trùng lặp
        final uniqueIds = existingIds.toSet().toList();

        await docRef.update(
            {'ids': uniqueIds, 'updated_at': FieldValue.serverTimestamp()});
      } else {
        // Tạo document mới
        await docRef.set({
          'ids': idsToStore.toList(),
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
      print('Đã cập nhật danh sách ID phim yêu thích: $idsToStore');
    } catch (e) {
      print('Lỗi khi cập nhật danh sách ID phim yêu thích: $e');
    }
  }

  // Xóa ID phim khỏi danh sách IDs yêu thích
  Future<void> _removeFromFavoriteIds(String movieId, String? slug) async {
    try {
      final docRef = _getFavoriteIdsDocument();
      final doc = await docRef.get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> existingIds = List<String>.from(data['ids'] ?? []);

        // Xóa movieId khỏi danh sách
        existingIds.remove(movieId);

        // Xóa slug nếu có
        if (slug != null && slug.isNotEmpty) {
          existingIds.remove(slug);
        }

        await docRef.update(
            {'ids': existingIds, 'updated_at': FieldValue.serverTimestamp()});
        print('Đã xóa khỏi danh sách ID phim yêu thích: $movieId, $slug');
      }
    } catch (e) {
      print('Lỗi khi xóa khỏi danh sách ID phim yêu thích: $e');
    }
  }

  Future<void> addFavorite(MovieModel movie) async {
    try {
      // First check if we need to remove placeholder
      await _removeplaceholder();

      // Lấy document ID để lưu phim
      final docId = _getDocumentId(movie);
      final slug = _getMovieSlug(movie);

      print('Lưu phim yêu thích với ID: $docId, Slug: $slug');

      // Thêm thông tin slug vào extraInfo nếu chưa có
      Map<String, dynamic> updatedExtraInfo = {...(movie.extraInfo ?? {})};

      // Add movie to favorites with isFavorite set to true
      final movieToSave = movie.copyWith(
        isFavorite: true,
        extraInfo: updatedExtraInfo,
      );

      // Lưu phim vào Firestore
      await _getFavoritesCollection().doc(docId).set(movieToSave);

      // Cập nhật danh sách ID phim yêu thích
      await _addToFavoriteIds(docId, slug);

      // Nếu có slug và khác ID, thêm reference document
      if (slug != null && slug != docId) {
        print('Tạo reference với slug: $slug -> ID: $docId');
        // Tạo một document nhỏ trỏ đến ID chính
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('favorites')
            .doc(slug)
            .set({
          'reference_id': docId,
          'is_reference': true,
          'original_title': movie.title,
        });
      }
    } catch (e) {
      print('Error adding favorite for user $_userId: $e');
      throw Exception('Failed to add favorite: ${e.toString()}');
    }
  }

  Future<void> removeFavorite(MovieModel movie) async {
    try {
      if (movie.id.isEmpty) {
        print('Warning: Cannot remove favorite with empty ID');
        return;
      }

      // Lấy slug từ movie nếu có
      final slug = _getMovieSlug(movie);

      // Xóa document chính
      await _getFavoritesCollection().doc(movie.id).delete();

      // Cập nhật danh sách ID phim yêu thích
      await _removeFromFavoriteIds(movie.id, slug);

      // Xóa reference document nếu có
      if (slug != null && slug != movie.id) {
        print('Xóa reference document với slug: $slug');
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('favorites')
            .doc(slug)
            .delete();
      }
    } catch (e) {
      print('Error removing favorite for user $_userId: $e');
      throw Exception('Failed to remove favorite: ${e.toString()}');
    }
  }

  Future<List<MovieModel>> getFavorites() async {
    try {
      final querySnapshot = await _getFavoritesCollection().get();

      // Lọc ra các document chính (không phải reference)
      final docs = querySnapshot.docs;
      List<MovieModel> movies = [];

      for (var doc in docs) {
        final data = doc.data();
        // Chỉ lấy document không phải là placeholder, không phải reference và không phải danh sách IDs
        if (doc.id != 'placeholder' &&
            doc.id != FAVORITE_IDS_DOC &&
            !(data.extraInfo != null &&
                data.extraInfo!.containsKey('is_reference') &&
                data.extraInfo!['is_reference'] == true)) {
          movies.add(data);
        }
      }

      return movies;
    } catch (e) {
      print('Error getting favorites for user $_userId: $e');
      throw Exception('Failed to get favorites: ${e.toString()}');
    }
  }

  Stream<List<MovieModel>> streamFavorites() {
    return _getFavoritesCollection().snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) =>
              doc.id != 'placeholder' &&
              doc.id != FAVORITE_IDS_DOC &&
              !(doc.data().extraInfo != null &&
                  doc.data().extraInfo!.containsKey('is_reference') &&
                  doc.data().extraInfo!['is_reference'] == true))
          .map((doc) => doc.data())
          .toList();
    });
  }

  // Kiểm tra xem phim đã được thêm vào yêu thích chưa - cách mới
  Future<bool> isMovieFavorite(String movieId) async {
    try {
      if (movieId.isEmpty) {
        print('Warning: Cannot check favorite status with empty ID');
        return false;
      }

      // Kiểm tra trong danh sách IDs trước (cách nhanh nhất)
      try {
        final idsDoc = await _getFavoriteIdsDocument().get();
        if (idsDoc.exists) {
          final data = idsDoc.data() as Map<String, dynamic>;
          if (data.containsKey('ids')) {
            final List<String> ids = List<String>.from(data['ids']);
            final bool isFavorite = ids.contains(movieId);
            print(
                'Kiểm tra yêu thích từ danh sách IDs: $movieId -> $isFavorite');
            if (isFavorite) return true;
          }
        }
      } catch (e) {
        print('Lỗi khi kiểm tra trong danh sách IDs: $e');
        // Nếu có lỗi, tiếp tục kiểm tra các cách khác
      }

      // Kiểm tra theo ID
      final docSnap = await _getFavoritesCollection().doc(movieId).get();
      if (docSnap.exists) {
        print('Tìm thấy phim yêu thích với ID: $movieId');
        return true;
      }

      // Nếu không tìm thấy, kiểm tra xem có phải là reference document không
      final referenceDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .doc(movieId)
          .get();

      if (referenceDoc.exists) {
        final data = referenceDoc.data();
        if (data != null && data.containsKey('reference_id')) {
          print(
              'Tìm thấy reference document: $movieId -> ${data['reference_id']}');
          return true;
        }
      }

      print('Không tìm thấy phim yêu thích với ID: $movieId');
      return false;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Xóa placeholder document nếu tồn tại
  Future<void> _removeplaceholder() async {
    try {
      final placeholderRef = _getFavoritesCollection().doc('placeholder');
      final placeholderDoc = await placeholderRef.get();

      if (placeholderDoc.exists) {
        await placeholderRef.delete();
        print('Removed placeholder document');
      }
    } catch (e) {
      print('Error removing placeholder: $e');
      // Không ném lỗi, vì đây chỉ là xử lý dọn dẹp
    }
  }
}
