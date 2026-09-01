import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/izin.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/list_izin.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/timeline/timeline_step.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/widgets/custom_snackbar_content.dart';
import 'package:intl/intl.dart';

import '../../../../../../../../models/karyawan.dart';
import 'package:http/http.dart' as http;
import '../../../../../../../../utils/constant.dart';
import '../../../../../../../../widgets/dialog.dart';

bool isOpen = false;

class ListItemIzinAnakBuahRiwayat extends StatefulWidget {
  final Izin izin;
  final Karyawan currUser;
  const ListItemIzinAnakBuahRiwayat({
    super.key,
    required this.izin,
    required this.currUser,
  });

  @override
  State<ListItemIzinAnakBuahRiwayat> createState() =>
      _ListItemIzinAnakBuahRiwayatState();
}

class _ListItemIzinAnakBuahRiwayatState
    extends State<ListItemIzinAnakBuahRiwayat> {
  //Status Permintaan
  String status = '';
  int statusNum = 0;

  _onSetStatus() {
    status = '';
    statusNum = 0;
    if (widget.izin.status == 1 &&
        widget.izin.disetujuhi == 0 &&
        widget.izin.diverifikasi == 0) {
      status = 'Menunggu Approval Manager';
      statusNum = 1;
    } else if (widget.izin.status == 1 &&
        widget.izin.disetujuhi == 1 &&
        widget.izin.diverifikasi == 0) {
      status = 'Approved';
      statusNum = 2;
    } else if (widget.izin.status == 1 &&
        widget.izin.disetujuhi == 1 &&
        widget.izin.diverifikasi == 1) {
      status = 'Approved';
      statusNum = 3;
    } else if (widget.izin.status == 3 &&
        widget.izin.disetujuhi == 0 &&
        widget.izin.diverifikasi == 0) {
      status = 'Dibatalkan';
      statusNum = 4;
    } else if (widget.izin.status == 2 &&
        widget.izin.disetujuhi == 0 &&
        widget.izin.diverifikasi == 0) {
      status = 'Ditolak';
      statusNum = 5;
    } else if (widget.izin.status == 1 &&
        widget.izin.disetujuhi == 0 &&
        widget.izin.diverifikasi == 1) {
      status = 'Disetjui';
      statusNum = 6;
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
        if (statusNum >= 3) ...[
          Padding(
            padding:
                const EdgeInsets.only(top: 14, bottom: 14, left: 17, right: 17)
                    .r,
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
                    builder: (context) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(),
                      child: DraggableScrollableSheet(
                        initialChildSize: 0.8,
                        minChildSize: 0.5,
                        maxChildSize: 1,
                        builder: (_, controller) => Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(0))),
                          padding: EdgeInsets.all(16.w),
                          child: ListView(
                            controller: controller,
                            children: [
                              SizedBox(
                                height: 25.h,
                              ),
                              SizedBox(width: 18.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      ? const Color(0xFF5BA53B)
                                                      : statusNum == 4
                                                          ? const Color(
                                                              0xFF585858)
                                                          : statusNum == 5
                                                              ? const Color(
                                                                  0xFFA11110)
                                                              : statusNum == 6
                                                                  ? const Color(
                                                                      0xFF5BA53B)
                                                                  : const Color(
                                                                      0xFF5BA53B),
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
                                                              : statusNum == 6
                                                                  ? "Disetujui"
                                                                  : "Disetujui",
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
                                            fontSize: 14.sp,
                                            color: const Color(0xFF585858),
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      Text(
                                        widget.izin.namaKaryawan!,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Tanggal izin",
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            DateFormat('dd-MM-yyyy').format(
                                                DateTime.parse(
                                                    widget.izin.tglIzin!)),
                                            style: TextStyle(
                                                fontSize: 14.sp,
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
                                          if (widget.izin.keperluan ==
                                              "Datang Telat") ...[
                                            Text(
                                              "Jam datang terlambat",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('kk:mm').format(
                                                  DateTime.parse(
                                                      widget.izin.dtgTelat!)),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                          if (widget.izin.keperluan ==
                                              "Pulang Cepat") ...[
                                            Text(
                                              "Jam Pulang Cepat",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('kk:mm').format(
                                                  DateTime.parse(
                                                      widget.izin.pulangCpt!)),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                          ],
                                          if (widget.izin.keperluan ==
                                              "Izin Sementara") ...[
                                            Text(
                                              "Jam mulai",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              '${widget.izin.jamKeluar}',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                          ],
                                        ],
                                      ),
                                      SizedBox(
                                        width: 20.w,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (widget.izin.keperluan ==
                                              "Izin Sementara") ...[
                                            Text(
                                              "Jam akhir",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              '${widget.izin.jamMasuk}',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 40.h,
                                  ),
                                  Text(
                                    "Catatan izin",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF585858),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  Text(
                                    '${widget.izin.keterangan}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF585858),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 35,
                                  ),
                                  Text(
                                    "Bukti izin",
                                    style: TextStyle(
                                      fontSize: 14.sp,
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
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "File unggahan bukti izin",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: const Color(0xFF585858),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await Future.delayed(const Duration(
                                              milliseconds: 500));
                                          showGeneralDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            barrierLabel:
                                                MaterialLocalizations.of(
                                                        context)
                                                    .modalBarrierDismissLabel,
                                            barrierColor: Colors.black87,
                                            transitionDuration: const Duration(
                                                milliseconds: 20),
                                            pageBuilder: (BuildContext
                                                    buildContext,
                                                Animation animation,
                                                Animation secondaryAnimation) {
                                              return Center(
                                                child: SizedBox(
                                                  height: 350.h,
                                                  width: 380.w,
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        '$API_URL_IMAGE/${widget.izin.lampiranPath}',
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      decoration: BoxDecoration(
                                                        // shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder: (context,
                                                            url) =>
                                                        const SizedBox(
                                                            child:
                                                                CircularProgressIndicator()),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
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
                                            color: const Color(0xFF142638),
                                            decoration:
                                                TextDecoration.underline,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 35,
                                  ),
                                  Text(
                                    "Riwayat Pengajuan",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF585858),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  //Timeline Datang Telat
                                  if (widget.izin.keperluan ==
                                      "Datang Telat") ...[
                                    if (statusNum >= 1) ...[
                                      KTimeLineStep(
                                        text:
                                            "Pengajuan izin Datang Telat dibuat",
                                        date: "",
                                        time: "",
                                        color: Colors.black,
                                        warna: Colors.grey,
                                        isFirst: true,
                                        isLast: false,
                                        isMiddle: false,
                                        idx: 1,
                                      ),
                                    ],
                                    if (statusNum >= 1) ...[
                                      KTimeLineStep(
                                        text:
                                            "Pengajuan izin Datang Telat telah dikirimkan untuk menunggu disetujui",
                                        date: statusNum == 1
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 1
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
                                                    .toLocal())
                                            : "",
                                        isFirst: false,
                                        isLast: statusNum >= 2
                                            ? false
                                            : true && statusNum == 5
                                                ? false
                                                : true && statusNum == 4
                                                    ? false
                                                    : true && statusNum == 3
                                                        ? false
                                                        : true && statusNum == 6
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
                                            "Pengajuan izin Datang Telat telah disetujui manager",
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
                                    if (statusNum >= 2 &&
                                        statusNum != 4 &&
                                        statusNum != 5) ...[
                                      KTimeLineStep(
                                        text: "Data dikirimkan ke HRD",
                                        date: statusNum == 2
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 2
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
                                                    .toLocal())
                                            : "",
                                        isFirst: false,
                                        isLast: statusNum == 3
                                            ? false
                                            : true && statusNum == 6
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
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 3
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
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
                                        text: "Pengajuan izin dibatalkan",
                                        date: statusNum == 4
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 4
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
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
                                            "Pengajuan izin Datang Telat telah Ditolak",
                                        date: statusNum == 5
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 5
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
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
                                    if (statusNum == 6) ...[
                                      KTimeLineStep(
                                        text: "Pengajuan disetujui oleh HRD",
                                        date: statusNum == 6
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 6
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
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
                                  ],

                                  //TimeLine Pulang Cepat
                                  if (widget.izin.keperluan ==
                                      "Pulang Cepat") ...[
                                    if (statusNum >= 1) ...[
                                      KTimeLineStep(
                                        text:
                                            "Pengajuan izin Pulang Cepat dibuat",
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
                                        text:
                                            "Pengajuan izin Pulang Cepat telah dikirimkan ke manager",
                                        date: statusNum == 1
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 1
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
                                                    .toLocal())
                                            : "",
                                        isFirst: false,
                                        isLast: statusNum >= 2
                                            ? false
                                            : true && statusNum == 5
                                                ? false
                                                : true && statusNum == 4
                                                    ? false
                                                    : true && statusNum == 3
                                                        ? false
                                                        : true && statusNum == 6
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
                                            "Pengajuan izin Pulang Cepat telah disetujui manager",
                                        date: "",
                                        time: "",
                                        isFirst: false,
                                        isLast: false,
                                        isMiddle: false,
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
                                        date: statusNum == 2
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 2
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
                                                    .toLocal())
                                            : "",
                                        isFirst: false,
                                        isLast: statusNum == 3
                                            ? false
                                            : true && statusNum == 6
                                                ? false
                                                : true,
                                        isMiddle: false,
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
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 3
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
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
                                        text: "Pengajuan dibatalkan",
                                        date: statusNum == 4
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 4
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
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
                                            "Pengajuan izin Pulang Cepat telah Ditolak",
                                        date: statusNum == 5
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 5
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
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
                                    if (statusNum == 6) ...[
                                      KTimeLineStep(
                                        text: "Pengajuan disetujui oleh HRD",
                                        date: statusNum == 6
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 6
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
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
                                  ],
                                  //TimeLine Izin Sementara
                                  if (widget.izin.keperluan ==
                                      "Izin Sementara") ...[
                                    if (statusNum >= 1) ...[
                                      KTimeLineStep(
                                        text: "Pengajuan izin Sementara dibuat",
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
                                        text:
                                            "Pengajuan izin Sementara telah dikirimkan ke manager",
                                        date: statusNum == 1
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 1
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
                                                    .toLocal())
                                            : "",
                                        isFirst: false,
                                        isLast: statusNum >= 2
                                            ? false
                                            : true && statusNum == 5
                                                ? false
                                                : true && statusNum == 4
                                                    ? false
                                                    : true && statusNum == 3
                                                        ? false
                                                        : true && statusNum == 6
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
                                            "Pengajuan izin Sementara telah disetujui manager",
                                        date: "",
                                        time: "",
                                        isFirst: false,
                                        isLast: false,
                                        isMiddle: false,
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
                                        date: statusNum == 2
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 2
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
                                                    .toLocal())
                                            : "",
                                        isFirst: false,
                                        isLast: statusNum == 3
                                            ? false
                                            : true && statusNum == 6
                                                ? false
                                                : true,
                                        isMiddle: false,
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
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 3
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
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
                                        text: "Pengajuan dibatalkan",
                                        date: DateFormat('MMM d\n').format(
                                            DateTime.parse(
                                                widget.izin.tglIzin!)),
                                        time: DateFormat('kk:mm').format(
                                            DateTime.parse(
                                                widget.izin.create!)),
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
                                            "Pengajuan izin Sementara telah Ditolak",
                                        date: DateFormat('MMM d\n').format(
                                            DateTime.parse(
                                                widget.izin.tglIzin!)),
                                        time: DateFormat('kk:mm').format(
                                            DateTime.parse(
                                                widget.izin.create!)),
                                        isFirst: false,
                                        isLast: true,
                                        isMiddle: false,
                                        color: const Color(0xFFA11110),
                                        warna: const Color(0xFFA11110),
                                        idx: 2,
                                      ),
                                    ],
                                    if (statusNum == 6) ...[
                                      KTimeLineStep(
                                        text: "Pengajuan disetujui oleh HRD",
                                        date: statusNum == 6
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.izin.updatedAt!))
                                            : "",
                                        time: statusNum == 6
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(
                                                        widget.izin.updatedAt!)
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
                                  ],
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
                    padding: EdgeInsets.all(16.w),
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
                                                : statusNum == 6
                                                    ? const Color(0xFF5BA53B)
                                                    : const Color(0xFF5BA53B),
                          ),
                        ),
                        Expanded(flex: 0, child: SizedBox(width: 18.w)),
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                      top: 6.r,
                                      bottom: 6.r,
                                      left: 8.r,
                                      right: 8.r,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.w),
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
                                                          : statusNum == 6
                                                              ? const Color(
                                                                  0xFF5BA53B)
                                                              : const Color(
                                                                  0xFF5BA53B),
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
                                                          : statusNum == 6
                                                              ? "Disetujui"
                                                              : "Disetujui",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              Text(
                                '${widget.izin.keperluan}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Nama Karyawan",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF585858),
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                widget.izin.namaKaryawan!,
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
                                        "Tanggal izin",
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF585858),
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        DateFormat('dd-MM-yyyy').format(
                                            DateTime.parse(
                                                widget.izin.tglIzin!)),
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.izin.keperluan ==
                                          "Datang Telat") ...[
                                        Text(
                                          "Jam datang terlambat",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF585858),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('kk:mm').format(
                                              DateTime.parse(
                                                  widget.izin.dtgTelat!)),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                      if (widget.izin.keperluan ==
                                          "Pulang Cepat") ...[
                                        Text(
                                          "Jam pulang cepat",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF585858),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('kk:mm').format(
                                              DateTime.parse(
                                                  widget.izin.pulangCpt!)),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                      if (widget.izin.keperluan ==
                                          "Izin Sementara") ...[
                                        Text(
                                          "Jam mulai",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF585858),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '${widget.izin.jamKeluar}',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                    ],
                                  ),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.izin.keperluan ==
                                          "Izin Sementara") ...[
                                        Text(
                                          "Jam akhir",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: const Color(0xFF585858),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '${widget.izin.jamMasuk}',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
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
      ],
    );
  }
}
