import 'package:flutter/material.dart';
import '../theme/colors/light_colors.dart';

class TopContainer extends StatelessWidget {
  final double height;
  final double width;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Radius? bottomRightRadius;
  final Radius? bottomLeftRadius;
  final Color? color;
  const TopContainer(
      {super.key,
      required this.height,
      required this.width,
      required this.child,
      this.padding,
      this.margin,
      this.bottomLeftRadius,
      this.bottomRightRadius,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20.0),
      margin: margin ?? const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: color ?? LightColors.kFagettiBlue,
        borderRadius: BorderRadius.only(
          bottomRight: bottomRightRadius ?? const Radius.circular(40.0),
          bottomLeft: bottomLeftRadius ?? const Radius.circular(40.0),
        ),
      ),
      height: height,
      width: width,
      child: child,
    );
  }
}
