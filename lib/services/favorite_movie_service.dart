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

    // Nếu không có ID và slug, dùng hash của title để tạo ID duy nhất
    return 'auto_${movie.title.hashCode.abs()}';
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

  // Dọn dẹp các reference documents cũ
  Future<void> cleanupOldReferences() async {
    try {
      // Lấy tất cả documents trong collection favorites
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .get();
      
      int count = 0;
      for (var doc in querySnapshot.docs) {
        // Bỏ qua placeholder và favorite_ids_list
        if (doc.id == 'placeholder' || doc.id == FAVORITE_IDS_DOC) {
          continue;
        }
        
        try {
          // Kiểm tra xem có phải reference document không
          final data = doc.data();
          if (data != null && 
              data.containsKey('reference_id') && 
              data.containsKey('is_reference')) {
            // Xóa reference document
            await doc.reference.delete();
            count++;
          }
        } catch (docError) {
          print('Lỗi xử lý document ${doc.id}: $docError');
          // Tiếp tục xử lý các document khác
          continue;
        }
      }
      
      if (count > 0) {
        print('Đã xóa $count reference documents cũ');
      }
    } catch (e) {
      print('Lỗi khi dọn dẹp reference documents cũ: $e');
      // Không ném lỗi, vì đây chỉ là xử lý dọn dẹp
    }
  }

  Future<void> addFavorite(MovieModel movie) async {
    try {
      // First check if we need to remove placeholder
      await _removeplaceholder();
      
      // Dọn dẹp các reference documents cũ
      await cleanupOldReferences();

      // Lấy document ID để lưu phim
      final docId = _getDocumentId(movie);
      final slug = _getMovieSlug(movie);

      // Kiểm tra xem phim đã tồn tại chưa
      final docSnap = await _getFavoritesCollection().doc(docId).get();
      if (docSnap.exists) {
        print('Phim đã tồn tại với ID: $docId, không thêm lại.');
        return; // Thoát nếu phim đã tồn tại
      }

      print('Lưu phim yêu thích với ID: $docId, Slug: $slug');

      // Thêm thông tin slug vào extraInfo nếu chưa có
      Map<String, dynamic> updatedExtraInfo = {...(movie.extraInfo ?? {})};
      
      // Thêm slug vào extraInfo nếu có
      if (slug != null && slug.isNotEmpty) {
        updatedExtraInfo['slug'] = slug;
      }

      // Add movie to favorites with isFavorite set to true
      final movieToSave = movie.copyWith(
        isFavorite: true,
        extraInfo: updatedExtraInfo,
      );

      // Lưu phim vào Firestore
      await _getFavoritesCollection().doc(docId).set(movieToSave);

      // Cập nhật danh sách ID phim yêu thích
      await _addToFavoriteIds(docId, slug);

      // Không tạo reference document riêng biệt nữa để tránh tạo các tập tin ảo
      // Thay vào đó, chỉ sử dụng danh sách IDs để theo dõi
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

      // Xóa reference document nếu có (giữ lại phần này để dọn dẹp các reference cũ)
      if (slug != null && slug != movie.id) {
        print('Kiểm tra và xóa reference document cũ với slug: $slug');
        final docRef = _firestore
            .collection('users')
            .doc(_userId)
            .collection('favorites')
            .doc(slug);
            
        final docSnap = await docRef.get();
        if (docSnap.exists) {
          final data = docSnap.data();
          // Chỉ xóa nếu đúng là reference document
          if (data != null && data.containsKey('reference_id')) {
            await docRef.delete();
            print('Đã xóa reference document với slug: $slug');
          }
        }
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
      Set<String> uniqueIds = {}; // Để theo dõi các ID đã thêm

      for (var doc in docs) {
        final data = doc.data();
        // Chỉ lấy document không phải là placeholder và không phải danh sách IDs
        if (doc.id != 'placeholder' && doc.id != FAVORITE_IDS_DOC) {
          // Bỏ qua reference documents cũ (cho tương thích với dữ liệu cũ)
          final Map<String, dynamic>? extraInfo = data.extraInfo;
          if (extraInfo != null && 
              extraInfo.containsKey('is_reference') && 
              extraInfo['is_reference'] == true) {
            continue;
          }
          
          // Chỉ thêm nếu ID chưa tồn tại
          if (uniqueIds.add(data.id)) {
            movies.add(data);
          }
        }
      }

      print('Đã tìm thấy ${movies.length} phim yêu thích');
      return movies;
    } catch (e) {
      print('Error getting favorites for user $_userId: $e');
      throw Exception('Failed to get favorites: ${e.toString()}');
    }
  }

  Stream<List<MovieModel>> streamFavorites() {
    return _getFavoritesCollection().snapshots().map((snapshot) {
      Set<String> uniqueIds = {};
      List<MovieModel> movies = [];
      
      for (var doc in snapshot.docs) {
        // Bỏ qua placeholder và favorite_ids_list
        if (doc.id == 'placeholder' || doc.id == FAVORITE_IDS_DOC) {
          continue;
        }
        
        final movie = doc.data();
        
        // Bỏ qua reference documents cũ (cho tương thích với dữ liệu cũ)
        if (movie.extraInfo != null && 
            movie.extraInfo!.containsKey('is_reference') && 
            movie.extraInfo!['is_reference'] == true) {
          continue;
        }
        
        // Chỉ thêm nếu ID chưa tồn tại
        if (uniqueIds.add(movie.id)) {
          movies.add(movie);
        }
      }
      
      return movies;
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

      // Không cần kiểm tra reference document nữa vì chúng ta không còn tạo chúng
      // Nhưng vẫn giữ lại đoạn code dưới đây để tương thích với dữ liệu cũ
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
              'Tìm thấy reference document cũ: $movieId -> ${data['reference_id']}');
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

  // Phương thức public để dọn dẹp tất cả các file ảo
  Future<void> cleanupPhantomFiles() async {
    try {
      // Gọi các phương thức dọn dẹp
      try {
        await _removeplaceholder();
      } catch (e) {
        print('Lỗi khi xóa placeholder: $e');
      }
      
      try {
        await cleanupOldReferences();
      } catch (e) {
        print('Lỗi khi dọn dẹp references: $e');
      }
      
      print('Hoàn tất quá trình dọn dẹp files');
    } catch (e) {
      print('Lỗi chung khi dọn dẹp các file ảo: $e');
      // Không ném lỗi ra ngoài
    }
  }
}
