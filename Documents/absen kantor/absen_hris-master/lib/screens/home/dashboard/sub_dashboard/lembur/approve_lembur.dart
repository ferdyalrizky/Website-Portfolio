import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/components/list_item_lembur_manager.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/components/list_semuadata.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/list_spk_lembur.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/summary_lembur/summary_lembur_item_list.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import '../../../../../../models/karyawan.dart';
import '../../../../../../models/lembur.dart';
import '../../../../../../widgets/loader.dart';
import '../../../../../utils/constant.dart';
import '../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../widgets/dialog.dart';

class SummaryLemburManajer extends StatefulWidget {
  final Karyawan currUser;
  final List<Lembur> lembur;
  const SummaryLemburManajer({
    super.key,
    required this.currUser,
    required this.lembur,
  });

  @override
  State<SummaryLemburManajer> createState() => _SummaryLemburManajerState();
}

class _SummaryLemburManajerState extends State<SummaryLemburManajer> {
  bool areAllSelected() {
    return listLemburSelectedDate.every((lembur) => lembur.isSelected);
  }

  String _dateRangeText =
      '${DateFormat('dd-MMMM-y').format(DateTime.now())} - ${DateFormat('dd-MMMM-y').format(DateTime.now().add(const Duration(days: 1)))}';

  bool isLoadingListLembur = true;
  String formattedSpklDate = "";
  List<Lembur> listLembur = [];
  List<int> selectedLembur = [];
  String status = '';
  int statusNum = 0;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  bool isLoadingSetInitialData = true;
  List<Lembur> listLemburSelectedDate = [];
  bool selectAll = false;

  void toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value!;
      listLemburSelectedDate.forEach((lembur) {
        // Cek apakah lembur memenuhi kondisi yang ditentukan
        if (lembur.status == 1 &&
            lembur.disetujui == 0 &&
            lembur.diverifikasi == 0) {
          lembur.isSelected =
              selectAll; // Set status lembur sesuai dengan selectAll
          if (selectAll) {
            selectedLembur.add(lembur.idLembur!);
          } else {
            selectedLembur.remove(
                lembur.idLembur!); // Hapus dari daftar jika tidak terpilih
          }
        }
      });
    });
  }

  void toggleSelection(int lemburId) {
    setState(() {
      final lembur =
          listLemburSelectedDate.firstWhere((l) => l.idLembur == lemburId);
      lembur.isSelected = !lembur.isSelected; // Toggle the selected state
      if (lembur.isSelected) {
        selectedLembur.add(lemburId);
      } else {
        selectedLembur.remove(lemburId);
      }
    });
    print(selectedLembur);
  }

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
        end: endDate,
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

    // void _showDatePicker(BuildContext context) async {
    //   final DateTimeRange? picked = await showDateRangePicker(
    //       context: context,
    //       initialEntryMode: DatePickerEntryMode.calendar,
    //       initialDateRange: DateTimeRange(
    //         start: startDate,
    //         end: startDate,
    //       ),
    //       firstDate: DateTime(2020),
    //       lastDate: DateTime(2030),
    //       builder: (context, child) {
    //         return Theme(
    //           data: Theme.of(context).copyWith(
    //             colorScheme: const ColorScheme.light(
    //               primary: Color(0xFFFFB000), // primary color
    //               secondary: Color(0xFFFFEFBD),
    //             ),
    //           ),
    //           child: child!,
    //         );
    //       });

    //   if (picked != null) {
    //     setState(() {
    //       isLoadingSetInitialData = true;
    //       startDate = picked.start;
    //       endDate = picked.end;
    //     });

    //     await _setListLemburSelectedDate(startDate, endDate);
    //   }
    // }

    if (picked != null) {
      setState(() {
        isLoadingSetInitialData = true;
        startDate = picked.start;
        endDate = picked.end;
        //hidecard = true;
        //hideempty = listSakitAnakBuah.isNotEmpty ? false : false;
        _dateRangeText =
            '${DateFormat('dd/MM/y').format(startDate)} - ${DateFormat('dd/MM/y').format(endDate)}';
      });

      await _setListLemburSelectedDate(startDate, endDate);
    }
  }

  _setListLemburSelectedDate(DateTime startDate, DateTime endDate) async {
    listLemburSelectedDate = [];

    for (var lembur in widget.lembur) {
      DateTime selectedLembur = DateTime.parse(lembur.tglLembur!);

      // Memastikan bahwa selectedLembur termasuk dalam rentang tanggal
      // if (selectedLembur.isAfter(startDate.subtract(Duration(days: 1))) &&
      //         selectedLembur.isBefore(endDate.add(Duration(days: 1))) ||
      //     selectedLembur.isAtSameMomentAs(startDate) ||
      //     selectedLembur.isAtSameMomentAs(endDate)) {
      //   listLemburSelectedDate.add(lembur);
      //   print("Menambahkan lembur: ${lembur.idLembur}"); // Log untuk debugging
      // }

      if (selectedLembur.isAfter(startDate.subtract(const Duration(days: 1))) &&
          selectedLembur.isBefore(endDate.add(const Duration(days: 1)))) {
        listLemburSelectedDate.add(lembur);
      }
    }

    // for (var i = 0; i < widget.listSakitAnakBuah.length; i++) {
    //   Sik selectedSakit = widget.listSakitAnakBuah[i];
    //   DateTime selectedDateSakit = DateTime.parse(selectedSakit.tanggalIzin!);

    //   if (selectedDateSakit
    //           .isAfter(startDate.subtract(const Duration(days: 1))) &&
    //       selectedDateSakit.isBefore(endDate.add(const Duration(days: 1)))) {
    //     listSakitAnakBuah.add(selectedSakit);
    //     //print(selectedSakit.karyawan);
    //   }
    // }

    print(
        "Total lembur yang ditambahkan: ${listLemburSelectedDate.length}"); // Log untuk debugging

    setState(() {
      isLoadingSetInitialData = false;
    });
  }

  _autoApproveSelectedItems() async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, "Proses...");

    String jenis = selectedLembur.isEmpty ? "Semua" : "Terpilih";

    List<int> listLemburId = selectedLembur.isEmpty
        ? listLemburSelectedDate.map((lembur) => lembur.idLembur!).toList()
        : selectedLembur;

    var json = {
      'lembur_list': listLemburId,
      'user_id': widget.currUser.id,
    };
    var body = jsonEncode(json);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };
    print(body);

    try {
      var request = await http.post(Uri.parse('$API_URL/v2/approveSemuaSpkl'),
          headers: header, body: body);
      var response = jsonDecode(request.body);
      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
      if (request.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Setujui Lembur Berhasil",
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
              msg: "Setujui Lembur Gagal",
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      print('error _kirimSemua ${e.toString()}');
      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
    }
  }

  _autoDeclineSelectedItems() async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, "Proses...");

    String jenis = selectedLembur.isEmpty ? "Semua" : "Terpilih";

    List<int> listLemburId = selectedLembur.isEmpty
        ? listLemburSelectedDate.map((lembur) => lembur.idLembur!).toList()
        : selectedLembur;

    var json = {
      'lembur_list': listLemburId,
      'user_id': widget.currUser.id,
    };
    var body = jsonEncode(json);
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };
    print(body);

    try {
      var request = await http.post(
          Uri.parse('$API_URL/v2/declineSelectedSpkl'),
          headers: header,
          body: body);
      var response = jsonDecode(request.body);
      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
      if (request.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Ditolak lembur Berhasil",
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
              msg: "Ditolak sakit Gagal",
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      print('error _kirimSemua ${e.toString()}');
      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
    }
  }

  @override
  void initState() {
    super.initState();

    _setListLemburSelectedDate(startDate, endDate);
  }

  @override
  Widget build(BuildContext context) {
    int selectedCount =
        listLemburSelectedDate.where((lembur) => lembur.isSelected).length;

    List<Lembur> filteredList = listLemburSelectedDate.where((lembur) {
      return statusNum >= 3;
    }).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10.h,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        _dateRangeText,
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
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            padding: EdgeInsets.all(16),
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            height: 155.h,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Anda sudah memilih ",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      "$selectedCount pengajuan lembur.",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Ingin disetujui atau ditolak?",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                      width: 130.w,
                                      height: 42.h,
                                      child: TextButton(
                                        onPressed: () async {
                                          showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Kamu sudah yakin ingin menolak',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    'lembur ini?',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                  SizedBox(height: 16.h),
                                                  Text(
                                                    'Kalau sudah yakin dengan menolak lembur ini,',
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF585858),
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Anda tidak dapat mengubahnya",
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF585858),
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    SizedBox(
                                                      width: 131.w,
                                                      height: 40.r,
                                                      child: TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                        style: TextButton
                                                            .styleFrom(
                                                          side:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                          backgroundColor:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Cek dulu deh',
                                                          style: TextStyle(
                                                            color: const Color(
                                                                0xFF142638),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16.sp,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 20),
                                                    SizedBox(
                                                      width: 120.w,
                                                      height: 40.h,
                                                      child: TextButton(
                                                        onPressed: () async {
                                                          final navigator =
                                                              Navigator.of(
                                                                  context);
                                                          final scaffoldMessenger =
                                                              ScaffoldMessenger
                                                                  .of(context);

                                                          await _autoDeclineSelectedItems();

                                                          scaffoldMessenger
                                                              .showSnackBar(
                                                            SnackBar(
                                                              elevation: 0,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              content:
                                                                  CustomSnackbarContent(
                                                                title:
                                                                    "Success",
                                                                msg:
                                                                    "Menolak Berhasil",
                                                                contentType:
                                                                    ContentType
                                                                        .success,
                                                              ),
                                                            ),
                                                          );

                                                          navigator.pop(true);
                                                          navigator.popUntil(
                                                              (route) => route
                                                                  .isFirst);

                                                          // Push the ListSpkLemburScreen
                                                          navigator.push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ListSpkLemburScreen(
                                                                currUser: widget
                                                                    .currUser,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              LightColors
                                                                  .kFagettiBlue,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Yakin dong',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          side: const BorderSide(
                                              color: Colors.black),
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Ditolak',
                                          style: TextStyle(
                                            color: Color(0xFF142638),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 130.w,
                                      height: 42.h,
                                      child: TextButton(
                                        onPressed: () async {
                                          showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Kamu sudah yakin ingin menyetujui',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    'lembur ini?',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                  SizedBox(height: 16.h),
                                                  Text(
                                                    'Kalau sudah yakin dengan menyetujui lembur ini,',
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF585858),
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Anda tidak dapat mengubahnya",
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF585858),
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    SizedBox(
                                                      width: 131.w,
                                                      height: 40.r,
                                                      child: TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                        style: TextButton
                                                            .styleFrom(
                                                          side:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                          backgroundColor:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Cek dulu deh',
                                                          style: TextStyle(
                                                            color: const Color(
                                                                0xFF142638),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16.sp,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 20),
                                                    SizedBox(
                                                      width: 120.w,
                                                      height: 40.h,
                                                      child: TextButton(
                                                        onPressed: () async {
                                                          final navigator =
                                                              Navigator.of(
                                                                  context);
                                                          final scaffoldMessenger =
                                                              ScaffoldMessenger
                                                                  .of(context);

                                                          await _autoApproveSelectedItems();

                                                          scaffoldMessenger
                                                              .showSnackBar(
                                                            SnackBar(
                                                              elevation: 0,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              content:
                                                                  CustomSnackbarContent(
                                                                title:
                                                                    "Success",
                                                                msg:
                                                                    "Disetujui Berhasil",
                                                                contentType:
                                                                    ContentType
                                                                        .success,
                                                              ),
                                                            ),
                                                          );

                                                          navigator.pop(true);
                                                          navigator.popUntil(
                                                              (route) => route
                                                                  .isFirst);

                                                          // Push the ListSpkLemburScreen
                                                          navigator.push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ListSpkLemburScreen(
                                                                currUser: widget
                                                                    .currUser,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              LightColors
                                                                  .kFagettiBlue,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Yakin dong',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              LightColors.kFagettiBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Disetujui',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      "Terpilih ($selectedCount)",
                      style: TextStyle(
                        color: const Color(0xFF142638),
                        decoration: TextDecoration.underline,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 135.w,
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text(
                        "Pilih Semua",
                        style: TextStyle(
                          color: const Color(0xFF142638),
                          fontSize: 14.sp,
                        ),
                      ),
                      value: selectAll,
                      onChanged: (bool? value) {
                        toggleSelectAll(value);
                      },
                    ),
                  ),
                ],
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
                            return ListItemLemburSemua(
                              lembur: listLemburSelectedDate[index],
                              currUser:
                                  widget.currUser, // Pass the current user
                              isSelected:
                                  listLemburSelectedDate[index].isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  toggleSelection(
                                      listLemburSelectedDate[index].idLembur!);
                                });
                              },
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
