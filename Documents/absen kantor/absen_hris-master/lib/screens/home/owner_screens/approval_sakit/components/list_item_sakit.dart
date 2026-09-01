import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/core.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/timeline/timeline_step.dart';
import 'package:intl/intl.dart';

import 'dart:math' as math;
import 'package:http/http.dart' as http;

import '../../../../../theme/colors/custom_theme.dart';
import '../../../../../theme/colors/light_colors.dart';
import '../../../../../utils/constant.dart';
import '../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../widgets/dialog.dart';
import '../../../dashboard/sub_dashboard/SIK/karyawan/sakit/components/view_lampiran_sakit.dart';

bool isOpen = false;

class ListItemSakit extends StatefulWidget {
  final Sik sik;
  final Karyawan currUser;
  final Karyawan thisUser;
  final Function onCallback;
  const ListItemSakit({
    super.key,
    required this.sik,
    required this.currUser,
    required this.thisUser,
    required this.onCallback,
  });

  @override
  State<ListItemSakit> createState() => _ListItemSakitState();
}

class _ListItemSakitState extends State<ListItemSakit> {
  _onApproveBtnPress() async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, "Proses...");

    try {
      final response = await http.get(
        Uri.parse('$API_URL/v3/approveSitc/${widget.sik.idSitc}'),
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
              msg: "Approve Sakit Berhasil",
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
              msg: "Approve Sakit Gagal",
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
      Uri.parse('$API_URL/v2/deleteSitc/${widget.sik.idSitc}'),
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
            msg: "Tolak Sakit Berhasil",
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
            msg: "Tolak Sakit Gagal",
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

    if (widget.sik.disetujui == 0 && widget.sik.diverifikasi == 0) {
      status = 'Menunggu Approval Anda';
      statusNum = 1;
    } else if (widget.sik.disetujui == 1 && widget.sik.diverifikasi == 0) {
      status = 'Menunggu Verifikasi HRD';
      statusNum = 2;
    } else if (widget.sik.disetujui == 1 && widget.sik.diverifikasi == 1) {
      status = 'Disetujui';
      statusNum = 3;
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
                    padding: const EdgeInsets.all(16),
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
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: Icon(
                                    Icons.close,
                                    size: 30.w,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nama Karyawan",
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF585858),
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              widget.sik.karyawan!,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13.sp,
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
                                      "Tanggal pengajuan",
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF585858),
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(
                                          DateTime.parse(
                                              widget.sik.tanggalPengajuan!)),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tanggal selesai",
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF585858),
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(
                                          DateTime.parse(
                                              widget.sik.tanggalIzin!)),
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
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
                              "${widget.sik.keterangan}",
                              style: TextStyle(
                                  color: const Color(0xFF585858),
                                  fontSize: 13.sp),
                            ),
                            SizedBox(
                              height: 40.h,
                            ),
                            Text(
                              "Bukti surat",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF585858),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.file_copy_outlined,
                                  color: Colors.black54,
                                  size: 18.w,
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  "File unggahan bukti izin",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF585858),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await Future.delayed(
                                        const Duration(milliseconds: 500));
                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel:
                                          MaterialLocalizations.of(context)
                                              .modalBarrierDismissLabel,
                                      barrierColor: Colors.black87,
                                      transitionDuration:
                                          const Duration(milliseconds: 20),
                                      pageBuilder: (BuildContext buildContext,
                                          Animation animation,
                                          Animation secondaryAnimation) {
                                        return Center(
                                          child: SizedBox(
                                            height: 350.h,
                                            width: 380.w,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  '$API_URL_IMAGE/${widget.sik.lampiranPath}',
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  // shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  const SizedBox(
                                                      child:
                                                          CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.error),
                                                  Text(
                                                      "404 Image Not Found\nPlease Contact Us")
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    "Lihat",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF142638),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
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
                            if (statusNum >= 2) ...[
                              KTimeLineStep(
                                text: "Pengajuan sakit dibuat",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(
                                        widget.sik.tanggalPengajuan!)),
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
                            if (statusNum >= 2) ...[
                              KTimeLineStep(
                                text:
                                    "Pengajuan sakit telah dikirimkan untuk menunggu disetujui",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(
                                        widget.sik.tanggalPengajuan!)),
                                time:
                                    DateFormat('kk:mm').format(DateTime.now()),
                                isFirst: false,
                                isLast: statusNum == 3 ? false : true,
                                isMiddle: false,
                                color: statusNum == 2
                                    ? const Color(0xFFE69E00)
                                    : Colors.black,
                                warna: statusNum == 2
                                    ? const Color(0xFFE69E00)
                                    : Colors.grey,
                                idx: 1,
                              ),
                            ],
                            if (statusNum == 3) ...[
                              KTimeLineStep(
                                text:
                                    "Pengajuan sakit telah disetujui oleh leader/SPV",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(
                                        widget.sik.tanggalPengajuan!)),
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
                            if (statusNum == 3) ...[
                              KTimeLineStep(
                                text: "Pengajuan sakit telah disetujui manager",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(
                                        widget.sik.tanggalPengajuan!)),
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
                            if (statusNum == 3) ...[
                              KTimeLineStep(
                                text: "Pengajuan sakit telah disetujui",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(
                                        widget.sik.tanggalPengajuan!)),
                                time:
                                    DateFormat('kk:mm').format(DateTime.now()),
                                isFirst: false,
                                isLast: true,
                                isMiddle: false,
                                color: const Color(0xFF5BA53B),
                                warna: const Color(0xFF5BA53B),
                                idx: 2,
                              ),
                            ],
                            if (statusNum == 1) ...[
                              KTimeLineStep(
                                text: "Pengajuan sakit telah Ditolak",
                                date: DateFormat('MMM d\n').format(
                                    DateTime.parse(
                                        widget.sik.tanggalPengajuan!)),
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
                        )
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
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Sakit",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16.sp),
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
                        Text(
                          widget.sik.karyawan!,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13.sp,
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
                                  "Tanggal Pengajuan",
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF585858),
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(
                                      DateTime.parse(
                                          widget.sik.tanggalPengajuan!)),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tanggal Selesai",
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF585858),
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(
                                      DateTime.parse(widget.sik.tanggalIzin!)),
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
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
                        ]
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
