import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardMenuCard extends StatelessWidget {
  final Color? cardColor;
  final Color? circleColor;
  final Color? iconColor;
  final Color? textColor;
  final String title;
  final String gambar;
  final double? height;
  final Function()? press;

  const DashboardMenuCard({
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
            height: 65.h,
            width: 65.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.w),
              color: const Color(0xFFE6F1F8),
            ),
            child: Transform.scale(
              scale: 0.7, // Ganti nilai skala sesuai kebutuhan Anda
              child: SvgPicture.asset(
                'assets/images/$gambar.svg',
              ),
            ),
          ),
          SizedBox(
            height: 4.h,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.0.sp,
              color: textColor ?? Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
