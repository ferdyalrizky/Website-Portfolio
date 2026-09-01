import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/timeline/timeline_step.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/edit_form_spk_lembur.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/list_spk_lembur.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/utils/public_func.dart';
import 'package:intl/intl.dart';

import '../../../../../../models/karyawan.dart';
import '../../../../../../models/lembur.dart';
import '../../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../../widgets/dialog.dart';

import 'package:http/http.dart' as http;

class ListItemLemburSpvList extends StatefulWidget {
  final Lembur lembur;
  final Karyawan currUser;

  final bool isSummary;

  const ListItemLemburSpvList({
    super.key,
    required this.lembur,
    required this.currUser,
    this.isSummary = false,
  });

  @override
  State<ListItemLemburSpvList> createState() => _ListItemLemburSpvListState();
}

bool isOpen = false;

class _ListItemLemburSpvListState extends State<ListItemLemburSpvList> {
  //Status Permintaan
  String status = '';
  int statusNum = 0;

  _onSetStatus() {
    setState(() {
      status = '';
      statusNum = 0;
      if (widget.lembur.status == 1 &&
          widget.lembur.disetujui == 0 &&
          widget.lembur.diverifikasi == 0) {
        status = 'Belum Dikirim';
        statusNum = 1;
      } else if (widget.lembur.status == 1 &&
          widget.lembur.disetujui == 1 &&
          widget.lembur.diverifikasi == 0) {
        status = 'Menunggu Approval Anda';
        statusNum = 2;
      } else if (widget.lembur.status == 1 &&
          widget.lembur.disetujui == 1 &&
          widget.lembur.diverifikasi == 1) {
        status = 'Menunggu Approval Anda';
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
    });
  }

  _onKirimBtnPress() async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, "Proses...");

    var header = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$API_URL/v2/kirimSpkl/${widget.lembur.idLembur}'))
        ..headers.addAll(header);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.body);

      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
      if (streamedResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Kirim SPKL Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Failed",
              msg: "Kirim SPKL Gagal",
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error $e');
    }
  }

  _onEditBtnPress() async {
    Route route = MaterialPageRoute(
        builder: (context) => EditFormSpkLembur(
            lembur: widget.lembur, currUser: widget.currUser));
    Navigator.push(context, route).then((value) {});
  }

  _onDibatalkanBtnPress() async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, "Proses...");

    var response = await http.get(
      Uri.parse("$API_URL/v2/getSpkl/cancel/${widget.lembur.idLembur}"),
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
            msg: "Hapus SPKL Berhasil",
            contentType: ContentType.success,
          ),
        ),
      );
      setState(() {
        widget.lembur.status = 3;
        widget.lembur.disetujui = 0;
        widget.lembur.diverifikasi = 0;
        statusNum = 4;
        _onSetStatus();
      });
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Failed",
            msg: "Hapus SPKL Gagal",
            contentType: ContentType.failure,
          ),
        ),
      );
    }
  }

  _onDitolakBtnPress() async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, "Proses...");

    var response = await http.get(
      Uri.parse("$API_URL/v2/deleteSpkl/${widget.lembur.idLembur}"),
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
            msg: "Ditolak SPKL Berhasil",
            contentType: ContentType.success,
          ),
        ),
      );
      Navigator.of(context).pop(true);
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => ListSpkLemburScreen(
                  currUser: widget.currUser,
                )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Failed",
            msg: "Ditolak SPKL Gagal",
            contentType: ContentType.failure,
          ),
        ),
      );
      Navigator.of(context).pop(true);
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => ListSpkLemburScreen(
                  currUser: widget.currUser,
                )),
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
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            DateFormat('dd-MM-yyyy').format(
                                                DateTime.parse(
                                                    widget.lembur.tglLembur!)),
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
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            timeFormat(
                                                widget.lembur.jamMulaiLembur!),
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
                                                color: const Color(0xFF585858),
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
                                                  fontWeight: FontWeight.w400),
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
                                                    color:
                                                        const Color(0xFF585858),
                                                    fontWeight: FontWeight.w600,
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
                                                          MaterialLocalizations
                                                                  .of(context)
                                                              .modalBarrierDismissLabel,
                                                      barrierColor:
                                                          Colors.black87,
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
                                                                  (context, url,
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
                                                      decoration: TextDecoration
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
                                      fontSize: 13.sp,
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
                                              DateTime.parse(
                                                      widget.lembur.updatedAt!)
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
                                      date: "",
                                      time: "",
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
                                      text: "Pengajuan lembur telah disetujui",
                                      date: statusNum == 3
                                          ? DateFormat('MMM d\n').format(
                                              DateTime.parse(
                                                  widget.lembur.updatedAt!))
                                          : "",
                                      time: statusNum == 3
                                          ? DateFormat('kk:mm').format(
                                              DateTime.parse(
                                                      widget.lembur.updatedAt!)
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
                                      text: "Pengajuan lembur telah Dibatalkan",
                                      date: statusNum == 4
                                          ? DateFormat('MMM d\n').format(
                                              DateTime.parse(
                                                  widget.lembur.updatedAt!))
                                          : "",
                                      time: statusNum == 4
                                          ? DateFormat('kk:mm').format(
                                              DateTime.parse(
                                                      widget.lembur.updatedAt!)
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
                                              DateTime.parse(
                                                      widget.lembur.updatedAt!)
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
                    //height: isOpen ? 200 : 100,
                    decoration: const BoxDecoration(color: Colors.white),
                    padding: const EdgeInsets.only(
                            top: 20, bottom: 20, right: 6, left: 1)
                        .r,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 0,
                              child: Container(
                                height: 33,
                                width: 5,
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
                                    padding: EdgeInsets.only(
                                      top: 6.r,
                                      bottom: 6.r,
                                      left: 8.r,
                                      right: 8.r,
                                    ),
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
                                    height: 20.h,
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
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            DateFormat('dd-MM-yyyy').format(
                                                DateTime.parse(
                                                    widget.lembur.tglLembur!)),
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
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Jam mulai",
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            timeFormat(
                                                widget.lembur.jamMulaiLembur!),
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          )
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
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            timeFormat(widget
                                                .lembur.jamSelesaiLembur!),
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          )
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
                                        builder: (context) => GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: DraggableScrollableSheet(
                                            initialChildSize: 0.2,
                                            minChildSize: 0.2,
                                            maxChildSize: 0.2,
                                            builder: (_, controller) =>
                                                Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              0))),
                                              padding: EdgeInsets.all(16.w),
                                              child: ListView(
                                                controller: controller,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        top: 3.r, bottom: 3.r),
                                                    margin: EdgeInsets.only(
                                                        left: 125.r,
                                                        right: 125.r),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFD9D9D9),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 20.h,
                                                  ),
                                                  if (widget.currUser.level ==
                                                          2 &&
                                                      statusNum == 1) ...[
                                                    ElevatedButton.icon(
                                                      label: Text(
                                                        'Edit',
                                                        style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                      onPressed:
                                                          _onEditBtnPress,
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        padding:
                                                            EdgeInsets.only(
                                                          top: 1.r,
                                                          bottom: 1.r,
                                                          left: 55.r,
                                                          right: 55.r,
                                                        ),
                                                        backgroundColor:
                                                            LightColors
                                                                .kFagettiBlue,
                                                      ),
                                                    ),
                                                  ],
                                                  ElevatedButton.icon(
                                                    label: Text(
                                                      'Dibatalkan',
                                                      style: TextStyle(
                                                          fontSize: 13.sp,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    onPressed:
                                                        _onDibatalkanBtnPress,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
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
                                                      backgroundColor:
                                                          Colors.white,
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

  Widget makeDismissible({required Widget child}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(
          onTap: () {},
          child: child,
        ),
      );
}
