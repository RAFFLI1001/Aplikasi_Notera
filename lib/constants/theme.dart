import 'package:flutter/material.dart';
import 'color_scheme.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  scaffoldBackgroundColor: darkGreyColor,
  colorScheme: const ColorScheme.dark(
    primary: primaryColor,
    surface: darkGreyColor,
    onPrimary: Colors.black,
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: darkGreyColor,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
);
