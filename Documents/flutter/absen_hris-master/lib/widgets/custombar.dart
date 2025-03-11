import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class CustomSnackbarContent extends StatelessWidget {
  final String title;
  final String msg;
  // final ContentType contentType;
  final String contentType;
  const CustomSnackbarContent({
    Key? key,
    required this.title,
    required this.msg,
    required this.contentType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ContentType type = ContentType.help;
    switch (contentType) {
      case "success":
        type = ContentType.success;
        break;
      case "failure":
        type = ContentType.failure;
        break;
      case "help":
        type = ContentType.help;
        break;
      case "warning":
        type = ContentType.warning;
        break;
      default:
        type = ContentType.help;
    }
    return AwesomeSnackbarContent(
      title: title,
      message: msg,
      contentType: type,
    );
  }
}
