// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/models/biaya.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/klaim_biaya/components/list_item_biaya_saya.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/klaim_biaya/form_biaya.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/klaim_biaya/summary_biaya/summary_klaim_biaya_screen.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:http/http.dart' as http;

class ListKlaimBiayaScreen extends StatefulWidget {
  final Karyawan currUser;
  const ListKlaimBiayaScreen({super.key, required this.currUser});

  static const route = '/list-biaya-screen';

  @override
  State<ListKlaimBiayaScreen> createState() => _ListKlaimBiayaScreenState();
}

class _ListKlaimBiayaScreenState extends State<ListKlaimBiayaScreen> {
  bool loadingGetBiaya = true;
  Karyawan user = Karyawan();

  List<Biaya> listBiayaSendiri = [];
  List<Biaya> listBiayaAnakBuah = [];
  List<Karyawan> listAnakBuah = [];

  int totalBiayaSendiri = 0;
  int totalBiayaBelumDikirimSendiri = 0;
  int totalBiayaMenungguVerifSendiri = 0;
  int totalBiayaApproveSendiri = 0;

  int menungguApproveManager = 0;
  int menungguVerifHrd = 0;
  int sudahApprove = 0;

  _getBiayaList() async {
    setState(() {
      loadingGetBiaya = true;
    });
    try {
      listBiayaSendiri = [];
      listBiayaAnakBuah = [];
      listAnakBuah = [];

      totalBiayaSendiri = 0;
      totalBiayaBelumDikirimSendiri = 0;
      totalBiayaMenungguVerifSendiri = 0;
      totalBiayaApproveSendiri = 0;

      menungguApproveManager = 0;
      menungguVerifHrd = 0;
      sudahApprove = 0;

      final response = await http.get(
        Uri.parse('$API_URL/v2/klaimBiaya/getData/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);

      for (var biaya in output) {
        //*Diri sendiri
        if (biaya['id_karyawan'] == widget.currUser.id) {
          listBiayaSendiri.add(Biaya.fromJson(biaya));
          //* Jumlahin total biaya
          totalBiayaSendiri++;

          //*Jumlahin berdasarkan status
          if (biaya['status'] == 0 &&
              biaya['disetujuhi'] == 0 &&
              biaya['diverifikasi'] == 0) {
            totalBiayaBelumDikirimSendiri++;
          } else if ((biaya['status'] == 1 &&
                  biaya['disetujuhi'] == 0 &&
                  biaya['diverifikasi'] == 0) ||
              (biaya['status'] == 1 &&
                  biaya['disetujuhi'] == 1 &&
                  biaya['diverifikasi'] == 0)) {
            totalBiayaMenungguVerifSendiri++;
          } else if (biaya['status'] == 1 &&
              biaya['disetujuhi'] == 1 &&
              biaya['diverifikasi'] == 1) {
            totalBiayaApproveSendiri++;
          }
        }
        //* anak buah
        else {
          listBiayaAnakBuah.add(Biaya.fromJson(biaya));
          listAnakBuah.add(Karyawan.fromJson(biaya['karyawan']));
          //*Jumlahin berdasarkan status
          if (biaya['status'] == 1 &&
              biaya['disetujuhi'] == 0 &&
              biaya['diverifikasi'] == 0) {
            menungguApproveManager++;
          } else if (biaya['status'] == 1 &&
              biaya['disetujuhi'] == 1 &&
              biaya['diverifikasi'] == 0) {
            menungguVerifHrd++;
          } else if (biaya['status'] == 1 &&
              biaya['disetujuhi'] == 1 &&
              biaya['diverifikasi'] == 1) {
            sudahApprove++;
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      loadingGetBiaya = false;
    });
  }

  void _afterCreateBiaya(dynamic value) {
    _getBiayaList();
  }

  _onCreateBiayaBtnPress(Karyawan currUser) {
    Route route = MaterialPageRoute(
        builder: (context) => FormKlaimBiayaScreen(currUser: widget.currUser));
    Navigator.push(context, route).then(_afterCreateBiaya);
  }

  @override
  void initState() {
    _getBiayaList();
    setState(() {
      user = widget.currUser;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 100.w,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 100.h,
              ),
              Row(
                children: [
                  SizedBox(width: 20.w),
                  Text(
                    'Klaim Biaya',
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: GoogleFonts.epilogue().fontFamily),
                  ),
                ],
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: widget.currUser.level == 1
              ? TabBar(
                  dividerColor: Colors.transparent,
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 2, color: Colors.black),
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF585858),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  labelColor: Colors.black,
                  tabs: const [
                      Tab(text: 'Saya'),
                      Tab(text: 'Riwayat'),
                    ])
              : null,
        ),
        body: loadingGetBiaya
            ? const Center(child: Loader())
            : widget.currUser.level == 1
                ? TabBarView(
                    children: [
                      tabBiayaDiriSendiri(),
                      tabBiaya(),
                    ],
                  )
                : tabBiayaDiriSendiri(),
        floatingActionButton: SizedBox(
          height: 75.h,
          width: 75.w,
          child: FloatingActionButton(
            backgroundColor: LightColors.kFagettiBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50)
                  .r, // Set the radius of the FloatingActionButton
            ),
            onPressed: () {
              _onCreateBiayaBtnPress(user);
            },
            child: Icon(
              Icons.add,
              size: 45.w,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  SafeArea tabBiayaDiriSendiri() {
    return SafeArea(
      child: Column(
        children: [
          listBiayaSendiri.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: listBiayaSendiri.length,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListItemKlaimBiayaSaya(
                        biaya: listBiayaSendiri[index],
                        currUser: widget.currUser,
                        onCallback: _getBiayaList,
                      );
                    },
                  ),
                )
              : Center(
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
        ],
      ),
    );
  }

  SafeArea tabBiaya() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! >= 1
                ? SummaryKlaimBiayaScreen(
                    listBiayaAnakBuah: listBiayaAnakBuah,
                    listBiayaSendiri: listBiayaSendiri,
                    currUser: widget.currUser,
                  )
                : ListView.builder(
                    itemCount: listAnakBuah.length,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container();
                    },
                  ),
          )
        ],
      ),
    );
  }
}
