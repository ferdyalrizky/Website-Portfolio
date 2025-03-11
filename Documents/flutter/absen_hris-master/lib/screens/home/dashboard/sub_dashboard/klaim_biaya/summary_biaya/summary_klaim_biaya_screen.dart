import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/models/biaya.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/klaim_biaya/form_biaya.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/klaim_biaya/summary_biaya/summary_klaim_biaya_item_list.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../../../../../models/karyawan.dart';
import '../../../../../../widgets/loader.dart';

class SummaryKlaimBiayaScreen extends StatefulWidget {
  final Karyawan currUser;
  final List<Biaya> listBiayaAnakBuah;
  final List<Biaya> listBiayaSendiri;
  const SummaryKlaimBiayaScreen({
    super.key,
    required this.listBiayaSendiri,
    required this.listBiayaAnakBuah,
    required this.currUser,
  });

  @override
  State<SummaryKlaimBiayaScreen> createState() =>
      _SummaryKlaimBiayaScreenState();
}

class _SummaryKlaimBiayaScreenState extends State<SummaryKlaimBiayaScreen> {
  List<Biaya> get combinedList {
    // Menggabungkan kedua list menggunakan addAll
    List<Biaya> combined = [];
    combined.addAll(listBiayaSendiri);
    combined.addAll(listBiayaAnakBuah);
    return combined;
  }

  DateTime today = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool loadingGetBiaya = true;
  bool hidecard = false;
  bool hideempty = false;
  Karyawan user = Karyawan();

  List<Biaya> listBiayaAnakBuah = [];
  List<Biaya> listBiayaSendiri = [];
  List<Karyawan> listAnakBuah = [];

  int totalBiayaSendiri = 0;
  int totalBiayaBelumDikirimSendiri = 0;
  int totalBiayaMenungguVerifSendiri = 0;
  int totalBiayaApproveSendiri = 0;

  int menungguApproveManager = 0;
  int menungguVerifHrd = 0;
  int sudahApprove = 0;

  String _dateRangeText = 'Silahkan pilih tanggal';

  void _onDaySelected(DateTime day, DateTime focusedDay) async {
    setState(() {
      loadingGetBiaya = true;

      today = day;
    });
    DateTime startDate = today.subtract(Duration(days: today.weekday));
    DateTime endDate = startDate.add(const Duration(days: 30));
    await _setListBiayaSelectedDateRange(startDate, endDate);
  }

  void _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDateRange: DateTimeRange(
        start: today,
        end: today,
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFB000),
              secondary: Color(0xFFFFEFBD),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        loadingGetBiaya = true;
        startDate = picked.start;
        endDate = picked.end;
        hidecard = true;
        hideempty = listBiayaSendiri.isNotEmpty ? false : false;
        hideempty = listBiayaAnakBuah.isNotEmpty ? false : false;
        _dateRangeText =
            '${DateFormat('dd/MM/y').format(startDate)} - ${DateFormat('dd/MM/y').format(endDate)}';
      });

      await _setListBiayaSelectedDateRange(startDate, endDate);
    }
  }

  _setListBiayaSelectedDateRange(DateTime startDate, DateTime endDate) async {
    // Kosongkan kedua list
    listBiayaSendiri = [];
    listBiayaAnakBuah = [];

    // Filter listBiayaSendiri
    for (var i = 0; i < widget.listBiayaSendiri.length; i++) {
      Biaya selectedBiaya = widget.listBiayaSendiri[i];
      DateTime selectedDateBiaya = DateTime.parse(selectedBiaya.tglKwintansi!);

      if (selectedDateBiaya
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          selectedDateBiaya.isBefore(endDate.add(const Duration(days: 1)))) {
        listBiayaSendiri.add(selectedBiaya);
      }
    }

    // Filter listBiayaAnakBuah
    for (var i = 0; i < widget.listBiayaAnakBuah.length; i++) {
      Biaya selectedBiayaAnakBuah = widget.listBiayaAnakBuah[i];
      DateTime selectedDateBiayaAnakBuah =
          DateTime.parse(selectedBiayaAnakBuah.create!);

      if (selectedDateBiayaAnakBuah
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          selectedDateBiayaAnakBuah
              .isBefore(endDate.add(const Duration(days: 1)))) {
        listBiayaAnakBuah.add(selectedBiayaAnakBuah);
      }
    }

    // Update state
    setState(() {
      loadingGetBiaya = false;
      hideempty = hidecard
          ? false
          : (listBiayaSendiri.isEmpty && listBiayaAnakBuah.isEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Container(
                margin: const EdgeInsets.only(
                        left: 12.0, right: 12.0, bottom: 12, top: 12)
                    .r,
                width: double.infinity,
                height: 60.h,
                child: ElevatedButton(
                  onPressed: () async {
                    _showDateRangePicker(context);
                    setState(() {
                      hidecard = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    side:
                        const BorderSide(color: Color(0xFF1A1A1A), width: 1.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            _dateRangeText,
                            style: TextStyle(
                                color: const Color(0xFF121212),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.calendar_month,
                        size: 25.w,
                        color: const Color(0xFF000000),
                      ),
                    ],
                  ),
                ),
              ),
              combinedList.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50.h,
                          ),
                          SizedBox(
                              width: 320.w,
                              height: 160.h,
                              child: SvgPicture.asset(
                                  "assets/images/tidakada.svg")),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "Tidak ada hasil",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Visibility(
                      visible: hidecard,
                      child: Expanded(
                        child: loadingGetBiaya
                            ? const Center(
                                child: Loader(),
                              )
                            : ListView.builder(
                                itemCount: listBiayaAnakBuah.length +
                                    listBiayaSendiri.length,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return ListItemKlaimBiayaRiwayat(
                                    biaya: combinedList[index],
                                    currUser: widget.currUser,
                                  );
                                },
                              ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
