import 'package:flutter/material.dart';

class AppThemes {
  // Define the dark theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black, // Set scaffold background color to black
    appBarTheme: AppBarTheme(
      color: Colors.black, // Optional: Set AppBar color to black as well
    ),
    // Define other theme properties here
  );

  // Define the light theme (optional)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white, // Default scaffold background color
    appBarTheme: AppBarTheme(
      color: Colors.white, // Optional: Set AppBar color for light theme
    ),
    // Define other theme properties here
  );
}
