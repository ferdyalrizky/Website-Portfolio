import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/timeline/timeline_step.dart';
import 'package:intl/intl.dart';

import '../../../../../../models/lembur.dart';
import '../../../../../../utils/constant.dart';
import '../../../../../../utils/public_func.dart';

class ListItemSummaryLembur extends StatefulWidget {
  final Lembur lembur;
  const ListItemSummaryLembur({super.key, required this.lembur});

  @override
  State<ListItemSummaryLembur> createState() => _ListItemSummaryLemburState();
}

bool isOpen = false;

class _ListItemSummaryLemburState extends State<ListItemSummaryLembur> {
  @override
  Widget build(BuildContext context) {
    String status = '';
    int statusNum = 0;
    if (widget.lembur.status == 1 &&
        widget.lembur.disetujui == 0 &&
        widget.lembur.diverifikasi == 0) {
      status = 'Menunggu Approval Manager';
      statusNum = 1;
    } else if (widget.lembur.status == 1 &&
        widget.lembur.disetujui == 1 &&
        widget.lembur.diverifikasi == 0) {
      status = 'Approved';
      statusNum = 2;
    } else if (widget.lembur.status == 1 &&
        widget.lembur.disetujui == 1 &&
        widget.lembur.diverifikasi == 1) {
      status = 'Approved';
      statusNum = 3;
    } else if (widget.lembur.status == 3 &&
        widget.lembur.disetujui == 0 &&
        widget.lembur.diverifikasi == 0) {
      status = 'Dibatalkan';
      statusNum = 4;
    } else if (widget.lembur.status == 2 &&
        widget.lembur.disetujui == 0 &&
        widget.lembur.diverifikasi == 0) {
      status = 'Ditolak';
      statusNum = 5;
    }
    return Column(
      children: [
        if (statusNum >= 3) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                      top: 14, bottom: 14, left: 15, right: 15)
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
                      builder: (context) => makeDismissible(
                        child: DraggableScrollableSheet(
                          initialChildSize: 0.7,
                          minChildSize: 0.5,
                          maxChildSize: 1,
                          builder: (_, controller) => Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(0))),
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
                                          icon: const Icon(
                                            Icons.close,
                                            size: 30,
                                            color: Colors.black,
                                          ),
                                        ),
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
                                          widget.lembur.namaKaryawan!,
                                          style: TextStyle(
                                              fontSize: 13.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
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
                                            Text(
                                              "Tanggal Lembur",
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color:
                                                      const Color(0xFF585858),
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              DateFormat('dd-MM-yyyy').format(
                                                  DateTime.parse(widget
                                                      .lembur.tglLembur!)),
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
                                              "Jam mulai",
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color:
                                                      const Color(0xFF585858),
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              timeFormat(widget
                                                  .lembur.jamMulaiLembur!),
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
                                              "Jam akhir",
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color:
                                                      const Color(0xFF585858),
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              timeFormat(widget
                                                  .lembur.jamSelesaiLembur!),
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
                                      height: 20.h,
                                    ),
                                    Text(
                                      "Catatan kerja",
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF585858),
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      "${widget.lembur.keperluanLembur}",
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF585858),
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    widget.lembur.lampiranPath != null
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Bukti Lembur",
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color:
                                                        const Color(0xFF585858),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.file_copy_outlined,
                                                    color: Colors.black54,
                                                    size: 18,
                                                  ),
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                  Text(
                                                    "File unggahan bukti Lembur",
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: const Color(
                                                          0xFF585858),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      await Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  500));
                                                      showGeneralDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            true,
                                                        barrierLabel:
                                                            MaterialLocalizations
                                                                    .of(context)
                                                                .modalBarrierDismissLabel,
                                                        barrierColor:
                                                            Colors.black87,
                                                        transitionDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    20),
                                                        pageBuilder: (BuildContext
                                                                buildContext,
                                                            Animation animation,
                                                            Animation
                                                                secondaryAnimation) {
                                                          return Center(
                                                            child: SizedBox(
                                                              height: 350.h,
                                                              width: 380.w,
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl:
                                                                    '$API_URL_IMAGE/${widget.lembur.lampiranPath}',
                                                                imageBuilder:
                                                                    (context,
                                                                            imageProvider) =>
                                                                        Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    // shape: BoxShape.circle,
                                                                    image:
                                                                        DecorationImage(
                                                                      image:
                                                                          imageProvider,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    ),
                                                                  ),
                                                                ),
                                                                placeholder: (context,
                                                                        url) =>
                                                                    const SizedBox(
                                                                        child:
                                                                            CircularProgressIndicator()),
                                                                errorWidget:
                                                                    (context,
                                                                            url,
                                                                            error) =>
                                                                        Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Image.asset(
                                                                      "assets/images/tidakadahasil.png",
                                                                      width:
                                                                          130.w,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          15.h,
                                                                    ),
                                                                    Text(
                                                                      "Tidak ada Gambar",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontSize:
                                                                            22.sp,
                                                                      ),
                                                                    )
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
                                                        color: const Color(
                                                            0xFF142638),
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        fontSize: 14.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : SizedBox(
                                            height: 0.h,
                                          ),
                                    Text(
                                      "Riwayat pengajuan",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF585858),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    if (statusNum >= 1) ...[
                                      KTimeLineStep(
                                        text: "Pengajuan lembur dibuat",
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
                                            "Pengajuan lembur telah dikirimkan untuk menunggu disetujui",
                                        date: statusNum == 1
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.lembur.updatedAt!))
                                            : "",
                                        time: statusNum == 1
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(widget
                                                        .lembur.updatedAt!)
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
                                            "Pengajuan lembur telah disetujui oleh manager",
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
                                        text:
                                            "Pengajuan lembur telah disetujui manager",
                                        date: statusNum == 2
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.lembur.updatedAt!))
                                            : "",
                                        time: statusNum == 2
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(widget
                                                        .lembur.updatedAt!)
                                                    .toLocal())
                                            : "",
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
                                        text:
                                            "Pengajuan lembur telah disetujui",
                                        date: statusNum == 3
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.lembur.updatedAt!))
                                            : "",
                                        time: statusNum == 3
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(widget
                                                        .lembur.updatedAt!)
                                                    .toLocal())
                                            : "",
                                        isFirst: false,
                                        isLast: true,
                                        isMiddle: false,
                                        color: Colors.green,
                                        warna: Colors.green,
                                        idx: 2,
                                      ),
                                    ],
                                    if (statusNum == 4) ...[
                                      KTimeLineStep(
                                        text:
                                            "Pengajuan lembur telah Dibatalkan",
                                        date: statusNum == 4
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.lembur.updatedAt!))
                                            : "",
                                        time: statusNum == 4
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(widget
                                                        .lembur.updatedAt!)
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
                                        text: "Pengajuan lembur telah Ditolak",
                                        date: statusNum == 5
                                            ? DateFormat('MMM d\n').format(
                                                DateTime.parse(
                                                    widget.lembur.updatedAt!))
                                            : "",
                                        time: statusNum == 5
                                            ? DateFormat('kk:mm').format(
                                                DateTime.parse(widget
                                                        .lembur.updatedAt!)
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: const BoxDecoration(color: Colors.white),
                      padding: const EdgeInsets.only(
                              top: 20, bottom: 20, right: 6, left: 1)
                          .r,
                      child: Center(
                        child: Column(
                          children: [
                            Row(
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
                                                        ? const Color(
                                                            0xFFA11110)
                                                        : const Color(
                                                            0xFFA11110),
                                  ),
                                ),
                                Expanded(flex: 0, child: SizedBox(width: 18.w)),
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              fontSize: 13.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      Text(
                                        "Nama karyawan",
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            color: const Color(0xFF585858),
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        widget.lembur.namaKaryawan!,
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Tanggal lembur",
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color:
                                                        const Color(0xFF585858),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Text(
                                                DateFormat('dd-MM-yyyy').format(
                                                    DateTime.parse(widget
                                                        .lembur.tglLembur!)),
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
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
                                              Text(
                                                "Jam mulai",
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color:
                                                        const Color(0xFF585858),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Text(
                                                timeFormat(widget
                                                    .lembur.jamMulaiLembur!),
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
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
                                              Text(
                                                "Jam akhir",
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color:
                                                        const Color(0xFF585858),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Text(
                                                timeFormat(widget
                                                    .lembur.jamSelesaiLembur!),
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
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
                          ],
                        ),
                      ),
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

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(
          onTap: () {},
          child: child,
        ),
      );
}
