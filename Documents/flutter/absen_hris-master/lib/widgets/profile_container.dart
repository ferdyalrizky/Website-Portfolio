import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/colors/light_colors.dart';

class ProfileContainer extends StatelessWidget {
  final double height;
  final double width;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Radius? bottomRightRadius;
  final Radius? bottomLeftRadius;
  final Color? color;
  const ProfileContainer(
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
      padding: padding ?? EdgeInsets.symmetric(horizontal: 20.0.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            LightColors.kFagettiBlue, // warna atas
            Colors.transparent, // warna bawah (transparan)
          ],
          stops: [0.3, 0.1], // posisi warna (0.5 = setengah)
        ),
        borderRadius: BorderRadius.only(
          bottomRight: bottomRightRadius ?? Radius.circular(0.0.r),
          bottomLeft: bottomLeftRadius ?? Radius.circular(0.0.r),
        ),
      ),
      height: height,
      width: width,
      child: child,
    );
  }
}
