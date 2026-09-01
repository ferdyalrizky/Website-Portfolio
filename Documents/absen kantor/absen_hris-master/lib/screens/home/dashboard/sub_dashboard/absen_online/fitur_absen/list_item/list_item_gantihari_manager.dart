import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/ganti_hari.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/timeline/timeline_step.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:intl/intl.dart';

import '../../../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../../../widgets/dialog.dart';
import 'package:http/http.dart' as http;

class ListItemGantihariManager extends StatefulWidget {
  final GantiHari gantihari;
  final Karyawan currUser;
  final Karyawan thisUser;
  final Function onCallback;
  const ListItemGantihariManager({
    super.key,
    required this.gantihari,
    required this.currUser,
    required this.onCallback,
    required this.thisUser,
  });

  @override
  State<ListItemGantihariManager> createState() =>
      _ListItemGantihariManagerState();
}

class _ListItemGantihariManagerState extends State<ListItemGantihariManager> {
  //Status Permintaan
  String status = '';
  int statusNum = 0;

  _onSetStatus() {
    status = '';
    statusNum = 0;

    if (widget.gantihari.status == 1 &&
        widget.gantihari.disetujui == 0 &&
        widget.gantihari.diverifikasi == 0) {
      status = 'Menunggu Approval Manager';
      statusNum = 1;
    } else if (widget.gantihari.status == 1 &&
        widget.gantihari.disetujui == 1 &&
        widget.gantihari.diverifikasi == 0) {
      status = 'Approved';
      statusNum = 2;
    } else if (widget.gantihari.status == 1 &&
        widget.gantihari.disetujui == 1 &&
        widget.gantihari.diverifikasi == 1) {
      status = 'Approved';
      statusNum = 3;
    } else if (widget.gantihari.status == 3 &&
        widget.gantihari.disetujui == 0 &&
        widget.gantihari.diverifikasi == 0) {
      status = 'Dibatalkan';
      statusNum = 4;
    } else if (widget.gantihari.status == 2 &&
        widget.gantihari.disetujui == 0 &&
        widget.gantihari.diverifikasi == 0) {
      status = 'Ditolak';
      statusNum = 5;
    }
  }

  _onApproveBtnPress() async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, "Proses...");
    print(widget.gantihari.idHari);

    try {
      final response = await http.get(
        Uri.parse(
            '$API_URL/v2/gantiHari/approve_data/${widget.gantihari.idHari}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);
      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Approve gantihari Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
        setState(() {
          widget.gantihari.disetujui = 1;
          widget.gantihari.status = 1;
          widget.gantihari.diverifikasi = 0;

          statusNum = 2;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Failed",
              msg: "Approve gantihari Gagal",
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error $e');
    }
  }

  _onTolakBtnPress() async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, "Proses...");

    var response = await http.get(
      Uri.parse(
          '$API_URL/v2/gantiHari/decline_data/${widget.gantihari.idHari}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      },
    );

    Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Success",
            msg: "Tolak gantihari Berhasil",
            contentType: ContentType.success,
          ),
        ),
      );
      setState(() {
        widget.gantihari.disetujui = 0;
        widget.gantihari.status = 2;
        widget.gantihari.diverifikasi = 0;
        statusNum = 5;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Failed",
            msg: "Tolak gantihari Gagal",
            contentType: ContentType.failure,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    _onSetStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (statusNum == 1 || statusNum == 2) ...[
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 14).r,
                child: GestureDetector(
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => makeDismissible(
                          child: DraggableScrollableSheet(
                            initialChildSize: 0.8,
                            minChildSize: 0.5,
                            maxChildSize: 1,
                            builder: (_, controller) => Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(0))),
                              padding: const EdgeInsets.all(16),
                              child: ListView(
                                controller: controller,
                                children: [
                                  SizedBox(
                                    height: 25.h,
                                  ),
                                  const SizedBox(width: 18),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(
                                              top: 6,
                                              bottom: 6,
                                              left: 8,
                                              right: 8,
                                            ).r,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: statusNum == 1
                                                  ? const Color(0xFFE69E00)
                                                  : statusNum == 2
                                                      ? const Color(0xFFE69E00)
                                                      : statusNum == 3
                                                          ? const Color(
                                                              0xFF5BA53B)
                                                          : statusNum == 4
                                                              ? const Color(
                                                                  0xFF585858)
                                                              : statusNum == 5
                                                                  ? const Color(
                                                                      0xFFA11110)
                                                                  : const Color(
                                                                      0xFFA11110),
                                            ),
                                            child: Text(
                                              statusNum == 1
                                                  ? "Menunggu Persetujuan Manager"
                                                  : statusNum == 2
                                                      ? "Menunggu Persetujuan HRD"
                                                      : statusNum == 3
                                                          ? "Disetujui"
                                                          : statusNum == 4
                                                              ? "Dibatalkan"
                                                              : statusNum == 5
                                                                  ? "Ditolak"
                                                                  : "Ditolak",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              icon: Icon(
                                                Icons.close,
                                                size: 30.w,
                                                color: Colors.black,
                                              ))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 40.h,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Nama Karyawan",
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Text(
                                            widget.thisUser.namaKaryawan!,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Tanggal gantihari",
                                                style: TextStyle(
                                                    color: Color(0xFF585858),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Text(
                                                DateFormat('dd-MM-yyyy').format(
                                                    DateTime.parse(widget
                                                        .gantihari.tglGanti!)),
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Jam datang terlambat",
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color:
                                                      const Color(0xFF585858),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('kk:mm')
                                                    .format(DateTime.now()),
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 20.w,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      Text(
                                        "Catatan gantihari",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF585858),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                        '${widget.gantihari.keterangan}',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      SizedBox(
                                        height: 35.h,
                                      ),
                                      Text(
                                        "Riwayat Pengajuan",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF585858),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      //Timeline Ganti Hari
                                      if (statusNum >= 1) ...[
                                        KTimeLineStep(
                                          text: "Pengajuan ganti hari dibuat",
                                          date: "",
                                          time: "",
                                          color: Colors.black,
                                          warna: Colors.grey,
                                          isFirst: true,
                                          isLast: false,
                                          isMiddle: false,
                                          idx: 0,
                                        ),
                                      ],
                                      if (statusNum >= 1) ...[
                                        KTimeLineStep(
                                          text: "Data dikirimkan ke manager",
                                          date: statusNum == 1
                                              ? DateFormat('MMM d\n').format(
                                                  DateTime.parse(widget
                                                      .gantihari.updatedAt!))
                                              : "",
                                          time: statusNum == 1
                                              ? DateFormat('kk:mm').format(
                                                  DateTime.parse(widget
                                                          .gantihari.updatedAt!)
                                                      .toLocal())
                                              : "",
                                          isFirst: false,
                                          isLast: statusNum >= 2
                                              ? false
                                              : statusNum == 5
                                                  ? false
                                                  : true && statusNum == 4
                                                      ? false
                                                      : true && statusNum == 3
                                                          ? false
                                                          : true,
                                          isMiddle: false,
                                          color: statusNum == 1
                                              ? const Color(0xFFE69E00)
                                              : Colors.black,
                                          warna: statusNum == 1
                                              ? const Color(0xFFE69E00)
                                              : Colors.grey,
                                          idx: 1,
                                        ),
                                      ],
                                      if (statusNum >= 2
                                          ? statusNum != 5 && statusNum != 4
                                          : false) ...[
                                        const KTimeLineStep(
                                          text:
                                              "Pengajuan disetujui oleh manager",
                                          date: "",
                                          time: "",
                                          isFirst: false,
                                          isLast: false,
                                          isMiddle: true,
                                          color: Colors.black,
                                          warna: Colors.grey,
                                          idx: 2,
                                        ),
                                      ],
                                      if (statusNum >= 2
                                          ? statusNum != 5 && statusNum != 4
                                          : false) ...[
                                        KTimeLineStep(
                                          text: "Data dikirimkan ke HRD",
                                          date: statusNum == 2
                                              ? DateFormat('MMM d\n').format(
                                                  DateTime.parse(widget
                                                      .gantihari.updatedAt!))
                                              : "",
                                          time: statusNum == 2
                                              ? DateFormat('kk:mm').format(
                                                  DateTime.parse(widget
                                                          .gantihari.updatedAt!)
                                                      .toLocal())
                                              : "",
                                          isFirst: false,
                                          isLast: statusNum == 5
                                              ? false
                                              : true && statusNum == 4
                                                  ? false
                                                  : true && statusNum == 3
                                                      ? false
                                                      : true,
                                          isMiddle: true,
                                          color: statusNum == 2
                                              ? const Color(0xFFE69E00)
                                              : Colors.black,
                                          warna: statusNum == 2
                                              ? const Color(0xFFE69E00)
                                              : Colors.grey,
                                          idx: 2,
                                        ),
                                      ],
                                      if (statusNum == 3) ...[
                                        KTimeLineStep(
                                          text: "Pengajuan disetujui oleh HRD",
                                          date: statusNum == 3
                                              ? DateFormat('MMM d\n').format(
                                                  DateTime.parse(widget
                                                      .gantihari.updatedAt!))
                                              : "",
                                          time: statusNum == 3
                                              ? DateFormat('kk:mm').format(
                                                  DateTime.parse(widget
                                                          .gantihari.updatedAt!)
                                                      .toLocal())
                                              : "",
                                          isFirst: false,
                                          isLast: true,
                                          isMiddle: false,
                                          color: const Color(0xFF5BA53B),
                                          warna: const Color(0xFF5BA53B),
                                          idx: 2,
                                        ),
                                      ],
                                      if (statusNum == 4) ...[
                                        KTimeLineStep(
                                          text:
                                              "Pengajuan ganti hari telah Dibatalkan",
                                          date: statusNum == 4
                                              ? DateFormat('MMM d\n').format(
                                                  DateTime.parse(widget
                                                      .gantihari.updatedAt!))
                                              : "",
                                          time: statusNum == 4
                                              ? DateFormat('kk:mm').format(
                                                  DateTime.parse(widget
                                                          .gantihari.updatedAt!)
                                                      .toLocal())
                                              : "",
                                          isFirst: false,
                                          isLast: true,
                                          isMiddle: false,
                                          color: const Color(0xFF585858),
                                          warna: const Color(0xFF585858),
                                          idx: 2,
                                        ),
                                      ],
                                      if (statusNum == 5) ...[
                                        KTimeLineStep(
                                          text:
                                              "Pengajuan ganti hari telah Ditolak",
                                          date: statusNum == 5
                                              ? DateFormat('MMM d\n').format(
                                                  DateTime.parse(widget
                                                      .gantihari.updatedAt!))
                                              : "",
                                          time: statusNum == 5
                                              ? DateFormat('kk:mm').format(
                                                  DateTime.parse(widget
                                                          .gantihari.updatedAt!)
                                                      .toLocal())
                                              : "",
                                          isFirst: false,
                                          isLast: true,
                                          isMiddle: false,
                                          color: const Color(0xFFA11110),
                                          warna: const Color(0xFFA11110),
                                          idx: 2,
                                        ),
                                      ],
                                      const SizedBox(
                                        height: 40,
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
                    child: Card(
                      shadowColor: Colors.grey.shade100,
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        //height: isOpen ? 200 : 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 0,
                              child: Container(
                                height: 33.h,
                                width: 5.w,
                                color: statusNum == 1
                                    ? const Color(0xFFE69E00)
                                    : statusNum == 2
                                        ? const Color(0xFFE69E00)
                                        : statusNum == 3
                                            ? const Color(0xFF5BA53B)
                                            : statusNum == 4
                                                ? const Color(0xFF585858)
                                                : statusNum == 5
                                                    ? const Color(0xFFA11110)
                                                    : const Color(0xFFA11110),
                              ),
                            ),
                            Expanded(flex: 0, child: SizedBox(width: 18.w)),
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                      top: 6,
                                      bottom: 6,
                                      left: 8,
                                      right: 8,
                                    ).r,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: statusNum == 1
                                          ? const Color(0xFFE69E00)
                                          : statusNum == 2
                                              ? const Color(0xFFE69E00)
                                              : statusNum == 3
                                                  ? const Color(0xFF5BA53B)
                                                  : statusNum == 4
                                                      ? const Color(0xFF585858)
                                                      : statusNum == 5
                                                          ? const Color(
                                                              0xFFA11110)
                                                          : const Color(
                                                              0xFFA11110),
                                    ),
                                    child: Text(
                                      statusNum == 1
                                          ? "Menunggu Persetujuan Manager"
                                          : statusNum == 2
                                              ? "Menunggu Persetujuan HRD"
                                              : statusNum == 3
                                                  ? "Disetujui"
                                                  : statusNum == 4
                                                      ? "Dibatalkan"
                                                      : statusNum == 5
                                                          ? "Ditolak"
                                                          : "Ditolak",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15.h,
                                  ),
                                  Text(
                                    "Nama Karyawan",
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: const Color(0xFF585858),
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  Text(
                                    widget.thisUser.namaKaryawan!,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Masuk kerja",
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            DateFormat('dd/MM/yyyy').format(
                                                DateTime.parse(widget
                                                    .gantihari.tglMasuk!)),
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 20.w,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Ganti hari",
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            DateFormat('dd/MM/yyyy').format(
                                                DateTime.parse(widget
                                                    .gantihari.tglGanti!)),
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 15.w,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  _buildBottomActions(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (statusNum == 1) ...[
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      bottom: 8, // add bottom padding
                    ).r,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          label: Text(
                            'Ditolak',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: _onTolakBtnPress,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                color: Colors.black,
                              ),
                            ),
                            padding: const EdgeInsets.only(
                              top: 1,
                              bottom: 1,
                              left: 50,
                              right: 50,
                            ).r,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        ElevatedButton.icon(
                          label: Text(
                            'Disetujui',
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: _onApproveBtnPress,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.only(
                              top: 1,
                              bottom: 1,
                              left: 50,
                              right: 50,
                            ).r,
                            backgroundColor: LightColors.kFagettiBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(
          onTap: () {},
          child: child,
        ),
      );
}
