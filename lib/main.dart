import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movieom_app/firebase_options.dart';
import 'package:movieom_app/routes/app_routes.dart';
import 'package:movieom_app/views/splash_screen.dart';
import 'widgets/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase da khoi tao thanh cong");
  } catch (e) {
    print("Loi khi khoi tao Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movieom App',
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: appRoutes,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
