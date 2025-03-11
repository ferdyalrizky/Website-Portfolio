import 'package:flutter/material.dart';

import '../theme/colors/custom_theme.dart';
import 'loader.dart';

class CustomButtom extends StatelessWidget {
  final String text;
  final void Function() onPress;
  final bool loading;
  final double width;
  final double height;
  final Color btnColor;
  const CustomButtom(
      {super.key,
      required this.text,
      required this.onPress,
      this.btnColor = CustomTheme.yellow,
      this.width = double.infinity,
      this.height = 56,
      this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: btnColor,
        boxShadow: CustomTheme.cardShadow,
      ),
      child: MaterialButton(
        onPressed: loading ? null : onPress,
        child: loading
            ? const Loader()
            : Text(
                text,
                style: CustomTheme.getTheme().textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
