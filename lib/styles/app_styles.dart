import 'package:flutter/material.dart';

class AppStyles {
  static final ThemeData mainTheme = ThemeData(
    primarySwatch: Colors.blue,
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    ),
  );
}
