import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/models/izin.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/components/list_item_izin_anak_buah.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../../utils/constant.dart';
import '../../../../../widgets/loader.dart';

class SummaryIzinAnakbuah extends StatefulWidget {
  final Karyawan currUser;
  final List<Izin> listIzinAnakBuah;
  const SummaryIzinAnakbuah({
    super.key,
    required this.listIzinAnakBuah,
    required this.currUser,
  });

  @override
  State<SummaryIzinAnakbuah> createState() => _SummaryIzinAnakbuahState();
}

class _SummaryIzinAnakbuahState extends State<SummaryIzinAnakbuah> {
  DateTime today = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));
  bool loadingGetIzin = true;
  bool hidecard = false;
  bool hideempty = false;
  Karyawan user = Karyawan();

  List<Izin> listIzinAnakBuah = [];

  int totalIzinSendiri = 0;
  int totalIzinBelumDikirimSendiri = 0;
  int totalIzinMenungguVerifSendiri = 0;
  int totalIzinApproveSendiri = 0;

  int menungguApproveManager = 0;
  int menungguVerifHrd = 0;
  int sudahApprove = 0;

  String _dateRangeText = 'Silahkan pilih tanggal';

  void _onDaySelected(DateTime day, DateTime focusedDay) async {
    setState(() {
      loadingGetIzin = true;

      today = day;
    });
    DateTime startDate = today.subtract(Duration(days: today.weekday));
    DateTime endDate = startDate.add(const Duration(days: 30));
    await _setListIzinSelectedDateRange(startDate, endDate);
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
        loadingGetIzin = true;
        startDate = picked.start;
        endDate = picked.end;
        hidecard = true;
        hideempty = listIzinAnakBuah.isNotEmpty ? false : false;
        _dateRangeText =
            '${DateFormat('dd/MM/y').format(startDate)} - ${DateFormat('dd/MM/y').format(endDate)}';
      });

      await _setListIzinSelectedDateRange(startDate, endDate);
    }
  }

  _setListIzinSelectedDateRange(DateTime startDate, DateTime endDate) async {
    listIzinAnakBuah = [];

    print("Start Date: $startDate");
    print("End Date: $endDate");

    for (var i = 0; i < widget.listIzinAnakBuah.length; i++) {
      Izin selectedIzin = widget.listIzinAnakBuah[i];
      DateTime selectedDateIzin = DateTime.parse(selectedIzin.tglIzin!);

      print("Selected Date Izin: $selectedDateIzin");

      if (selectedDateIzin
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          selectedDateIzin.isBefore(endDate.add(const Duration(days: 1)))) {
        listIzinAnakBuah.add(selectedIzin);
      }
    }

    setState(() {
      loadingGetIzin = false;
      hideempty = hidecard
          ? false
          : listIzinAnakBuah.isNotEmpty
              ? true
              : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10.h,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50,
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
                                color: Color(0xFF121212),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      Icon(
                        size: 28.w,
                        Icons.calendar_month,
                        color: Color(0xFF000000),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          listIzinAnakBuah.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50.h,
                      ),
                      SizedBox(
                          width: 320.w,
                          height: 160.h,
                          child:
                              SvgPicture.asset("assets/images/tidakada.svg")),
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
                    child: loadingGetIzin
                        ? const Center(
                            child: Loader(),
                          )
                        : listIzinAnakBuah.isEmpty
                            ? Visibility(
                                visible: hidecard = true,
                                child: const Center(
                                  child: Text('Tidak ada klaim biaya'),
                                ),
                              )
                            : ListView.builder(
                                itemCount: listIzinAnakBuah.length,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ListItemIzinAnakBuah(
                                    izin: listIzinAnakBuah[index],
                                    currUser: widget.currUser,
                                  );
                                },
                              ),
                  ),
                )
        ],
      ),
    );
  }
}
