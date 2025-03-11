import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class CustomSnackbarContent extends StatelessWidget {
  final String title;
  final String msg;
  final ContentType contentType;
  const CustomSnackbarContent({
    super.key,
    required this.title,
    required this.msg,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    return AwesomeSnackbarContent(
      title: title,
      message: msg,
      contentType: contentType,
    );
  }
}
