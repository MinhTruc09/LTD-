import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String USER_EMAIL_KEY = 'user_email';
  static const String USER_UID_KEY = 'user_uid';
  static const String IS_LOGGED_IN_KEY = 'is_logged_in';

  final _userIdController = StreamController<String>.broadcast();
  Stream<String> get userIdStream => _userIdController.stream;

  Future<UserCredential> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _saveUserSession(credential.user);
    _userIdController.add(credential.user!.uid);
    return credential;
  }

  Future<UserCredential> signUp(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _saveUserSession(credential.user);
    _userIdController.add(credential.user!.uid);
    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _clearUserSession();
    _userIdController.add('');
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> _saveUserSession(User? user) async {
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_EMAIL_KEY, user.email ?? '');
    await prefs.setString(USER_UID_KEY, user.uid);
    await prefs.setBool(IS_LOGGED_IN_KEY, true);
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(USER_EMAIL_KEY);
    await prefs.remove(USER_UID_KEY);
    await prefs.setBool(IS_LOGGED_IN_KEY, false);
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(IS_LOGGED_IN_KEY) ?? false;
  }

  Future<String?> getSavedUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_EMAIL_KEY);
  }

  Future<String?> getSavedUserUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_UID_KEY);
  }

  Future<String?> getCurrentUserEmail() async {
    final user = _auth.currentUser;
    if (user != null) {
      return user.email;
    }
    return await getSavedUserEmail();
  }

  Future<String?> getCurrentUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }
    return await getSavedUserUid(); // Fallback về UID đã lưu nếu cần
  }

  void dispose() {
    _userIdController.close();
  }
}
