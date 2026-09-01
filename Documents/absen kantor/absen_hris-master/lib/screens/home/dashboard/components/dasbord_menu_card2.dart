import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardMenuCard2 extends StatelessWidget {
  final Color? cardColor;
  final Color? circleColor;
  final Color? iconColor;
  final Color? textColor;
  final String title;
  final String gambar;
  final double? height;
  final Function()? press;

  const DashboardMenuCard2({
    super.key,
    this.cardColor,
    required this.title,
    required this.gambar,
    this.height,
    required this.press,
    this.circleColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        children: [
          Container(
            height: 55.h,
            width: 65.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.w),
              color: Colors.transparent,
            ),
            child: Transform.scale(
              scale: 1.4,
              child: SvgPicture.asset(
                'assets/images/$gambar.svg',
              ),
            ),
          ),
          SizedBox(
            height: 19.h,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: textColor ?? Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
