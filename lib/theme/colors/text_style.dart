import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextStyle {
  static const TextStyle bodySmall = TextStyle(
    fontSize: 18,
    color: Colors.black,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 20,
    color: Colors.black,
  );
  static const TextStyle bodyBig = TextStyle(
    fontSize: 24,
    color: Colors.black,
  );

  static TextStyle title = TextStyle(
    color: Colors.black,
    fontSize: 20.sp,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w700,
  );

  static TextStyle getTitleStyle() {
    return GoogleFonts.epilogue(
      textStyle: title,
    );
  }

  static TextStyle subheading = TextStyle(
    color: Colors.black,
    fontSize: 16.sp,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w600,
  );

  static TextStyle subtitle = TextStyle(
    color: Colors.black,
    fontSize: 14.sp,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle headerSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle headerMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle headerBig = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle textFieldFormWarningRed = TextStyle(
    color: Colors.red,
    fontSize: 20,
  );

  static textWarningRequired() {
    return const TextSpan(
      text: '*harus diisi',
      style: textFieldFormWarningRed,
    );
  }
}
