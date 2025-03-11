import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_laporan.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:intl/intl.dart';

import '../../../../../../models/karyawan.dart';
import '../../../../../../models/lembur.dart';

import 'package:http/http.dart' as http;

import '../../../../../../utils/public_func.dart';

class SummaryLemburAllDeptScreen extends StatefulWidget {
  final Karyawan currUser;
  const SummaryLemburAllDeptScreen({super.key, required this.currUser});

  @override
  State<SummaryLemburAllDeptScreen> createState() =>
      _SummaryLemburAllDeptScreenState();
}

class _SummaryLemburAllDeptScreenState
    extends State<SummaryLemburAllDeptScreen> {
  bool isLoadingSetInitialData = true;
  final _formKey = GlobalKey<FormBuilderState>();
  DateTime today = DateTime.now();
  bool isLoading = true;
  List<Lembur> listLemburAll = [];
  List<Lembur> listLemburSelectedDate = [];
  List<Department> listDepartment = [];
  List<String> listDepartmentString = [];
  int selectedDepartment = 0;
  String selectedDepartmentString = "";

  void _onDaySelected(DateTime day, DateTime focusedDay) async {
    setState(() {
      isLoading = true;
      today = day;
    });

    await _onChangeDeptOrChangeDate();
  }

  _getDeptList() async {
    try {
      final response =
          await http.get(Uri.parse('$API_URL/v2/getAllDept'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      });
      final output = jsonDecode(response.body);
      for (var i = 0; i < output.length; i++) {
        listDepartment.add(Department.fromJson(output[i]));
        listDepartmentString.add(output[i]['nama_department']);
      }
      selectedDepartment = listDepartment[0].id!;
      selectedDepartmentString = listDepartment[0].namaDepartment!;
      print(listDepartmentString);
    } catch (e) {
      print(e.toString());
    }
  }

  _setListLemburanSelectedDate() async {
    listLemburSelectedDate = [];
    String formattedToday = DateFormat('yyyy-MM-dd').format(today);

    for (var i = 0; i < listLemburAll.length; i++) {
      Lembur selectedLembur = listLemburAll[i];
      print(selectedLembur.tglLembur);
      String selectedDateLembur = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(selectedLembur.tglLembur!));
      if (selectedDateLembur == formattedToday) {
        listLemburSelectedDate.add(selectedLembur);
      }
    }
  }

  _getLemburByDept() async {
    listLemburAll = [];
    try {
      final response = await http.get(
        Uri.parse('$API_URL/v2/getSpklByDept/$selectedDepartment'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      var output = jsonDecode(response.body);
      // for (var lembur in output) {
      //   print('INI !!!');
      //   print(lembur);
      //   listLemburAll.add(Lembur.fromJson(lembur));
      // }
      for (var i = 0; i < output.length; i++) {
        listLemburAll.add(Lembur.fromJson(output[i]));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  _onChangeDeptOrChangeDate() async {
    setState(() {
      isLoading = true;
    });

    await _getLemburByDept();
    await _setListLemburanSelectedDate();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    firstInit();
    super.initState();
  }

  firstInit() async {
    setState(() {
      isLoading = true;
    });

    await _getDeptList();
    await _getLemburByDept();

    setState(() {
      isLoading = false;
    });
  }

  void _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: today,
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
        });

    if (picked != null) {
      setState(() {
        isLoadingSetInitialData = true;
        today = picked;
      });

      await _setListLemburanSelectedDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: Loader(),
            )
          : FormBuilder(
              key: _formKey,
              initialValue: {
                'department': selectedDepartmentString,
              },
              child: Column(
                children: [
                  SizedBox(
                    height: 20.h,
                  ),
                  RPadding(
                    padding: const EdgeInsets.only(left: 10, right: 10).r,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          _showDatePicker(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          side: const BorderSide(
                              color: Color(0xFF1A1A1A), width: 1.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd-MMMM-y').format(today),
                              style: const TextStyle(
                                  color: Color(0xFF121212),
                                  fontSize: 14,
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
                  ),
                  CustomLaporan(
                    dropdownName: 'department',
                    items: listDepartmentString,
                    onChanged: (p0) {
                      setState(() {
                        var departmentGet = listDepartment
                            .where((element) => element.namaDepartment == p0);
                        selectedDepartment = departmentGet.first.id!;
                        selectedDepartmentString =
                            departmentGet.first.namaDepartment!;
                      });
                      _onChangeDeptOrChangeDate();
                    },
                  ),
                  Text(
                      "Total Karyawan Lembur : ${listLemburSelectedDate.length}"),
                  listLemburSelectedDate.isEmpty
                      ? const Expanded(
                          child: Center(
                              child: Text("Tidak ada yang lembur hari ini")),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: listLemburSelectedDate.length,
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) => GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () =>
                                            Navigator.of(context).pop(),
                                        child: DraggableScrollableSheet(
                                          initialChildSize: 0.5,
                                          minChildSize: 0.5,
                                          maxChildSize: 1,
                                          builder: (_, controller) => Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            0))),
                                            padding: const EdgeInsets.all(16),
                                            child: ListView(
                                              controller: controller,
                                              children: [
                                                Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        IconButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          icon: const Icon(
                                                            Icons.close,
                                                            size: 30,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      listLemburSelectedDate[
                                                              index]
                                                          .namaKaryawan!,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 20),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  children: [
                                                    const Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Tanggal mulai",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily: GoogleFonts
                                                                      .inter()
                                                                  .fontFamily),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                                  'dd/MM/yyyy')
                                                              .format(DateTime.parse(
                                                                  listLemburSelectedDate[
                                                                          index]
                                                                      .tglLembur!)),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily: GoogleFonts
                                                                      .inter()
                                                                  .fontFamily),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Tanggal Selesai",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily: GoogleFonts
                                                                      .inter()
                                                                  .fontFamily),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(DateTime.parse(
                                                                  listLemburSelectedDate[
                                                                          index]
                                                                      .tglLemburSelesai!)),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily: GoogleFonts
                                                                      .inter()
                                                                  .fontFamily),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Jam mulai",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily: GoogleFonts
                                                                      .inter()
                                                                  .fontFamily),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          timeFormat(
                                                              listLemburSelectedDate[
                                                                      index]
                                                                  .jamMulaiLembur!),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily: GoogleFonts
                                                                      .inter()
                                                                  .fontFamily),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Jam Selesai",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily: GoogleFonts
                                                                      .inter()
                                                                  .fontFamily),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          timeFormat(
                                                              listLemburSelectedDate[
                                                                      index]
                                                                  .jamSelesaiLembur!),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily: GoogleFonts
                                                                      .inter()
                                                                  .fontFamily),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Durasi",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily: GoogleFonts
                                                                      .inter()
                                                                  .fontFamily),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          "${listLemburSelectedDate[index].durasiLembur.toString().replaceAll('.0', '')} jam",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily: GoogleFonts
                                                                      .inter()
                                                                  .fontFamily),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                const Text(
                                                  "Keterangan",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "${listLemburSelectedDate[index].keperluanLembur}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    color: Colors.white,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          color: Color(0xFF585858),
                                        ),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            listLemburSelectedDate[index]
                                                .namaKaryawan!,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Tanggal mulai",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            GoogleFonts.inter()
                                                                .fontFamily),
                                                  ),
                                                  Text(
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(DateTime.parse(
                                                            listLemburSelectedDate[
                                                                    index]
                                                                .tglLembur!)),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            GoogleFonts.inter()
                                                                .fontFamily),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Tanggal Selesai",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            GoogleFonts.inter()
                                                                .fontFamily),
                                                  ),
                                                  Text(
                                                    DateFormat('dd-MM-yyyy')
                                                        .format(DateTime.parse(
                                                            listLemburSelectedDate[
                                                                    index]
                                                                .tglLemburSelesai!)),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            GoogleFonts.inter()
                                                                .fontFamily),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Jam mulai",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            GoogleFonts.inter()
                                                                .fontFamily),
                                                  ),
                                                  Text(
                                                    timeFormat(
                                                        listLemburSelectedDate[
                                                                index]
                                                            .jamMulaiLembur!),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            GoogleFonts.inter()
                                                                .fontFamily),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Jam Selesai",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            GoogleFonts.inter()
                                                                .fontFamily),
                                                  ),
                                                  Text(
                                                    timeFormat(
                                                        listLemburSelectedDate[
                                                                index]
                                                            .jamSelesaiLembur!),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            GoogleFonts.inter()
                                                                .fontFamily),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Durasi",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            GoogleFonts.inter()
                                                                .fontFamily),
                                                  ),
                                                  Text(
                                                    "${listLemburSelectedDate[index].durasiLembur.toString().replaceAll('.0', '')} jam",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            GoogleFonts.inter()
                                                                .fontFamily),
                                                  ),
                                                ],
                                              )
                                            ],
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
              ),
            ),
    );
  }
}
