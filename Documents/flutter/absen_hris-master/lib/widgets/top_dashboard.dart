import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/masuk%20absen/lokasi_absen.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/jam_live.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:hris_v2/models/absen_online.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/keluar%20absen/lokasi_absen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:http/http.dart' as http;

class TopContainerDashboard extends StatefulWidget {
  final Karyawan currUser;
  final double height;
  final double width;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Radius? bottomRightRadius;
  final Radius? bottomLeftRadius;
  final Color? color;
  const TopContainerDashboard(
      {super.key,
      required this.currUser,
      required this.height,
      required this.width,
      required this.child,
      this.padding,
      this.margin,
      this.bottomLeftRadius,
      this.bottomRightRadius,
      this.color});

  @override
  State<TopContainerDashboard> createState() => _TopContainerDashboardState();
}

class _TopContainerDashboardState extends State<TopContainerDashboard> {
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
    print(_absenOnline);
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
                      padding: widget.padding ??
                          const EdgeInsets.only(
                            top: 10,
                            left: 20,
                            right: 20,
                          ).r,
                      margin: widget.margin ?? const EdgeInsets.all(0),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/home2.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      height: widget.height,
                      width: widget.width,
                      child: widget.child,
                    ),
                  ],
                ),
                SizedBox(
                  height: 50.h,
                ),
              ],
            ),
            if (Platform.isAndroid) ...[
              Positioned(
                bottom: -10.h,
                left: 10.w,
                right: 10.w,
                child: RPadding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 12, right: 12)
                        .r,
                    decoration: BoxDecoration(
                        color: const Color(0xFF0277B7),
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 10).r,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat.yMMMMEEEEd('id_ID')
                                    .format(DateTime.now()),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                ),
                              ),
                              const ClockWidget(),
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
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
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
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                            top: 14,
                                            bottom: 14,
                                            left: 14,
                                            right: 14,
                                          ).r,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        const Color(0xFF5BA53B),
                                                    radius: 20.r,
                                                    child: const Icon(
                                                      Icons.login,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "ABSEN MASUK",
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF585858),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12.sp,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 3.h,
                                                      ),
                                                      Text(
                                                        _absenOnline!
                                                                    .absenMasuk ==
                                                                ""
                                                            ? "Belum bisa"
                                                            : DateFormat(
                                                                    "HH:mm:ss")
                                                                .format(DateFormat(
                                                                        "HH:mm:ss")
                                                                    .parse(_absenOnline!
                                                                        .absenMasuk)),
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF121212),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 12.w,
                                  ),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
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
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                            top: 14,
                                            bottom: 14,
                                            left: 15,
                                            right: 15,
                                          ).r,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFB31312),
                                                      radius: 20.r,
                                                      child: const Icon(
                                                        Icons.logout,
                                                        color: Colors.white,
                                                      )),
                                                  SizedBox(
                                                    width: 5.w,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "ABSEN KELUAR",
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF585858),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12.sp,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 3,
                                                      ),
                                                      Text(
                                                        _absenOnline!
                                                                    .absenPulang ==
                                                                ""
                                                            ? "Belum bisa"
                                                            : DateFormat(
                                                                    "HH:mm:ss")
                                                                .format(DateFormat(
                                                                        "HH:mm:ss")
                                                                    .parse(_absenOnline!
                                                                        .absenPulang)),
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF121212),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (Platform.isIOS) ...[
              Positioned(
                bottom: -10.h,
                left: 2.w,
                right: 2.w,
                child: RPadding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 15, right: 15)
                        .r,
                    decoration: BoxDecoration(
                        color: const Color(0xFF0277B7),
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 10).r,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat.yMMMMEEEEd('id_ID')
                                    .format(DateTime.now()),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                ),
                              ),
                              const ClockWidget(),
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
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
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
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                            top: 12,
                                            bottom: 14,
                                            left: 14,
                                            right: 14,
                                          ).r,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        const Color(0xFF5BA53B),
                                                    radius: 20.r,
                                                    child: const Icon(
                                                      Icons.login,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "ABSEN MASUK",
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF585858),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12.sp,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 3.h,
                                                      ),
                                                      Text(
                                                        _absenOnline!
                                                                    .absenMasuk ==
                                                                ""
                                                            ? "Belum bisa"
                                                            : DateFormat(
                                                                    "HH:mm:ss")
                                                                .format(DateFormat(
                                                                        "HH:mm:ss")
                                                                    .parse(_absenOnline!
                                                                        .absenMasuk)),
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF121212),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 12.w,
                                  ),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _absenOnline!.absenMasuk == ""
                                              ? () {}
                                              : _absenOnline!.absenPulang == ""
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            AbsenOnlineScreenKeluar(
                                                          currUser:
                                                              widget.currUser,
                                                        ),
                                                      ),
                                                    )
                                                  : () {};
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                            top: 12,
                                            bottom: 14,
                                            left: 14,
                                            right: 14,
                                          ).r,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFB31312),
                                                      radius: 20.r,
                                                      child: const Icon(
                                                        Icons.logout,
                                                        color: Colors.white,
                                                      )),
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "ABSEN KELUAR",
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF585858),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12.sp,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 3,
                                                      ),
                                                      Text(
                                                        _absenOnline!
                                                                    .absenPulang ==
                                                                ""
                                                            ? "Belum bisa"
                                                            : DateFormat(
                                                                    "HH:mm:ss")
                                                                .format(DateFormat(
                                                                        "HH:mm:ss")
                                                                    .parse(_absenOnline!
                                                                        .absenPulang)),
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF121212),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
