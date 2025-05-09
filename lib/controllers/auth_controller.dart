import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream controller để theo dõi thay đổi userId
  final StreamController<String> _userIdController =
      StreamController<String>.broadcast();

  // Getter để truy cập streamq
  Stream<String> get userIdStream => _userIdController.stream;

  AuthController() {
    _initAuthStateListener();
  }

  // Khởi tạo listener theo dõi trạng thái xác thực
  void _initAuthStateListener() {
    _auth.authStateChanges().listen((User? user) {
      final userId = user?.uid ?? 'guest';
      _userIdController.add(userId);
    });
  }

  // Giải phóng tài nguyên
  void dispose() {
    _userIdController.close();
  }

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

    // Thông báo cho stream biết ID đã thay đổi
    if (credential.user != null) {
      _userIdController.add(credential.user!.uid);
    }

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

    // Thông báo cho stream biết ID đã thay đổi
    if (credential.user != null) {
      _userIdController.add(credential.user!.uid);
    }

    return credential;
  }

  // Phương thức đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    await _clearUserSession();

    // Thông báo cho stream biết đã đăng xuất
    _userIdController.add('guest');
  }

  // Phương thức đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Kiểm tra người dùng hiện tại
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Lấy ID người dùng hiện tại
  Future<String?> getCurrentUserId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }

    // Nếu không có người dùng hiện tại, thử lấy từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_UID_KEY);
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
