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

import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';

import 'package:hris_v2/widgets/top_container_hadir.dart';

import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

class AbsenOnlineHome extends StatefulWidget {
  //TODO: Nambah Data User untuk Absen Online push ke API
  final Karyawan currUser;
  const AbsenOnlineHome({super.key, required this.currUser});

  @override
  State<AbsenOnlineHome> createState() => _AbsenOnlineHomeState();
}

class _AbsenOnlineHomeState extends State<AbsenOnlineHome> {
  bool isInSelectedArea = true;
  File? fotoSelfie;
  Uint8List? selfieBytes;
  AbsenOnline? _absenOnline;
  List<String> _alamat = [];
  List<String> _visitsTime = [];
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

      // Store visits in a list
      _visitsTime = List<String>.from(_absenOnline!.visits);
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoadingAbsenOnline = false;
    });
  }

  _lokasiAlamatVisit() async {
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

      // Store visits in a list
      _alamat = List<String>.from(_absenOnline!.alamat);
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
    await _lokasiAlamatVisit();
  }

  //![START Screen Build]
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              TopAbsenHadir(
                currUser: widget.currUser,
                height: 150.w,
                width: double.infinity,
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(28.w),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        Center(
                          child: Container(
                            height: 2.h,
                            width: 500.w,
                            color: const Color(0xFFE2E2E2),
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Text(
                          "Absen hari ini",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 22.h,
                        ),
                        isLoadingAbsenOnline
                            ? const Column(
                                children: [
                                  Center(child: Loader()),
                                ],
                              )
                            : Column(
                                children: [
                                  _absenOnline!.absenPulang == ""
                                      ? Container()
                                      : Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15.w)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        const Color(0xFFB31312),
                                                    radius: 25.w,
                                                    child: Icon(
                                                      size: 30.w,
                                                      Icons.logout,
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
                                                        "Absen keluar",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 16.sp,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 3.h,
                                                      ),
                                                      Text(
                                                        DateFormat("dd MMMM y")
                                                            .format(
                                                                DateTime.now()),
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF717171),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    _absenOnline!.absenPulang ==
                                                            ""
                                                        ? "--:--"
                                                        : "${DateFormat("HH:mm").format(DateFormat("HH:mm").parse(_absenOnline!.absenPulang))} WIB",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                  SizedBox(
                                    height: 22.h,
                                  ),
                                  _visitsTime.isNotEmpty && _alamat.isNotEmpty
                                      ? Column(
                                          children: List.generate(
                                              _visitsTime.length, (index) {
                                            int reverseIndex =
                                                _visitsTime.length - 1 - index;
                                            return InkWell(
                                              onTap: () {
                                                // Show modal bottom sheet for the selected visit
                                                showModalBottomSheet(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  isScrollControlled: true,
                                                  context: context,
                                                  builder: (context) =>
                                                      GestureDetector(
                                                    behavior:
                                                        HitTestBehavior.opaque,
                                                    onTap: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child:
                                                        DraggableScrollableSheet(
                                                      initialChildSize: 0.4,
                                                      minChildSize: 0.4,
                                                      maxChildSize: 1,
                                                      builder:
                                                          (_, controller) =>
                                                              Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.white,
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                    .all(16)
                                                                .w,
                                                        child: ListView(
                                                          controller:
                                                              controller,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    IconButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.of(context).pop(),
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .close,
                                                                        size: 30
                                                                            .w,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Column(
                                                                  children: [
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(15.w),
                                                                      ),
                                                                      margin: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              8.h),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              CircleAvatar(
                                                                                backgroundColor: const Color(0xFFFFB000),
                                                                                radius: 25.w,
                                                                                child: Icon(
                                                                                  Icons.location_on,
                                                                                  size: 30.w,
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 10.w),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    "Kunjungan ${reverseIndex + 1}", // Display visit number
                                                                                    style: TextStyle(
                                                                                      color: Colors.black,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontSize: 16.sp,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 3.h),
                                                                                  Text(
                                                                                    DateFormat("dd MMMM y").format(DateTime.now()),
                                                                                    style: TextStyle(
                                                                                      color: const Color(0xFF717171),
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 14.sp,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                "${DateFormat("HH:mm").format(DateFormat("HH:mm").parse(_visitsTime[reverseIndex]))} WIB", // Display the visit time
                                                                                style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.w700,
                                                                                  fontSize: 16.sp,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                          "Alamat",
                                                                          style: TextStyle(
                                                                              color: Color(0xFF585858),
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                5.h),
                                                                        Text(
                                                                          "${_alamat[reverseIndex]}",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize:
                                                                                16.sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.w),
                                                ),
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 8.h),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFFFFB000),
                                                          radius: 25.w,
                                                          child: Icon(
                                                            Icons.location_on,
                                                            size: 30.w,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10.w),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Kunjungan ${reverseIndex + 1}", // Display visit number
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 16.sp,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 3.h),
                                                            Text(
                                                              DateFormat(
                                                                      "dd MMMM y")
                                                                  .format(DateTime
                                                                      .now()),
                                                              style: TextStyle(
                                                                color: const Color(
                                                                    0xFF717171),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14.sp,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "${DateFormat("HH:mm").format(DateFormat("HH:mm").parse(_visitsTime[reverseIndex]))} WIB", // Display the visit time
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 16.sp,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                        )
                                      : Container(), // If there are no visits, show an empty container
                                  SizedBox(
                                    height: 22.h,
                                  ),

                                  _absenOnline!.absenMasuk == ""
                                      ? Column(
                                          children: [
                                            Image.asset(
                                                "assets/images/belumabsen.png"),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            Text(
                                              "Anda belum absen hari ini",
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight:
                                                      ui.FontWeight.w600,
                                                  color: Colors.black),
                                            )
                                          ],
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15.r)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        const Color(0xFF5BA53B),
                                                    radius: 25.w,
                                                    child: Icon(
                                                      Icons.login,
                                                      size: 30.w,
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
                                                        "Absen masuk",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 16.sp,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 3.h,
                                                      ),
                                                      Text(
                                                        DateFormat("dd MMMM y")
                                                            .format(
                                                                DateTime.now()),
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF717171),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _absenOnline!.absenMasuk ==
                                                            ""
                                                        ? "--:--"
                                                        : DateFormat("HH:mm")
                                                                        .parse(_absenOnline!
                                                                            .absenMasuk)
                                                                        .hour >=
                                                                    9 ||
                                                                (DateFormat("HH:mm")
                                                                            .parse(_absenOnline!
                                                                                .absenMasuk)
                                                                            .hour ==
                                                                        9 &&
                                                                    DateFormat("HH:mm")
                                                                            .parse(_absenOnline!.absenMasuk)
                                                                            .minute >
                                                                        0)
                                                            ? "${DateFormat("HH:mm").format(DateFormat("HH:mm").parse(_absenOnline!.absenMasuk))} WIB"
                                                            : "${DateFormat("HH:mm").format(DateFormat("HH:mm").parse(_absenOnline!.absenMasuk))} WIB",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                  (DateFormat("HH:mm")
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
                                                      ? Text(
                                                          "Terlambat",
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                            color: const Color(
                                                                0xFF717171),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14.sp,
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
