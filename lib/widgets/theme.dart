import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  fontFamily: 'Roboto',
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  primaryColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    titleTextStyle: TextStyle(color: Colors.white),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: Colors.white)
  )
);