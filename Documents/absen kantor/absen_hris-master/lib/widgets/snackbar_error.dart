import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class CustomSnackbarError extends StatelessWidget {
  final String msg;
  final ContentType contentType;
  const CustomSnackbarError({
    super.key,
    required this.msg,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    return AwesomeSnackbarContent(
      message: msg,
      contentType: contentType,
      title: '',
    );
  }
}
