import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/biaya.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/timeline/timeline_step.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/klaim_biaya/edit_form_biaya.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/klaim_biaya/list_biaya.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:intl/intl.dart';

import '../../../../../../utils/constant.dart';
import '../../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../../widgets/dialog.dart';

import 'package:http/http.dart' as http;

bool isOpen = false;

class ListItemKlaimBiayaSaya extends StatefulWidget {
  final Biaya biaya;
  final Karyawan currUser;
  final Function onCallback;
  const ListItemKlaimBiayaSaya(
      {super.key,
      required this.biaya,
      required this.currUser,
      required this.onCallback});

  @override
  State<ListItemKlaimBiayaSaya> createState() => _ListItemKlaimBiayaSayaState();
}

class _ListItemKlaimBiayaSayaState extends State<ListItemKlaimBiayaSaya> {
  bool imageLoaded = false;
  @override
  Widget build(BuildContext context) {
    List<KTimeLineStep> steps = [];
    String status = "";
    int statusNum = 0;

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

    onEditBtnPress() async {
      Route route = MaterialPageRoute(
          builder: (context) => EditFormKlaimBiaya(
              biaya: widget.biaya, currUser: widget.currUser));
      Navigator.push(context, route).then((value) {
        widget.onCallback();
      });
    }

    onBatalkanBtnPress() async {
      final GlobalKey<State> keyLoader = GlobalKey<State>();
      Dialogs.loading(context, keyLoader, "Proses...");

      var response = await http.get(
        Uri.parse('$API_URL/v2/klaimBiaya/cancel/${widget.biaya.idBiaya}'),
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
              msg: "Batalkan Izin Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
        Navigator.of(context).pop(true);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => ListKlaimBiayaScreen(
                    currUser: widget.currUser,
                  )),
        );

        widget.onCallback();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Failed",
              msg: "Batalkan Izin Gagal",
              contentType: ContentType.failure,
            ),
          ),
        );
        Navigator.of(context).pop(true);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => ListKlaimBiayaScreen(
                    currUser: widget.currUser,
                  )),
        );
        print("Error: ${response.statusCode} - ${response.reasonPhrase}");
        print("Response body: ${response.body}");
      }
    }

    onHapusBtnPress() async {
      final GlobalKey<State> keyLoader = GlobalKey<State>();
      Dialogs.loading(context, keyLoader, "Proses...");

      var response = await http.get(
        Uri.parse('$API_URL./klaimBiaya/destroy/${widget.biaya.idBiaya}'),
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
              msg: "Hapus Biaya Berhasil",
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
              msg: "Hapus Biaya Gagal",
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    }

    return Padding(
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
                        SizedBox(width: 18.w),
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
                                                ? "Menunggu Disetujui Finance"
                                                : "Disetujui",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
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
                            if (widget.biaya.jnsKlaimBiaya == "Acara") ...[
                              Text(
                                "Nama acara",
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF585858),
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
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tanggal kwitansi",
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF585858),
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      DateFormat('dd-MM-yyyy').format(
                                          DateTime.parse(
                                              widget.biaya.tglKwintansi!)),
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 30.w,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Jumlah uang",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: const Color(0xFF585858),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      "Rp.${NumberFormat.decimalPattern('id').format(double.parse(widget.biaya.jmlUang!))}",
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
                              height: 20.h,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Deskripsi",
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF585858),
                                      fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                Text(
                                  "${widget.biaya.deskripsiUang}",
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF585858),
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 35.h,
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
                                          pageBuilder: (BuildContext
                                                  buildContext,
                                              Animation animation,
                                              Animation secondaryAnimation) {
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
                                                    decoration: BoxDecoration(
                                                      // shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.contain,
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
                                          decoration: TextDecoration.underline,
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
                                          pageBuilder: (BuildContext
                                                  buildContext,
                                              Animation animation,
                                              Animation secondaryAnimation) {
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
                                                    decoration: BoxDecoration(
                                                      // shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.contain,
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
                                          decoration: TextDecoration.underline,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                Text(
                                  "Riwayat Pengajuan",
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF585858),
                                      fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                //Timeline Datang Telat
                                if (widget.biaya.jnsKlaimBiaya == "Acara") ...[
                                  if (statusNum >= 1) ...[
                                    KTimeLineStep(
                                      text: "Pengajuan klaim biaya dibuat",
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
                                              DateTime.parse(
                                                  widget.biaya.updatedAt!))
                                          : "",
                                      time: statusNum == 1
                                          ? DateFormat('kk:mm').format(
                                              DateTime.parse(
                                                      widget.biaya.updatedAt!)
                                                  .toLocal())
                                          : "",
                                      isFirst: false,
                                      isLast: statusNum == 2
                                          ? false
                                          : true && statusNum == 5
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
                                  if (statusNum == 2) ...[
                                    KTimeLineStep(
                                      text: "Pengajuan disetujui oleh Finance",
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
                                      text: "Dana sedang diproses oleh Finance",
                                      date: statusNum == 2
                                          ? DateFormat('MMM d\n').format(
                                              DateTime.parse(
                                                  widget.biaya.updatedAt!))
                                          : "",
                                      time: statusNum == 2
                                          ? DateFormat('kk:mm').format(
                                              DateTime.parse(
                                                      widget.biaya.updatedAt!)
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
                                      text: "Pengajuan dibatalkan",
                                      date: statusNum == 3
                                          ? DateFormat('MMM d\n').format(
                                              DateTime.parse(
                                                  widget.biaya.updatedAt!))
                                          : "",
                                      time: statusNum == 3
                                          ? DateFormat('kk:mm').format(
                                              DateTime.parse(
                                                      widget.biaya.updatedAt!)
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
                                          "Pengajuan biaya Datang Telat telah Ditolak",
                                      date: statusNum == 5
                                          ? DateFormat('MMM d\n').format(
                                              DateTime.parse(
                                                  widget.biaya.updatedAt!))
                                          : "",
                                      time: statusNum == 5
                                          ? DateFormat('kk:mm').format(
                                              DateTime.parse(
                                                      widget.biaya.updatedAt!)
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
                                      text: "Pengajuan klaim biaya dibuat",
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
                                              DateTime.parse(
                                                  widget.biaya.updatedAt!))
                                          : "",
                                      time: statusNum == 1
                                          ? DateFormat('kk:mm').format(
                                              DateTime.parse(
                                                      widget.biaya.updatedAt!)
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
                                      text: "Pengajuan disetujui oleh Finance",
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
                                      text: "Dana sedang diproses oleh Finance",
                                      date: statusNum == 2
                                          ? DateFormat('MMM d\n').format(
                                              DateTime.parse(
                                                  widget.biaya.updatedAt!))
                                          : "",
                                      time: statusNum == 2
                                          ? DateFormat('kk:mm').format(
                                              DateTime.parse(
                                                      widget.biaya.updatedAt!)
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
                                      text: "Pengajuan dibatalkan",
                                      date: statusNum == 3
                                          ? DateFormat('MMM d\n').format(
                                              DateTime.parse(
                                                  widget.biaya.updatedAt!))
                                          : "",
                                      time: statusNum == 3
                                          ? DateFormat('kk:mm').format(
                                              DateTime.parse(
                                                      widget.biaya.updatedAt!)
                                                  .toLocal())
                                          : "",
                                      isFirst: false,
                                      isLast: true,
                                      isMiddle: false,
                                      color: Colors.black,
                                      warna: const Color(0xFF585858),
                                      idx: 2,
                                    ),
                                  ],
                                  if (statusNum == 5) ...[
                                    KTimeLineStep(
                                      text:
                                          "Pengajuan biaya Datang Telat telah Ditolak",
                                      date: statusNum == 5
                                          ? DateFormat('MMM d\n').format(
                                              DateTime.parse(
                                                  widget.biaya.updatedAt!))
                                          : "",
                                      time: statusNum == 5
                                          ? DateFormat('kk:mm').format(
                                              DateTime.parse(
                                                      widget.biaya.updatedAt!)
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
                                  height: 10.h,
                                ),
                                if (statusNum == 5) ...[
                                  Text(
                                    "Alasan penolakan",
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: const Color(0xFF585858),
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  Text(
                                    widget.biaya.keterangan!,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
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
                      color: statusNum == 5
                          ? Colors.red
                          : statusNum == 3
                              ? Colors.grey
                              : statusNum == 1
                                  ? const Color(0xFFE69E00)
                                  : Colors.green,
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
                                        ? "Menunggu Disetujui Finance"
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
                              fontWeight: FontWeight.w500, fontSize: 16.sp),
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
                                  "Tanggal kwitansi",
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF585858),
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.parse(
                                          widget.biaya.tglKwintansi!)),
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
                                  "Jumlah Uang",
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: const Color(0xFF585858),
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "Rp.${NumberFormat.decimalPattern('id').format(double.parse(widget.biaya.jmlUang!))}",
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
                      ],
                    ),
                  ),
                  if (statusNum == 1) ...[
                    Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              context: context,
                              builder: (context) => makeDismissible(
                                child: DraggableScrollableSheet(
                                  initialChildSize: 0.2,
                                  minChildSize: 0.2,
                                  maxChildSize: 0.2,
                                  builder: (_, controller) => Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(0))),
                                    padding: const EdgeInsets.all(16).w,
                                    child: ListView(
                                      controller: controller,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(
                                                  top: 3, bottom: 3)
                                              .r,
                                          margin: const EdgeInsets.only(
                                                  left: 125, right: 125)
                                              .r,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD9D9D9),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        ElevatedButton.icon(
                                          label: Text(
                                            'Edit',
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          onPressed: onEditBtnPress,
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.only(
                                              top: 1,
                                              bottom: 1,
                                              left: 55,
                                              right: 55,
                                            ).r,
                                            backgroundColor:
                                                LightColors.kFagettiBlue,
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          label: Text(
                                            'Dibatalkan',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          onPressed: () {
                                            onBatalkanBtnPress();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              side: const BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                            padding: const EdgeInsets.only(
                                              top: 1,
                                              bottom: 1,
                                              left: 55,
                                              right: 55,
                                            ).r,
                                            backgroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )),
                  ],
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
