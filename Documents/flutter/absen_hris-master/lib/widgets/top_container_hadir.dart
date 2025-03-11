import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/absen_online.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/keluar%20absen/lokasi_absen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/kunjungan/lokasi_absen.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/jam_live1.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

import '../screens/home/dashboard/sub_dashboard/absen_online/masuk absen/lokasi_absen.dart';

class TopAbsenHadir extends StatefulWidget {
  final Karyawan currUser;
  final double height;
  final double width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Radius? bottomRightRadius;
  final Radius? bottomLeftRadius;
  final Color? color;
  const TopAbsenHadir(
      {super.key,
      required this.currUser,
      required this.height,
      required this.width,
      this.padding,
      this.margin,
      this.bottomLeftRadius,
      this.bottomRightRadius,
      this.color});

  @override
  State<TopAbsenHadir> createState() => _TopAbsenHadirState();
}

class _TopAbsenHadirState extends State<TopAbsenHadir> {
  bool isInSelectedArea = true;
  File? fotoSelfie;
  Uint8List? selfieBytes;
  AbsenOnline? _absenOnline;
  String _visitsTime = "";
  late bool isLoadingAbsenOnline;

  bool checkInOutBtnLoading = false;

  final _formKey = GlobalKey<FormBuilderState>();

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  //TODO bikin ambil data absen online
  _getOnlineAbsenData() async {
    setState(() {
      isLoadingAbsenOnline = true;
    });
    var header = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };
    try {
      var response = await http.get(
        Uri.parse('$API_URL/v2/getRekapAbsenOnline/${widget.currUser.nip}'),
        headers: header,
      );
      final output = jsonDecode(response.body);
      print(output);
      _absenOnline = AbsenOnline.fromJson(output);
      if (_absenOnline!.visits[0] != "") {
        _visitsTime = "";
        for (var i = 0; i < _absenOnline!.visits.length; i++) {
          _visitsTime += "${_absenOnline!.visits[i]}\n";
        }
      } else {
        _visitsTime = "-";
      }
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoadingAbsenOnline = false;
    });
  }

  //?[End Helper Method]

  //&[START Lifecycle]
  @override
  void initState() {
    initializing();
    super.initState();
  }
  //&[END Lifecycle]

  initializing() async {
    await _getOnlineAbsenData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: widget.padding ??
                      EdgeInsets.symmetric(horizontal: 20.0.w),
                  margin: widget.margin ?? EdgeInsets.all(0.w),
                  decoration: BoxDecoration(
                    color: widget.color ?? const Color(0xFF0277B7),
                  ),
                  height: widget.height,
                  width: widget.width,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 26.h,
                      ),
                      const ClockWidgetAbsen(),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        DateFormat.yMMMMEEEEd('id_ID').format(DateTime.now()),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            Container(
              height: 225.h,
              color: Colors.white, // ganti dengan warna yang diinginkan
            )
          ],
        ),
        Positioned(
          bottom: -25.r,
          left: 0.r,
          right: 0.r,
          child: RPadding(
            padding: const EdgeInsets.all(30),
            child: Container(
              padding: const EdgeInsets.only(
                      top: 14, bottom: 14, left: 28, right: 28)
                  .r,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 2.r,
                        blurRadius: 10.r,
                        color: Colors.black.withOpacity(0.1))
                  ],
                  color: const Color(0xFFFBFBFB),
                  borderRadius: BorderRadius.circular(14.w)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 15).r,
                    child: isLoadingAbsenOnline
                        ? const Center(
                            child: Loader(),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "Absen masuk",
                                    style: TextStyle(
                                      color: const Color(0xFF585858),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    _absenOnline!.absenMasuk == ""
                                        ? "--:--"
                                        : (DateFormat("HH:mm")
                                                            .parse(_absenOnline!
                                                                .absenMasuk)
                                                            .hour >=
                                                        9 &&
                                                    DateFormat("HH:mm")
                                                            .parse(_absenOnline!
                                                                .absenMasuk)
                                                            .minute >
                                                        1) ||
                                                (DateFormat("HH:mm")
                                                            .parse(_absenOnline!
                                                                .absenMasuk)
                                                            .hour ==
                                                        9 &&
                                                    DateFormat("HH:mm")
                                                            .parse(_absenOnline!
                                                                .absenMasuk)
                                                            .minute >
                                                        0)
                                            ? "-${(DateFormat("HH:mm").parse(_absenOnline!.absenMasuk).hour - 9).toString().padLeft(2, "0")}:${(DateFormat("HH:mm").parse(_absenOnline!.absenMasuk).minute - 1).toString().padLeft(2, "0")}"
                                            : DateFormat("HH:mm").format(
                                                DateFormat("HH:mm").parse(
                                                    _absenOnline!.absenMasuk)),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18.sp,
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Absen keluar",
                                    style: TextStyle(
                                      color: const Color(0xFF585858),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    _absenOnline!.absenPulang == ""
                                        ? "--:--"
                                        : DateFormat("HH:mm").format(
                                            DateFormat("HH:mm").parse(
                                                _absenOnline!.absenPulang)),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  isLoadingAbsenOnline
                      ? const Center(
                          child: Loader(),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12).r,
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity.w,
                                height: 50.h,
                                child: ElevatedButton.icon(
                                  label: Text(
                                    'Absen Masuk',
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            AbsenOnlineScreen(
                                          currUser: widget.currUser,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: const Color(0xFF65B741),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              SizedBox(
                                width: double.infinity.w,
                                height: 50.h,
                                child: ElevatedButton.icon(
                                  label: Text(
                                    'Kunjungan',
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            AbsenOnlineScreenKunjungan(
                                          currUser: widget.currUser,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor: const Color(0xFFFFB000)),
                                ),
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              SizedBox(
                                width: double.infinity.w,
                                height: 50.h,
                                child: ElevatedButton.icon(
                                  label: Text(
                                    'Absen Keluar',
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            AbsenOnlineScreenKeluar(
                                          currUser: widget.currUser,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor: const Color(0xFFB31312)),
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
