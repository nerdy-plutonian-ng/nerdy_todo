import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorscheme,
);
final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorscheme,
);

const lightColorscheme = ColorScheme(
    brightness: Brightness.light,
    primary: grey,
    onPrimary: Colors.white,
    secondary: blue,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: Colors.white,
    onBackground: darkGrey,
    surface: Colors.white,
    onSurface: darkGrey);

const darkColorscheme = ColorScheme(
    brightness: Brightness.dark,
    primary: darkGrey,
    onPrimary: Colors.white,
    secondary: blue,
    onSecondary: Colors.white,
    error: Colors.redAccent,
    onError: Colors.black,
    background: grey,
    onBackground: Colors.white,
    surface: grey,
    onSurface: Colors.white);

const darkGrey = Color(0xFF161717);
const lightGrey = Color(0xFFB4B4B4);
const grey = Color(0xFF333333);
const blue = Color(0xFF29ABE2);
