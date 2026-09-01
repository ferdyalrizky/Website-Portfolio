import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/konseling_request.dart';
import 'package:hris_v2/models/pertanyaan_konseling.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/timeline/timeline_step.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/konseling/konseling.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/konseling/list/list_pertanyaan.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/custom_snackbar_content.dart';
import 'package:hris_v2/widgets/dialog.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../../../../models/karyawan.dart';

bool isOpen = false;

class ListItemKonselingRiwayat extends StatefulWidget {
  final Counseling konseling;
  final Karyawan currUser;
  const ListItemKonselingRiwayat({
    super.key,
    required this.konseling,
    required this.currUser,
  });

  @override
  State<ListItemKonselingRiwayat> createState() =>
      _ListItemKonselingRiwayatState();
}

class _ListItemKonselingRiwayatState extends State<ListItemKonselingRiwayat> {
  late List<Pertanyaan> pertanyaanList = []; // Initialize the list
  late Map<int, int?> selectedAnswers = {}; // Store selected answers

  int statusNum = 0;
  String status = '';

  _onSetStatus() {
    status = '';
    statusNum = 0;

    if (widget.konseling.status == "waiting") {
      status = "waiting";
      statusNum = 1;
    } else if (widget.konseling.status == "approve") {
      status = "approve";
      statusNum = 2;
    } else if (widget.konseling.status == "decline") {
      status = "decline";
      statusNum = 3;
    } else if (widget.konseling.status == "cancel") {
      status = "cancel";
      statusNum = 4;
    } else if (widget.konseling.status == "reschedule") {
      status = "reschedule";
      statusNum = 5;
    }
  }

  @override
  void initState() {
    _onSetStatus();
    print("Tanggal Konseling: ${widget.konseling.dateRequest}");
    print(
        "Status Konseling: ${widget.konseling.status}, Status Num: $statusNum");
    super.initState();
    fetchPertanyaan();
  }

  Future<void> fetchPertanyaan() async {
    try {
      final response = await http
          .get(Uri.parse('http://app.fagetti.com/api/konseling/pertanyaan'));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['data'] != null) {
          setState(() {
            pertanyaanList = (jsonData['data'] as List)
                .map((item) => Pertanyaan.fromJson(item))
                .toList();
          });
        } else {
          print("No data found in the response.");
        }
      } else {
        print("Failed to load questions: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching questions: $e");
    }
  }

  onBatalkanBtnPress() async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, "Proses...");

    // Prepare the request body
    final body = jsonEncode({"id": widget.konseling.id});

    var response = await http.post(
      Uri.parse('$API_URL/konseling/cancel'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      },
      body: body,
    );

    Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();

    if (response.statusCode == 200) {
      // Check for success status code
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
      setState(() {
        widget.konseling.status = 'cancel';

        statusNum = 5;
        _onSetStatus();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Failed",
            msg: "Batalkan Izin Gagal: ${response.reasonPhrase}",
            contentType: ContentType.failure,
          ),
        ),
      );
      print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      print("Response body: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (statusNum == 2 ||
            statusNum == 3 ||
            statusNum == 4 ||
            statusNum == 5) ...[
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
                            initialChildSize: 1,
                            minChildSize: 1,
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
                                          IconButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              icon: Icon(
                                                Icons.arrow_back,
                                                size: 30.w,
                                                color: Colors.black,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  ? Color(0xFF65B741)
                                                  : statusNum == 3
                                                      ? Colors.red
                                                      : statusNum == 4
                                                          ? const Color(
                                                              0xFF585858)
                                                          : statusNum == 1
                                                              ? const Color(
                                                                  0xFFE69E00)
                                                              : statusNum == 2
                                                                  ? Color(
                                                                      0xFF65B741)
                                                                  : Color(
                                                                      0xFF65B741),
                                            ),
                                            child: Text(
                                              statusNum == 5
                                                  ? "Disetujui - Jadwal ulang"
                                                  : statusNum == 3
                                                      ? "Ditolak"
                                                      : statusNum == 4
                                                          ? "Dibatalkan"
                                                          : statusNum == 1
                                                              ? "Menunggu persetujuan Psikolog"
                                                              : statusNum == 2
                                                                  ? "Disetujui"
                                                                  : "Disetujui",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30.h,
                                          ),
                                          Text(
                                            widget.konseling.lokasi!,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Tanggal Pertemuan",
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color:
                                                        const Color(0xFF585858),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Text(
                                                DateFormat('dd-MM-yyyy').format(
                                                    (widget.konseling
                                                        .dateRequest)),
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
                                                "Jam Pertemuan",
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color:
                                                      const Color(0xFF585858),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Text(
                                                "${DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parse(widget.konseling.timeRequest))} WIB",
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

                                      if (statusNum == 5) ...[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              "Jadwal Ulang",
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color:
                                                      const Color(0xFF585858),
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              widget.konseling.rescheduleTime !=
                                                      null
                                                  ? "${widget.konseling.rescheduleDate} - ${widget.konseling.rescheduleTime ?? ""}"
                                                  : "${widget.konseling.rescheduleDate}",
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ],

                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Kuisioner",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF585858),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),

                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  KuisionerScreen(
                                                pertanyaanList: pertanyaanList,
                                                selectedAnswers: widget
                                                    .konseling
                                                    .getParsedAnswers(),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Lihat kuisioner",
                                          style: TextStyle(
                                            color: const Color(0xFF0277B7),
                                            decoration:
                                                TextDecoration.underline,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Keluhan umum",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: const Color(0xFF585858),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        '${widget.konseling.keluhan}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 25,
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
                                      if (statusNum >= 1) ...[
                                        KTimeLineStep(
                                          text: "Pengajuan konseling dibuat",
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
                                          text: "Data dikirimkan ke Psikolog",
                                          date: statusNum == 1
                                              ? DateFormat('MMM d\n').format(
                                                  (widget.konseling.updatedAt))
                                              : "",
                                          time: statusNum == 1
                                              ? DateFormat('kk:mm').format(
                                                  (widget.konseling.updatedAt)
                                                      .toLocal())
                                              : "",
                                          isFirst: false,
                                          isLast: statusNum == 2
                                              ? false
                                              : true && statusNum == 3
                                                  ? false
                                                  : true && statusNum == 4
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
                                              "Pengajuan konseling telah disetujui",
                                          date: statusNum == 2
                                              ? DateFormat('MMM d\n').format(
                                                  (widget.konseling.updatedAt))
                                              : "",
                                          time: statusNum == 2
                                              ? DateFormat('kk:mm').format(
                                                  (widget.konseling.updatedAt)
                                                      .toLocal())
                                              : "",
                                          isFirst: false,
                                          isLast: true,
                                          isMiddle: false,
                                          color: Color(0xFF65B741),
                                          warna: Color(0xFF65B741),
                                          idx: 2,
                                        ),
                                      ],
                                      if (statusNum == 3) ...[
                                        KTimeLineStep(
                                          text:
                                              "Pengajuan konseling telah ditolak",
                                          date: statusNum == 3
                                              ? DateFormat('MMM d\n').format(
                                                  (widget.konseling.updatedAt))
                                              : "",
                                          time: statusNum == 3
                                              ? DateFormat('kk:mm').format(
                                                  (widget.konseling.updatedAt)
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

                                      if (statusNum == 4) ...[
                                        KTimeLineStep(
                                          text:
                                              "Pengajuan konseling telah dibatalkan",
                                          date: statusNum == 4
                                              ? DateFormat('MMM d\n').format(
                                                  (widget.konseling.updatedAt))
                                              : "",
                                          time: statusNum == 4
                                              ? DateFormat('kk:mm').format(
                                                  (widget.konseling.updatedAt)
                                                      .toLocal())
                                              : "",
                                          isFirst: false,
                                          isLast: true,
                                          isMiddle: false,
                                          color: Colors.black,
                                          warna: Colors.grey,
                                          idx: 2,
                                        ),
                                      ],

                                      if (statusNum >= 5) ...[
                                        const KTimeLineStep(
                                          text:
                                              "Pengajuan disetujui oleh Psikolog",
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
                                      if (statusNum == 5) ...[
                                        KTimeLineStep(
                                          text:
                                              "Pengajuan dijadwalkan ulang oleh Psikolog",
                                          date: statusNum == 5
                                              ? DateFormat('MMM d\n').format(
                                                  (widget.konseling.updatedAt))
                                              : "",
                                          time: statusNum == 5
                                              ? DateFormat('kk:mm').format(
                                                  (widget.konseling.updatedAt)
                                                      .toLocal())
                                              : "",
                                          isFirst: false,
                                          isLast: true,
                                          isMiddle: false,
                                          color: Color(0xFF65B741),
                                          warna: Color(0xFF65B741),
                                          idx: 2,
                                        ),
                                      ],

                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      if (statusNum == 3) ...[
                                        Text(
                                          "Alasan Penolakan",
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: const Color(0xFF585858),
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Text(
                                          "${widget.konseling.reason}",
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
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 33.h,
                              width: 5.w,
                              color: statusNum == 5
                                  ? Color(0xFF65B741)
                                  : statusNum == 3
                                      ? Color(0xFFB31312)
                                      : statusNum == 1
                                          ? const Color(0xFFE69E00)
                                          : statusNum == 4
                                              ? const Color(0xFF585858)
                                              : statusNum == 2
                                                  ? Color(0xFF65B741)
                                                  : Color(0xFF65B741),
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
                                          ? Color(0xFF65B741)
                                          : statusNum == 3
                                              ? Color(0xFFB31312)
                                              : statusNum == 1
                                                  ? const Color(0xFFE69E00)
                                                  : statusNum == 4
                                                      ? const Color(0xFF585858)
                                                      : statusNum == 2
                                                          ? Color(0xFF65B741)
                                                          : Color(0xFF65B741),
                                    ),
                                    child: Text(
                                      statusNum == 5
                                          ? "Disetujui - Jadwal ulang"
                                          : statusNum == 3
                                              ? "Ditolak"
                                              : statusNum == 1
                                                  ? "Menunggu persetujuan Psikolog"
                                                  : statusNum == 4
                                                      ? "Dibatalkan"
                                                      : statusNum == 2
                                                          ? "Disetujui"
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
                                    widget.konseling.lokasi!,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
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
                                            "Tanggal Pertemuan",
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            DateFormat('dd-MM-yyyy').format(
                                                (widget.konseling.dateRequest)),
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
                                          Text(
                                            "Jam Pertemuan",
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: const Color(0xFF585858),
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                            "${DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parse(widget.konseling.timeRequest))} WIB",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                  if (statusNum == 5) ...[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        Text(
                                          "Jadwal Ulang",
                                          style: TextStyle(
                                              fontSize: 13.sp,
                                              color: const Color(0xFF585858),
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Text(
                                          widget.konseling.rescheduleTime !=
                                                  null
                                              ? "${widget.konseling.rescheduleDate} - ${widget.konseling.rescheduleTime ?? ""}"
                                              : "${widget.konseling.rescheduleDate}",
                                          style: TextStyle(
                                              fontSize: 13.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
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
                                          initialChildSize: 0.15,
                                          minChildSize: 0.15,
                                          maxChildSize: 0.15,
                                          builder: (_, controller) => Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            0))),
                                            padding: const EdgeInsets.all(16).w,
                                            child: ListView(
                                              controller: controller,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                              top: 3, bottom: 3)
                                                          .r,
                                                  margin: const EdgeInsets.only(
                                                          left: 125, right: 125)
                                                      .r,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFD9D9D9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20.h,
                                                ),
                                                ElevatedButton.icon(
                                                  label: Text(
                                                    'Dibatalkan',
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    onBatalkanBtnPress();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      side: const BorderSide(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 1,
                                                      bottom: 1,
                                                      left: 55,
                                                      right: 55,
                                                    ).r,
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
                                ),
                              ),
                            ],
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
