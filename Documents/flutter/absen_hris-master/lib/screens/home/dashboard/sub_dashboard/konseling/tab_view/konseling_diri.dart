import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/models/konseling_request.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/konseling/list/list_diri_sendiri.dart';
import 'package:intl/intl.dart';
import '../../../../../../models/karyawan.dart';
import '../../../../../../widgets/loader.dart';

class SummaryKonselingScreen extends StatefulWidget {
  final Karyawan currUser;
  final List<Counseling> listKonselingSendiri;
  const SummaryKonselingScreen({
    super.key,
    required this.listKonselingSendiri,
    required this.currUser,
  });

  @override
  State<SummaryKonselingScreen> createState() => _SummaryKonselingScreenState();
}

class _SummaryKonselingScreenState extends State<SummaryKonselingScreen> {
  List<Counseling> listKonselingSendiri = [];
  DateTime today = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool loadingGetKonseling = false;
  bool loadingkonselingall = false;
  bool hidecard = false;
  bool hideempty = false;
  Karyawan user = Karyawan();

  int totalKonselingSendiri = 0;
  int totalKonselingBelumDikirimSendiri = 0;
  int totalKonselingMenungguVerifSendiri = 0;
  int totalKonselingApproveSendiri = 0;

  int menungguApproveManager = 0;
  int menungguVerifHrd = 0;
  int sudahApprove = 0;

  String _dateRangeText = 'Silahkan pilih tanggal';

  void _onDaySelected(DateTime day, DateTime focusedDay) async {
    setState(() {
      loadingGetKonseling = true;

      today = day;
    });
    DateTime startDate = today.subtract(Duration(days: today.weekday));
    DateTime endDate = startDate.add(const Duration(days: 30));
    await _setListKonselingSelectedDateRange(startDate, endDate);
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
        loadingGetKonseling = true;
        startDate = picked.start;
        endDate = picked.end;
        hidecard = true;
        hideempty = listKonselingSendiri.isNotEmpty ? false : false;
        _dateRangeText =
            '${DateFormat('dd/MM/y').format(startDate)} - ${DateFormat('dd/MM/y').format(endDate)}';
      });

      await _setListKonselingSelectedDateRange(startDate, endDate);
    }
  }

  _setListKonselingSelectedDateRange(
      DateTime startDate, DateTime endDate) async {
    listKonselingSendiri = [];

    for (var i = 0; i < widget.listKonselingSendiri.length; i++) {
      Counseling selectedKonseling = widget.listKonselingSendiri[i];
      DateTime selectedDateKonseling = (selectedKonseling.dateRequest);

      if (selectedDateKonseling
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          selectedDateKonseling
              .isBefore(endDate.add(const Duration(days: 1)))) {
        listKonselingSendiri.add(selectedKonseling);
      }
    }

    setState(() {
      loadingGetKonseling = false;
      hideempty = hidecard
          ? false
          : listKonselingSendiri.isNotEmpty
              ? true
              : true;
    });
  }

  @override
  void initState() {
    super.initState();
    listKonselingSendiri = List.from(widget.listKonselingSendiri);
    hideempty = listKonselingSendiri.isNotEmpty;
    hidecard = true;
    loadingkonselingall = false;
    print("Initial listKonselingSendiri: ${listKonselingSendiri.length}");
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
                side: const BorderSide(color: Color(0xFF1A1A1A), width: 1.0),
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
          listKonselingSendiri.isEmpty
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
                    child: loadingGetKonseling || loadingkonselingall
                        ? const Center(
                            child: Loader(),
                          )
                        : ListView.builder(
                            itemCount: listKonselingSendiri.length,
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return ListItemKonselingSendiri(
                                konseling: listKonselingSendiri[index],
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
