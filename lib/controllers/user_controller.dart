import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movieom_app/Entity/user_model.dart';

class UserController {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Thêm thông tin người dùng mới với UID làm ID của document
  Future<void> addUserDetails({
    required String userId, // Thêm tham số userId
    required String firstName,
    required String lastName,
    required String email,
    required int age,
  }) async {
    // Tạo document trong 'users' với ID là userId
    final userDocRef = _usersCollection.doc(userId);
    await userDocRef.set({
      'first_name': firstName, // Chuẩn hóa tên trường
      'last_name': lastName,
      'email': email,
      'age': age,
    });

    // Tạo subcollection 'favorites' trống với một document rỗng
    // Document này sẽ bị xóa khi người dùng thêm phim yêu thích đầu tiên
    await userDocRef.collection('favorites').doc('placeholder').set(
        {'created_at': FieldValue.serverTimestamp(), 'is_placeholder': true});
  }

  // Lấy thông tin người dùng theo email
  Future<UserModel?> getUserByEmail(String email) async {
    final querySnapshot =
        await _usersCollection.where('email', isEqualTo: email).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUserDetails(
      String userId, Map<String, dynamic> data) async {
    await _usersCollection.doc(userId).update(data);
  }

  // Xóa người dùng
  Future<void> deleteUser(String userId) async {
    await _usersCollection.doc(userId).delete();
  }
}
