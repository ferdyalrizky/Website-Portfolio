// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/models/konseling_request.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/konseling/form_konseling.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/konseling/tab_view/konseling_diri.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/konseling/tab_view/konseling_riwayat.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:http/http.dart' as http;

class KonselingScreen extends StatefulWidget {
  final Karyawan currUser;
  const KonselingScreen({super.key, required this.currUser});

  static const route = '/list-konseling-screen';

  @override
  State<KonselingScreen> createState() => _KonselingScreenState();
}

class _KonselingScreenState extends State<KonselingScreen> {
  bool loadingGetKonseling = true;
  Karyawan user = Karyawan();

  List<Counseling> listKonselingSendiri = [];

  List<Karyawan> listAnakBuah = [];

  int totalKonselingSendiri = 0;
  int totalKonselingBelumDikirimSendiri = 0;
  int totalKonselingMenungguVerifSendiri = 0;
  int totalKonselingApproveSendiri = 0;

  int menungguApproveManager = 0;
  int menungguVerifHrd = 0;
  int sudahApprove = 0;

  _getKonselingList() async {
    setState(() {
      loadingGetKonseling = true;
    });
    try {
      listKonselingSendiri = [];
      listAnakBuah = [];

      final response = await http.get(
        Uri.parse(
            'http://app.fagetti.com/api/konseling-baru?karyawan_id=${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      final output = jsonDecode(response.body);

      if (output['data'] != null && output['data'].isNotEmpty) {
        CounselingResponse counselingResponse =
            CounselingResponse.fromJson(output);

        listKonselingSendiri = counselingResponse.data
            .where((counseling) => counseling.karyawanId == widget.currUser.id)
            .toList();
      } else {
        print('No data found for the current user.');
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        loadingGetKonseling = false;
      });
    }
  }

  void _afterCreateKonseling(dynamic value) {
    _getKonselingList();
  }

  _onCreateKonselingBtnPress(Karyawan currUser) {
    Route route = MaterialPageRoute(
        builder: (context) => FormKonselingScreen(currUser: widget.currUser));
    Navigator.push(context, route).then(_afterCreateKonseling);
  }

  @override
  void initState() {
    _getKonselingList();
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
                    'Konseling',
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
          bottom: TabBar(
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
                Tab(text: 'Pengajuan'),
                Tab(text: 'Riwayat'),
              ]),
        ),
        body: loadingGetKonseling
            ? const Center(child: Loader())
            : TabBarView(
                children: [
                  tabKonselingDiriSendiri(user),
                  tabKonselingRiwayat(user),
                ],
              ),
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
              _onCreateKonselingBtnPress(user);
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

  SafeArea tabKonselingDiriSendiri(Karyawan currUser) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
              child: SummaryKonselingScreen(
            listKonselingSendiri: listKonselingSendiri,
            currUser: widget.currUser,
          ))
        ],
      ),
    );
  }

  SafeArea tabKonselingRiwayat(Karyawan currUser) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
              child: SummaryKonselingScreenRiwayat(
            listKonselingSendiri: listKonselingSendiri,
            currUser: widget.currUser,
          ))
        ],
      ),
    );
  }
}
