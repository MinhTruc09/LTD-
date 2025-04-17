import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Khóa lưu thông tin đăng nhập
  static const String USER_EMAIL_KEY = 'user_email';
  static const String USER_UID_KEY = 'user_uid';
  static const String IS_LOGGED_IN_KEY = 'is_logged_in';

  // Phương thức đăng nhập
  Future<UserCredential> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Lưu thông tin đăng nhập
    await _saveUserSession(credential.user);

    return credential;
  }

  // Phương thức đăng ký
  Future<UserCredential> signUp(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Lưu thông tin đăng nhập
    await _saveUserSession(credential.user);

    return credential;
  }

  // Phương thức đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    await _clearUserSession();
  }

  // Phương thức đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Kiểm tra người dùng hiện tại
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Lưu thông tin phiên đăng nhập
  Future<void> _saveUserSession(User? user) async {
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_EMAIL_KEY, user.email ?? '');
    await prefs.setString(USER_UID_KEY, user.uid);
    await prefs.setBool(IS_LOGGED_IN_KEY, true);
  }

  // Xóa thông tin phiên đăng nhập
  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(USER_EMAIL_KEY);
    await prefs.remove(USER_UID_KEY);
    await prefs.setBool(IS_LOGGED_IN_KEY, false);
  }

  // Kiểm tra xem người dùng đã đăng nhập chưa
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(IS_LOGGED_IN_KEY) ?? false;
  }

  // Lấy thông tin email người dùng đã lưu
  Future<String?> getSavedUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_EMAIL_KEY);
  }

  // Lấy UID người dùng đã lưu
  Future<String?> getSavedUserUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_UID_KEY);
  }
}
