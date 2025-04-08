import 'package:flutter/material.dart';
import 'package:movieom_app/views/main_login_screen.dart';
import 'package:movieom_app/widgets/movieom_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();
    
    Future.delayed(const Duration(seconds: 3),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainLoginScreen()));
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset('assets/images/img.png',height: 400,width: 400,),
            Transform.translate(
                offset: const Offset(0, -150),
                child: const MovieomLogo()),


          ],
        ),
      ),
    );;
  }
}
