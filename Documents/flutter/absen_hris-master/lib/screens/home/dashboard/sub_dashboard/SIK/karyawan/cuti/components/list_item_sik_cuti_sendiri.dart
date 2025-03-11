// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/sik.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/cuti/components/edit_cuti.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/cuti/list_sik_cuti_karyawan_screen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/timeline/timeline_step.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:intl/intl.dart';

import '../../../../../../../../models/karyawan.dart';

import 'package:http/http.dart' as http;

import '../../../../../../../../utils/constant.dart';
import '../../../../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../../../../widgets/dialog.dart';

bool isOpen = false;

class ListItemSikCutiSendiri extends StatefulWidget {
  final Sik sik;
  final Karyawan currUser;
  final Function onCallback;
  const ListItemSikCutiSendiri(
      {super.key,
      required this.sik,
      required this.currUser,
      required this.onCallback});

  @override
  State<ListItemSikCutiSendiri> createState() => _ListItemSikCutiSendiriState();
}

class _ListItemSikCutiSendiriState extends State<ListItemSikCutiSendiri> {
  int jatahCuti = 0;
  @override
  Widget build(BuildContext context) {
    //Status Permintaan
    String status = '';
    int statusNum = 0;
    if (widget.sik.status == 1 &&
        widget.sik.disetujui == 0 &&
        widget.sik.diverifikasi == 0) {
      status = 'Menunggu Approval Manager';
      statusNum = 1;
    } else if (widget.sik.status == 1 &&
        widget.sik.disetujui == 1 &&
        widget.sik.diverifikasi == 0) {
      status = 'Approved';
      statusNum = 2;
    } else if (widget.sik.status == 1 &&
        widget.sik.disetujui == 1 &&
        widget.sik.diverifikasi == 1) {
      status = 'Approved';
      statusNum = 3;
    } else if (widget.sik.status == 3 &&
        widget.sik.disetujui == 0 &&
        widget.sik.diverifikasi == 0) {
      status = 'Dibatalkan';
      statusNum = 4;
    } else if (widget.sik.status == 2 &&
        widget.sik.disetujui == 0 &&
        widget.sik.diverifikasi == 0) {
      status = 'Ditolak';
      statusNum = 5;
    } else if (widget.sik.status == 1 &&
        widget.sik.disetujui == 0 &&
        widget.sik.diverifikasi == 1) {
      status = 'Disetujui';
      statusNum = 6;
    }

    onEditBtnPress() async {
      Route route = MaterialPageRoute(
          builder: (context) => EditCuti(
                currUser: widget.currUser,
                sik: widget.sik,
                jatahCutiUser: jatahCuti,
              ));
      Navigator.push(context, route).then((value) {
        widget.onCallback();
      });
    }

    onBatalkanBtnPress() async {
      final GlobalKey<State> keyLoader = GlobalKey<State>();
      Dialogs.loading(context, keyLoader, "Proses...");

      var response = await http.get(
        Uri.parse('$API_URL/v3/Sitc/cancelSitc/${widget.sik.idSitc}'),
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
              msg: "Batalkan Cuti Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
        Navigator.of(context).pop(true);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => ListSikCutiKaryawanScreen(
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
              msg: "Batalkan Cuti Gagal",
              contentType: ContentType.failure,
            ),
          ),
        );
        Navigator.of(context).pop(true);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => ListSikCutiKaryawanScreen(
                    currUser: widget.currUser,
                  )),
        );
        print("Error: ${response.statusCode} - ${response.reasonPhrase}");
        print("Response body: ${response.body}");
      }
    }

    onKirimBtnPress() async {
      final GlobalKey<State> keyLoader = GlobalKey<State>();
      Dialogs.loading(context, keyLoader, "Proses...");

      var header = {
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      };
      Map<String, String> body = {
        'disetujui': widget.currUser.level == 1 ? '1' : '0',
      };

      try {
        var request = http.MultipartRequest(
            'POST', Uri.parse('$API_URL/v3/kirimSitc/${widget.sik.idSitc}'))
          ..fields.addAll(body)
          ..headers.addAll(header);
        var response = await request.send();

        Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            // const SnackBar(
            //   content: Text(
            //     "Kirim SIK Cuti Berhasil!",
            //     style: TextStyle(fontSize: 16),
            //   ),
            // ),
            SnackBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              content: CustomSnackbarContent(
                title: "Success",
                msg: "Kirim SIK Cuti Berhasil",
                contentType: ContentType.success,
              ),
            ),
          );

          widget.onCallback();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            // const SnackBar(
            //   content: Text(
            //     "Kirim SIK Cuti Gagal",
            //     style: TextStyle(fontSize: 16),
            //   ),
            // ),
            SnackBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              content: CustomSnackbarContent(
                title: "Failed",
                msg: "Kirim SIK Cuti Gagal",
                contentType: ContentType.failure,
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error $e');
      }
    }

    onHapusBtnPress() async {
      final GlobalKey<State> keyLoader = GlobalKey<State>();
      Dialogs.loading(context, keyLoader, "Proses...");

      var response = await http.get(
        Uri.parse('$API_URL/v3/deleteSitc/${widget.sik.idSitc}'),
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
              msg: "Hapus SIK Cuti Berhasil",
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
              msg: "Hapus SIK Cuti Gagal",
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
                                                        : statusNum == 6
                                                            ? const Color(
                                                                0xFF5BA53B)
                                                            : const Color(
                                                                0xFF5BA53B),
                                  ),
                                  child: Text(
                                    widget.currUser.level == 1
                                        ? (statusNum == 1
                                            ? "Menunggu Persetujuan Owner"
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
                                                                : "Disetujui")
                                        : (statusNum == 1
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
                                                                : "Disetujui"),
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
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tanggal Mulai",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF585858),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(
                                          DateTime.parse(
                                              widget.sik.tanggalMulai!)),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tanggal Selesai",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF585858),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(
                                          DateTime.parse(
                                              widget.sik.tanggalSelesai!)),
                                      style: TextStyle(
                                        fontSize: 14.sp,
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
                                fontSize: 14.sp,
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
                                  fontSize: 14.sp,
                                  color: const Color(0xFF585858),
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 40.h,
                            ),
                            Text(
                              "Riwayat pengajuan",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF585858),
                                  fontWeight: FontWeight.w400),
                            ),
                            if (widget.currUser.level! > 1) ...[
                              if (statusNum >= 1) ...[
                                KTimeLineStep(
                                  text: "Pengajuan cuti dibuat",
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
                                          DateTime.parse(widget.sik.updatedAt!))
                                      : "",
                                  time: statusNum == 1
                                      ? DateFormat('kk:mm').format(
                                          DateTime.parse(widget.sik.updatedAt!)
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
                                      "Pengajuan cuti telah disetujui oleh manager",
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
                                          DateTime.parse(widget.sik.updatedAt!))
                                      : "",
                                  time: statusNum == 2
                                      ? DateFormat('kk:mm').format(
                                          DateTime.parse(widget.sik.updatedAt!)
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
                                          DateTime.parse(widget.sik.updatedAt!))
                                      : "",
                                  time: statusNum == 3
                                      ? DateFormat('kk:mm').format(
                                          DateTime.parse(widget.sik.updatedAt!)
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
                                  text: "Pengajuan cuti telah DiBatalkan",
                                  date: statusNum == 4
                                      ? DateFormat('MMM d\n').format(
                                          DateTime.parse(widget.sik.updatedAt!))
                                      : "",
                                  time: statusNum == 4
                                      ? DateFormat('kk:mm').format(
                                          DateTime.parse(widget.sik.updatedAt!)
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
                                  text: "Pengajuan cuti telah Ditolak",
                                  date: statusNum == 5
                                      ? DateFormat('MMM d\n').format(
                                          DateTime.parse(widget.sik.updatedAt!))
                                      : "",
                                  time: statusNum == 5
                                      ? DateFormat('kk:mm').format(
                                          DateTime.parse(widget.sik.updatedAt!)
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
                                          DateTime.parse(widget.sik.updatedAt!))
                                      : "",
                                  time: statusNum == 6
                                      ? DateFormat('kk:mm').format(
                                          DateTime.parse(widget.sik.updatedAt!)
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
                            if (widget.currUser.level! == 1) ...[
                              if (statusNum >= 1) ...[
                                KTimeLineStep(
                                  text: "Pengajuan cuti dibuat",
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
                                  text: "Data dikirimkan ke ownner",
                                  date: statusNum == 1
                                      ? DateFormat('MMM d\n').format(
                                          DateTime.parse(widget.sik.updatedAt!))
                                      : "",
                                  time: statusNum == 1
                                      ? DateFormat('kk:mm').format(
                                          DateTime.parse(widget.sik.updatedAt!)
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
                                      "Pengajuan cuti telah disetujui oleh owner",
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
                                          DateTime.parse(widget.sik.updatedAt!))
                                      : "",
                                  time: statusNum == 2
                                      ? DateFormat('kk:mm').format(
                                          DateTime.parse(widget.sik.updatedAt!)
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
                                  text: "Pengajuan disetujui oleh HRD",
                                  date: statusNum == 3
                                      ? DateFormat('MMM d\n').format(
                                          DateTime.parse(widget.sik.updatedAt!))
                                      : "",
                                  time: statusNum == 3
                                      ? DateFormat('kk:mm').format(
                                          DateTime.parse(widget.sik.updatedAt!)
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
                                  text: "Pengajuan cuti telah DiBatalkan",
                                  date: statusNum == 4
                                      ? DateFormat('MMM d\n').format(
                                          DateTime.parse(widget.sik.updatedAt!))
                                      : "",
                                  time: statusNum == 4
                                      ? DateFormat('kk:mm').format(
                                          DateTime.parse(widget.sik.updatedAt!)
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
                                  text: "Pengajuan cuti telah Ditolak",
                                  date: statusNum == 5
                                      ? DateFormat('MMM d\n').format(
                                          DateTime.parse(widget.sik.updatedAt!))
                                      : "",
                                  time: statusNum == 5
                                      ? DateFormat('kk:mm').format(
                                          DateTime.parse(widget.sik.updatedAt!)
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
                          ],
                        ),
                        const SizedBox(
                          height: 25,
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
                                                : statusNum == 6
                                                    ? const Color(0xFF5BA53B)
                                                    : const Color(0xFF5BA53B),
                          ),
                          child: Text(
                            widget.currUser.level == 1
                                ? (statusNum == 1
                                    ? "Menunggu Persetujuan Owner"
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
                                                        : "Disetujui")
                                : (statusNum == 1
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
                                                        : "Disetujui"),
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
                          widget.sik.namaCutiNormatif!,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
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
                                  "Tanggal mulai",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF585858),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.parse(widget.sik.tanggalMulai!)),
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                )
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
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.parse(
                                          widget.sik.tanggalSelesai!)),
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.currUser.level! > 1 && statusNum == 1) ...[
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
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(0.r))),
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
                                                BorderRadius.circular(15.r),
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
                  if (widget.currUser.level! == 1 && statusNum == 2) ...[
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
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(0.r))),
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
                                                BorderRadius.circular(15.r),
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
