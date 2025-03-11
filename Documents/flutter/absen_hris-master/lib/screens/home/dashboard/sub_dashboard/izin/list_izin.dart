// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/form_izin_screen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/sumarry_izin.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/sumarry_riwayat.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';

import '../../../../../models/izin.dart';

import 'package:http/http.dart' as http;

import 'components/list_item_izin_sendiri.dart';

class ListIzin extends StatefulWidget {
  final Karyawan currUser;
  const ListIzin({Key? key, required this.currUser}) : super(key: key);

  static const route = '/list-izin-screen';

  @override
  State<ListIzin> createState() => _ListIzinState();
}

class _ListIzinState extends State<ListIzin> {
  bool loadingGetIzin = true;
  Karyawan user = Karyawan();

  List<Izin> listIzinSendiri = [];
  List<Izin> listIzinAnakBuah = [];
  List<Karyawan> listAnakBuah = [];

  int totalIzinSendiri = 0;
  int totalIzinBelumDikirimSendiri = 0;
  int totalIzinMenungguVerifSendiri = 0;
  int totalIzinApproveSendiri = 0;

  int menungguApproveManager = 0;
  int menungguVerifHrd = 0;
  int sudahApprove = 0;

  _getIzinList() async {
    setState(() {
      loadingGetIzin = true;
    });
    try {
      listIzinSendiri = [];
      listIzinAnakBuah = [];
      listAnakBuah = [];

      totalIzinSendiri = 0;
      totalIzinBelumDikirimSendiri = 0;
      totalIzinMenungguVerifSendiri = 0;
      totalIzinApproveSendiri = 0;

      menungguApproveManager = 0;
      menungguVerifHrd = 0;
      sudahApprove = 0;

      final response = await http.get(
        Uri.parse('$API_URL/v3/lihatDtpc/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      print(widget.currUser.id);
      final output = jsonDecode(response.body);

      for (var izin in output) {
        //*Diri sendiri
        if (izin['id_karyawan'] == widget.currUser.id) {
          listIzinSendiri.add(Izin.fromJson(izin));
          //* Jumlahin total izin
          totalIzinSendiri++;

          //*Jumlahin berdasarkan status
          if (izin['status'] == 0 &&
              izin['disetujuhi'] == 0 &&
              izin['diverifikasi'] == 0) {
            totalIzinBelumDikirimSendiri++;
          } else if ((izin['status'] == 1 &&
                  izin['disetujuhi'] == 0 &&
                  izin['diverifikasi'] == 0) ||
              (izin['status'] == 1 &&
                  izin['disetujuhi'] == 1 &&
                  izin['diverifikasi'] == 0)) {
            totalIzinMenungguVerifSendiri++;
          } else if (izin['status'] == 1 &&
              izin['disetujuhi'] == 1 &&
              izin['diverifikasi'] == 1) {
            totalIzinApproveSendiri++;
          }
        }
        //* anak buah
        else {
          listIzinAnakBuah.add(Izin.fromJson(izin));
          listAnakBuah.add(Karyawan.fromJson(izin['karyawan']));
          //*Jumlahin berdasarkan status
          if (izin['status'] == 1 &&
              izin['disetujuhi'] == 0 &&
              izin['diverifikasi'] == 0) {
            menungguApproveManager++;
          } else if (izin['status'] == 1 &&
              izin['disetujuhi'] == 1 &&
              izin['diverifikasi'] == 0) {
            menungguVerifHrd++;
          } else if (izin['status'] == 1 &&
              izin['disetujuhi'] == 1 &&
              izin['diverifikasi'] == 1) {
            sudahApprove++;
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      loadingGetIzin = false;
    });
  }

  void _afterCreateIzin(dynamic value) {
    _getIzinList();
  }

  _onCreateIzinBtnPress(Karyawan currUser) {
    Route route = MaterialPageRoute(
        builder: (context) => FormIzinScreen(currUser: widget.currUser));
    Navigator.push(context, route).then(_afterCreateIzin);
  }

  @override
  void initState() {
    _getIzinList();
    setState(() {
      user = widget.currUser;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 100.w,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
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
                  SizedBox(width: 20.w), // add some space from the left edge
                  Text(
                    'Izin',
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
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 2, color: Colors.black),
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF585858),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600, // add thickness or weight here
                  ),
                  labelColor: Colors.black,
                  tabs: [
                      Tab(text: 'Saya'),
                      Tab(text: 'Karyawan'),
                      Tab(text: 'Riwayat')
                    ])
              : null,
        ),
        body: loadingGetIzin
            ? const Center(child: Loader())
            : widget.currUser.level == 1
                ? TabBarView(
                    children: [
                      tabIzinDiriSendiri(),
                      tabIzinAnakBuah(),
                      tabIzinAnakBuahRiwayat(),
                    ],
                  )
                : tabIzinDiriSendiri(),
        floatingActionButton: SizedBox(
          height: 75.r,
          width: 75.r,
          child: FloatingActionButton(
            backgroundColor: LightColors.kFagettiBlue,
            child: Icon(
              Icons.add,
              size: 45.w,
              color: Colors.white,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  50), // Set the radius of the FloatingActionButton
            ),
            onPressed: () {
              _onCreateIzinBtnPress(user);
            },
          ),
        ),
      ),
    );
  }

  SafeArea tabIzinDiriSendiri() {
    return SafeArea(
      child: Column(
        children: [
          listIzinSendiri.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: listIzinSendiri.length,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListItemIzinSendiri(
                        izin: listIzinSendiri[index],
                        currUser: widget.currUser,
                        onCallback: _getIzinList,
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

  SafeArea tabIzinAnakBuah() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! >= 1
                ? SummaryIzinAnakbuah(
                    listIzinAnakBuah: listIzinAnakBuah,
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

  SafeArea tabIzinAnakBuahRiwayat() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! >= 1
                ? SummaryIzinAnakbuahRiwayat(
                    listIzinAnakBuah: listIzinAnakBuah,
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
