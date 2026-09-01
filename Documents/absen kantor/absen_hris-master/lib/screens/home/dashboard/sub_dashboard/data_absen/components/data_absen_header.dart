import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';

class DataAbsenHeader extends StatelessWidget {
  final int hadir;
  final int telat;
  final int tidakHadir;
  final int alpha;
  final int izin;
  final int sakit;
  final int cuti;
  final int totalJamLembur;
  final int dayoff;
  final double height;
  final double width;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Radius? bottomRightRadius;
  final Radius? bottomLeftRadius;
  final Color? color;
  const DataAbsenHeader(
      {super.key,
      required this.hadir,
      required this.telat,
      required this.tidakHadir,
      required this.alpha,
      required this.izin,
      required this.sakit,
      required this.cuti,
      required this.totalJamLembur,
      required this.dayoff,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        initializeDateFormatting('id_ID', null).then((_) {});
        return Stack(
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding:
                          padding ?? EdgeInsets.symmetric(horizontal: 20.0.w),
                      margin: margin ?? EdgeInsets.all(0.w),
                      decoration: BoxDecoration(
                        color: color ?? const Color(0xFF0277B7),
                      ),
                      height: height,
                      width: width,
                      child: child,
                    ),
                  ],
                ),
                SizedBox(
                  height: 120.h,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                      top: 14, bottom: 14, right: 14, left: 14)
                  .r,
              child: Container(
                padding: const EdgeInsets.only(
                        top: 14, bottom: 14, left: 14, right: 14)
                    .r,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.1))
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15).r),
                child: Padding(
                  padding: const EdgeInsets.only(
                          left: 14, right: 14, top: 14, bottom: 14)
                      .r,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          columnHeader('Hadir', hadir),
                          SizedBox(
                            width: 29.w,
                          ),
                          columnHeader('Terlambat', telat),
                          SizedBox(
                            width: 29.w,
                          ),
                          columnHeader('Izin', izin),
                          SizedBox(
                            width: 29.w,
                          ),
                          columnHeader('Alfa', alpha),
                        ],
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Row(
                        children: [
                          columnHeader('Sakit', sakit),
                          SizedBox(
                            width: 29.w,
                          ),
                          columnHeader('Cuti', cuti),
                          SizedBox(
                            width: 29.w,
                          ),
                          columnHeader('Lembur', totalJamLembur),
                          SizedBox(
                            width: 29.w,
                          ),
                          columnHeader('Hari Off', dayoff),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Column columnHeader(String text, int value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: const Color(0xFF585858),
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
        ),
      ),
      SizedBox(
        height: 5.h,
      ),
      Text(
        value.toString(),
        textAlign: TextAlign.start,
        style: TextStyle(
          color: const Color(0xFF121212),
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
        ),
      ),
    ],
  );
}
