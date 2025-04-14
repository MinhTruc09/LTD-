import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movieom_app/services/auth_model.dart';

import '../views/main_screen_picker.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return MainScreenPicker(); // Trả về MainScreenPicker thay vì HomeScreen
            } else {
              return AuthModel();
            }
          }),
    );
  }
}