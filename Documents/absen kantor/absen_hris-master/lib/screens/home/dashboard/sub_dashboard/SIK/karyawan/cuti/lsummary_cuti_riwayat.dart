import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/cuti/components/list_item_cuti_riwayat.dart';
import 'package:intl/intl.dart';

import '../../../../../../../models/karyawan.dart';
import '../../../../../../../models/sik.dart';

import '../../../../../../../widgets/loader.dart';

class SummarySikAnakbuahRiwayat extends StatefulWidget {
  final Karyawan currUser;
  final List<Sik> listSikAnakBuah;
  const SummarySikAnakbuahRiwayat({
    super.key,
    required this.listSikAnakBuah,
    required this.currUser,
  });

  @override
  State<SummarySikAnakbuahRiwayat> createState() =>
      _SummarySikAnakbuahRiwayatState();
}

class _SummarySikAnakbuahRiwayatState extends State<SummarySikAnakbuahRiwayat> {
  DateTime today = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool loadingGetSik = true;
  bool hidecard = false;
  bool hideempty = false;
  Karyawan user = Karyawan();

  List<Sik> listSikAnakBuah = [];

  int totalApproveSendiri = 0;
  int totalMenungguVerifSendiri = 0;
  int totalBelumDikirimSendiri = 0;

  int menungguApproveManager = 0;
  int menungguVerifHrd = 0;
  int sudahApprove = 0;

  String _dateRangeText = 'Silahkan pilih tanggal';

  void _onDaySelected(DateTime day, DateTime focusedDay) async {
    setState(() {
      loadingGetSik = true;

      today = day;
    });
    DateTime startDate = today.subtract(Duration(days: today.weekday));
    DateTime endDate = startDate.add(const Duration(days: 30));
    await _setListSikSelectedDateRange(startDate, endDate);
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
        loadingGetSik = true;
        startDate = picked.start;
        endDate = picked.end;
        hidecard = true;
        hideempty = listSikAnakBuah.isEmpty ? false : false;
        _dateRangeText =
            '${DateFormat('dd/MM/y').format(startDate)} - ${DateFormat('dd/MM/y').format(endDate)}';
      });

      await _setListSikSelectedDateRange(startDate, endDate);
    }
  }

  _setListSikSelectedDateRange(DateTime startDate, DateTime endDate) async {
    listSikAnakBuah = [];

    for (var i = 0; i < widget.listSikAnakBuah.length; i++) {
      Sik selectedSik = widget.listSikAnakBuah[i];
      DateTime selectedDateSik = DateTime.parse(selectedSik.tanggalMulai!);

      if (selectedDateSik
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          selectedDateSik.isBefore(endDate.add(const Duration(days: 1)))) {
        listSikAnakBuah.add(selectedSik);
      }
    }

    setState(() {
      loadingGetSik = false;
      hideempty = hidecard
          ? false
          : listSikAnakBuah.isNotEmpty
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
                    side:
                        BorderSide(color: const Color(0xFF1A1A1A), width: 1.w),
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
          listSikAnakBuah.isEmpty
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
                    child: loadingGetSik
                        ? const Center(
                            child: Loader(),
                          )
                        : listSikAnakBuah.isEmpty
                            ? Visibility(
                                visible: hidecard = true,
                                child: const Center(
                                  child: Text('Tidak ada klaim biaya'),
                                ),
                              )
                            : ListView.builder(
                                itemCount: listSikAnakBuah.length,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ListItemSikCutiAnakBuahRiwayat(
                                    sik: listSikAnakBuah[index],
                                    currUser: widget.currUser,
                                  );
                                },
                              ),
                  ),
                ),
        ],
      ),
    );
  }
}
