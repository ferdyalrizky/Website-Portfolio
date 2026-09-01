import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/size_config.dart';
import 'package:hris_v2/utils/constant.dart';

class TopPenilaian extends StatefulWidget {
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
  const TopPenilaian({
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
  State<TopPenilaian> createState() => _TopPenilaianState();
}

class _TopPenilaianState extends State<TopPenilaian> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.currUser.profilePhotoUrl == ""
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: getProportionateScreenWidth(48.w),
                        height: getPropotionateScreenHeight(48.h),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2.r,
                                blurRadius: 10.r,
                                color: Colors.black.withOpacity(0.1))
                          ],
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            image: AssetImage('assets/images/avatar.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: getProportionateScreenWidth(48).w,
                        height: getPropotionateScreenHeight(48).h,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2.r,
                                blurRadius: 10.r,
                                color: Colors.black.withOpacity(0.1))
                          ],
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                                '$API_URL_PROFILE_PICT/${widget.currUser.profilePhotoUrl}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 5.h,
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 13).r,
                    child: Text(
                      widget.currUser.namaKaryawan!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: GoogleFonts.epilogue(
                        fontSize: 14.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    widget.currUser.jobTitle == ""
                        ? "Job not define"
                        : widget.currUser.jobTitle!,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF585858),
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  top: 6.r, bottom: 6.r, left: 12.r, right: 12.r),
              decoration: BoxDecoration(
                  color: ((widget.score +
                                  widget.nilai +
                                  widget.skil +
                                  widget.kerjabro +
                                  widget.hadir +
                                  widget.tampilann) /
                              20 *
                              1) <
                          2
                      ? const Color(0xFFB31312)
                      : ((widget.score +
                                      widget.nilai +
                                      widget.skil +
                                      widget.kerjabro +
                                      widget.hadir +
                                      widget.tampilann) /
                                  20 *
                                  1) <
                              3
                          ? const Color(0xFFFFB000)
                          : const Color(0xFF5BA53B),
                  borderRadius: BorderRadius.circular(8.r)),
              child: Column(
                children: [
                  Text(
                    "Final Score",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    ((widget.score +
                                widget.nilai +
                                widget.skil +
                                widget.kerjabro +
                                widget.hadir +
                                widget.tampilann) /
                            20 *
                            1)
                        .toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
