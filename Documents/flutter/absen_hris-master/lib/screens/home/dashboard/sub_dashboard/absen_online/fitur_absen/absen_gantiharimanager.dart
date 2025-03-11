import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/models/ganti_hari.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/fitur_absen/edit_absen/history_manager.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/fitur_absen/list_item/list_item_gantihari_manager.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:intl/intl.dart';

import '../../../../../../utils/constant.dart';
import 'package:http/http.dart' as http;

class AbsenOnlineGantihariManager extends StatefulWidget {
  final Karyawan currUser;
  final List<GantiHari> listGantiHariAnakBuah;
  const AbsenOnlineGantihariManager({
    super.key,
    required this.currUser,
    required this.listGantiHariAnakBuah,
  });

  @override
  State<AbsenOnlineGantihariManager> createState() =>
      _AbsenOnlineGantihariManagerState();
}

class _AbsenOnlineGantihariManagerState
    extends State<AbsenOnlineGantihariManager> {
  final TextEditingController _filter = TextEditingController();
  final String _searchText = "";
  List<Karyawan> namaKaryawans = [];
  List<Karyawan> filteredNamaKaryawans = [];
  final Icon _searchIcon = const Icon(Icons.search);
  final Widget _appBarTitle = const Text("List Karyawan");
  bool isLoading = true;

  DateTime today = DateTime.now();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));
  bool loadingGetGantiHari = true;
  bool hidecard = false;
  bool hideempty = false;
  Karyawan user = Karyawan();

  List<GantiHari> listGantiHariSendiri = [];
  List<GantiHari> listGantiHariAnakBuah = [];
  List<Karyawan> listAnakBuah = [];

  int totalGantiHariSendiri = 0;
  int totalGantiHariBelumDikirimSendiri = 0;
  int totalGantiHariMenungguVerifSendiri = 0;
  int totalGantiHariApproveSendiri = 0;

  int ditolak = 0;
  int dibatalkan = 0;
  int menungguApproveManager = 0;
  int menungguVerifHrd = 0;
  int sudahApprove = 0;

  String _dateRangeText = 'Silahkan pilih tanggal';

  _getGantiHariList() async {
    setState(() {
      loadingGetGantiHari = true;
    });
    try {
      listGantiHariSendiri = [];
      listGantiHariAnakBuah = [];
      listAnakBuah = [];

      totalGantiHariSendiri = 0;
      totalGantiHariBelumDikirimSendiri = 0;
      totalGantiHariMenungguVerifSendiri = 0;
      totalGantiHariApproveSendiri = 0;

      ditolak = 0;
      dibatalkan = 0;
      menungguApproveManager = 0;
      menungguVerifHrd = 0;
      sudahApprove = 0;

      final response = await http.get(
        Uri.parse('$API_URL/v2/gantiHari/getData/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);

      for (var gantihari in output) {
        //*Diri sendiri
        if (gantihari['id_karyawan'] == widget.currUser.id) {
          listGantiHariSendiri.add(GantiHari.fromJson(gantihari));
          totalGantiHariSendiri++;

          //*Jumlahin berdasarkan status
          if (gantihari['status'] == 0 &&
              gantihari['disetujuhi'] == 0 &&
              gantihari['diverifikasi'] == 0) {
            totalGantiHariBelumDikirimSendiri++;
          } else if ((gantihari['status'] == 1 &&
                  gantihari['disetujuhi'] == 0 &&
                  gantihari['diverifikasi'] == 0) ||
              (gantihari['status'] == 1 &&
                  gantihari['disetujuhi'] == 1 &&
                  gantihari['diverifikasi'] == 0)) {
            totalGantiHariMenungguVerifSendiri++;
          } else if (gantihari['status'] == 1 &&
              gantihari['disetujuhi'] == 1 &&
              gantihari['diverifikasi'] == 1) {
            totalGantiHariApproveSendiri++;
          }
        }
        //* anak buah
        else {
          listGantiHariAnakBuah.add(GantiHari.fromJson(gantihari));
          listAnakBuah.add(Karyawan.fromJson(gantihari['karyawan']));

          //*Jumlahin berdasarkan status
          if (gantihari['status'] == 1 &&
              gantihari['disetujuhi'] == 0 &&
              gantihari['diverifikasi'] == 0) {
            menungguApproveManager++;
          } else if (gantihari['status'] == 1 &&
              gantihari['disetujuhi'] == 1 &&
              gantihari['diverifikasi'] == 0) {
            menungguVerifHrd++;
          } else if (gantihari['status'] == 1 &&
              gantihari['disetujuhi'] == 1 &&
              gantihari['diverifikasi'] == 1) {
            sudahApprove++;
          } else if (gantihari['status'] == 2 &&
              gantihari['disetujuhi'] == 0 &&
              gantihari['diverifikasi'] == 0) {
            ditolak++;
          } else if (gantihari['status'] == 3 &&
              gantihari['disetujuhi'] == 0 &&
              gantihari['diverifikasi'] == 0) {
            dibatalkan++;
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      loadingGetGantiHari = false;
    });
  }

  void _afterCreateGantiHari(dynamic value) {
    _getGantiHariList();
  }

  _onHistoryGantiHari(Karyawan currUser) {
    Route route = MaterialPageRoute(
        builder: (context) => HistoryManager(
              currUser: widget.currUser,
              listGantiHariAnakBuah: listGantiHariAnakBuah,
            ));
    Navigator.push(context, route).then(_afterCreateGantiHari);
  }

  @override
  void initState() {
    _getGantiHariList();
    user = widget.currUser;
    today = DateTime.now();
    startDate = today.subtract(const Duration(days: 30));
    endDate = today;
    _setListGantiHariSelectedDateRange(startDate, endDate);
    super.initState();
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) async {
    setState(() {
      loadingGetGantiHari = true;

      today = day;
    });
    DateTime startDate = today.subtract(Duration(days: today.weekday));
    DateTime endDate = startDate.add(const Duration(days: 30));
    await _setListGantiHariSelectedDateRange(startDate, endDate);
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
        loadingGetGantiHari = true;
        startDate = picked.start;
        endDate = picked.end;
        hidecard = true;
        hideempty = listGantiHariAnakBuah.isEmpty ? false : false;
        _dateRangeText =
            '${DateFormat('dd/MM/y').format(startDate)} - ${DateFormat('dd/MM/y').format(endDate)}';
      });

      await _setListGantiHariSelectedDateRange(startDate, endDate);
    }
  }

  _setListGantiHariSelectedDateRange(
      DateTime startDate, DateTime endDate) async {
    listGantiHariAnakBuah = [];

    for (var i = 0; i < widget.listGantiHariAnakBuah.length; i++) {
      GantiHari selectedGantihari = widget.listGantiHariAnakBuah[i];
      DateTime selectedDateBiaya = DateTime.parse(selectedGantihari.tglGanti!);

      if (selectedDateBiaya
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          selectedDateBiaya.isBefore(endDate.add(const Duration(days: 1)))) {
        listGantiHariAnakBuah.add(selectedGantihari);
      }
    }

    setState(() {
      loadingGetGantiHari = false;
      hideempty = hidecard
          ? false
          : listGantiHariAnakBuah.isNotEmpty
              ? true
              : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0277B7),
            Colors.white,
          ],
          stops: [0.18, 0.18],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RPadding(
          padding: const EdgeInsets.all(8.0).w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20.h,
              ),
              Row(
                children: [
                  SizedBox(
                    height: 60.h,
                    width: 305.w,
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
                        side: const BorderSide(
                            color: Color(0xFF1A1A1A), width: 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                _dateRangeText,
                                style: const TextStyle(
                                    color: Color(0xFF121212),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.calendar_month,
                            color: Color(0xFF000000),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  SizedBox(
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        _onHistoryGantiHari(user);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        side: const BorderSide(
                            color: Color(0xFF1A1A1A), width: 1.0),
                      ),
                      child: Icon(
                        Icons.history,
                        size: 30.w,
                        color: const Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 25.h,
              ),
              listGantiHariAnakBuah.isEmpty
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
                        child: loadingGetGantiHari
                            ? const Center(
                                child: Loader(),
                              )
                            : listGantiHariAnakBuah.isEmpty
                                ? Visibility(
                                    visible: hidecard = true,
                                    child: const Center(
                                      child: Text('Tidak ada data'),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: listGantiHariAnakBuah.length <
                                            listAnakBuah.length
                                        ? listGantiHariAnakBuah.length
                                        : listAnakBuah.length,
                                    shrinkWrap: true,
                                    physics: const ScrollPhysics(),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListItemGantihariManager(
                                        thisUser: listAnakBuah[index],
                                        gantihari: listGantiHariAnakBuah[index],
                                        onCallback: _getGantiHariList,
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
