import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/core.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/sakit/components/list_item_sik_sakit_anak_buah.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/sakit/components/list_riwayat_anakbuah.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../../../../utils/constant.dart';
import '../../../../../../../widgets/loader.dart';

class SummarySakitRiwayat extends StatefulWidget {
  final Karyawan currUser;
  final List<Sik> listSakitAnakBuah;
  const SummarySakitRiwayat({
    super.key,
    required this.listSakitAnakBuah,
    required this.currUser,
  });

  @override
  State<SummarySakitRiwayat> createState() => _SummarySakitRiwayatState();
}

class _SummarySakitRiwayatState extends State<SummarySakitRiwayat> {
  DateTime today = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));
  bool loadingGetSakit = true;
  bool hidecard = false;
  bool hideempty = false;
  Karyawan user = Karyawan();

  List<Sik> listSakitAnakBuah = [];

  int totalSakitSendiri = 0;
  int totalSakitBelumDikirimSendiri = 0;
  int totalSakitMenungguVerifSendiri = 0;
  int totalSakitApproveSendiri = 0;

  int menungguApproveManager = 0;
  int menungguVerifHrd = 0;
  int sudahApprove = 0;

  String _dateRangeText = 'Silahkan pilih tanggal';

  void _onDaySelected(DateTime day, DateTime focusedDay) async {
    setState(() {
      loadingGetSakit = true;

      today = day;
    });
    DateTime startDate = today.subtract(Duration(days: today.day));
    DateTime endDate = startDate.add(const Duration(days: 30));
    await _setListSakitSelectedDateRange(startDate, endDate);
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
              primary: Color(0xFFFFB000), // primary color
              secondary: Color(0xFFFFEFBD),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        loadingGetSakit = true;
        startDate = picked.start;
        endDate = picked.end;
        hidecard = true;
        hideempty = listSakitAnakBuah.isNotEmpty ? false : false;
        _dateRangeText =
            '${DateFormat('dd/MM/y').format(startDate)} - ${DateFormat('dd/MM/y').format(endDate)}';
      });

      await _setListSakitSelectedDateRange(startDate, endDate);
    }
  }

  _setListSakitSelectedDateRange(DateTime startDate, DateTime endDate) async {
    listSakitAnakBuah = [];

    for (var i = 0; i < widget.listSakitAnakBuah.length; i++) {
      Sik selectedSakit = widget.listSakitAnakBuah[i];
      DateTime selectedDateSakit = DateTime.parse(selectedSakit.tanggalMulai!);

      if (selectedDateSakit
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          selectedDateSakit.isBefore(endDate.add(const Duration(days: 1)))) {
        listSakitAnakBuah.add(selectedSakit);
        print(selectedSakit.karyawan);
      }
    }

    setState(() {
      loadingGetSakit = false;
      hideempty = hidecard
          ? false
          : listSakitAnakBuah.isNotEmpty
              ? true
              : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 10.h,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50.h,
              margin: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 12,
                top: 12,
              ).r,
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ).r,
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
                  side: BorderSide(color: const Color(0xFF1A1A1A), width: 1.w),
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
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    Icon(
                      size: 20.w,
                      Icons.calendar_month,
                      color: const Color(0xFF000000),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        listSakitAnakBuah.isEmpty
            ? Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50.h,
                    ),
                    SizedBox(
                        width: 320.w,
                        height: 160.h,
                        child: SvgPicture.asset("assets/images/tidakada.svg")),
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
            : Expanded(
                child: loadingGetSakit
                    ? const Center(
                        child: Loader(),
                      )
                    : ListView.builder(
                        itemCount: listSakitAnakBuah.length,
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListItemSikSakitAnakBuahRiwayat(
                            sik: listSakitAnakBuah[index],
                          );
                        },
                      ),
              ),
      ]),
    );
  }
}
