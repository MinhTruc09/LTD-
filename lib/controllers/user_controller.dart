import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movieom_app/Entity/user_model.dart';

class UserController {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Thêm thông tin người dùng mới
  Future<void> addUserDetails(
      String firstName, String lastName, String email, int age) async {
    await _usersCollection.add({
      'first name': firstName,
      'last name': lastName,
      'email': email,
      'age': age,
    });
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
