import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/summary_lembur/sumarry_lembur_spv_list.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/summary_lembur/summary_lembur_item_list.dart';
import 'package:intl/intl.dart';

import '../../../../../../models/karyawan.dart';
import '../../../../../../models/lembur.dart';
import '../../../../../../widgets/loader.dart';

class SummaryLemburSpvScreen extends StatefulWidget {
  final Karyawan currUser;
  final List<Lembur> listLembur;
  const SummaryLemburSpvScreen({
    super.key,
    required this.listLembur,
    required this.currUser,
  });

  @override
  State<SummaryLemburSpvScreen> createState() => _SummaryLemburSpvScreenState();
}

class _SummaryLemburSpvScreenState extends State<SummaryLemburSpvScreen> {
  String status = '';
  int statusNum = 0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool isLoadingSetInitialData = true;
  List<Lembur> listLemburSelectedDate = [];

  void _onDaySelected(DateTime day, DateTime focusedDay) async {
    setState(() {
      isLoadingSetInitialData = true;
      startDate = day;
    });

    await _setListLemburSelectedDate(startDate, endDate);
  }

  void _showDatePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendar,
        initialDateRange: DateTimeRange(
          start: startDate,
          end: startDate,
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
        });

    if (picked != null) {
      setState(() {
        isLoadingSetInitialData = true;
        startDate = picked.start;
        endDate = picked.end;
      });

      await _setListLemburSelectedDate(startDate, endDate);
    }
  }

  _setListLemburSelectedDate(DateTime startDate, DateTime endDate) async {
    listLemburSelectedDate = [];
    for (var i = 0; i < widget.listLembur.length; i++) {
      Lembur selectedLembur1 = widget.listLembur[i];
      DateTime selectedLembur = DateTime.parse(selectedLembur1.tglLembur!);

      if (selectedLembur.isAfter(startDate.subtract(Duration(days: 1))) &&
          selectedLembur.isBefore(endDate.add(Duration(days: 1)))) {
        listLemburSelectedDate.add(selectedLembur1);
        if (selectedLembur1.status == 1 &&
            selectedLembur1.disetujui == 1 &&
            selectedLembur1.diverifikasi == 1) {
          statusNum = 3; // Approved
        } else if (selectedLembur1.status == 3 &&
            selectedLembur1.disetujui == 0 &&
            selectedLembur1.diverifikasi == 0) {
          statusNum = 4; // Dibatalkan
        } else if (selectedLembur1.status == 2 &&
            selectedLembur1.disetujui == 0 &&
            selectedLembur1.diverifikasi == 0) {
          statusNum = 5; // Ditolak
        }
      }
    }

    setState(() {
      isLoadingSetInitialData = false;
    });
  }

  @override
  void initState() {
    startDate = DateTime.now();
    _setListLemburSelectedDate(startDate, endDate);
    super.initState();
    endDate = startDate.add(Duration(days: 1));
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
            children: [
              Container(
                margin: const EdgeInsets.only(
                        left: 12, right: 12.0, bottom: 12, top: 12)
                    .r,
                width: double.infinity,
                height: 60.h,
                child: ElevatedButton(
                  onPressed: () {
                    _showDatePicker(context);
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
                      Text(
                        '${DateFormat('dd-MMMM-y').format(startDate)} - ${DateFormat('dd-MMMM-y').format(endDate)}',
                        style: TextStyle(
                            color: const Color(0xFF121212),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400),
                      ),
                      const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF000000),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Center(
              child: Column(
            children: [
              if (widget.currUser.level != 3 &&
                  (widget.currUser.level == 1 ||
                      widget.currUser.level == 2 ||
                      widget.currUser.level == 4 ||
                      widget.currUser.level == 5))
                ...[],
            ],
          )),
          listLemburSelectedDate.isEmpty
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
              : Expanded(
                  child: isLoadingSetInitialData
                      ? const Center(
                          child: Loader(),
                        )
                      : ListView.builder(
                          itemCount: listLemburSelectedDate.length,
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return ListItemLemburSpvList(
                              lembur: listLemburSelectedDate[index],
                              currUser: widget.currUser,
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
