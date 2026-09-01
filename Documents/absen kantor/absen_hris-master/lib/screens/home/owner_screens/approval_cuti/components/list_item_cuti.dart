import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/core.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/timeline/timeline_step.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:intl/intl.dart';

import 'dart:math' as math;
import 'package:http/http.dart' as http;

import '../../../../../theme/colors/custom_theme.dart';
import '../../../../../utils/constant.dart';
import '../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../widgets/dialog.dart';

bool isOpen = false;

class ListItemCuti extends StatefulWidget {
  final Sik cuti;
  final Karyawan currUser;
  final Karyawan thisUser;
  final Function onCallback;
  const ListItemCuti({
    super.key,
    required this.cuti,
    required this.currUser,
    required this.thisUser,
    required this.onCallback,
  });

  @override
  State<ListItemCuti> createState() => _ListItemCutiState();
}

class _ListItemCutiState extends State<ListItemCuti> {
  _onApproveBtnPress() async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, "Proses...");

    try {
      final response = await http.get(
        Uri.parse('$API_URL/v3/approveSitc/${widget.cuti.idSitc}'),
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
              msg: "Approve Cuti Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
        widget.onCallback();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Failed",
              msg: "Approve Cuti Gagal",
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error $e');
    }
  }

  _onHapusBtnPress() async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, "Proses...");

    var response = await http.get(
      Uri.parse('$API_URL/v2/deleteSitc/${widget.cuti.idSitc}'),
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
            msg: "Tolak Cuti Berhasil",
            contentType: ContentType.success,
          ),
        ),
      );

      widget.onCallback();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Failed",
            msg: "Tolak Cuti Gagal",
            contentType: ContentType.failure,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = "";
    int statusNum = 0;

    if (widget.cuti.status == 1 &&
        widget.cuti.disetujui == 0 &&
        widget.cuti.diverifikasi == 0) {
      status = 'Menunggu Approval Manager';
      statusNum = 1;
    } else if (widget.cuti.status == 1 &&
        widget.cuti.disetujui == 1 &&
        widget.cuti.diverifikasi == 0) {
      status = 'Approved';
      statusNum = 2;
    } else if (widget.cuti.status == 1 &&
        widget.cuti.disetujui == 1 &&
        widget.cuti.diverifikasi == 1) {
      status = 'Approved';
      statusNum = 3;
    } else if (widget.cuti.status == 3 &&
        widget.cuti.disetujui == 0 &&
        widget.cuti.diverifikasi == 0) {
      status = 'Dibatalkan';
      statusNum = 4;
    } else if (widget.cuti.status == 2 &&
        widget.cuti.disetujui == 0 &&
        widget.cuti.diverifikasi == 0) {
      status = 'Ditolak';
      statusNum = 5;
    }

    return RPadding(
      padding:
          const EdgeInsets.only(top: 14, bottom: 14, left: 17, right: 17).r,
      child: GestureDetector(
        onTap: () {
          setState(() {
            isOpen = !isOpen;
          });
        },
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              context: context,
              builder: (context) => makeDismissible(
                child: DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  minChildSize: 0.5,
                  maxChildSize: 1,
                  builder: (_, controller) => Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(0))),
                    padding: const EdgeInsets.all(16).w,
                    child: ListView(
                      controller: controller,
                      children: [
                        SizedBox(
                          height: 25.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
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
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tanggal Mulai",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: const Color(0xFF585858),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(
                                          DateTime.parse(
                                              widget.cuti.tanggalIzin!)),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tanggal Selesai",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: const Color(0xFF585858),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(
                                          DateTime.parse(
                                              widget.cuti.tanggalIzin!)),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40.h,
                            ),
                            Text(
                              "Keterangan",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF585858),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            Text(
                              "${widget.cuti.keterangan}",
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF585858),
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 40.h,
                            ),
                            Text(
                              "Riwayat pengajuan",
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF585858),
                                  fontWeight: FontWeight.w400),
                            ),
                            if (statusNum >= 1) ...[
                              KTimeLineStep(
                                text: "Pengajuan cuti dibuat",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(
                                        widget.cuti.tanggalPengajuan!)),
                                time:
                                    DateFormat('kk:mm').format(DateTime.now()),
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
                                text:
                                    "Pengajuan cuti telah dikirimkan untuk menunggu disetujui",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(widget.cuti.tanggalIzin!)),
                                time:
                                    DateFormat('kk:mm').format(DateTime.now()),
                                isFirst: false,
                                isLast: statusNum >= 2
                                    ? false
                                    : true && statusNum == 5
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
                            if (statusNum >= 2 &&
                                statusNum != 4 &&
                                statusNum != 5) ...[
                              KTimeLineStep(
                                text:
                                    "Pengajuan cuti telah disetujui oleh manager",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(
                                        widget.cuti.tanggalPengajuan!)),
                                time:
                                    DateFormat('kk:mm').format(DateTime.now()),
                                isFirst: false,
                                isLast: false,
                                isMiddle: true,
                                color: Colors.black,
                                warna: Colors.grey,
                                idx: 2,
                              ),
                            ],
                            if (statusNum >= 2 &&
                                statusNum != 4 &&
                                statusNum != 5) ...[
                              KTimeLineStep(
                                text: "Data dikirimkan ke HRD",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(
                                        widget.cuti.tanggalPengajuan!)),
                                time:
                                    DateFormat('kk:mm').format(DateTime.now()),
                                isFirst: false,
                                isLast: statusNum == 3 ? false : true,
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
                                text: "Pengajuan cuti telah disetujui",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(
                                        widget.cuti.tanggalPengajuan!)),
                                time:
                                    DateFormat('kk:mm').format(DateTime.now()),
                                isFirst: false,
                                isLast: true,
                                isMiddle: false,
                                color: const Color(0xFF585858),
                                warna: const Color(0xFF585858),
                                idx: 2,
                              ),
                            ],
                            if (statusNum == 4) ...[
                              KTimeLineStep(
                                text: "Pengajuan cuti telah Ditolak",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(
                                        widget.cuti.tanggalPengajuan!)),
                                time:
                                    DateFormat('kk:mm').format(DateTime.now()),
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
                                text: "Pengajuan cuti telah Ditolak",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(
                                        widget.cuti.tanggalPengajuan!)),
                                time:
                                    DateFormat('kk:mm').format(DateTime.now()),
                                isFirst: false,
                                isLast: true,
                                isMiddle: false,
                                color: const Color(0xFFA11110),
                                warna: const Color(0xFFA11110),
                                idx: 2,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(
                          height: 25.h,
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              //height: isOpen ? 200 : 100,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding:
                  const EdgeInsets.only(top: 20, bottom: 20, right: 6, left: 1)
                      .r,
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
                                                ? const Color(0xFFA11110)
                                                : const Color(0xFFA11110),
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
                                fontSize: 13.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Text(
                          widget.cuti.namaCutiNormatif!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
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
                            fontSize: 13.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tangggal mulai",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF585858),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.parse(widget.cuti.tanggalIzin!)),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tangggal selesai",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF585858),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.parse(widget.cuti.tanggalIzin!)),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        if (statusNum == 1) ...[
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                    bottom: 8.r, // add bottom padding
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        label: Text(
                                          'Ditolak',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        onPressed: _onHapusBtnPress,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side: const BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          padding: EdgeInsets.only(
                                            top: 1.r,
                                            bottom: 1.r,
                                            left: 55.r,
                                            right: 55.r,
                                          ),
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
                                              fontSize: 14.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        onPressed: _onApproveBtnPress,
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.only(
                                            top: 1.r,
                                            bottom: 1.r,
                                            left: 55.r,
                                            right: 55.r,
                                          ),
                                          backgroundColor:
                                              LightColors.kFagettiBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
