import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/cuti/components/list_item_sik_cuti_anak_buah.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/cuti/lsummary_cuti_riwayat.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/cuti/summary_cuti.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';

import 'package:flutter/material.dart';
import 'package:hris_v2/models/sik.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';

import '../../../../../../../models/karyawan.dart';

import 'package:http/http.dart' as http;

import 'components/list_item_sik_cuti_sendiri.dart';
import 'form_sik_cuti_karyawan_screen.dart';

class ListSikCutiKaryawanScreen extends StatefulWidget {
  final Karyawan currUser;
  const ListSikCutiKaryawanScreen({
    super.key,
    required this.currUser,
  });

  @override
  State<ListSikCutiKaryawanScreen> createState() =>
      _ListSikCutiKaryawanScreenState();
}

class _ListSikCutiKaryawanScreenState extends State<ListSikCutiKaryawanScreen> {
  bool loadingGetSik = true;
  Karyawan user = Karyawan();
  int jatahCuti = 0;

  List<Sik> listSikSendiri = [];
  List<Sik> listSikAnakBuah = [];
  List<Karyawan> listAnakBuah = [];

  int totalCutiTahunanSendiri = 0;
  int totalCutiNormatifSendiri = 0;
  int totalApproveSendiri = 0;
  int totalMenungguVerifSendiri = 0;
  int totalBelumDikirimSendiri = 0;

  int menungguApproveManager = 0;
  int menungguVerifHrd = 0;
  int sudahApprove = 0;

  @override
  void initState() {
    user = widget.currUser;
    _getJatahCuti();
    _getSikList();
    super.initState();
  }

  _getJatahCuti() async {
    setState(() {
      loadingGetSik = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$API_URL/v3/getJatahCuti/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);
      jatahCuti = output['jatah_cuti'];
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _getSikList() async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/v3/lihatSitc/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);

      //*Reset List
      listSikSendiri = [];
      listSikAnakBuah = [];
      listAnakBuah = [];

      totalCutiTahunanSendiri = 0;
      totalCutiNormatifSendiri = 0;
      totalApproveSendiri = 0;
      totalMenungguVerifSendiri = 0;
      totalBelumDikirimSendiri = 0;

      menungguApproveManager = 0;
      totalApproveSendiri = 0;
      sudahApprove = 0;

      for (var sik in output) {
        if (sik['keperluan'] == "Cuti") {
          //*Diri Sendiri
          if (sik['id_karyawan'] == widget.currUser.id) {
            listSikSendiri.add(Sik.fromJson(sik));

            //* Jumlahin Cuti Normatif / Cuti Tahunan
            if (sik['cuti_normatif'] == null) {
              totalCutiTahunanSendiri++;
            } else {
              totalCutiNormatifSendiri++;
            }

            //* Jumlahin berdasarkan status
            if (sik['status'] == 0 &&
                sik['disetujui'] == 0 &&
                sik['diverifikasi'] == 0) {
              totalBelumDikirimSendiri++;
            } else if ((sik['status'] == 1 &&
                    sik['disetujui'] == 0 &&
                    sik['diverifikasi'] == 0) ||
                (sik['status'] == 1 &&
                    sik['disetujui'] == 1 &&
                    sik['diverifikasi'] == 0)) {
              totalMenungguVerifSendiri++;
            } else if (sik['status'] == 1 &&
                sik['disetujui'] == 1 &&
                sik['diverifikasi'] == 1) {
              totalApproveSendiri++;
            }
          }
          //* anak buah
          else {
            listSikAnakBuah.add(Sik.fromJson(sik));
            listAnakBuah.add(Karyawan.fromJson(sik['karyawan']));
            if (sik['status'] == 1 &&
                sik['disetujui'] == 0 &&
                sik['diverifikasi'] == 0) {
              menungguApproveManager++;
            } else if (sik['status'] == 1 &&
                sik['disetujui'] == 1 &&
                sik['diverifikasi'] == 0) {
              menungguVerifHrd++;
            } else if (sik['status'] == 1 &&
                sik['disetujui'] == 1 &&
                sik['diverifikasi'] == 1) {
              sudahApprove++;
            }
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      loadingGetSik = false;
    });
  }

  void _afterCreateSik(dynamic value) {
    setState(() {
      loadingGetSik = true;
    });
    _getSikList();
  }

  _onCreateSikBtnPress(Karyawan currUser) {
    Route route = MaterialPageRoute(
        builder: (context) => FormSikCutiKaryawanScreen(
              currUser: currUser,
              jatahCutiUser: jatahCuti,
            ));
    Navigator.push(context, route).then(_afterCreateSik);
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
                  const SizedBox(
                      width: 20), // add some space from the left edge
                  Text(
                    'Cuti',
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
                    borderSide: BorderSide(width: 2.w, color: Colors.black),
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF585858),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600, // add thickness or weight here
                  ),
                  labelColor: Colors.black,
                  tabs: const [
                      Tab(text: 'Saya'),
                      Tab(text: 'Karyawan'),
                      Tab(text: 'Riwayat'),
                    ])
              : null,
        ),
        body: loadingGetSik
            ? const Center(
                child: Loader(),
              )
            : widget.currUser.level == 1
                ? TabBarView(children: [
                    tabCutiDiriSendiri(),
                    tabCutiAnakBuah(),
                    tabCutiAnakBuahRiwayat(),
                  ])
                : tabCutiDiriSendiri(),
        floatingActionButton: SizedBox(
          height: 75.r,
          width: 75.r,
          child: FloatingActionButton(
            backgroundColor: LightColors.kFagettiBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50)
                  .r, // Set the radius of the FloatingActionButton
            ),
            onPressed: () {
              _onCreateSikBtnPress(user);
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

  SafeArea tabCutiDiriSendiri() {
    return SafeArea(
      child: Column(
        children: [
          listSikSendiri.isEmpty
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
                  child: ListView.builder(
                    itemCount: listSikSendiri.length,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return ListItemSikCutiSendiri(
                        sik: listSikSendiri[index],
                        onCallback: _getSikList,
                        currUser: widget.currUser,
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  SafeArea tabCutiAnakBuah() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! >= 1
                ? SummarySikAnakbuah(
                    listSikAnakBuah: listSikAnakBuah,
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

  SafeArea tabCutiAnakBuahRiwayat() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: widget.currUser.level! >= 1
                ? SummarySikAnakbuahRiwayat(
                    listSikAnakBuah: listSikAnakBuah,
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
