import 'package:flutter/material.dart';

class CustomTheme {
  static const Color grey = Color(0xffDFDFDF);
  static const Color yellow = Color(0xffFFDB47);
  static const Color kFagettiBlue = Color(0xFF2D2F93);
  static const Color kMonoFagettiBlue = Color(0xFF393BBA);
  static const Color kDarkRed = Color(0xff92140C);
  static const Color kCrayolaGreen = Color(0xff60A561);
  static const Color kMonoCrayolaGreen = Color(0xff4C864D);
  static const Color kPurpleSendBtn = Color(0xff6861ce);
  static const Color kGreen = Color(0xffC7CE61);
  static const cardShadow = [
    BoxShadow(color: grey, blurRadius: 6, spreadRadius: 4, offset: Offset(0, 2))
  ];
  static const buttonShadow = [
    BoxShadow(color: grey, blurRadius: 3, spreadRadius: 4, offset: Offset(1, 3))
  ];

  static getCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(35),
      boxShadow: cardShadow,
    );
  }

  static ThemeData getTheme() {
    Map<String, double> fontSize = {
      "sm": 14,
      "md": 18,
      "lg": 24,
    };

    return ThemeData(
      primaryColor: yellow,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        toolbarHeight: 70,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: 'Roboto',
          fontSize: fontSize['lg'],
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: fontSize['lg'],
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: fontSize['md'],
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: Colors.white,
          fontSize: fontSize['sm'],
          fontWeight: FontWeight.bold,
        ),
        bodySmall: TextStyle(
          color: Colors.white,
          fontSize: fontSize['sm'],
          fontWeight: FontWeight.normal,
        ),
        titleSmall: TextStyle(
          fontSize: fontSize['sm'],
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
