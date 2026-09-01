import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/karyawan.dart';

class FinalCalculation extends StatefulWidget {
  final Karyawan currUser;
  final int score;
  final Function(int) onScoreChanged;
  final int nilai;
  final Function(int) onNilaiChanged;
  final int hadir;
  final Function(int) onHadirChanged;
  final int skil;
  final Function(int) onSkilChanged;
  final int kerjabro;
  final Function(int) onKerjaBroChanged;
  final int tampilann;
  final Function(int) onTampilannChanged;
  const FinalCalculation({
    super.key,
    required this.currUser,
    this.score = 0,
    required this.onScoreChanged,
    this.nilai = 0,
    required this.onNilaiChanged,
    this.hadir = 0,
    required this.onHadirChanged,
    this.skil = 0,
    required this.onSkilChanged,
    this.kerjabro = 0,
    required this.onKerjaBroChanged,
    this.tampilann = 0,
    required this.onTampilannChanged,
  });

  @override
  State<FinalCalculation> createState() => _FinalCalculationState();
}

class _FinalCalculationState extends State<FinalCalculation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Final calculation",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 15.h,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Components",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp),
                ),
                Text(
                  "Total Score",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp),
                ),
                Text(
                  "Converted Score",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          Container(
            color: const Color.fromARGB(255, 187, 185, 185),
            height: 2.h,
          ),
          SizedBox(
            height: 5.h,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10).r,
            child: Row(
              children: [
                Row(
                  children: [
                    Text(
                      "Review",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp),
                    ),
                    SizedBox(
                      width: 3.w,
                    ),
                    Text(
                      "(80%)",
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w800,
                          fontSize: 16.sp),
                    ),
                  ],
                ),
                SizedBox(
                  width: 48.w,
                ),
                Text(
                  ((widget.score + widget.nilai + widget.skil + widget.kerjabro) / 16 * 1).toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 102.w,
                ),
                Text(
                  ((widget.score + widget.nilai + widget.skil + widget.kerjabro) / 20 * 1).toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10).r,
            child: Row(
              children: [
                Row(
                  children: [
                    Text(
                      "Absensi",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp),
                    ),
                    SizedBox(
                      width: 3.w,
                    ),
                    Text(
                      "(15%)",
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w800,
                          fontSize: 16.sp),
                    ),
                  ],
                ),
                SizedBox(
                  width: 41.w,
                ),
                Text(
                  ((widget.hadir) / 3 * 1).toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 103.w,
                ),
                Text(
                  ((widget.hadir) / 20 * 1).toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10).r,
            child: Row(
              children: [
                Row(
                  children: [
                    Text(
                      "Penampilan",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp),
                    ),
                    SizedBox(
                      width: 3.w,
                    ),
                    Text(
                      "(5%)",
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w800,
                          fontSize: 16.sp),
                    ),
                  ],
                ),
                SizedBox(
                  width: 23.w,
                ),
                Text(
                  ((widget.tampilann) / 1 * 1).toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 103.w,
                ),
                Text(
                  ((widget.tampilann) / 20 * 1).toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          Container(
            color: const Color.fromARGB(255, 187, 185, 185),
            height: 2.h,
          ),
          Container(
            height: 40.h,
            width: double.infinity,
            color: const Color.fromARGB(255, 248, 235, 215),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                ),
                Text(
                  "Final Score",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp),
                ),
                SizedBox(
                  width: 3.w,
                ),
                SizedBox(
                  width: 186.w,
                ),
                Text(
                  ((widget.score + widget.nilai + widget.skil + widget.kerjabro + widget.hadir + widget.tampilann) / 20 * 1).toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
