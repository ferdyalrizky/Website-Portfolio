import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/biaya.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/timeline/timeline_step.dart';
import 'package:intl/intl.dart';

import '../../../../../../../../utils/constant.dart';
import '../../../../../../models/karyawan.dart';

bool isOpen = false;

class ListItemKlaimBiayaRiwayat extends StatefulWidget {
  final Biaya biaya;
  final Karyawan currUser;
  const ListItemKlaimBiayaRiwayat({
    super.key,
    required this.biaya,
    required this.currUser,
  });

  @override
  State<ListItemKlaimBiayaRiwayat> createState() =>
      _ListItemKlaimBiayaRiwayatState();
}

class _ListItemKlaimBiayaRiwayatState extends State<ListItemKlaimBiayaRiwayat> {
  List<Biaya> listBiayaSendiri = [];
  //Status Permintaan
  String status = '';
  int statusNum = 0;

  _onSetStatus() {
    status = '';
    statusNum = 0;

    if (widget.biaya.status == 1 &&
        widget.biaya.disetujui == 0 &&
        widget.biaya.diverifikasi == 0) {
      status = 'Menunggu Approval';
      statusNum = 1;
    } else if (widget.biaya.status == 1 &&
        widget.biaya.disetujui == 1 &&
        widget.biaya.diverifikasi == 1) {
      status = 'Approved';
      statusNum = 2;
    } else if (widget.biaya.status == 3 &&
        widget.biaya.disetujui == 0 &&
        widget.biaya.diverifikasi == 0) {
      status = 'Dibatalkan';
      statusNum = 3;
    } else if (widget.biaya.status == 2 &&
        widget.biaya.disetujui == 0 &&
        widget.biaya.diverifikasi == 0) {
      status = 'Ditolak';
      statusNum = 5;
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
        if (statusNum >= 2 && statusNum <= 5) ...[
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                        top: 14, bottom: 14, left: 17, right: 17)
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
                            initialChildSize: 0.8,
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
                                  SizedBox(width: 18.w),
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
                                              color: statusNum == 5
                                                  ? Colors.red
                                                  : statusNum == 3
                                                      ? Colors.grey
                                                      : statusNum == 1
                                                          ? const Color(
                                                              0xFFE69E00)
                                                          : Colors.green,
                                            ),
                                            child: Text(
                                              statusNum == 5
                                                  ? "Ditolak"
                                                  : statusNum == 3
                                                      ? "Dibatalkan"
                                                      : statusNum == 1
                                                          ? "Menunggu Disetujui"
                                                          : "Disetujui",
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
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Nama Karyawan",
                                            style: TextStyle(
                                                color: Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Text(
                                            widget.biaya.namaKaryawan!,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                          if (widget.biaya.jnsKlaimBiaya ==
                                              "Acara") ...[
                                            Text(
                                              "Nama acara",
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color:
                                                      const Color(0xFF585858),
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              widget.biaya.namaAcara!,
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
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
                                                "Tanggal biaya",
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
                                                        .biaya.tglKwintansi!)),
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
                                              if (widget.biaya.jnsKlaimBiaya ==
                                                  "Acara") ...[
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
                                              if (widget.biaya.jnsKlaimBiaya ==
                                                  "Transportasi") ...[
                                                Text(
                                                  "Jam mulai",
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color:
                                                        const Color(0xFF585858),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  'aaaa',
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                )
                                              ],
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (widget.biaya.jnsKlaimBiaya ==
                                                  "Transportasi") ...[
                                                Text(
                                                  "Jam akhir",
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color:
                                                        const Color(0xFF585858),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  'sdasdaads',
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Catatan biaya",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF585858),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text('${widget.biaya.deskripsiUang}'),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      Text(
                                        "File unggahan bukti biaya",
                                        style: TextStyle(
                                          fontSize: 12.sp,
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
                                            "File unggahan bukti persetujuan",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: const Color(0xFF585858),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500));
                                              showGeneralDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                barrierLabel:
                                                    MaterialLocalizations.of(
                                                            context)
                                                        .modalBarrierDismissLabel,
                                                barrierColor: Colors.black87,
                                                transitionDuration:
                                                    const Duration(
                                                        milliseconds: 20),
                                                pageBuilder: (BuildContext
                                                        buildContext,
                                                    Animation animation,
                                                    Animation
                                                        secondaryAnimation) {
                                                  return Center(
                                                    child: SizedBox(
                                                      height: 280.h,
                                                      width: double.infinity,
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            '$API_URL_IMAGE/${widget.biaya.lampiranAcc}',
                                                        imageBuilder: (context,
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
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Text(
                                              'Lihat',
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
                                            "File unggahan bukti kwitansi",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: const Color(0xFF585858),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500));
                                              showGeneralDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                barrierLabel:
                                                    MaterialLocalizations.of(
                                                            context)
                                                        .modalBarrierDismissLabel,
                                                barrierColor: Colors.black87,
                                                transitionDuration:
                                                    const Duration(
                                                        milliseconds: 20),
                                                pageBuilder: (BuildContext
                                                        buildContext,
                                                    Animation animation,
                                                    Animation
                                                        secondaryAnimation) {
                                                  return Center(
                                                    child: SizedBox(
                                                      height: 280.h,
                                                      width: double.infinity,
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            '$API_URL_IMAGE/${widget.biaya.lampiranKwitansi}',
                                                        imageBuilder: (context,
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
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Text(
                                              'Lihat',
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
                                      //Timeline Datang Telat
                                      if (widget.biaya.jnsKlaimBiaya ==
                                          "Acara") ...[
                                        if (statusNum >= 1) ...[
                                          KTimeLineStep(
                                            text: "Pengajuan acara dibuat",
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
                                            text: "Data dikirimkan ke Finance",
                                            date: statusNum == 1
                                                ? DateFormat('MMM d\n').format(
                                                    DateTime.parse(widget
                                                        .biaya.updatedAt!))
                                                : "",
                                            time: statusNum == 1
                                                ? DateFormat('kk:mm').format(
                                                    DateTime.parse(widget
                                                            .biaya.updatedAt!)
                                                        .toLocal())
                                                : "",
                                            isFirst: false,
                                            isLast: statusNum == 2
                                                ? false
                                                : true && statusNum == 3
                                                    ? false
                                                    : true && statusNum == 5
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
                                        if (statusNum == 2) ...[
                                          KTimeLineStep(
                                            text:
                                                "Pengajuan acara disetujui oleh Finance",
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
                                        if (statusNum == 2) ...[
                                          KTimeLineStep(
                                            text:
                                                "Dana sedang diproses oleh Finance",
                                            date: statusNum == 2
                                                ? DateFormat('MMM d\n').format(
                                                    DateTime.parse(widget
                                                        .biaya.updatedAt!))
                                                : "",
                                            time: statusNum == 2
                                                ? DateFormat('kk:mm').format(
                                                    DateTime.parse(widget
                                                            .biaya.updatedAt!)
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
                                        if (statusNum == 3) ...[
                                          KTimeLineStep(
                                            text:
                                                "Pengajuan acara telah Ditolak",
                                            date: statusNum == 3
                                                ? DateFormat('MMM d\n').format(
                                                    DateTime.parse(widget
                                                        .biaya.updatedAt!))
                                                : "",
                                            time: statusNum == 3
                                                ? DateFormat('kk:mm').format(
                                                    DateTime.parse(widget
                                                            .biaya.updatedAt!)
                                                        .toLocal())
                                                : "",
                                            isFirst: false,
                                            isLast: true,
                                            isMiddle: false,
                                            color: Color(0xFF585858),
                                            warna: Color(0xFF585858),
                                            idx: 2,
                                          ),
                                        ],
                                        if (statusNum == 5) ...[
                                          KTimeLineStep(
                                            text:
                                                "Pengajuan acara telah Ditolak",
                                            date: statusNum == 5
                                                ? DateFormat('MMM d\n').format(
                                                    DateTime.parse(widget
                                                        .biaya.updatedAt!))
                                                : "",
                                            time: statusNum == 5
                                                ? DateFormat('kk:mm').format(
                                                    DateTime.parse(widget
                                                            .biaya.updatedAt!)
                                                        .toLocal())
                                                : "",
                                            isFirst: false,
                                            isLast: true,
                                            isMiddle: false,
                                            color: Colors.red,
                                            warna: Colors.red,
                                            idx: 2,
                                          ),
                                        ],
                                      ],

                                      //TimeLine Transportasi
                                      if (widget.biaya.jnsKlaimBiaya ==
                                          "Transportasi") ...[
                                        if (statusNum >= 1) ...[
                                          KTimeLineStep(
                                            text:
                                                "Pengajuan Transportasi dibuat",
                                            date: "",
                                            time: '',
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
                                            text: "Data dikirimkan ke Finance",
                                            date: statusNum == 1
                                                ? DateFormat('MMM d\n').format(
                                                    DateTime.parse(widget
                                                        .biaya.updatedAt!))
                                                : "",
                                            time: statusNum == 1
                                                ? DateFormat('kk:mm').format(
                                                    DateTime.parse(widget
                                                            .biaya.updatedAt!)
                                                        .toLocal())
                                                : "",
                                            isFirst: false,
                                            isLast: statusNum == 2
                                                ? false
                                                : true && statusNum == 3
                                                    ? false
                                                    : true && statusNum == 5
                                                        ? false
                                                        : true,
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
                                        if (statusNum == 2) ...[
                                          KTimeLineStep(
                                            text:
                                                "Pengajuan Transportasi disetujui oleh Finance",
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
                                        if (statusNum == 2) ...[
                                          KTimeLineStep(
                                            text:
                                                "Dana sedang diproses oleh Finance",
                                            date: statusNum == 2
                                                ? DateFormat('MMM d\n').format(
                                                    DateTime.parse(widget
                                                        .biaya.updatedAt!))
                                                : "",
                                            time: statusNum == 2
                                                ? DateFormat('kk:mm').format(
                                                    DateTime.parse(widget
                                                            .biaya.updatedAt!)
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
                                        if (statusNum == 3) ...[
                                          KTimeLineStep(
                                            text:
                                                "Pengajuan Transportasi telah dibatalkan",
                                            date: statusNum == 3
                                                ? DateFormat('MMM d\n').format(
                                                    DateTime.parse(widget
                                                        .biaya.updatedAt!))
                                                : "",
                                            time: statusNum == 3
                                                ? DateFormat('kk:mm').format(
                                                    DateTime.parse(widget
                                                            .biaya.updatedAt!)
                                                        .toLocal())
                                                : "",
                                            isFirst: false,
                                            isLast: true,
                                            isMiddle: true,
                                            color: Colors.black,
                                            warna: Colors.grey,
                                            idx: 2,
                                          ),
                                        ],
                                        if (statusNum == 5) ...[
                                          KTimeLineStep(
                                            text:
                                                "Pengajuan Transportasi telah Ditolak",
                                            date: statusNum == 5
                                                ? DateFormat('MMM d\n').format(
                                                    DateTime.parse(widget
                                                        .biaya.updatedAt!))
                                                : "",
                                            time: statusNum == 5
                                                ? DateFormat('kk:mm').format(
                                                    DateTime.parse(widget
                                                            .biaya.updatedAt!)
                                                        .toLocal())
                                                : "",
                                            isFirst: false,
                                            isLast: true,
                                            isMiddle: false,
                                            color: Colors.red,
                                            warna: Colors.red,
                                            idx: 2,
                                          ),
                                        ],
                                      ],
                                      SizedBox(
                                        height: 20.h,
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
                                color: statusNum == 5
                                    ? Colors.red
                                    : statusNum == 3
                                        ? Colors.grey
                                        : statusNum == 1
                                            ? const Color(0xFFE69E00)
                                            : Colors.green,
                              ),
                            ),
                            const Expanded(flex: 0, child: SizedBox(width: 18)),
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
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: statusNum == 5
                                          ? Colors.red
                                          : statusNum == 3
                                              ? Colors.grey
                                              : statusNum == 1
                                                  ? const Color(0xFFE69E00)
                                                  : Colors.green,
                                    ),
                                    child: Text(
                                      statusNum == 5
                                          ? "Ditolak"
                                          : statusNum == 3
                                              ? "Dibatalkan"
                                              : statusNum == 1
                                                  ? "Menunggu Disetujui"
                                                  : "Disetujui",
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
                                    '${widget.biaya.jnsKlaimBiaya}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp),
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
                                    widget.biaya.namaKaryawan!,
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
                                            "Tanggal biaya",
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            DateFormat('dd-MM-yyyy').format(
                                                DateTime.parse(widget
                                                    .biaya.tglKwintansi!)),
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
                                            "Jumlah uang",
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            "Rp ${widget.biaya.jmlUang}",
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                    ],
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
