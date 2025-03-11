import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/keluar%20absen/face_detection.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';

class BacaAturanKeluar extends StatefulWidget {
  final Karyawan currUser;
  const BacaAturanKeluar({super.key, required this.currUser});

  @override
  State<BacaAturanKeluar> createState() => _BacaAturanKeluarState();
}

class _BacaAturanKeluarState extends State<BacaAturanKeluar> {
  int _countdown = 5;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: RPadding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 37.h,
            ),
            Align(
              alignment: Alignment.center,
              child: SvgPicture.asset("assets/images/wajah.svg"),
            ),
            SizedBox(
              height: 24.h,
            ),
            Text(
              "Verifikasi wajah",
              textAlign: TextAlign.center,
              style: GoogleFonts.epilogue(
                  fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10.h,
            ),
            Text(
              "Hal ini ingin memastikan bahwa anda adalah benar karyawan Fagetti. Pastikan wajah Anda terlihat jelas.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: const Color(0xFF585858),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 40.h,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r), // tambahkan radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // warna shadow
                    spreadRadius: 2, // lebar shadow
                    blurRadius: 7, // blur shadow
                    offset: const Offset(0, 3), // posisi shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/images/aturan1.svg",
                        width: 30.w,
                        height: 30.h,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.6),
                            child: Text(
                              "Foto Tempat yang terang. Misal depan lampu / sumber cahaya",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                  fontSize: 14.sp, fontWeight: FontWeight.w800),
                            ),
                          ),
                          Text(
                            "Lakukan verifikasi absen wajah segera.",
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/images/aturan2.svg",
                        width: 30.w,
                        height: 30.h,
                      ),
                      SizedBox(
                        width: 16.w,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.6),
                            child: Text(
                              "Lepas semua aksesoris dulu cth: topi, helm, kacamata, masker dll",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                  fontSize: 14.sp, fontWeight: FontWeight.w800),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.5),
                            child: Text(
                              "Lepaskan topi, helm, kacamata, masker dll",
                              textAlign: TextAlign.justify,
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/images/aturan3.svg",
                        width: 30.w,
                        height: 30.h,
                      ),
                      SizedBox(
                        width: 16.w,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.6),
                            child: Text(
                              "Ikuti petunjuk dengan benar",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                  fontSize: 14.sp, fontWeight: FontWeight.w800),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.5),
                            child: Text(
                              "Dekatkan wajah ke dalam bingkai dan arahkan mata ke kamera",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
      bottomNavigationBar: BottomAppBar(
        height: 160.h,
        color: Colors.white24,
        child: Column(
          children: [
            SizedBox(
              height: 5.h,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: LightColors.kFagettiBlue,
                minimumSize: const Size(380, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FaceDetectionAbsenKeluar(
                            currUser: widget.currUser,
                          )),
                );
              },
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Ok, lanjut',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
