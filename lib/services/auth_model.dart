import 'package:flutter/material.dart';
import 'package:movieom_app/views/signin_screen.dart';
import 'package:movieom_app/views/signup_screen.dart';

class AuthModel extends StatefulWidget {
  const AuthModel({super.key});

  @override
  State<AuthModel> createState() => _AuthModelState();
}

class _AuthModelState extends State<AuthModel> {

  bool showLoginPage = true;
  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return SignInScreen(showRegisterPage: toggleScreens,);
    }else{
      return SignupScreen(showLoginPage: toggleScreens);
    }

  }
  void toggleScreens(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
}
